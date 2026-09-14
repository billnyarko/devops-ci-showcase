from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import os
import time

START_TIME = time.time()
VERSION = os.getenv("APP_VERSION", "0.1.0")

app = FastAPI(title="devops-ci-showcase")

REQUEST_COUNT = Counter("http_requests_total", "Total requests", ["method", "path", "status"])
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "Latency", ["path"])


@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    elapsed = time.time() - start
    # Avoid high-cardinality paths; normalize to route template if available
    path = request.scope.get("route").path if request.scope.get("route") else request.url.path
    REQUEST_COUNT.labels(request.method, path, str(response.status_code)).inc()
    REQUEST_LATENCY.labels(path).observe(elapsed)
    return response


@app.get("/healthz")
def healthz():
    return {"status": "ok", "version": VERSION}


@app.get("/readyz")
def readyz():
    # Real projects check DB / downstream here.
    return {"ready": True}


@app.get("/api/hello")
def hello(name: str = "world"):
    return {"message": f"hello {name}", "version": VERSION}


@app.get("/metrics-app")
def metrics_app():
    uptime = round(time.time() - START_TIME, 2)
    return JSONResponse({"uptime_seconds": uptime, "version": VERSION})


@app.get("/metrics")
def metrics():
    # Prometheus scrape endpoint — text format, not JSON
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
