import pytest
import uuid
import io
import httpx
import sys
from unittest.mock import MagicMock, patch, AsyncMock
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException

from app.services import ai_service, storage_service, geo_service, inspection_service, auth_service, pdf_service
from app.models.inspection import Inspection, InspectionStatus, InspectionSeverity
from app.models.media import Media, MediaType, MediaStatus
from app.models.user import User, UserRole
from app.models.report import Report
from app.schemas.inspection import InspectionCreate, LocationPoint, InspectionUpdate
from app.schemas.user import UserCreate

@pytest.mark.asyncio
async def test_ai_service_map_severity():
    assert ai_service.map_severity(0.4, "any") == "pending_review"
    assert ai_service.map_severity(0.9, "rachadura crítica") == "critical"
    assert ai_service.map_severity(0.9, "corrosão de armadura") == "critical"
    assert ai_service.map_severity(0.7, "infiltração ou umidade") == "moderate"
    assert ai_service.map_severity(0.9, "estrutura intacta e sem danos") == "low"
    assert ai_service.map_severity(0.9, "outra coisa") == "low"

@pytest.mark.asyncio
async def test_ai_service_classify_image_success():
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "choices": [
            {
                "message": {
                    "content": '{"label": "rachadura crítica", "score": 0.9}'
                }
            }
        ]
    }
    
    with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
        mock_post.return_value = mock_response
        result = await ai_service.classify_image(b"fake_image")
        assert result["label"] == "rachadura crítica"
        assert result["score"] == 0.9
        assert result["source"] == "huggingface"

@pytest.mark.asyncio
async def test_ai_service_classify_image_503_fallback():
    mock_response = MagicMock()
    mock_response.status_code = 503
    
    with patch("httpx.AsyncClient.post", new_callable=AsyncMock) as mock_post:
        mock_post.return_value = mock_response
        result = await ai_service.classify_image(b"fake_image")
        assert result["label"] == "unknown"
        assert result["source"] == "local_fallback"

@pytest.mark.asyncio
async def test_ai_service_classify_image_error():
    with patch("httpx.AsyncClient.post", side_effect=Exception("API error")):
        result = await ai_service.classify_image(b"fake_image")
        assert result["label"] == "unknown"
        assert result["source"] == "local_fallback"

@pytest.mark.asyncio
async def test_storage_service_get_presigned_upload_url_error():
    with patch("app.services.storage_service.get_external_s3_client_context") as mock_s3:
        mock_client = AsyncMock()
        mock_client.generate_presigned_url.side_effect = Exception("S3 error")
        mock_s3.return_value.__aenter__.return_value = mock_client
        
        with pytest.raises(HTTPException) as exc:
            await storage_service.get_presigned_upload_url("b", "k", "t")
        assert exc.value.status_code == 503

@pytest.mark.asyncio
async def test_storage_service_delete_object_error():
    with patch("app.services.storage_service.get_s3_client_context") as mock_s3:
        mock_client = AsyncMock()
        mock_client.delete_object.side_effect = Exception("S3 error")
        mock_s3.return_value.__aenter__.return_value = mock_client
        
        with pytest.raises(HTTPException) as exc:
            await storage_service.delete_object("b", "k")
        assert exc.value.status_code == 503

@pytest.mark.asyncio
async def test_geo_service_export_geojson(db_session: AsyncSession):
    # Setup test user
    user = User(id=uuid.uuid4(), email=f"geo_{uuid.uuid4()}@vistor.ai", password="pw", name="N", role=UserRole.inspector)
    db_session.add(user)
    await db_session.commit()
    
    # Create an inspection using the service
    payload = InspectionCreate(title="Teste", category="civil", lat=-5.0, lon=-35.0, gps_accuracy=10.0)
    insp = await inspection_service.create(db_session, payload, user.id)
    
    output, filename = await geo_service.export_data(db_session, "geojson")
    assert filename.endswith(".geojson")
    content = output.read().decode('utf-8')
    assert "FeatureCollection" in content
    assert str(insp.id) in content

@pytest.mark.asyncio
async def test_geo_service_export_csv(db_session: AsyncSession):
    # Setup test user
    user = User(id=uuid.uuid4(), email=f"geocsv_{uuid.uuid4()}@vistor.ai", password="pw", name="N", role=UserRole.inspector)
    db_session.add(user)
    await db_session.commit()
    
    # Create an inspection
    payload = InspectionCreate(title="Export CSV", category="electrical", lat=-6.0, lon=-36.0, gps_accuracy=5.0)
    insp = await inspection_service.create(db_session, payload, user.id)
    
    output, filename = await geo_service.export_data(db_session, "csv")
    assert filename.endswith(".csv")
    content = output.read().decode('utf-8')
    assert "category,status,severity" in content
    assert "electrical" in content

@pytest.mark.asyncio
async def test_inspection_service_get_by_id_not_found(db_session: AsyncSession):
    user = User(id=uuid.uuid4(), email="u_err@v.ai", password="p", name="N", role=UserRole.inspector)
    with pytest.raises(HTTPException) as exc:
        await inspection_service.get_by_id(db_session, uuid.uuid4(), user)
    assert exc.value.status_code == 404

@pytest.mark.asyncio
async def test_inspection_service_update_not_owner(db_session: AsyncSession):
    user1 = User(id=uuid.uuid4(), email="u1@v.ai", password="p", name="N1", role=UserRole.inspector)
    user2 = User(id=uuid.uuid4(), email="u2@v.ai", password="p", name="N2", role=UserRole.inspector)
    db_session.add_all([user1, user2])
    await db_session.commit()
    
    payload = InspectionCreate(title="Teste", category="civil", lat=-5.0, lon=-35.0, gps_accuracy=10.0)
    insp = await inspection_service.create(db_session, payload, user1.id)
    
    update_payload = InspectionUpdate(description="updated")
    with pytest.raises(HTTPException) as exc:
        await inspection_service.update(db_session, insp.id, update_payload, user2)
    assert exc.value.status_code == 403

@pytest.mark.asyncio
async def test_auth_service_create_user_duplicate(db_session: AsyncSession):
    email = f"dup_{uuid.uuid4()}@v.ai"
    payload = UserCreate(name="U1", email=email, password="password123", role=UserRole.inspector)
    await auth_service.create_user(db_session, payload)
    
    with pytest.raises(HTTPException) as exc:
        await auth_service.create_user(db_session, payload)
    assert exc.value.status_code == 409

@pytest.mark.asyncio
async def test_pdf_service_generate_report(db_session: AsyncSession):
    # Setup user
    email = f"pdf_{uuid.uuid4()}@v.ai"
    user = User(id=uuid.uuid4(), email=email, password="p", name="N", role=UserRole.inspector)
    db_session.add(user)
    await db_session.commit()
    
    # Create inspection
    payload = InspectionCreate(title="Teste", category="civil", lat=-5.0, lon=-35.0, gps_accuracy=10.0)
    insp = await inspection_service.create(db_session, payload, user.id)
    
    # Mock weasyprint and s3
    with patch("weasyprint.HTML") as mock_html_class, \
         patch("app.services.storage_service.get_s3_client_context") as mock_s3:
        
        mock_html_instance = mock_html_class.return_value
        mock_html_instance.write_pdf.return_value = b"fake_pdf_content"
        
        mock_client = AsyncMock()
        mock_s3.return_value.__aenter__.return_value = mock_client
        
        key, sha = await pdf_service.generate_report(insp.id, db_session, user.id)
        assert key.startswith("reports/")
        assert sha is not None
        
        # Test idempotency (should return same report)
        key2, sha2 = await pdf_service.generate_report(insp.id, db_session, user.id)
        assert key == key2
        assert sha == sha2

@pytest.mark.asyncio
async def test_pdf_service_verify_report_hash(db_session: AsyncSession):
    # Setup user
    user = User(id=uuid.uuid4(), email=f"pdf_v_{uuid.uuid4()}@v.ai", password="p", name="N", role=UserRole.inspector)
    db_session.add(user)
    await db_session.commit()
    
    # Create inspection
    payload = InspectionCreate(title="Teste", category="civil", lat=-5.0, lon=-35.0, gps_accuracy=10.0)
    insp = await inspection_service.create(db_session, payload, user.id)

    # Create report manually
    report = Report(
        inspection_id=insp.id,
        generated_by=user.id,
        minio_key="test.pdf",
        sha256="fake_hash"
    )
    db_session.add(report)
    await db_session.commit()
    
    # Mock s3
    with patch("app.services.storage_service.get_s3_client_context") as mock_s3:
        mock_client = AsyncMock()
        mock_body = AsyncMock()
        mock_body.read.return_value = b"pdf content"
        mock_client.get_object.return_value = {"Body": mock_body}
        mock_s3.return_value.__aenter__.return_value = mock_client
        
        # Verify hash (should fail because we used "fake_hash")
        is_valid = await pdf_service.verify_report_hash(report.id, db_session)
        assert is_valid is False

@pytest.mark.asyncio
async def test_storage_service_generate_thumbnail():
    # Mock PIL and S3
    with patch("PIL.Image.open") as mock_open, \
         patch("app.services.storage_service.get_s3_client_context") as mock_s3:
        
        mock_img = MagicMock()
        mock_img.format = "JPEG"
        mock_open.return_value = mock_img
        
        mock_client = AsyncMock()
        mock_s3.return_value.__aenter__.return_value = mock_client
        
        key = await storage_service.generate_thumbnail(b"fake_image", "test_key")
        assert key == "test_key"
        mock_client.put_object.assert_called_once()

@pytest.mark.asyncio
async def test_media_router_presign_error_mime(authed_client, db_session):
    # Get user from authed_client somehow or just create a new inspection
    # Using the existing inspector from conftest
    from app.models.user import User
    result = await db_session.execute(select(User).where(User.email == "inspector@vistor.ai"))
    user = result.scalar_one()
    
    payload = InspectionCreate(title="Teste", category="civil", lat=-5.0, lon=-35.0, gps_accuracy=10.0)
    insp = await inspection_service.create(db_session, payload, user.id)

    response = await authed_client.post("/api/media/presign", json={
        "inspection_id": str(insp.id),
        "filename": "test.txt",
        "file_size": 1024,
        "content_type": "text/plain"
    })
    assert response.status_code == 400
    assert "não permitido" in response.json()["detail"]

@pytest.mark.asyncio
async def test_media_router_presign_error_size(authed_client, db_session):
    from app.models.user import User
    result = await db_session.execute(select(User).where(User.email == "inspector@vistor.ai"))
    user = result.scalar_one()
    
    payload = InspectionCreate(title="Teste", category="civil", lat=-5.0, lon=-35.0, gps_accuracy=10.0)
    insp = await inspection_service.create(db_session, payload, user.id)

    response = await authed_client.post("/api/media/presign", json={
        "inspection_id": str(insp.id),
        "filename": "test.jpg",
        "file_size": 30 * 1024 * 1024, # 30MB
        "content_type": "image/jpeg"
    })
    assert response.status_code == 400
    assert "excede o tamanho máximo" in response.json()["detail"]
