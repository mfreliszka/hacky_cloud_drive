# Use a Python image with poetry preinstalled
FROM pfeiffermax/python-poetry:1.14.0-poetry1.8.5-python3.11.11-slim-bookworm

RUN apt-get update && apt-get install -y make

# Set working directory
WORKDIR /src


COPY poetry.lock pyproject.toml /src/
COPY Makefile /src/

RUN make install-deploy

COPY . /src/

# Expose port 8000
EXPOSE 8000

CMD ["make", "run-deploy"]

