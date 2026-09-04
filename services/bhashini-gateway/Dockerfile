# Build from services/ root:  docker build -f bhashini-gateway/Dockerfile -t bhashini .
FROM python:3.12-slim
WORKDIR /app

COPY bhashini-gateway/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY shared/ ./shared/
COPY bhashini-gateway/app/ ./app/

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
