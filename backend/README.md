# Vistor AI — Backend API (FastAPI)

Guia técnico de referência e documentação de desenvolvimento para o módulo backend da plataforma Vistor AI.

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

> Edite as conexões com banco de dados, Redis, MinIO S3 e as chaves de API necessárias no arquivo `.env` do backend.

### 4. Migrações de Banco de Dados (Alembic)

Para aplicar as migrações locais até a revisão mais atualizada:

```bash
alembic upgrade head
```

> [!IMPORTANT]
> **Alterações de Esquema:** Ao modificar um modelo SQLAlchemy, gere uma nova migração executando `alembic revision --autogenerate -m "descricao"`. **Nunca** modifique arquivos de migração históricos que já foram integrados ao repositório.

### 5. Administrador Inicial (Bootstrap)

Toda vez que a aplicação é iniciada (ou após zerar o banco de dados), um administrador padrão é automaticamente criado no banco se nenhum administrador estiver cadastrado na tabela de usuários.

> [!NOTE]
> **Fluxo em bancos zerados:** Na primeira subida dos containers com banco limpo, a tabela de usuários ainda não existe, portanto o bootstrap administrativo é pulado silenciosamente (registrando um aviso no log). **Após aplicar as migrações**, é necessário reiniciar o serviço da API (`docker compose restart api` ou reiniciando o servidor local) para disparar a lógica do ciclo de vida novamente e criar a conta do administrador padrão.

Os dados de acesso padrão são lidos das variáveis do arquivo `.env` do backend:

* **Usuário padrão:** `admin@vistor.ai` (configurável via `INITIAL_ADMIN_EMAIL`)
* **Senha padrão:** `password123` (configurável via `INITIAL_ADMIN_PASSWORD`)

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

---

## Segurança e Regras de Negócio Invioláveis

O desenvolvimento no backend deve respeitar as seguintes diretrizes de segurança e de negócio estabelecidas:

### 1. Autenticação e Autorização (RBAC & IDOR)

* **Rate Limiting:** A rota de autenticação (`/auth/login`) possui limite estrito de 5 tentativas por minuto por IP para evitar ataques de força bruta.
* **Tokens JWT:** Os tokens de acesso expiram em 15 minutos e os tokens de atualização (refresh tokens) expiram em 7 dias, sendo gerenciados via cache Redis.
* **RBAC (Role-Based Access Control):** Sempre utilize o mecanismo de verificação de permissões em endpoints administrativos ou gerenciais usando a dependência `require_role([Role.manager, Role.admin])`.
* **IDOR (Insecure Direct Object References):** Valide sempre o pertencimento do recurso. O inspetor comum só pode visualizar/alterar recursos criados por ele mesmo (`inspector_id == current_user.id`), enquanto gestores e administradores possuem permissão de leitura/escrita global.

### 2. Integridade dos Dados e Auditoria

* **Soft Delete:** Nunca utilize exclusão física (`DELETE`) para a entidade `Inspection`. Use exclusão lógica marcando o campo `deleted_at = func.now()`. As consultas de listagem ativa devem filtrar apenas registros onde `deleted_at` é nulo.
* **Trilha de Auditoria:** Toda e qualquer alteração de estado na entidade `Inspection` (criação, edição de severidade, encerramento ou remoção) deve registrar uma linha na tabela `AuditLog` detalhando o usuário executor, ação e valores alterados.
* **PostGIS:** Coordenadas de GPS são salvas no tipo espacial `GEOMETRY(POINT, 4326)`. Consultas de proximidade devem fazer uso do índice espacial `GIST`.

### 3. Processamento de IA e Fallbacks

* O modelo primário de classificação visual de severidade é o `google/vit-base-patch16-224` acessado via HuggingFace Inference API.
* A chamada externa tem timeout fixo de **10 segundos**. Caso ocorra falha ou timeout, a API deve acionar o fallback local executando o modelo ONNX compilado.
* Classificações com score de confiança inferior a `0.55` mudam o status da inspeção para `pending_review`, exigindo posterior confirmação manual de um inspetor humano antes do fechamento.

### 4. Geração de Laudos Técnicos

* Os laudos em formato PDF são gerados usando o template em Jinja2 e compilados pelo WeasyPrint.
* A assinatura de integridade é garantida pela gravação do hash SHA-256 do arquivo no momento de sua criação. A cada download do PDF pelo usuário, o hash do arquivo no storage é recalculado e comparado com o hash gravado. Qualquer divergência bloqueia o download e dispara um alerta de auditoria.

---

## Documentação Complementar

Consulte também os demais guias de referência técnica:

* [docs/backend/GEMINI.md](../docs/backend/GEMINI.md) — Documentação de arquitetura, padrões e rotinas do backend.
* [docs/admin/GEMINI.md](../docs/admin/GEMINI.md) — Diretrizes de segurança, auditoria e controle de infraestrutura.
* [API Swagger UI](http://localhost:8000/docs) — Disponível localmente com a aplicação rodando.

---
