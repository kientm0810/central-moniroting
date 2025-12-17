FROM python:3.12-slim

WORKDIR /app
RUN pip install flask

COPY app.py .

EXPOSE 3000
CMD ["python", "app.py"]
