FROM python:3.11-slim
WORKDIR /app
RUN pip install flask requests beautifulsoup4 urllib3
COPY app.py .
CMD ["python", "app.py"]
