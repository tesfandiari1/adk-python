FROM python:3.13-slim

WORKDIR /app

# Copy all files necessary for installation first
COPY pyproject.toml README.md LICENSE ./
COPY src ./src

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir . && \
    # Install optional Node.js for MCP tools
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy remaining files
COPY . .

# Set environment variables
ENV PYTHONPATH=/app

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["adk", "web"] 