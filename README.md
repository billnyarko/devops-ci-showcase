# DevOps CI Showcase

What this proves: Python service + tests + Docker + Compose + CI + IaC.

## Stack
- FastAPI (`app/main.py`): `/healthz`, `/readyz`, `/api/hello`, `/metrics`
- Metrics: `prometheus_client` Counter + Histogram + middleware
- Tests: `pytest` (`tests/`)
- Docker: multi-stage, non-root, HEALTHCHECK
- CI: `.github/workflows/ci.yml` — test → build → push to GHCR
- IaC: `infra/main.tf` — Terraform Docker provider example
- Observability: Prometheus (`monitoring/prometheus.yml`) + Grafana provisioned

## Run locally
```powershell
pip install -r requirements.txt
pytest -q
docker compose up --build
# app: http://localhost:8000/healthz
# metrics: http://localhost:8000/metrics
# prometheus: http://localhost:9090
# grafana: http://localhost:3000 (admin/admin)
```

## Portfolio talking points
1. CI gates merges: tests must pass before image builds.
2. Immutable artifact: same image tested locally and in CI.
3. Health/ready probes ready for K8s.
4. Non-root container + healthcheck.
5. IaC makes deploys reproducible.
