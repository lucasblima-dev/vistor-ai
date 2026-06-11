import pytest
from httpx import AsyncClient
from app.models.user import User
from app.models.audit_log import AuditLog
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
from datetime import datetime, timedelta

@pytest.mark.asyncio
async def test_list_audit_logs_unauthorized(client: AsyncClient):
    response = await client.get("/api/audit-logs/")
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_list_audit_logs_success(authed_client: AsyncClient, db_session: AsyncSession, test_user: User):
    # Cria alguns logs de auditoria fictícios no banco
    entity_id = uuid.uuid4()
    now = datetime.utcnow()
    log1 = AuditLog(
        user_id=test_user.id,
        entity="inspection",
        entity_id=entity_id,
        action="create",
        new_value={"status": "open"},
        created_at=now - timedelta(seconds=10)
    )
    log2 = AuditLog(
        user_id=test_user.id,
        entity="inspection",
        entity_id=entity_id,
        action="ai_classified",
        new_value={"ai_label": "crack", "ai_score": 0.85},
        created_at=now
    )
    db_session.add(log1)
    db_session.add(log2)
    await db_session.commit()

    # Faz o GET no endpoint
    response = await authed_client.get(
        "/api/audit-logs/",
        params={
            "entity": "inspection",
            "entity_id": str(entity_id)
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2
    
    # Valida que o log mais recente (ai_classified) vem primeiro devido à ordenação desc
    assert data[0]["action"] == "ai_classified"
    assert data[0]["user_name"] == test_user.name
    assert data[0]["new_value"]["ai_label"] == "crack"
    
    assert data[1]["action"] == "create"
    assert data[1]["user_name"] == test_user.name
