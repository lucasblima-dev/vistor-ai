import pytest
from httpx import AsyncClient
from app.models.user import UserRole
from app.schemas.user import UserOut

@pytest.mark.asyncio
async def test_admin_create_user_success(admin_client: AsyncClient):
    response = await admin_client.post(
        "/api/users/",
        json={
            "name": "New Inspector",
            "email": "new_inspector@vistor.ai",
            "password": "securepassword123",
            "role": "inspector"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "New Inspector"
    assert data["email"] == "new_inspector@vistor.ai"
    assert data["role"] == "inspector"
    assert "id" in data

@pytest.mark.asyncio
async def test_admin_create_user_duplicate_email(admin_client: AsyncClient):
    # First creation
    await admin_client.post(
        "/api/users/",
        json={
            "name": "First User",
            "email": "dup@vistor.ai",
            "password": "securepassword123",
            "role": "inspector"
        }
    )
    
    # Second creation with same email
    response = await admin_client.post(
        "/api/users/",
        json={
            "name": "Second User",
            "email": "dup@vistor.ai",
            "password": "securepassword123",
            "role": "manager"
        }
    )
    assert response.status_code == 409
    assert "email já está sendo utilizado" in response.json()["detail"]

@pytest.mark.asyncio
async def test_non_admin_cannot_create_user(authed_client: AsyncClient, manager_client: AsyncClient):
    # Inspector (authed_client) cannot create
    response1 = await authed_client.post(
        "/api/users/",
        json={
            "name": "Hacker",
            "email": "hacker1@vistor.ai",
            "password": "securepassword123",
            "role": "admin"
        }
    )
    assert response1.status_code == 403
    
    # Manager (manager_client) cannot create
    response2 = await manager_client.post(
        "/api/users/",
        json={
            "name": "Hacker",
            "email": "hacker2@vistor.ai",
            "password": "securepassword123",
            "role": "admin"
        }
    )
    assert response2.status_code == 403
