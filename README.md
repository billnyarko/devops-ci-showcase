# DevOps CI Showcase

What this proves: Python service + tests + Docker + Compose + CI + IaC.

## Stack
- FastAPI (`app/main.py`): `/healthz`, `/readyz`, `/api/hello`, `/metrics`
- Metrics: `prometheus_client` Counter + Histogram + middleware
- Tests: `pytest` (`tests/`)
- Docker: multi-stage, non-root, HEALTHCHECK
- CI: `.github/workflows/ci.yml` — lint → test → build → push to GHCR → Trivy scan
- IaC: `infra/main.tf` — Terraform Docker provider example
- Observability: Prometheus (`monitoring/prometheus.yml`) + alerts (`monitoring/alerts.yml`) + Grafana provisioned with dashboard
- K8s: Deployment + Service (`k8s/`, Kustomize) using the GHCR image

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

## Observability
- Grafana (`http://localhost:3000`, admin/admin) auto-loads the **devops-ci-showcase** dashboard: request rate, 5xx %, p50/p95 latency, uptime.
- Prometheus (`http://localhost:9090`) evaluates `monitoring/alerts.yml`: `AppDown` (critical), `HighErrorRate` >5% 5xx, `HighLatencyP95` >1s. Check Alerts page to see state.

## Hardening
- Lint: `ruff check` + `ruff format --check` run in CI (`lint` job) and locally via `.\run.ps1 lint`. Config in `pyproject.toml`.
- Image scan: Trivy scans the pushed image on every `main`/tag push, fails on fixable CRITICAL/HIGH CVEs.
- Pre-commit: `pip install pre-commit; pre-commit install` — runs whitespace/YAML checks + Ruff on every commit.
- Releases: push a tag `git tag v0.2.0; git push origin v0.2.0` and CI publishes `ghcr.io/billnyarko/devops-ci-showcase:0.2.0` (+ `0.2`, `latest` on main, always `sha-<commit>`). Pin the K8s image to a version instead of `:latest` for rollback-able deploys.

## Deploy to Kubernetes (needs a cluster: Docker Desktop K8s, kind, or minikube)
```powershell
kubectl kustomize k8s/          # render locally, no cluster needed
kubectl apply -k k8s/
kubectl rollout status deploy/devops-ci-showcase
kubectl port-forward svc/devops-ci-showcase 8080:80
# open http://localhost:8080/healthz
```

## Portfolio talking points
1. CI gates merges: tests must pass before image builds.
2. Immutable artifact: same image tested locally and in CI.
3. Health/ready probes ready for K8s.
4. Non-root container + healthcheck.
5. IaC makes deploys reproducible.
6. K8s Deployment consumes the exact image CI pushed: code → CI → registry → cluster.
