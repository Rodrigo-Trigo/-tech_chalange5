# --- Estágio 1: build (instala dependências) ---
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# --- Estágio 2: imagem final (enxuta) ---
FROM python:3.11-slim

WORKDIR /app

# cria o usuário não-root ANTES de copiar qualquer coisa
RUN useradd -m appuser

# copia as dependências já instaladas, já transferindo a posse para appuser
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

ENV PATH=/home/appuser/.local/bin:$PATH

USER appuser

EXPOSE 8083

CMD ["gunicorn", "--bind", "0.0.0.0:8083", "app:app"]