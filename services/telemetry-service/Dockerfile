# Build context is services/telemetry-service; shared/ is copied in via the
# compose build (see note). For a standalone build, build from services/ root:
#   docker build -f telemetry-service/Dockerfile -t telemetry .
FROM python:3.12-slim
WORKDIR /app

COPY telemetry-service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY shared/ ./shared/
COPY telemetry-service/app/ ./app/

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
