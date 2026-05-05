# Vistor AI — Progress

---

## Status das Sprints

| Sprint | Descrição | Status | Concluída em |
|---|---|---|---|
| 0 | Arquivos base (gitignore, env, docs, estrutura) | ✅ Concluído | 27/04/2026 |
| 1 | Docker Compose + Dependências (Task 1.1 a 1.3) | ✅ Concluído | 05/05/2026 |
| 2 | FastAPI esqueleto + health endpoint | ⬜ Pendente | — |
| 3 | Models SQLAlchemy + Migrations Alembic | ⬜ Pendente | — |
| 4 | Autenticação (JWT, refresh, blacklist) | ⬜ Pendente | — |
| 5 | Inspeções CRUD + PostGIS | ⬜ Pendente | — |
| 6 | Mídia — upload/download MinIO | ⬜ Pendente | — |
| 7 | IA (HuggingFace) + PDF (WeasyPrint) | ⬜ Pendente | — |
| 8 | Testes + cobertura ≥ 70% | ⬜ Pendente | — |

### Mobile

| Sprint | Descrição | Status | Concluída em |
|---|---|---|---|
| 9 | Fundação Flutter (tema, router, api client) | ⬜ Pendente | — |
| 10 | Auth + Home + Nova Inspeção | ⬜ Pendente | — |
| 11 | Detalhe de Inspeção + Gerar Laudo | ⬜ Pendente | — |
| 12 | Mapa + Heatmap | ⬜ Pendente | — |
| 13 | Laudos + Perfil + Offline | ⬜ Pendente | — |
| 14 | Gestão de Equipe + Exportar + Usuários | ⬜ Pendente | — |

> Legenda: ⬜ Pendente · 🔄 Em andamento · ✅ Concluído · ⚠️ Bloqueado

---

## Última sessão

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

## Última sessão

**Data:** 29/04/2026
**Sprint:** 1 - Docker Compose + Dependências
**Sessão:** Configuração da Infraestrutura

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

## Última sessão

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

## Última sessão

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