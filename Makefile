install:
	pip install -r requirements.txt

test:
	pytest -q

run:
	uvicorn app.main:app --reload --port 8000

build:
	docker build -t devops-ci-showcase:local .

compose-up:
	docker compose up --build

tf-init:
	terraform -chdir=infra init
