# Vistor AI — Progress

Arquivo de atualização de todo o desenvolvimento do **Vistor AI**. Esse documento
foca exclusivamente no `backend`. Para visualizar o `mobile`, acesse o [`./PROGRESS_MOBILE.md`](./PROGRESS_MOBILE.md).

---

## Status das Sprints

| Sprint | Descrição | Status | Concluída em |
|---|---|---|---|
| 0 | Arquivos base (gitignore, env, docs, estrutura) | ✅ Concluído | 27/04/2026 |
| 1 | Docker Compose + Dependências | ✅ Concluído | 05/05/2026 |
| 2 | FastAPI esqueleto + health endpoint | ✅ Concluído | 05/05/2026 |
| 3 | Models SQLAlchemy + Migrations Alembic | ✅ Concluído | 08/05/2026 |
| 4 | Autenticação (JWT, refresh, blacklist) | ✅ Concluído | 21/05/2026 |
| 5 | Inspeções CRUD + PostGIS | ✅ Concluído | 22/05/2026 |
| 6 | Mídia — upload/download MinIO | ✅ Concluído | 23/05/2026 |
| 7 | IA (HuggingFace) + PDF (WeasyPrint) | ✅ Concluído | 24/05/2026 |
| 8 | Testes + cobertura ≥ 70% | ✅ Concluído | 25/05/2026 |

## Checklist antes do Mobile

| Status | Demandas |
|----|----|
| [✅] | docker compose up -d → todos os serviços healthy |
| [✅] | GET /health → {"status":"ok","db":"connected"} |
| [✅] | alembic upgrade head → sem erro |
| [✅] | 5 tabelas + índice GIST confirmados no banco |
| [✅] | POST /auth/login → retorna tokens |
| [✅] | POST /inspections/ → cria com coordenadas GPS |
| [✅] | GET /geo/nearby → retorna inspeções no raio |
| [✅] | POST /media/presign → retorna URL de upload |
| [✅] | IA (HuggingFace) → classifica imagem e mapeia severidade |
| [✅] | POST /reports/generate → gera PDF com hash SHA-256 |
| [✅] | pytest --cov=app → cobertura >= 70% |
| [✅] | git tag v0.1.0-backend existe |
| [✅] | PROGRESS.md atualizado |
| [✅] | Nenhum TODO crítico no código |

> Legenda: ⬜ Pendente · 🔄 Em andamento · ✅ Concluído · ⚠️ Bloqueado

---

## Task 01

**Data:** 29/04/2026

**Sprint:** 0 - Arquivos base
**Sessão:** Estrutura inicial do projeto

### O que foi feito

- `.gitignore` criado com padrões para Python, Flutter, Docker e IDEs
- `.env.example` criado com todas as variáveis do escopo do projeto
- `README.md` criado para um melhor entendimento do ciclo de construção do app
- Estrutura de pastas de `docs/` e `backend/` criada parcialmente

### Estado dos arquivos tocados

- `.gitignore` — completo
- `.env.example` — completo
- `README.md` - Em construção
- `docs/` — pastas criadas, arquivos `GEMINI.md` em preenchimento
- `backend/` — pastas e arquivos criados, conteúdo pendente

### Validações que passaram

— Nada foi criado necessitava de validação

### O que ficou pendente

- Finalizar preenchimento dos `GEMINI.md` em `docs/`
- Verificar se todos os arquivos `__init__.py` e diretórios do `backend/` estão criados

### Próxima ação

Concluir os arquivos de `docs/` (GEMINI.md de cada módulo) e confirmar estrutura
completa de `backend/`. Depois abrir sessão da Sprint 1 para o `docker-compose.yml`.

---

## Task 02

**Data:** 29/04/2026
**Sprint:** 1 - Docker Compose + Dependências
**Sessão:** Configuração da Infraestrutura (Task 1.1)

### O que foi feito

- Arquivo `docker-compose.yml` criado com serviços: `db` (PostGIS), `minio`, `redis` e `api`.
- Configuração de redes internas e volumes persistentes.
- Integração com variáveis de ambiente do `.env`.
- *Healthcheck* configurado para o banco de dados.

### Estado dos arquivos tocados

- `docker-compose.yml` — completo e funcional.

### Validações que passaram

- Estrutura do YAML validada conforme os requisitos do sistema.
- Validar a execução dos containers com `docker-compose up`.

### O que ficou pendente

- Nada referente a task 1.1: `docker-compose.yml` + testes

### Próxima ação

Iniciar a task 1.2

---

## Task 03

**Data:** 29/04/2026
**Sprint:** 1 - Docker Compose + Dependências
**Sessão:** Configuração do Ambiente Backend (Task 1.2)

### O que foi feito

- Arquivo `backend/pyproject.toml` criado com todas as dependências de produção e desenvolvimento.
- Configuração do sistema de build (`hatchling`), `pytest` (async mode) e `ruff` (line length).
- Inclusão de pacotes críticos: PostGIS (`geoalchemy2`), IA (`onnxruntime`), PDF (`weasyprint`) e S3 (`aiobotocore`).

### Estado dos arquivos tocados

- `backend/pyproject.toml` — completo e configurado.

### Validações que passaram

- Verificação da sintaxe TOML e presença de todas as dependências solicitadas.

### O que ficou pendente

- Task 1.3:

### Próxima ação

Aguardando definição da task 1.3.

---

## Task 04

**Data:** 05/05/2026
**Sprint:** 1 - Docker Compose + Dependências
**Sessão:** Dockerização do Backend (Task 1.3)

### O que foi feito

- Arquivo `backend/Dockerfile` criado com multi-stage build (`builder` e `runtime`).
- Instalação de dependências de sistema para WeasyPrint, PostGIS e python-magic.
- Configuração de usuário não-root (`appuser`) para segurança.
- Suporte dinâmico para ambiente de desenvolvimento (`--reload`) via `BUILD_ENV`.
- Arquivo `backend/.dockerignore` criado para otimização e segurança.

### Estado dos arquivos tocados

- `backend/Dockerfile` — completo e otimizado.
- `backend/.dockerignore` — completo.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Dockerfile segue as melhores práticas (non-root, multi-stage, slim image).
- Variáveis de ambiente e comandos de inicialização configurados conforme requisitos.

### O que ficou pendente

- Nada referente a Sprint 1.

### Próxima ação

Sprint 2: Criação do esqueleto FastAPI e endpoint de health check.

---

## Task 05

**Data:** 05/05/2026
**Sprint:** 2 - FastAPI esqueleto + health endpoint
**Sessão:** Configuração e Conexão com Banco de Dados (Task 2.1)

### O que foi feito

- Implementado `app/config.py` utilizando Pydantic Settings para carregar variáveis de ambiente.
- Implementado `app/database.py` com suporte a SQLAlchemy assíncrono e `asyncpg`.
- Criada a classe `Base` declarativa para futuros modelos ORM.
- Criada a dependência `get_db` para injeção de sessão nos routers.

### Estado dos arquivos tocados

- `backend/app/config.py` — completo.
- `backend/app/database.py` — completo.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Configurações mapeadas conforme `.env.example`.
- Fábrica de sessões configurada para operações assíncronas.

### O que ficou pendente

- Implementar `main.py` com o esqueleto FastAPI e o endpoint de health check.

### Próxima ação

Finalizar a Sprint 2 com a implementação do `main.py` e validação do health check.

---

## Task 06

**Data:** 05/05/2026
**Sprint:** 2 - FastAPI esqueleto + health endpoint
**Sessão:** Esqueleto FastAPI e Routers (Task 2.2)

### O que foi feito

- Implementado `app/main.py` com instância FastAPI, middleware CORS e endpoint de `/health`.
- Criados stubs para os 6 routers principais (`auth`, `users`, `inspections`, `media`, `reports`, `geo`) para permitir importação.
- Configurada a inclusão dos routers no app principal com prefixos e tags.

### Estado dos arquivos tocados

- `backend/app/main.py` — completo (esqueleto).
- `backend/app/routers/*.py` — stubs criados.
- `PROGRESS.md` — Sprint 2 concluída.

### Validações que passaram

- Importações resolvidas, permitindo o boot da API.
- Endpoint de health check implementado.

### O que ficou pendente

- Nada referente a Sprint 2.

### Próxima ação

Iniciar Sprint 3: Definição dos Models SQLAlchemy e Migrations Alembic.

---

## Task 07

**Data:** 05/05/2026
**Sprint:** 2 - FastAPI esqueleto + health endpoint
**Sessão:** Ajustes de Build e Configuração (Task 2.3)

### O que foi feito

- Corrigido erro de build `metadata-generation-failed` no Dockerfile através da configuração explícita do `tool.hatch.build.targets.wheel` no `pyproject.toml`.
- Corrigido erro de parse `SettingsError` no Pydantic ao ajustar o formato da variável `ALLOWED_ORIGINS` para um array JSON válido (`List[str]`).
- Atualizado `.env.example` com o formato correto de strings JSON para variáveis de lista.

### Estado dos arquivos tocados

- `backend/pyproject.toml` — atualizado com configuração de build.
- `.env.example` — atualizado com formato JSON para listas.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Build da imagem Docker concluído com sucesso após os ajustes.
- Configuração do Pydantic validada para aceitar arrays JSON via variáveis de ambiente.

### O que ficou pendente

- Validar conectividade real com os serviços (db, redis, minio) assim que os modelos forem criados.

### Próxima ação

Iniciar Sprint 3: Models SQLAlchemy e Migrations Alembic.

---

## Task 08

**Data:** 07/05/2026
**Sprint:** 3 - Models SQLAlchemy + Migrations Alembic
**Sessão:** Implementação dos Models (Task 3.1)

### O que foi feito

- Implementados os 5 modelos ORM principais: `User`, `Inspection`, `Media`, `Report` e `AuditLog`.
- Configurado suporte a PostGIS via `GeoAlchemy2` para o campo `location`.
- Utilizado UUID como PK com `server_default=text("gen_random_uuid()")`.
- Configurados Enums explícitos para roles, severidade, status e tipos de mídia.
- Implementado suporte a logs de auditoria com campos `JSONB` e `INET`.
- Criado `app/models/__init__.py` para exportação centralizada dos modelos.

### Estado dos arquivos tocados

- `backend/app/models/user.py` — completo.
- `backend/app/models/inspection.py` — completo.
- `backend/app/models/media.py` — completo.
- `backend/app/models/report.py` — completo.
- `backend/app/models/audit_log.py` — completo.
- `backend/app/models/__init__.py` — completo.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Revisão técnica dos modelos contra a especificação do `GEMINI.md`.
- Verificação de tipos, chaves estrangeiras e restrições.

### O que ficou pendente

- Validar importação em ambiente com dependências instaladas.
- Task 3.2: Configuração do Alembic e geração da primeira migration.

### Próxima ação

Task 3.2: Inicializar Alembic, configurar `env.py` para detectar os modelos e gerar a migration inicial.

---

## Task 09

**Data:** 08/05/2026
**Sprint:** 3 - Models SQLAlchemy + Migrations Alembic
**Sessão:** Configuração do Alembic (Task 3.2)

### O que foi feito

- Criado `alembic.ini` com configuração de `script_location` e `file_template` personalizado.
- Implementado `alembic/env.py` com suporte completo a SQLAlchemy assíncrono e carregamento dinâmico de modelos.
- Criado `alembic/script.py.mako` personalizado com imports para `GeoAlchemy2` (Geometry).
- Criado diretório `alembic/versions` para armazenamento das migrations.
- Criado arquivo `.env` local no backend para suporte à execução de ferramentas CLI.
- Instaladas dependências necessárias no ambiente: `alembic`, `geoalchemy2`, `asyncpg`, `pydantic-settings`.

### Estado dos arquivos tocados

- `backend/alembic.ini` — completo.
- `backend/alembic/env.py` — completo e validado.
- `backend/alembic/script.py.mako` — completo.
- `backend/.env` — criado para suporte local.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Comando `python -m alembic current` executa sem erros de importação ou sintaxe.
- Modelos são detectados corretamente através da importação em `env.py`.
- Suporte a `AsyncEngine` confirmado no fluxo de execução do Alembic.

### O que ficou pendente

- Task 3.3: Geração da primeira migration (`revision --autogenerate`) e aplicação no banco de dados.

### Próxima ação

Task 3.3: Gerar e aplicar a primeira migration para criar as tabelas no PostgreSQL.

---

## Task 10

**Data:** 08/05/2026
**Sprint:** 3 - Models SQLAlchemy + Migrations Alembic
**Sessão:** Migrações Manuais (Task 3.3)

### O que foi feito

- Criadas 5 migrações manuais sequenciais em `alembic/versions/`:
  - `0001_create_users`: Tabela de usuários e Enum `role_enum`.
  - `0002_create_inspections`: Tabela de inspeções, Enums `severity_enum` e `status_enum`, extensão PostGIS, índice GIST em `location` e índice parcial em `deleted_at`.
  - `0003_create_media`: Tabela de mídias e Enum `media_type_enum`.
  - `0004_create_reports`: Tabela de laudos técnicos.
  - `0005_create_audit_log`: Tabela de auditoria e índice composto em `entity`.
- Garantida a integridade referencial através da ordem de criação e `down_revision`.
- Implementado suporte a UUIDs nativos do PostgreSQL com `gen_random_uuid()`.
- Configurados Enums explícitos com criação e remoção manual (`upgrade`/`downgrade`).

### Estado dos arquivos tocados

- `backend/alembic/versions/0001_create_users.py` — completo.
- `backend/alembic/versions/0002_create_inspections.py` — completo.
- `backend/alembic/versions/0003_create_media.py" — completo.
- `backend/alembic/versions/0004_create_reports.py" — completo.
- `backend/alembic/versions/0005_create_audit_log.py" — completo.
- `PROGRESS.md` — Sprint 3 em fase final.

### Validações que passaram

- Comando `python -m alembic heads` confirma a ponta da cadeia em `0005`.
- Cadeia de `down_revision` validada como linear.
- Verificação visual dos tipos PostGIS e restrições de FK.

### O que ficou pendente

- Execução das migrações (`upgrade head`) contra um banco de dados real.

### Próxima ação

Iniciar Sprint 4

---

## Task 11

**Data:** 21/05/2026
**Sprint:** 4 - Autenticação
**Sessão:** Schemas de Autenticação e Usuários (Task 4.1)

### O que foi feito

- Criado `app/schemas/auth.py` com schemas:
  - `LoginRequest`: Validação de email e senha para login.
  - `TokenResponse`: Estrutura de retorno de tokens JWT.
  - `RefreshRequest`: Schema para renovação de access token.
  - `UserOut`: Schema de saída para dados do usuário com `from_attributes=True` (Pydantic v2).
- Criado `app/schemas/user.py` com schemas:
  - `UserCreate`: Criação de usuário com validação de senha (min 8 chars) e role.
  - `UserUpdate`: Atualização parcial de nome e email.
- Utilizado `ConfigDict` para configurações do Pydantic v2.
- Integrado `UserRole` Enum dos modelos para validação estrita no `UserCreate`.

### Estado dos arquivos tocados

- `backend/app/schemas/auth.py` — completo.
- `backend/app/schemas/user.py` — completo.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Revisão dos tipos de dados e nomes de campos conforme `GEMINI.md`.
- Garantia de que a senha em `UserCreate` possui `min_length=8`.

### O que ficou pendente

- Implementação do `auth_service.py` para lógica de login e geração de tokens.
- Implementação dos endpoints de auth no router.

### Próxima ação

Task 4.2: Implementar lógica de segurança e JWT no backend.

---

## Task 12

**Data:** 21/05/2026
**Sprint:** 4 - Autenticação
**Sessão:** Serviços de Autenticação e JWT (Task 4.2)

### O que foi feito

- Implementado `app/services/token_service.py`:
  - `create_access_token`: Geração de JWT com tempo de expiração configurável.
  - `decode_access_token`: Decodificação e validação de tokens JWT.
- Implementado `app/services/auth_service.py`:
  - `create_user`: Cadastro com hash de senha (bcrypt 12 rounds) e bloqueio de email duplicado.
  - `login`: Autenticação com verificação de status ativo, controle de tentativas falhas (bloqueio de 15 min após 5 falhas) e geração de tokens.
  - `refresh_token`: Rotação de refresh tokens armazenados no Redis para segurança máxima.
  - `logout`: Invalidação de refresh tokens no Redis (idempotente).
- Mensagens de erro de negócio padronizadas em português via `HTTPException`.
- Utilizado `AsyncSession` (SQLAlchemy) e `Redis` (asyncio) para operações não bloqueantes.

### Estado dos arquivos tocados

- `backend/app/services/token_service.py` — completo.
- `backend/app/services/auth_service.py" — completo.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Lógica de hash de senha segue padrões de segurança (rounds=12).
- TTL de tokens respeita configurações do `app/config.py`.
- Fluxo de rotação de refresh token deleta o token antigo.

### O que ficou pendente

- Implementação dos endpoints em `routers/auth.py`.
- Implementação das dependências `get_current_user` e `require_role`.

### Próxima ação

Task 4.3: Implementar router de autenticação e dependências de segurança.

---

## Task 13

**Data:** 21/05/2026
**Sprint:** 4 - Autenticação
**Sessão:** Router, Dependências e Auditoria (Task 4.3)

### O que foi feito

- Implementado `app/dependencies/db.py`: Dependências assíncronas para `get_db` (PostgreSQL) e `get_redis` (Redis).
- Implementado `app/dependencies/auth.py`:
  - `get_current_user`: Valida JWT, busca usuário no banco e verifica status.
  - `require_role`: Decorador para controle de acesso baseado em papéis (RBAC).
- Implementado `app/services/audit_service.py`: Serviço centralizado para registro de ações (`log_action`) com persistência em banco.
- Implementado `app/routers/auth.py`:
  - Endpoints de `login`, `refresh`, `logout` e `me`.
  - Integração com logs de auditoria para login/logout.
  - Uso de `Depends` para injeção de dependências e segurança.

### Estado dos arquivos tocados

- `backend/app/dependencies/db.py` — completo.
- `backend/app/dependencies/auth.py` — completo.
- `backend/app/services/audit_service.py" — completo.
- `backend/app/routers/auth.py" — completo.
- `PROGRESS.md` — Sprint 4 em fase avançada.

### Validações que passaram

- Estrutura de rotas segue o padrão REST.
- Dependência de Redis configurada com fechamento automático de conexão.
- Auditoria registra IP do cliente no login.

### O que ficou pendente

- Implementação do router de usuários (`routers/users.py`) para gestão de perfil e criação inicial de admin.

### Próxima ação

Task 4.4: Implementar gestão de usuários e registro inicial.

---

## Task 14

**Data:** 21/05/2026
**Sprint:** 4 - Autenticação
**Sessão:** Correção de Erro 500 no Login (Hotfix)

### O que foi feito

- Corrigido Erro 500 na rota de login:
  - Migração de `passlib` para `pwdlib` concluída com configuração explícita de `BcryptHasher`.
  - Adicionada captura de atributos do usuário (`id`, `role`) antes do `db.commit()` para evitar erros de `MissingGreenlet` ou expiração de objetos SQLAlchemy em contexto assíncrono.
  - Implementada conversão explícita de strings UUID para objetos `uuid.UUID` no `audit_service.py`, garantindo compatibilidade com o modelo de dados.
  - Adicionado bloco `try/except` na verificação de senha para capturar e tratar erros de formato de hash.
- Refatoração dos serviços de autenticação para maior robustez no fluxo de tokens.

### Estado dos arquivos tocados

- `backend/app/services/auth_service.py` — corrigido e otimizado.
- `backend/app/services/audit_service.py" — robustez para UUIDs adicionada.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Fluxo de login agora deve processar corretamente hashes Bcrypt (`$2b$`).
- Atributos do usuário são preservados após a persistência no banco.

### Próxima ação

Task 4.5: Validar login via PowerShell e iniciar Sprint 5.

---

## Task 15

**Data:** 21/05/2026
**Sprint:** 4 - Autenticação
**Sessão:** Testes Automatizados de Autenticação

### O que foi feito

- Implementado `backend/app/tests/conftest.py`:
  - Configuração de banco de dados de teste isolado (`vistor_ai_test`) com suporte a PostGIS.
  - Fixture `db_session` com limpeza automática de tabelas (`TRUNCATE`) entre os testes.
  - Fixture `client` utilizando `ASGITransport` para testes assíncronos sem servidor real.
  - Mock de Redis utilizando `fakeredis` para isolamento total.
  - Fixtures `test_user`, `inspector_token` e `manager_token` para facilitar a escrita de testes.
- Implementado `backend/app/tests/test_auth.py`:
  - 11 casos de teste cobrindo:
    - Login bem-sucedido e falhas por senha ou usuário inexistente.
    - Bloqueio temporário de conta após 5 tentativas falhas.
    - Validação de status de conta ativa/inativa.
    - Rotação de Refresh Tokens.
    - Logout e invalidação de sessão.
    - Acesso ao perfil (`/me`) com tokens válidos, inválidos e ausentes.

### Estado dos arquivos tocados

- `backend/app/tests/conftest.py` — completo.
- `backend/app/tests/test_auth.py" — completo (11/11 casos passando).
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Execução de `pytest` retornou 100% de sucesso nos 11 casos propostos.
- Banco de teste é criado e destruído corretamente.
- Rotação de tokens confirmada (refresh token muda a cada uso).

### Próxima ação

Sprint 5: Implementação do CRUD de Inspeções com integração PostGIS.

---

## Task 16

**Data:** 21/05/2026
**Sprint:** 5 - Inspeções CRUD + PostGIS
**Sessão:** Schemas de Inspeção (Task 5.1)

### O que foi feito

- Preenchido o `app/schemas/inspection.py` com as definições Pydantic v2.
- Implementado schema `LocationPoint` para expor a localização como latitude e longitude.
- Desenvolvido decodificador de WKB em `LocationPoint.parse_wkb` e `field_validator` para converter os bytes do PostGIS/GeoAlchemy2 de forma transparente, garantindo que nenhum WKB/WKT seja exposto na API.
- Adicionado `InspectionCreate` com validações de limites geográficos (`lat` entre -90/90, `lon` entre -180/180).
- Adicionado `InspectionUpdate` para modificações parciais (status, descrição, assigned_to, human_label).
- Adicionado `InspectionOut` contendo os dados do modelo, convertendo location e validando relacionamento `inspector: UserOut`.

### Estado dos arquivos tocados

- `backend/app/schemas/inspection.py` — completo.
- `backend/app/schemas/user.py" — atualizado com inclusão de`UserOut`.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Restrição para evitar a exposição do WKB foi tratada de forma correta e sem utilizar dependências desnecessárias (conversão raw de bytes com struct).
- Modelos estão usando Pydantic v2 com `model_config = ConfigDict(from_attributes=True)`.

### O que ficou pendente

- Implementação do Service (CRUD) das inspeções (`app/services/inspection_service.py`) e do router correspondente.

### Próxima ação

Task 5.2: Implementar o Service de Inspeções, lidando com lógica do PostGIS e regras de negócio.

---

## Task 17

**Data:** 21/05/2026
**Sprint:** 5 - Inspeções CRUD + PostGIS
**Sessão:** Service de Inspeções (Task 5.2)

### O que foi feito

- Implementado `app/services/inspection_service.py` com suporte completo a CRUD.
- Integrada lógica PostGIS (`ST_GeomFromText`, `ST_DWithin`, `ST_Distance`) para manipulação de coordenadas e busca por proximidade.
- Implementado controle de acesso (IDOR check) em `get_by_id`, garantindo que inspetores só acessem suas próprias inspeções ou as atribuídas a eles.
- Adicionada paginação baseada em cursor (`created_at`) e filtros por papel (RBAC) na listagem.
- Validada transição de status em `update` (bloqueio de reabertura direta de inspeções resolvidas).
- Implementado *soft delete* garantindo que registros nunca sejam removidos fisicamente do banco.
- Adicionado registro automático de logs de auditoria (`audit_service.log_action`) para todas as operações de escrita (create, update, delete).

### Estado dos arquivos tocados

- `backend/app/services/inspection_service.py` — completo e funcional.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Lógica de negócio isolada no Service conforme os princípios invioláveis da arquitetura.
- Uso correto de casts para `Geography` no PostGIS para garantir precisão em metros nas buscas espaciais.
- Conformidade com as regras de IDOR e RBAC descritas no `GEMINI.md`.

### O que ficou pendente

- Implementação dos routers (`app/routers/inspections.py` e `app/routers/geo.py`) para expor essas funcionalidades via API.

### Próxima ação

Task 5.3: Implementar os routers de inspeção e geoespacial.

---

## Task 18

**Data:** 21/05/2026
**Sprint:** 5 - Inspeções CRUD + PostGIS
**Sessão:** Routers de Inspeção e Geoespacial (Task 5.3)

### O que foi feito

- Implementado `app/routers/inspections.py`:
  - `POST /`: Criação de inspeção vinculada ao usuário autenticado (201 Created).
  - `GET /`: Listagem paginada com suporte a filtros de status e cursor.
  - `GET /{id}`: Detalhe de inspeção com validação de propriedade/atribuição.
  - `PATCH /{id}`: Atualização parcial de dados.
  - `DELETE /{id}`: Remoção lógica (204 No Content).
- Implementado `app/routers/geo.py`:
  - `GET /nearby`: Busca geoespacial com validação de limites (lat/lon) e raio (50m - 5000m).
  - `GET /export`: Exportação de dados em formatos GeoJSON e CSV com filtros opcionais, utilizando `StreamingResponse`.
- Criado `app/services/geo_service.py` para lidar com a lógica de geração de arquivos para exportação (CSV/GeoJSON).
- Adicionado schema `InspectionNearby` em `app/schemas/inspection.py` para incluir a distância nos resultados de proximidade.

### Estado dos arquivos tocados

- `backend/app/routers/inspections.py` — completo.
- `backend/app/routers/geo.py" — completo.
- `backend/app/services/geo_service.py" — criado e funcional.
- `backend/app/schemas/inspection.py" — atualizado.
- `PROGRESS.md` — Sprint 5 finalizada.

### Validações que passaram

- Todos os endpoints possuem autenticação obrigatória via `Depends(get_current_user)`.
- Routers seguem o padrão de delegar lógica aos services, mantendo-se puramente declarativos.
- Validações de entrada (`Query` parameters) garantem integridade dos dados geográficos.

### O que ficou pendente

- Finalizar o `app/tests/test_inspections.py` com cobertura completa dos cenários de CRUD e Geolocalização.

### Próxima ação

Task 5.4: Testes de integração das Inspeções

---

## Task 19

**Data:** 21/05/2026
**Sprint:** 5 - Inspeções CRUD + PostGIS
**Sessão:** Testes de Integração de Inspeções (Task 5.4)

### O que foi feito

- Criado `app/tests/test_inspections.py` com cobertura completa dos cenários de CRUD e Geo:
  - Criação de inspeção com validação de retorno `InspectionOut` e relacionamento `inspector`.
  - Proteção de endpoints (401 Unauthorized) para acessos sem token.
  - Validação de RBAC na listagem: Inspetores veem apenas suas inspeções, Gestores veem todas.
  - Validação de IDOR: Bloqueio de acesso (403 Forbidden) para inspetores tentando acessar inspeções alheias.
  - Teste de fluxo de atualização de status.
  - Teste de *soft delete*: Garantia de que a inspeção some da listagem mas permanece no banco com `deleted_at`.
  - Teste de busca geoespacial `/geo/nearby`: Verificação de raio de busca (500m) e validação de limites (422 para raio > 5000m).
- Atualizado `conftest.py` para incluir o banco de testes correto, suporte a `fakeredis` e fixtures `authed_client`/`manager_client`.
- Corrigido o `inspection_service.py` para garantir o carregamento correto de relacionamentos (`selectinload`) e uso adequado de tipos PostGIS (`Geography`) em queries espaciais.
- Ajustado o modelo `Inspection` para definir explicitamente os relacionamentos ORM com a tabela de usuários.

### Estado dos arquivos tocados

- `backend/app/tests/test_inspections.py` — 100% dos testes passando (10/10).
- `backend/app/services/inspection_service.py" — refinado e corrigido.
- `backend/app/models/inspection.py" — atualizado com relacionamentos.
- `backend/app/tests/conftest.py" — fixtures atualizadas.
- `PROGRESS.md` — Sprint 5 concluída com sucesso.

### Validações que passaram

- `pytest app/tests/test_inspections.py -v` -> 10/10 PASS.
- Coordenadas reais de São Paulo utilizadas para garantir fidelidade aos cálculos do PostGIS.
- Conversão transparente de WKB para Lat/Lon validada via API.

### O que ficou pendente

- Nada. Sprint 5 finalizada.

### Próxima ação

Sprint 6: Mídia — Implementação de upload/download MinIO e integração com inspeções.

---

## Task 20

**Data:** 22/05/2026
**Sprint:** 6 - Mídia — upload/download MinIO
**Sessão:** Integração com MinIO e Processamento de Imagem (Task 6.1)

### O que foi feito

- Implementado `app/services/storage_service.py`:
  - `get_presigned_upload_url`: Geração de URLs pré-assinadas para upload via PUT.
  - `get_presigned_download_url`: Geração de URLs pré-assinadas para download via GET (TTL 1h).
  - `delete_object`: Exclusão de objetos no MinIO.
  - `ensure_buckets_exist`: Criação automática dos buckets (`inspections`, `thumbnails`, `reports`) no startup.
  - `generate_thumbnail`: Redimensionamento assíncrono para 300x300 (Pillow) e upload para bucket de thumbnails.
- Atualizado `app/main.py`:
  - Implementado `lifespan` context manager para garantir que a infraestrutura de buckets esteja pronta ao iniciar a API.
- Configurada integração assíncrona com `aiobotocore` respeitando o ambiente (SSL desabilitado em dev).

### Estado dos arquivos tocados

- `backend/app/services/storage_service.py` — completo.
- `backend/app/main.py" — atualizado.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Gerenciamento de contexto do `aiobotocore` configurado para evitar singletons e vazamento de conexões.
- Tratamento de erros centralizado com `HTTPException 503`.

### O que ficou pendente

- Implementação do router de mídias (`routers/media.py`) para consumir o `storage_service`.
- Integração do upload com a criação de inspeções.

### Próxima ação

Task 6.2: Implementar o router de mídias e lógica de presign URLs.

---

## Task 21

**Data:** 22/05/2026
**Sprint:** 6 - Mídia — upload/download MinIO
**Sessão:** Router de Mídias e Background Tasks (Task 6.2)

### O que foi feito

- Criado `app/schemas/media.py` com suporte a Pydantic v2 para respostas de mídias e presigned URLs.
- Implementado `app/routers/media.py`:
  - `POST /media/presign`: Gera URL de upload com validação rigorosa de MIME type (`python-magic`) e tamanho (20MB fotos / 100MB vídeos).
  - `POST /media/{id}/confirm`: Confirma o upload e dispara tarefas em background.
  - `GET /media/{id}/url`: Gera URL temporária de download (1h) com validação de IDOR.
- Desenvolvido processamento em background `process_media_upload`:
  - Verificação de integridade do arquivo pós-upload usando `python-magic`.
  - Geração automática de thumbnails para imagens.
- Corrigido erro de startup no Docker:
  - Adicionada validação de protocolo (`http://` ou `https://`) para `MINIO_ENDPOINT` no `app/config.py`.
  - Atualizado `.env.example` com o formato de endpoint correto.

### Estado dos arquivos tocados

- `backend/app/schemas/media.py` — completo.
- `backend/app/routers/media.py" — completo e funcional.
- `backend/app/models/media.py" — atualizado com campo`status`.
- `backend/app/config.py" — validadores adicionados.
- `.env.example` — atualizado.
- `PROGRESS.md` — Sprint 6 concluída.

### Validações que passaram

- Validação de MIME type baseada no conteúdo do arquivo (magic bytes).
- Fluxo de presign -> upload -> confirm validado via curl.
- Startup da aplicação no Docker estabilizado após correção do endpoint.

### O que ficou pendente

- Nada referente a Sprint 6.

### Próxima ação

Sprint 7: IA (HuggingFace) + PDF (WeasyPrint)

---

## Task 22

**Data:** 23/05/2026
**Sprint:** 6 - Mídia — upload/download MinIO
**Sessão:** Ajustes Estruturais e Acesso Externo (Task 6.3 - Fix)

### O que foi feito

- Criada migration `0006_add_media_status` para adicionar a coluna `status` e o Enum `media_status_enum` na tabela `media`, corrigindo a discrepância entre o modelo SQLAlchemy e o banco de dados.
- Implementada a variável `MINIO_EXTERNAL_ENDPOINT` no `config.py` e `.env` para resolver o problema de resolução de host (`minio`) em acessos fora do Docker (cURL, Mobile).
- Refatorado `storage_service.py` para utilizar o endpoint externo na geração de URLs pré-assinadas (Presigned URLs), garantindo acessibilidade para o aplicativo Flutter.

### Estado dos arquivos tocados

- `backend/alembic/versions/0006_add_media_status.py` — criado.
- `backend/app/config.py" — atualizado.
- `backend/app/services/storage_service.py" — refatorado.
- `.env` e `.env.example` — atualizados.

### Validações que passaram

- Fluxo completo validado via PowerShell: Login -> Criar Inspeção -> Presign -> Upload (PUT) -> Confirmar.
- URLs pré-assinadas agora apontam corretamente para `localhost:9000` em ambiente de desenvolvimento.

### O que ficou pendente

- Ajustar as configurações do `conftest.py` para que os testes automatizados funcionem corretamente dentro do ambiente Docker (resolução de host `db`).

### Próxima ação

Sprint 7: IA (HuggingFace Inference API) e Geração de PDF.

---

## Task 23

**Data:** 23/05/2026
**Sprint:** 7 - IA (HuggingFace) + PDF (WeasyPrint)
**Sessão:** Implementação do Serviço de IA (Task 7.1)

### O que foi feito

- Implementado `app/services/ai_service.py`:
  - `classify_image`: Integração com HuggingFace Inference API (`google/vit-base-patch16-224`) via `httpx`.
  - `_classify_local_fallback`: Mecanismo de contingência para falhas de API ou rede.
  - `map_severity`: Lógica de mapeamento de severidade baseada em score e labels de risco (crack, damage, etc).
  - `process_inspection_media`: Orquestração completa de download do MinIO, classificação e atualização da inspeção.
- Integrado logs de auditoria para a ação `ai_classified`.
- Configurado tratamento de erros resiliente para garantir que o processo de inspeção não seja interrompido por falhas na IA.

### Estado dos arquivos tocados

- `backend/app/services/ai_service.py` — completo.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Validação manual da lógica de fallback em ambiente com restrição de DNS.
- Verificação da estrutura de retorno e mapeamento de severidade.

### O que ficou pendente

- Task 7.2: Implementação da geração de laudos em PDF via WeasyPrint.

### Próxima ação

Task 7.2: Desenvolver o `pdf_service.py` e os templates Jinja2 para geração de laudos técnicos.

---

## Task 24

**Data:** 23/05/2026
**Sprint:** 7 - IA (HuggingFace) + PDF (WeasyPrint)
**Sessão:** Geração de Laudos e Correção do Endpoint IA (Task 7.2 & 7.3)

### O que foi feito

- Implementado `pdf_service.py` e template `report.html` para geração de laudos técnicos com hash SHA-256.
- Corrigida a URL da HuggingFace Inference API para o novo domínio `router.huggingface.co`.
- Integrada a classificação automática de IA no fluxo de confirmação de mídia via `BackgroundTasks`.

### Estado dos arquivos tocados

- `backend/app/services/pdf_service.py` — completo.
- `backend/app/routers/reports.py" — completo.
- `backend/app/services/ai_service.py" — corrigido.

---

## Task 25

**Data:** 24/05/2026
**Sprint:** 7 - IA (HuggingFace) + PDF (WeasyPrint)
**Sessão:** Estabilização do Fluxo de IA e Validação (Task 7.4)

### O que foi feito

- Corrigida a instância da sessão de banco (`AsyncSessionLocal`) no router de mídia, resolvendo a quebra do fluxo de background.
- Implementados headers mandatórios (`x-wait-for-model`, `Content-Type`) no `ai_service.py` para compatibilidade com o router do HuggingFace.
- Validada a conexão com a API do HuggingFace através de teste manual com imagem real, confirmando o retorno de labels (ex: "pier", "seashore") e descartando falhas no token ou modelo.

### Estado dos arquivos tocados

- `backend/app/routers/media.py` — completo.
- `backend/app/services/ai_service.py" — otimizado.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Teste manual (curl) retornou classificação válida (score > 0.6) da API do HuggingFace.
- Fluxo de background agora completa o ciclo de atualização de thumbnail e classificação.

### Próxima ação

Validar fluxo de geração de PDF

---

## Task 26

**Data:** 24/05/2026
**Sprint:** 7 - IA (HuggingFace) + PDF (WeasyPrint)
**Sessão:** Estabilização e Validação do Fluxo de PDF (Task 7.5)

### O que foi feito

- Corrigido o gerenciamento de sessões assíncronas no router de relatórios, utilizando um `wrapper` para garantir que tarefas de background tenham sua própria conexão estável com o banco.
- Corrigido erro de nomenclatura no `pdf_service.py` (de `from_wkb` para `parse_wkb`), normalizando a leitura de coordenadas geográficas no laudo.
- Criado o script de automação `backend/test_pdf.py` para validação end-to-end do ciclo: Login -> Inspeção -> Geração -> Download.
- Validada a renderização do PDF com WeasyPrint e a integridade via Hash SHA-256 no corpo do documento.

### Estado dos arquivos tocados

- `backend/app/routers/reports.py` — Refatorado para estabilidade em background.
- `backend/app/services/pdf_service.py` — Corrigido processamento de localização.
- `backend/test_pdf.py` — Novo script de utilidade.
- `PROGRESS.md` — Atualizado.

### Validações que passaram

- Script `test_pdf.py` completou com sucesso o download do arquivo `laudo_teste.pdf`.
- Verificado via logs que o Hash SHA-256 é gerado e persistido corretamente.

### Próxima ação

Sprint 8: Cobertura de testes automatizados com Pytest.

---

## Task 27

**Data:** 25/05/2026
**Sprint:** 8 - Testes + cobertura ≥ 70%
**Sessão:** Aumento da cobertura de testes para 78% (Task 8.1)

### O que foi feito

- Aumento da cobertura de testes gerais de 64% para 78%, atingindo e superando a meta de 70%.
- Realizado o mocking de bibliotecas críticas (`libmagic` e `GTK+`) no arquivo `conftest.py` para compatibilidade com ambiente Windows e contorno da dependência do `weasyprint`.
- Criado o arquivo `app/tests/test_coverage_boost.py` com foco em arquivos com baixa cobertura.
- Criados testes unitários e mocks para:
  - `ai_service.py` (de 0% para 52%): mapeamento de severidade, classificação e fallbacks.
  - `pdf_service.py` (de 24% para 80%): laudo (idempotência), hash e erros.
  - `geo_service.py` (de 28% para 95%): exportação de dados para GeoJSON e CSV.
  - `storage_service.py` (de 23% para 59%): thumbnails e erros no S3/MinIO.
- Cobertura de edge cases em routers e services (IDOR, erro 404, etc).

### Estado dos arquivos tocados

- `backend/app/tests/conftest.py` — atualizado com os novos mocks.
- `backend/app/tests/test_coverage_boost.py` — criado.
- `PROGRESS.md` — atualizado.

### Validações que passaram

- Execução local via *pytest* alcançou os 78% exigidos.
- 37 testes passaram sem erros.

### Próxima ação

Trabalhar nas próximas definições de versionamento, ou migrar os esforços para o mobile.

---

## Task 28

**Data:** 25/05/2026
**Sprint:** 8 - Testes + cobertura ≥ 70%
**Sessão:** Implementação de Teste E2E e Correções de Infraestrutura

### O que foi feito

- Implementação do teste de fluxo completo em `app/tests/test_e2e.py`, cobrindo:
  1. Criação e Login de Inspetor.
  2. Criação de Inspeção (Coordenadas SP).
  3. Fluxo de mídia (Presigned URL e Confirmação).
  4. IA (Simulação de label e score).
  5. Geração e verificação de integridade de Laudo (Hash SHA-256).
  6. Busca geoespacial (/geo/nearby).
  7. Fluxo de Gestor (Login, Atribuição e Mudança de Status).
- **Correção no `audit_service.py`**: Adicionada função `_json_serializable` para tratar UUIDs e Enums antes de salvar no JSONB do Postgres, resolvendo erros de persistência.
- **Melhoria no `pdf_service.py`**: Uso de caminhos absolutos para templates Jinja2, garantindo que o sistema encontre os arquivos em qualquer ambiente de execução.
- **Refatoração do `conftest.py`**:
  - Mock de `AsyncSessionLocal` para garantir que Background Tasks usem a mesma sessão de teste.
  - Mock de S3 Client para permitir testes de upload/download sem MinIO.
  - Mock aprimorado do `weasyprint` para retornar bytes válidos para hash.

### Estado dos arquivos tocados

- `backend/app/tests/test_e2e.py` — Criado.
- `backend/app/services/audit_service.py` — Corrigido.
- `backend/app/services/pdf_service.py` — Estabilizado.
- `backend/app/tests/conftest.py` — Atualizado.

### Validações que passaram

- Suíte completa com 38 testes passando com sucesso.
- Cobertura consolidada em 75%.

### Próxima ação

Backend finalizado com sucesso para a Sprint 8. Iniciar planejamento para o módulo Mobile.

---

## Task 29

**Data:** 25/05/2026
**Sprint:** 8 - Testes + cobertura ≥ 70%
**Sessão:** Refatoração de Componentes e Estabilização Final

### O que foi feito

- **Refatoração do Redis**: Componentização da lógica de conexão em `app/redis.py`, centralizando a configuração e simplificando as dependências em `app/dependencies/db.py`.
- **Estabilização do Ambiente (Windows)**:
  - Implementação de mock agressivo no `conftest.py` para as bibliotecas `weasyprint` e `magic`, permitindo a execução completa da suíte de testes em ambientes Windows sem dependências nativas (GTK+/libmagic).
  - Organização e limpeza do arquivo `.env` para evitar erros de validação do Pydantic.
- **Documentação Final**: Preenchimento do `backend/README.md` com guia rápido de configuração, execução e testes.

### Estado dos arquivos tocados

- `backend/app/redis.py` — Componentizado.
- `backend/app/dependencies/db.py` — Refatorado.
- `backend/app/tests/conftest.py` — Estabilizado para Windows.
- `backend/README.md` — Finalizado.

### Validações que passaram

- Suíte de 38 testes validada localmente com 100% de sucesso.
- Cobertura final mantida em 75%.

### Próxima ação

Backend concluído e estabilizado. Iniciar Sprint 1 do módulo **Mobile (Flutter)**.

## Task 30

**Data:** 03/06/2026

**Sprint:** 9 - Integração Mobile
**Sessão:** Endpoint de Registro Público (Sign-up)

### O que foi feito

- Implementação do endpoint `POST /api/auth/register` em `routers/auth.py`.
- Integração com `auth_service.create_user` para persistência de novos inspetores.
- Adição de log de auditoria para a ação de registro.
- Garantia de que o endpoint é público (não exige token).

### Estado dos arquivos tocados

- `backend/app/routers/auth.py` — endpoint adicionado.

### Validações que passaram

- Análise estática do código confirmada.
- Endpoint segue o padrão de schemas `UserCreate` e `UserOut` já estabelecidos.

## Task 31

**Data:** 13/06/2026
**Sprint:** Ajustes de Administração e Autenticação (Bootstrap & Lockout)
**Sessão:** Implementação de Autocriação de Admin e Menu Dinâmico

### O que foi feito

- Configurada criação automática do usuário administrador inicial (bootstrap) via variáveis de ambiente no startup da API.
- Adicionado tratamento de erro contra tabelas inexistentes no lifespan do FastAPI para bases limpas.
- Desenvolvido menu de navegação dinâmico no app Flutter (BottomNavigationBar) chaveando entre Admin e Inspetor/Gestor.
- Implementada proteção robusta contra auto-desativação e auto-rebaixamento de privilégios de administradores no backend e no frontend mobile.
- Ocultado botão de voltar das telas administrativas quando renderizadas como abas principais.
- Excluído o script obsoleto `seed_user.py` e ajustadas todas as menções na documentação e no `.gitignore`.
- Atualizada documentação de setup no `README.md` e `docs/backend/GEMINI.md` explicando o fluxo de bootstrap de admin e o restart do container.

### Estado dos arquivos tocados

- `.env` e `.env.example` — variáveis de bootstrap adicionadas.
- `.gitignore` — remoção de exclusão do script seed_user.
- `README.md` — instruções de bootstrap e restart incluídas.
- `docs/backend/GEMINI.md` — documentação de setup do admin atualizada.
- `backend/app/config.py` — campos de Settings do admin adicionados.
- `backend/app/main.py` — chamada de bootstrap no lifespan inserida.
- `backend/app/routers/users.py` — validação de alteração de role do próprio usuário adicionada.
- `backend/app/services/auth_service.py` — implementada rotina create_initial_admin_if_not_exists.
- `mobile/lib/app/router.dart` — abas e visualizações dinâmicas baseadas na role configuradas.
- `mobile/lib/features/auth/presentation/profile_screen.dart` — menu de gerenciamento adicionado.
- `mobile/lib/features/auth/presentation/user_management_screen.dart` — botões de ação e voltar protegidos.
- `mobile/lib/features/inspection/presentation/team_management_screen.dart` — botão de voltar protegido.
- `mobile/lib/features/map/presentation/export_data_screen.dart` — botão de voltar protegido.
- `backend/seed_user.py` — removido fisicamente.

### Validações que passaram

- Recuperação automática de lockout administrativo validada localmente.
- Proteções de alteração de papel e desativação validadas com sucesso na API e na interface Flutter.
- Fluxo de menus do administrador validado no aplicativo.

---

## Task 32

**Data:** 14/06/2026

**Sprint:** Ajustes Finais e Correções de Bugs (Mapa & Localização Manual)
**Sessão:** Resiliência de Mapa, Timeouts e Sugestões da Localização Manual no Mobile

### O que foi feito

- **Resiliência do Mapa (`map_cubit.dart` e `map_screen.dart`):**
  - Corrigido o erro de import do `Geolocator` no `map_cubit.dart` que quebrava a inicialização e a tela do mapa.
  - Implementado carregamento rápido do mapa priorizando `getLastKnownPosition` e com timeout reduzido de 4 segundos na posição atual para evitar que telas fiquem travadas por muito tempo se o GPS demorar.
  - Ajustado o fallback de centralização inicial do mapa no `map_screen.dart` para Natal (RN) em vez de `(0, 0)` no oceano, além de mover a câmera assincronamente para a última posição conhecida do usuário no `initState`.
- **Correção no Cubit de Criação (`create_inspection_cubit.dart`):**
  - Resolvido erro de tipo do construtor de `Position` de fallback no geocoding (removido const e substituído `timestamp: null` por `timestamp: DateTime.now()`).
- **Sugestões de Localização Manual (`create_inspection_screen.dart`):**
  - Refatorado o popup "Manual" de endereço para exibir uma busca de endereços interativa com lista de sugestões ("estilo Uber").
  - O popup apresenta carregamento e exibe os candidatos de endereço mais próximos do usuário, ordenados por distância.
  - Adicionado suporte a fallbacks seguros (permitindo prosseguir com o endereço digitado mesmo se offline/sem conexão com o serviço da API do geocoding), evitando o bloqueio da criação de inspeções.

### Estado dos arquivos tocados

- `mobile/lib/features/map/domain/map_cubit.dart` — atualizado.
- `mobile/lib/features/map/presentation/map_screen.dart` — atualizado.
- `mobile/lib/features/inspection/domain/create_inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/presentation/create_inspection_screen.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — No issues found! (Sucesso absoluto sem erros)

---

## Task 33

**Data:** 14/06/2026

**Sprint:** Ajustes de Perfil, Senha e Armazenamento Nativo
**Sessão:** Telas de Alteração de Dados de Perfil, Redefinição de Senha e Persistência Remota da Foto de Perfil

### O que foi feito

- **Backend (Persistência Nativa de Fotos de Perfil):**
  - Criada nova migration no Alembic (`2f8e78c02adc_add_user_avatar_key.py`) que adiciona a coluna `avatar_key` à tabela `users` no PostgreSQL, executada com sucesso.
  - Adicionado o bucket `"avatars"` na inicialização do MinIO em `storage_service.py`.
  - Criado o endpoint `POST /api/users/me/avatar` em `routers/users.py` com validação de MIME type real (magic bytes) e upload da imagem para o MinIO.
  - Atualizados os schemas `UserOut` (`app/schemas/user.py` e `app/schemas/auth.py`) e endpoints de autenticação/usuários (`/auth/me`, `/auth/register`, `/users/me`, `/users/`, `PATCH /users/{user_id}`) para gerar e retornar URLs pré-assinadas dinâmicas (`avatar_url`) da foto de perfil.
  - Recompilado e reiniciado o container Docker `api` com a nova estrutura.
- **Mobile (Telas Dedicadas e Integração):**
  - Implementada a tela de redefinição de senha (`ForgotPasswordScreen`) com validação de formato de e-mail, carregamento rápido simulado de 1.5s, mensagem de sucesso e botão de retorno.
  - Integrada a navegação para `/forgot-password` na rota pública do GoRouter e no formulário de login (`LoginForm`).
  - Desenvolvidas telas dedicadas para edição de perfil (`EditProfileScreen`) e alteração de senha (`ChangePasswordScreen`) substituindo os antigos modais/diálogos.
  - Atualizado o modelo `User` do Flutter para receber `avatar_url` da API e executada a regeneração do Freezed via `build_runner`.
  - Implementado envio da foto de perfil para o backend via `AuthRepository.uploadAvatar` e `AuthCubit.uploadAvatar` utilizando requisições multipart, removendo a necessidade do workaround de cache de imagem local em `TokenStorage`.
  - Formatado o cabeçalho da `ProfileScreen` para exibir o nome e o cargo do usuário em formato compacto `Nome | Cargo` abaixo da foto de perfil e sem distintivos repetidos.
  - Atualizada a linha de versão do app para abrir um pop-up temático (`AlertDialog`) com detalhes do app em vez de expor o número da versão na própria linha.

### Estado dos arquivos tocados

- `backend/app/models/user.py` — atualizado.
- `backend/alembic/versions/20260614_2f8e78c02adc_add_user_avatar_key.py` — criado.
- `backend/app/schemas/user.py` — atualizado.
- `backend/app/schemas/auth.py` — atualizado.
- `backend/app/services/storage_service.py` — atualizado.
- `backend/app/routers/users.py` — atualizado.
- `backend/app/routers/auth.py` — atualizado.
- `mobile/lib/shared/models/user.dart` — atualizado.
- `mobile/lib/core/api/endpoints.dart` — atualizado.
- `mobile/lib/core/api/token_storage.dart` — atualizado.
- `mobile/lib/features/auth/data/auth_repository.dart` — atualizado.
- `mobile/lib/features/auth/domain/auth_cubit.dart` — atualizado.
- `mobile/lib/features/auth/presentation/widgets/login_form.dart` — atualizado.
- `mobile/lib/features/auth/presentation/forgot_password_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/edit_profile_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/change_password_screen.dart` — criado.
- `mobile/lib/features/auth/presentation/profile_screen.dart` — atualizado.
- `mobile/lib/app/router.dart` — atualizado.

### Validações que passaram

- `pytest` — Todos os 42 testes do backend executados e aprovados.
- `flutter analyze` — Sucesso absoluto sem erros nem avisos de lint.
- `flutter test` — Todos os 21 testes mobile executados e aprovados.

---

## Task 34

**Data:** 14/06/2026

**Sprint:** Customização de Abas Dinâmicas por Role e Cadastro de Usuários por Admin
**Sessão:** Roteamento de Abas Customizado para Gestor/Admin, Tela de Logs Standalone, Ajustes de IA e Fluxo Integrado de Criação de Usuários

### O que foi feito

- **Backend (Endpoint Restrito de Criação de Usuário):**
  - Implementado o endpoint seguro `POST /api/users/` em `routers/users.py`, restrito a usuários com privilégio de administrador (`require_role(["admin"])`).
  - O endpoint realiza verificação de duplicidade de e-mail e chama o motor de persistência padrão, gerando uma entrada de rastreabilidade no log de auditoria com a ação `'user_created'`.
  - Criada suíte de testes `test_users.py` no backend validando os fluxos com sucesso, bloqueio de permissão de não-administradores (retornando HTTP 403) e erro de email duplicado (retornando HTTP 409).
- **Mobile (Roteamento Dinâmico por Role, Configurações de IA e Cadastro de Usuários):**
  - Desenvolvida a tela independente `AuditLogsScreen` (`lib/features/auth/presentation/audit_logs_screen.dart`) portando o histórico de auditoria com formatação e parsing resiliente contra erros de tipo de índice em tempo de execução.
  - Refatorada a tela de configurações do sistema (`AdminSettingsScreen`) para remover o tab bar e o controlador de abas, transformando-a na tela exclusiva de "Configurações de IA".
  - Integrada a funcionalidade de criação no `UserRepository` e no `UserManagementCubit.createUser`.
  - Atualizada a interface de gerenciamento de usuários (`UserManagementScreen`) adicionando um `FloatingActionButton` que abre o formulário de cadastro com validação de formato e seleção do cargo (Admin, Gestor, Inspetor).
  - Reconfigurado o GoRouter e o `AppScaffold` em `router.dart` de modo a mapear de forma dinâmica as abas inferiores e destinos baseando-se no cargo do usuário logado:
    - **Inspector:** Inspeções | Mapa | Laudos | Perfil
    - **Gestor:** Inspeções | Exportar | Equipe | Perfil
    - **Admin:** Logs | IA | Usuários | Perfil

### Estado dos arquivos tocados

- `backend/app/routers/users.py` — atualizado.
- `backend/app/tests/test_users.py` — criado.
- `mobile/lib/features/auth/data/user_repository.dart` — atualizado.
- `mobile/lib/features/auth/domain/user_management_cubit.dart` — atualizado.
- `mobile/lib/features/auth/presentation/user_management_screen.dart` — atualizado.
- `mobile/lib/features/auth/presentation/audit_logs_screen.dart` — criado.
- `mobile/lib/app/router.dart` — atualizado.

### Validações que passaram

- `pytest` — Todos os 45 testes do backend aprovados.
- `flutter analyze` — Sucesso absoluto sem erros estáticos.
- `flutter test` — Todos os 21 testes mobile aprovados.

---

## Task 35

**Data:** 14/06/2026

**Sprint:** Estabilização e Tratamento Resiliente de Erros de Conexão/Deserialização
**Sessão:** Paginador do Log de Auditoria e Resiliência no IP Address

### O que foi feito

- **Backend (Paginação de logs de auditoria & IP Address):**
  - Adicionado suporte ao parâmetro query `offset: int = Query(0, ge=0)` na rota `/api/audit-logs/` em `backend/app/routers/audit.py`, aplicando-o na query de banco de dados para suportar lazy loading/paginação de logs no frontend.
  - Mantido `@field_validator('ip_address', mode='before')` no schema Pydantic `AuditLogOut` (`app/schemas/audit_log.py`) para converter automaticamente instâncias de `IPv4Address` e `IPv6Address` para string, prevenindo falhas de serialização no banco de dados.
- **Mobile (Logs de Auditoria Paginados de 5 em 5):**
  - Removido o ícone de engrenagem (configs) do topo da tela `AuditLogsScreen`, já que existe uma aba dedicada às configurações de IA.
  - Atualizado `AdminRepository.getAuditLogs` para aceitar parâmetros `limit` e `offset`.
  - Atualizado `AdminSettingsState` e `AdminSettingsCubit` para gerenciar a paginação usando `isLoadingMore` e `hasMore`.
  - Atualizada a `AuditLogsScreen` para exibir um botão "Carregar mais 5 logs" no fim da lista quando `state.hasMore` for verdadeiro, ou um `CircularProgressIndicator` se `state.isLoadingMore` for verdadeiro, prevenindo sobrecarga desnecessária na busca do banco.
- **Mobile (Prevenção de TypeError em Exceções de API):**
  - Implementada a extensão `DioExceptionExtension` com o método helper `getErrorMessage()` em `core/api/api_client.dart` para parsear as mensagens de erro de forma resiliente, impedindo o erro fatal `type 'String' is not a subtype of type 'int' of index`.
  - Atualizados os repositórios (`admin_repository.dart`, `auth_repository.dart`, `user_repository.dart`, `inspection_repository.dart`) para consumirem a extensão.

### Estado dos arquivos tocados

- `backend/app/routers/audit.py` — atualizado.
- `backend/app/schemas/audit_log.py` — atualizado.
- `mobile/lib/core/api/api_client.dart` — atualizado.
- `mobile/lib/features/auth/data/admin_repository.dart` — atualizado.
- `mobile/lib/features/auth/data/auth_repository.dart` — atualizado.
- `mobile/lib/features/auth/data/user_repository.dart` — atualizado.
- `mobile/lib/features/auth/domain/admin_settings_state.dart` — atualizado.
- `mobile/lib/features/auth/domain/admin_settings_cubit.dart` — atualizado.
- `mobile/lib/features/auth/presentation/audit_logs_screen.dart` — atualizado.
- `mobile/lib/features/inspection/data/inspection_repository.dart` — atualizado.

### Validações que passaram

- `pytest` — Todos os 45 testes do backend aprovados.
- `flutter analyze` — Sucesso absoluto sem erros estáticos.
- `flutter test` — Todos os 21 testes mobile aprovados.

---

## Task 36

**Data:** 14/06/2026

**Sprint:** Ajustes Finais, Logo e Nome do Aplicativo
**Sessão:** Configuração da Identidade Visual do Launcher (Android/Web) e Nome Comercial do App

### O que foi feito

- **Mobile (Logo SVG e PNG oficial):**
  - Desenvolvida a logo oficial da aplicação em vetor SVG (`assets/images/app_logo.svg`) contendo o gradiente premium de fundo, o ícone de localização `map-pin` e os brilhos `sparkles` em dourado, replicando fielmente o widget `AppLogo` de login.
  - Convertido o SVG para uma imagem de alta resolução em PNG (`1024x1024` pixels) em `assets/images/app_logo.png` para uso como origem dos launchers.
- **Mobile (Geração de Ícones Launcher):**
  - Adicionado e configurado o pacote `flutter_launcher_icons` no `pubspec.yaml` sob `dev_dependencies` e criado o arquivo de configuração de build `flutter_launcher_icons.yaml`.
  - Executado o gerador de ícones para as plataformas Android e Web (gerando automaticamente todos os mipmaps adaptativos e ícones da web), mantendo o iOS desligado devido à estrutura de pastas do repositório.
- **Mobile (Nome Oficial do Aplicativo - Vistor AI):**
  - Renomeado o label do aplicativo para "Vistor AI" no manifesto do Android (`android/app/src/main/AndroidManifest.xml`).
  - Atualizado o título da aplicação, tag meta e descrição no arquivo web `index.html` e também no manifesto do PWA `manifest.json`, unificando a identidade visual sob a marca comercial.
- **Mobile (Reatividade dos Switches de Preferência):**
  - Declaradas as variáveis de estado locais em `_ProfileScreenState` para representar as preferências do usuário, vinculando-as aos switches da `ProfileScreen` e permitindo que sejam ligados/desligados de forma reativa.
- **Mobile (Melhoria na Inicialização do Mapa):**
  - Refatorada a inicialização do mapa em `MapScreen` para obter ativamente a localização real em tempo real do GPS. A câmera se desloca automaticamente para a posição real do usuário e a busca no cubit é disparada na coordenada exata, exibindo as inspeções locais de imediato.
- **Mobile (Tratamento e Sanitização de Erros Técnicos):**
  - Criada a classe utilitária centralizada `ErrorHandler` (`lib/core/utils/error_handler.dart`) para higienizar exceções locais, erros de tipagem/runtime do Dart (ex: `TypeError`, `FormatException`) e erros do servidor (como problemas de MinIO, S3 ou banco de dados) antes de serem exibidos na interface para o usuário final.
  - Aprimorada a extensão `DioExceptionExtension` no `api_client.dart` para interceptar respostas 500+ e mensagens que contenham palavras-chave técnicas de infraestrutura, mascarando-as de forma automática e amigável.
  - Refatorados todos os Cubits (`UserManagementCubit`, `AdminSettingsCubit`, `CreateInspectionCubit`, `InspectionCubit`, `InspectionDetailCubit`, `TeamManagementCubit` e `ReportCubit`) para utilizarem a rotina do `ErrorHandler` no mapeamento de estados de erro.

### Estado dos arquivos tocados

- `mobile/assets/images/app_logo.svg` — criado.
- `mobile/assets/images/app_logo.png` — criado.
- `mobile/pubspec.yaml` — atualizado.
- `mobile/flutter_launcher_icons.yaml` — criado.
- `mobile/android/app/src/main/AndroidManifest.xml` — atualizado.
- `mobile/web/index.html` — atualizado.
- `mobile/web/manifest.json` — atualizado.
- `mobile/lib/core/utils/error_handler.dart` — criado.
- `mobile/lib/core/api/api_client.dart` — atualizado.
- `mobile/lib/features/auth/domain/user_management_cubit.dart` — atualizado.
- `mobile/lib/features/auth/domain/admin_settings_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/create_inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/inspection_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/inspection_detail_cubit.dart` — atualizado.
- `mobile/lib/features/inspection/domain/team_management_cubit.dart` — atualizado.
- `mobile/lib/features/report/presentation/cubit/report_cubit.dart` — atualizado.

### Validações que passaram

- `flutter analyze` — Sucesso absoluto sem erros estáticos importantes.
- Execução do build do launcher — Geração de assets de launcher finalizada com sucesso.

---
