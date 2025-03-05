run:
	uvicorn config.asgi:application --reload

lint:
	ruff check storage tests config
	ruff format --check storage tests config

format:
	ruff format .

rfrontend:
	cd frontend; flutter run -d chrome