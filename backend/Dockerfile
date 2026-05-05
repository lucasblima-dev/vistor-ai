FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip

# O README.md é necessário pois é referenciado no pyproject.toml
COPY pyproject.toml README.md ./
COPY app ./app

RUN pip install --no-cache-dir .

FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libmagic1 \
    libpango-1.0-0 \
    libharfbuzz0b \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

# user não root 
RUN addgroup --system appgroup && \
    adduser --system --group appuser

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY . .

RUN chown -R appuser:appgroup /app

ARG BUILD_ENV=production
ENV BUILD_ENV=${BUILD_ENV}

# Troca para o usuário não root
USER appuser

EXPOSE 8000

CMD ["sh", "-c", "if [ \"$BUILD_ENV\" = \"development\" ]; then \
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload; \
    else \
    uvicorn app.main:app --host 0.0.0.0 --port 8000; \
    fi"]
