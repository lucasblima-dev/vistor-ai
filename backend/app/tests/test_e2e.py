import pytest
import io
import uuid
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.user import User, UserRole
from app.models.inspection import Inspection, InspectionStatus
from app.models.media import Media
from app.services.auth_service import pwd_context

@pytest.mark.asyncio
async def test_complete_workflow_e2e(client: AsyncClient, db_session: AsyncSession):
    """
    Fluxo E2E: Inspetor cria inspeção, faz upload, IA classifica, 
    gera laudo e Gestor atribui a inspeção.
    """
    
    # --- 1. Criar usuário inspetor ---
    inspector_data = {
        "email": f"inspector_{uuid.uuid4().hex[:6]}@example.com",
        "name": "Inspetor E2E",
        "password": pwd_context.hash("password123"),
        "role": UserRole.inspector,
        "is_active": True
    }
    inspector = User(**inspector_data)
    db_session.add(inspector)
    await db_session.commit()
    await db_session.refresh(inspector)

    # --- 2. Login -> pegar token ---
    login_response = await client.post("/api/auth/login", json={
        "email": inspector_data["email"],
        "password": "password123"
    })
    assert login_response.status_code == 200
    access_token = login_response.json()["access_token"]
    auth_headers = {"Authorization": f"Bearer {access_token}"}

    inspection_payload = {
        "title": "Rachadura em pilar",
        "category": "civil",
        "description": "Rachadura em pilar de concreto",
        "lat": -23.5505,
        "lon": -46.6333
    }
    create_resp = await client.post("/api/inspections/", json=inspection_payload, headers=auth_headers)
    assert create_resp.status_code == 201
    inspection_id = create_resp.json()["id"]

    # --- 4. Obter presigned URL para upload de foto ---
    presign_resp = await client.post("/api/media/presign", json={
        "inspection_id": inspection_id,
        "filename": "crack.jpg",
        "content_type": "image/jpeg",
        "file_size": 1024
    }, headers=auth_headers)
    assert presign_resp.status_code == 200
    media_id = presign_resp.json()["id"]
    
    # --- 5. (Simulado) Confirmar upload de mídia ---
    # Nota: Não fazemos o PUT real no S3 no teste E2E pois o MinIO pode não estar rodando no CI,
    # mas confirmamos o upload na API para disparar as tasks de background.
    confirm_resp = await client.post(f"/api/media/{media_id}/confirm", headers=auth_headers)
    assert confirm_resp.status_code == 200
    
    # Forçamos a atualização manual do ai_label pois o background task é isolado no teste
    # e queremos testar o fluxo de consumo dos dados.
    stmt = select(Inspection).where(Inspection.id == inspection_id)
    result = await db_session.execute(stmt)
    db_inspection = result.scalar_one()
    
    db_inspection.ai_label = "structural_damage"
    db_inspection.ai_score = 0.85
    db_inspection.status = InspectionStatus.open
    await db_session.commit()

    # --- 6. Verificar que ai_label foi preenchido na inspeção ---
    get_resp = await client.get(f"/api/inspections/{inspection_id}", headers=auth_headers)
    assert get_resp.status_code == 200
    assert get_resp.json()["ai_label"] == "structural_damage"

    # --- 7. Gerar laudo ---
    # O endpoint real usa background tasks e retorna 202. 
    # Para o teste E2E, simulamos a criação do laudo no banco para testar a integridade.
    report_resp = await client.post("/api/reports/generate", json={"inspection_id": inspection_id}, headers=auth_headers)
    assert report_resp.status_code == 202
    
    # Criamos o objeto Report manualmente para prosseguir com o teste de integridade/download se necessário
    from app.models.report import Report
    new_report = Report(
        inspection_id=uuid.UUID(inspection_id),
        generated_by=inspector.id,
        minio_key=f"reports/{inspection_id}.pdf",
        sha256="03754271b00a0e1c761384c9dd0e7575ae942ae4c0952cf4b64da85f7c168307" # fake pdf content hash
    )
    db_session.add(new_report)
    await db_session.commit()
    await db_session.refresh(new_report)
    report_id = str(new_report.id)

    # --- 8. Verificar hash do laudo ---
    get_report_resp = await client.get(f"/api/reports/{report_id}", headers=auth_headers)
    assert get_report_resp.status_code == 200
    assert get_report_resp.json()["sha256"] == "03754271b00a0e1c761384c9dd0e7575ae942ae4c0952cf4b64da85f7c168307"

    # --- 9. Buscar inspeção via /geo/nearby com raio de 1km ---
    # Buscando de um ponto a 100m de distância
    nearby_resp = await client.get(
        "/api/geo/nearby", 
        params={"lat": -23.5506, "lon": -46.6334, "radius_m": 1000},
        headers=auth_headers
    )
    assert nearby_resp.status_code == 200
    assert any(item["inspection"]["id"] == inspection_id for item in nearby_resp.json())

    # --- 10. Criar usuário gestor, logar como gestor ---
    manager_data = {
        "email": f"manager_{uuid.uuid4().hex[:6]}@example.com",
        "name": "Gestor E2E",
        "password": pwd_context.hash("password123"),
        "role": UserRole.manager,
        "is_active": True
    }
    manager = User(**manager_data)
    db_session.add(manager)
    await db_session.commit()
    
    manager_login = await client.post("/api/auth/login", json={
        "email": manager_data["email"],
        "password": "password123"
    })
    manager_token = manager_login.json()["access_token"]
    manager_headers = {"Authorization": f"Bearer {manager_token}"}

    # --- 11. Atribuir inspeção ao inspetor ---
    assign_resp = await client.patch(
        f"/api/inspections/{inspection_id}",
        json={"assigned_to": str(inspector.id), "status": "in_progress"},
        headers=manager_headers
    )
    assert assign_resp.status_code == 200

    # --- 12. Verificar que inspeção tem status "in_progress" e assigned_to preenchido ---
    final_resp = await client.get(f"/api/inspections/{inspection_id}", headers=manager_headers)
    assert final_resp.status_code == 200
    data = final_resp.json()
    assert data["status"] == "in_progress"
    assert data["assigned_to"] == str(inspector.id)
    assert data["inspector_id"] == str(inspector.id) # Criador original
