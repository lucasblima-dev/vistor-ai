# Módulo: Backend (FastAPI)

> Contexto técnico específico do backend.

> Complementa o GEMINI.md raiz com convenções de código Python/FastAPI.

---

## Estrutura de Pastas

```
backend/
├── Dockerfile
├── .env.example
├── alembic.ini
├── pyproject.toml
│
├── alembic/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
│       ├── 0001_create_users.py
│       ├── 0002_create_inspections.py
│       ├── 0003_create_media.py
│       ├── 0004_create_reports.py
│       ├── 0005_create_audit_log.py
│       └── 0006_create_locations.py
│
└── app/
    ├── main.py
    ├── config.py
    ├── database.py
    ├── redis.py          (Conexão Redis)
    │
    ├── models/
    │   ├── __init__.py
    │   ├── user.py
    │   ├── inspection.py
    │   ├── media.py
    │   ├── report.py
    │   ├── audit_log.py
    │   ├── location.py  
    │   └── setting.py      (se salvo no DB)
    │
    ├── schemas/
    │   ├── __init__.py
    │   ├── auth.py
    │   ├── user.py
    │   ├── inspection.py
    │   ├── media.py
    │   ├── report.py
    │   ├── audit_log.py    (LogOut)
    │   ├── location.py  
    │   └── setting.py   
    │
    ├── routers/
    │   ├── __init__.py
    │   ├── auth.py
    │   ├── users.py
    │   ├── inspections.py
    │   ├── media.py
    │   ├── reports.py
    │   ├── geo.py
    │   ├── settings.py  
    │   ├── locations.py 
    │   └── audit.py     
    │
    ├── services/
    │   ├── __init__.py
    │   ├── auth_service.py
    │   ├── user_service.py         (Isola a lógica do usuário)
    │   ├── audit_service.py        (Contém o log_action)
    │   ├── inspection_service.py
    │   ├── ai_service.py
    │   ├── storage_service.py
    │   ├── pdf_service.py
    │   ├── geo_service.py
    │   ├── notification_service.py
    │   ├── settings_service.py
    │   └── location_service.py
    │
    ├── dependencies/
    │   ├── auth.py
    │   └── db.py
    │
    ├── templates/
    │   ├── report.html
    │   ├── email_daily.html
    │   └── email_new_user.html
    │
    ├── static/
    │   └── logo.png
    │
    └── tests/
        ├── conftest.py
        ├── test_auth.py
        ├── test_users.py
        ├── test_inspections.py
        ├── test_media.py
        ├── test_geo.py
        ├── test_ai_service.py
        └── test_pdf_service.py
```

---

## Setup de Desenvolvimento Local

Caso precise executar, depurar ou testar o backend localmente fora do container Docker, siga as instruções abaixo para preparar o ambiente Python de desenvolvimento:

### 1. Pré-requisitos de Sistema (Nativos)

A API utiliza o **WeasyPrint** (geração de PDF) e o **python-magic** (validação de tipo de arquivos por magic bytes). Esses pacotes possuem dependências nativas de sistema:

* **No Linux (Debian/Ubuntu):**

  ```bash
  sudo apt-get update
  sudo apt-get install -y build-essential python3-dev \
      libpango-1.0-0 libpangoft2-1.0-0 \
      libcairo2 libjpeg-turbo8 libmagic1 shared-mime-info
  ```

* **No Windows:**
  * Instale as bibliotecas nativas de GTK3 (contendo Cairo e Pango) requeridas pelo WeasyPrint, conforme instruções de instalação oficiais do WeasyPrint para Windows.
  * Para o `python-magic`, instale a versão compilada com DLLs inclusas: `pip install python-magic-bin`.

### 2. Configuração do Ambiente Python

1. Acesse o diretório `backend/`:

   ```bash
   cd backend
   ```

2. Crie e ative o ambiente virtual virtualenv:

   ```bash
   python -m venv .venv
   # Ativação no Windows (PowerShell):
   .venv\Scripts\Activate.ps1
   # Ativação no Linux/macOS:
   source .venv/bin/activate
   ```

3. Instale o pacote em modo editável e as dependências extras de desenvolvimento:

   ```bash
   pip install --upgrade pip
   pip install -e .
   pip install ".[dev]"
   ```

### 3. Variáveis de Ambiente (.env)

Crie o arquivo `.env` a partir do modelo padrão:

```bash
cp .env.example .env
```

> Edite as conexões com banco de dados, Redis, MinIO S3 e as chaves de API necessárias no arquivo [backend/.env](/vistor-ai/backend/.env).

### 4. Migrações de Banco de Dados (Alembic)

Para aplicar as migrações locais até a revisão mais atualizada:

```bash
alembic upgrade head
```

> [!IMPORTANT]
> **Alterações de Esquema:** Ao modificar um modelo SQLAlchemy, gere uma nova migração executando `alembic revision --autogenerate -m "descricao"`. **Nunca** modifique arquivos de migração históricos que já foram integrados ao repositório.

### 5. Criação de Usuário de Testes (Seed)

Execute o script para popular o banco local com a conta de teste:

```bash
python seed_user.py
```

* **Credenciais padrão:**
  * **Usuário:** `test@example.com`
  * **Senha:** `password123`

### 6. Execução Local e Testes

* **Servidor de Desenvolvimento (Uvicorn):**

  ```bash
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  ```

* **Executar suíte de testes (com cobertura):**

  ```bash
  pytest --cov=app --cov-report=term-missing
  ```

  *(Nota: A cobertura de código mínima obrigatória para o backend é de **70%**).*
* **Análise de Linter e Estilo (Ruff):**

  ```bash
  ruff check .
  ruff format .
  ```

---

## Organização das camadas

```
router  →  service  →  (model / external API)
             ↑
         dependency (get_db, get_current_user)
```

**Nunca pule camadas.** Router não acessa model diretamente. Service não importa outro router.

---

## Padrão de Router

```python
# routers/inspections.py
from fastapi import APIRouter, Depends, HTTPException, status
from app.dependencies.auth import get_current_user, require_role
from app.dependencies.db import get_db
from app.services import inspection_service
from app.schemas.inspection import InspectionCreate, InspectionOut

router = APIRouter()

@router.post("/", response_model=InspectionOut, status_code=status.HTTP_201_CREATED)
async def create_inspection(
    payload: InspectionCreate,
    db      = Depends(get_db),
    user    = Depends(get_current_user),
):
    return await inspection_service.create(db, payload, owner_id=user.id)
```

* Sempre declare `response_model` explicitamente.
* Sempre use `status_code` explícito em POST (201) e DELETE (204).
* Nunca acesse `db` diretamente no router — passe para o service.

---

## Padrão de Service

```python
# services/inspection_service.py
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.inspection import Inspection
from app.schemas.inspection import InspectionCreate
from app.services.audit_service import log_action

async def create(db: AsyncSession, payload: InspectionCreate, owner_id: str) -> Inspection:
    insp = Inspection(**payload.model_dump(), inspector_id=owner_id)
    db.add(insp)
    await db.commit()
    await db.refresh(insp)
    await log_action(db, user_id=owner_id, entity="inspection",
                     entity_id=str(insp.id), action="create")
    return insp
```

* Sempre `await db.commit()` + `await db.refresh()` após escrita.
* Sempre registrar em `audit_log` após operações de escrita.
* Levante `HTTPException` (não genérica) para erros de negócio.

---

## Padrão de Migration (Alembic)

```python
# alembic/versions/0002_create_inspections.py
"""create inspections table"""
from alembic import op
import sqlalchemy as sa
from geoalchemy2 import Geometry

def upgrade():
    op.create_table("inspections",
        sa.Column("id", sa.UUID(), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("location", Geometry("POINT", srid=4326), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        # ... demais colunas
    )
    # Índice GIST obrigatório para PostGIS
    op.execute("CREATE INDEX idx_inspections_location ON inspections USING GIST (location)")
    # Índice parcial para soft delete
    op.execute("CREATE INDEX idx_inspections_active ON inspections (created_at DESC) WHERE deleted_at IS NULL")

def downgrade():
    op.drop_table("inspections")
```

---

## Tratamento de Erros — Padrão

```python
# Negócio: use HTTPException com detalhe claro
raise HTTPException(status_code=404, detail="Inspeção não encontrada")
raise HTTPException(status_code=403, detail="Acesso negado — recurso pertence a outro usuário")
raise HTTPException(status_code=422, detail="Inspeção deve ter status 'open' para atribuição")

# I/O externo: capture, logue e retorne erro genérico ao cliente
try:
    result = await ai_service.classify_image(image_bytes)
except httpx.TimeoutException:
    logger.warning("HuggingFace timeout — usando fallback ONNX")
    result = await ai_service._classify_local_fallback(image_bytes)
```

---

## Testes — Estrutura esperada

```python
# tests/test_inspections.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_inspection_requires_auth(client: AsyncClient):
    response = await client.post("/api/inspections/", json={})
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_create_inspection_success(authed_client: AsyncClient, inspector_user):
    payload = { "category": "electrical", "lat": -5.793, "lon": -35.209 }
    response = await authed_client.post("/api/inspections/", json=payload)
    assert response.status_code == 201
    assert response.json()["status"] == "open"
```

* `conftest.py` deve fornecer fixtures: `db`, `client`, `authed_client`, `inspector_user`, `manager_user`.
* Testes de integração usam banco PostgreSQL em container separado (`pytest-docker` ou `testcontainers`).
