# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 APP_VERSION=0.1.0
WORKDIR /srv
COPY requirements.txt ./
# Patch OS packages (Trivy gate: fail on fixable CRITICAL/HIGH)
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/* \
  && pip install --no-cache-dir -r requirements.txt
COPY app ./app

# Run as non-root — good DevOps practice
RUN useradd -m appuser && chown -R appuser /srv
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')"
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
