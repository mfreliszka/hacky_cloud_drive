install-deploy:
	poetry config virtualenvs.create false
	poetry install

run:
	uvicorn config.asgi:application --reload

lint:
	ruff check storage tests config
	ruff format --check storage tests config

format:
	ruff format .

rfrontend:
	cd frontend; flutter run -d chrome

bbackend:
	docker build --no-cache -t web .

run-deploy:
	uvicorn --host 0.0.0.0 --port 8000 config.asgi:application

up:
	docker compose up -d

down:
	docker compose down -v

build:
	docker compose build

build_no_cache:
	docker compose build --no-cache
