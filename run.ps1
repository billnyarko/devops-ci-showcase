param([string]$Task = "help")

$ProjectRoot = $PSScriptRoot

function Install-Deps { python -m pip install -r "$ProjectRoot\requirements.txt" }
function Invoke-Lint { python -m ruff check .; python -m ruff format --check . }
function Invoke-Tests { python -m pytest -q }
function Start-App { python -m uvicorn app.main:app --reload --port 8000 }
function Build-Image { docker build -t devops-ci-showcase:local $ProjectRoot }
function Up-Compose { docker compose -f "$ProjectRoot\docker-compose.yml" up --build }
function Init-Tf { terraform -chdir="$ProjectRoot\infra" init }

switch ($Task) {
  "install" { Install-Deps }
  "lint" { Invoke-Lint }
  "test" { Invoke-Tests }
  "run" { Start-App }
  "build" { Build-Image }
  "compose-up" { Up-Compose }
  "tf-init" { Init-Tf }
  default {
    Write-Output "Usage: .\run.ps1 <install|lint|test|run|build|compose-up|tf-init>"
  }
}
