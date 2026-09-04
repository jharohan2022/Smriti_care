# Build from services/ root:  docker build -f identity-service/Dockerfile -t identity .
FROM python:3.12-slim
WORKDIR /app

COPY identity-service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY shared/ ./shared/
COPY identity-service/app/ ./app/

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
