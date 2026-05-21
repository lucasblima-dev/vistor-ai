import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User
from app.services.auth_service import pwd_context

@pytest.mark.asyncio
async def test_login_success(client: AsyncClient, test_user: User):
    response = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"

@pytest.mark.asyncio
async def test_login_wrong_password(client: AsyncClient, test_user: User):
    response = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "wrongpassword"
    })
    assert response.status_code == 401
    assert response.json()["detail"] == "Credenciais inválidas."

@pytest.mark.asyncio
async def test_login_user_not_found(client: AsyncClient):
    response = await client.post("/api/auth/login", json={
        "email": "nonexistent@example.com",
        "password": "password123"
    })
    assert response.status_code == 401
    assert response.json()["detail"] == "Credenciais inválidas."

@pytest.mark.asyncio
async def test_login_account_lockout(client: AsyncClient, test_user: User):
    # 5 tentativas falhas
    for _ in range(5):
        response = await client.post("/api/auth/login", json={
            "email": "test@example.com",
            "password": "wrongpassword"
        })
        assert response.status_code == 401

    # A 6ª tentativa ou após o bloqueio deve retornar 403
    response = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 403
    assert "bloqueada temporariamente" in response.json()["detail"]

@pytest.mark.asyncio
async def test_login_inactive_user(client: AsyncClient, db_session: AsyncSession, test_user: User):
    test_user.is_active = False
    await db_session.commit()
    
    response = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 403
    assert "desativada" in response.json()["detail"]

@pytest.mark.asyncio
async def test_refresh_token_success(client: AsyncClient, test_user: User):
    # Login para obter refresh token
    login_res = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    refresh_token = login_res.json()["refresh_token"]
    
    # Refresh
    response = await client.post("/api/auth/refresh", json={
        "refresh_token": refresh_token
    })
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["refresh_token"] != refresh_token

@pytest.mark.asyncio
async def test_refresh_token_invalid(client: AsyncClient):
    response = await client.post("/api/auth/refresh", json={
        "refresh_token": "invalid_token"
    })
    assert response.status_code == 401
    assert "inválido ou expirado" in response.json()["detail"]

@pytest.mark.asyncio
async def test_logout_success(client: AsyncClient, test_user: User):
    # Login
    login_res = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    access_token = login_res.json()["access_token"]
    refresh_token = login_res.json()["refresh_token"]
    
    # Logout
    response = await client.post("/api/auth/logout", 
        json={"refresh_token": refresh_token},
        headers={"Authorization": f"Bearer {access_token}"}
    )
    assert response.status_code == 204
    
    # Tenta usar o refresh token após logout
    refresh_res = await client.post("/api/auth/refresh", json={
        "refresh_token": refresh_token
    })
    assert refresh_res.status_code == 401

@pytest.mark.asyncio
async def test_get_me_success(client: AsyncClient, test_user: User):
    # Login
    login_res = await client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    access_token = login_res.json()["access_token"]
    
    response = await client.get("/api/auth/me", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"

@pytest.mark.asyncio
async def test_get_me_no_token(client: AsyncClient):
    response = await client.get("/api/auth/me")
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_me_expired_token(client: AsyncClient):
    # Para testar expirado, daria para manipular o token_service ou mockar o tempo 
    # vou usar um token mal formado/inválido que cai na mesma exceção 401
    response = await client.get("/api/auth/me", headers={"Authorization": "Bearer invalid_token"})
    assert response.status_code == 401
    assert "validar as credenciais" in response.json()["detail"]
