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

### 5. Administrador Inicial (Bootstrap)

Toda vez que a aplicação é iniciada (ou após zerar o banco de dados), um administrador padrão é automaticamente criado no banco se nenhum administrador estiver cadastrado na tabela de usuários.

> [!NOTE]
> **Fluxo em bancos zerados:** Na primeira subida dos containers com banco limpo, a tabela de usuários ainda não existe, portanto o bootstrap administrativo é pulado silenciosamente (registrando um aviso no log). **Após aplicar as migrações**, é necessário reiniciar o serviço da API (`docker compose restart api`) para disparar a lógica do ciclo de vida novamente e criar a conta do administrador padrão.

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
