<h1 align="center">
  Vistor AI
</h1>

<p align="center">
  Plataforma móvel de inspeção técnica de infraestrutura com inteligência artificial e funcionamento offline-first.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white" />
  <img alt="Python" src="https://img.shields.io/badge/Python-3.11-3776AB?style=flat-square&logo=python&logoColor=white" />
  <img alt="FastAPI" src="https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white" />
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL_16-4169E1?style=flat-square&logo=postgresql&logoColor=white" />
  <img alt="Docker" src="https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white" />
</p>

---

> **Status do Projeto:** Em desenvolvimento ativo. Acompanhe o andamento sprint a sprint em [`PROGRESS.md`](./PROGRESS.md).

## Sobre o Projeto

O **Vistor AI** é um sistema voltado para a realização de inspeções técnicas de infraestrutura em campo. Projetado para cenários de alta criticidade (ausência de conectividade, necessidade de agilidade operacional e ambientes hostis), a plataforma permite o registro assíncrono de ocorrências com suporte a mídia (fotos/vídeos) e geolocalização de alta precisão.

O sistema integra modelos de visão computacional para a pré-classificação automática de severidade e um motor geoespacial robusto para monitoramento em tempo real por meio de mapas de calor e análise de proximidade.

## Principais Funcionalidades

- **Offline-First**: Operação integral sem conectividade via banco local (Drift/SQLite) com sincronização automática em segundo plano (SyncManager).
- **Inteligência Artificial**: Processamento de imagens via HuggingFace Inference API (modelo `google/vit-base-patch16-224`) com fallback para execução local via ONNX.
- **Geoprocessamento (PostGIS)**: Validação de precisão de GPS, agrupamento espacial de ocorrências e geração de heatmaps gerenciais.
- **Confiabilidade e Auditoria**: Geração de laudos técnicos em PDF com assinatura de integridade via hash SHA-256 e trilha de auditoria imutável (audit_log).

---

## Arquitetura e Perfis de Acesso

O sistema utiliza RBAC (Role-Based Access Control) para segmentar as operações:

1. **Inspetor (Mobile)**: Foco em coleta de dados em campo, gestão de mídia e validação de classificações sugeridas pela IA.
2. **Gestor (Mobile/Web)**: Monitoramento tático via dashboards geoespaciais, atribuição de vistorias e exportação de dados (GeoJSON/CSV).
3. **Administrador**: Gestão de infraestrutura, calibração de modelos de IA, controle de acesso e auditoria de logs.

---

## Tecnologias Utilizadas

| Camada | Tecnologias e Frameworks |
|---|---|
| **Mobile (Frontend)** | Flutter 3.x, Dart, BLoC/Cubit, Drift (SQLite), Freezed, Dio, flutter_map |
| **Backend (API)** | FastAPI (Python 3.11), Uvicorn, SQLAlchemy 2.0 (Async), Pydantic |
| **Banco de Dados** | PostgreSQL 16, PostGIS 3.4 |
| **Cache e Mensageria** | Redis 7 |
| **Armazenamento S3** | MinIO (Self-hosted) |
| **Processamento de IA** | HuggingFace Inference API, ONNX Runtime |
| **Relatórios e PDF** | WeasyPrint, Jinja2 |
| **Infraestrutura** | Docker, Docker Compose, Alembic (Migrations) |

---

## Como Executar Localmente

### Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- [Fluuter SDK](https://docs.flutter.dev/install/manual)

### 1. Infraestrutura Base

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/vistor-ai.git
cd vistor-ai

# Configure as variáveis de ambiente
cp .env.example .env

# Inicie os serviços de suporte
docker compose up -d
```

### 2. Backend (FastAPI)

```bash
cd backend
cp .env.example .env

# Configuração do ambiente Python
python -m venv venv
source venv/bin/activate  # ou venv\Scripts\activate no Windows
pip install -r requirements.txt

# Execução de migrations e inicialização
alembic upgrade head
uvicorn app.main:app --reload
```

API disponível em: `http://localhost:8000`. Documentação Swagger: `/docs`.

### 3. Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## Documentação de Referência

Para detalhes específicos sobre padrões, fluxos e regras de negócio, consulte:

- [`/GEMINI.md`](./GEMINI.md) — Diretrizes globais e princípios invioláveis.
- [`/docs/backend/GEMINI.md`](./docs/backend/GEMINI.md) — Padrões de Service/Router e convenções Python.
- [`/docs/inspetor/GEMINI.md`](./docs/inspetor/GEMINI.md) — Especificações do módulo de campo.
- [`/docs/gestor/GEMINI.md`](./docs/gestor/GEMINI.md) — Regras de geoprocessamento e dashboard.
- [`/docs/admin/GEMINI.md`](./docs/admin/GEMINI.md) — Protocolos de auditoria e segurança.

___

<p align="center">
  <small>Vistor AI — Sistema de Inspeção Técnica Inteligente</small>
</p>
