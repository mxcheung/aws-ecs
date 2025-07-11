FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy source
COPY . /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port for ECS
EXPOSE 80

# Run the Flask app
CMD ["python", "app.py"]
