import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.inspection import Inspection, InspectionStatus
from app.models.user import User, UserRole
from app.services.auth_service import create_user
from app.schemas.user import UserCreate

@pytest.mark.asyncio
async def test_create_inspection_success(authed_client: AsyncClient):
    # 1. POST /inspections/ com dados válidos → 201, retorna InspectionOut
    payload = {
        "category": "civil",
        "description": "Buraco na via",
        "lat": -23.55,
        "lon": -46.63,
        "gps_accuracy": 10.0
    }
    response = await authed_client.post("/api/inspections/", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["category"] == "civil"
    assert data["location"]["lat"] == -23.55
    assert data["location"]["lon"] == -46.63
    assert "id" in data
    assert "inspector" in data
    assert data["inspector"]["email"] == "inspector@vistor.ai"

@pytest.mark.asyncio
async def test_create_inspection_no_auth(client: AsyncClient):
    # 2. POST /inspections/ sem autenticação → 401
    payload = {
        "category": "civil",
        "lat": -23.55,
        "lon": -46.63
    }
    response = await client.post("/api/inspections/", json=payload)
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_list_inspections_rbac(
    client: AsyncClient, 
    db_session: AsyncSession, 
    inspector_token: str, 
    manager_token: str
):
    # 3. GET /inspections/ como inspetor → retorna apenas inspeções próprias
    # 4. GET /inspections/ como gestor → retorna todas as inspeções
    
    # Criar outro inspetor
    other_payload = UserCreate(name="Other", email="other@vistor.ai", password="password123", role=UserRole.inspector)
    await create_user(db_session, other_payload)
    res = await client.post("/api/auth/login", json={"email": "other@vistor.ai", "password": "password123"})
    other_token = res.json()["access_token"]
    
    # Outro inspetor cria 1
    await client.post("/api/inspections/", json={"category": "cat1", "lat": 0, "lon": 0}, headers={"Authorization": f"Bearer {other_token}"})
    
    # Inspetor principal cria 1
    await client.post("/api/inspections/", json={"category": "cat2", "lat": 0, "lon": 0}, headers={"Authorization": f"Bearer {inspector_token}"})
    
    # Teste Inspetor: deve ver apenas 1
    res_insp = await client.get("/api/inspections/", headers={"Authorization": f"Bearer {inspector_token}"})
    assert len(res_insp.json()) == 1
    assert res_insp.json()[0]["category"] == "cat2"
    
    # Teste Gestor: deve ver 2
    res_mgr = await client.get("/api/inspections/", headers={"Authorization": f"Bearer {manager_token}"})
    assert len(res_mgr.json()) == 2

@pytest.mark.asyncio
async def test_get_inspection_owner_success(authed_client: AsyncClient):
    # 5. GET /inspections/{id} do inspetor proprietário → 200
    res_create = await authed_client.post("/api/inspections/", json={"category": "own", "lat": 0, "lon": 0})
    insp_id = res_create.json()["id"]
    
    response = await authed_client.get(f"/api/inspections/{insp_id}")
    assert response.status_code == 200
    assert response.json()["category"] == "own"

@pytest.mark.asyncio
async def test_get_inspection_idor_forbidden(
    client: AsyncClient, 
    db_session: AsyncSession, 
    inspector_token: str
):
    # 6. GET /inspections/{id} de outro inspetor → 403 (IDOR)
    other_payload = UserCreate(name="O", email="o_idor@v.ai", password="password123", role=UserRole.inspector)
    await create_user(db_session, other_payload)
    res = await client.post("/api/auth/login", json={"email": "o_idor@v.ai", "password": "password123"})
    o_token = res.json()["access_token"]
    
    res_create = await client.post("/api/inspections/", json={"category": "p", "lat": 0, "lon": 0}, headers={"Authorization": f"Bearer {o_token}"})
    insp_id = res_create.json()["id"]
    
    response = await client.get(f"/api/inspections/{insp_id}", headers={"Authorization": f"Bearer {inspector_token}"})
    assert response.status_code == 403

@pytest.mark.asyncio
async def test_get_inspection_manager_access(
    client: AsyncClient, 
    db_session: AsyncSession, 
    manager_token: str
):
    # 7. GET /inspections/{id} como gestor vendo inspeção de qualquer inspetor → 200
    other_payload = UserCreate(name="I", email="i_mgr@v.ai", password="password123", role=UserRole.inspector)
    await create_user(db_session, other_payload)
    res = await client.post("/api/auth/login", json={"email": "i_mgr@v.ai", "password": "password123"})
    i_token = res.json()["access_token"]
    
    res_create = await client.post("/api/inspections/", json={"category": "any", "lat": 0, "lon": 0}, headers={"Authorization": f"Bearer {i_token}"})
    insp_id = res_create.json()["id"]
    
    response = await client.get(f"/api/inspections/{insp_id}", headers={"Authorization": f"Bearer {manager_token}"})
    assert response.status_code == 200

@pytest.mark.asyncio
async def test_update_inspection_status(authed_client: AsyncClient):
    # 8. PATCH /inspections/{id} atualizando status → 200, novo status retornado
    res_create = await authed_client.post("/api/inspections/", json={"category": "c", "lat": 0, "lon": 0})
    insp_id = res_create.json()["id"]
    
    res_patch = await authed_client.patch(f"/api/inspections/{insp_id}", json={"status": "in_progress"})
    assert res_patch.status_code == 200
    assert res_patch.json()["status"] == "in_progress"

@pytest.mark.asyncio
async def test_soft_delete_flow(authed_client: AsyncClient, db_session: AsyncSession):
    # 9. DELETE /inspections/{id} → 204 (NO CONTENT), inspeção some da listagem
    # 10. DELETE /inspections/{id} → inspeção ainda existe no banco com deleted_at preenchido
    res_create = await authed_client.post("/api/inspections/", json={"category": "del", "lat": 0, "lon": 0})
    insp_id = res_create.json()["id"]
    
    res_del = await authed_client.delete(f"/api/inspections/{insp_id}")
    assert res_del.status_code == 204
    
    res_list = await authed_client.get("/api/inspections/")
    assert all(i["id"] != insp_id for i in res_list.json())
    
    # Check DB
    query = select(Inspection).where(Inspection.id == insp_id)
    result = await db_session.execute(query)
    insp = result.scalar_one()
    assert insp.deleted_at is not None

@pytest.mark.asyncio
async def test_geo_nearby_radius(authed_client: AsyncClient):
    # 11. GET /geo/nearby com raio de 500m → retorna apenas inspeções dentro do raio
    lat_center, lon_center = -23.5505, -46.6333 # SP
    
    # Perto (aprox 80m)
    await authed_client.post("/api/inspections/", json={"category": "near", "lat": -23.5512, "lon": -46.6333})
    # Longe (aprox 6km)
    await authed_client.post("/api/inspections/", json={"category": "far", "lat": -23.6, "lon": -46.7})
    
    response = await authed_client.get(f"/api/geo/nearby?lat={lat_center}&lon={lon_center}&radius_m=500")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["inspection"]["category"] == "near"
    assert data[0]["distance_m"] < 500

@pytest.mark.asyncio
async def test_geo_nearby_validation_error(authed_client: AsyncClient):
    # 12. GET /geo/nearby com raio 99999 → 422
    response = await authed_client.get("/api/geo/nearby?lat=0&lon=0&radius_m=99999")
    assert response.status_code == 422
