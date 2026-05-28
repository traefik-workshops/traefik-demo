FROM python:3.11-slim

WORKDIR /app

# Copy service files
COPY base_service.py /app/
COPY *_service.py /app/
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create directories for data and OpenAPI specs
RUN mkdir -p /api /public

# Expose port
EXPOSE 3000

# Default to flights service (can be overridden)
CMD ["python", "flights_service.py"]
