# Dockerized Google ADK

This document explains how to run Google Agent Development Kit (ADK) in a Docker container.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (optional, for easier management)
- A Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey) or Google Cloud Vertex AI access

## Authentication Setup

ADK requires authentication to access Google's LLM services. You have two options:

### Option 1: Using Google AI Studio (Recommended for Quick Start)

1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a `.env` file in the project root (copy from `.env.example`):

```bash
cp .env.example .env
```

3. Edit the `.env` file and replace `PASTE_YOUR_ACTUAL_API_KEY_HERE` with your actual API key:

```
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=your-actual-api-key
```

### Option 2: Using Google Cloud Vertex AI

1. Set up a [Google Cloud project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
2. Enable the [Vertex AI API](https://cloud.google.com/vertex-ai/docs/start/cloud-environment)
3. Create a `.env` file in the project root (copy from `.env.example`):

```bash
cp .env.example .env
```

4. Edit the `.env` file and configure the Vertex AI settings:

```
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=us-central1
```

## Secure API Key Handling (Best Practices)

When using API keys with Docker containers, follow these security best practices:

1. **Never commit API keys to version control**:
   - Always use `.env` files that are excluded in `.gitignore`
   - Never hardcode API keys in docker-compose.yml or Dockerfile

2. **For local development**:
   - Mount your .env file as a volume (as shown in our docker-compose.yml)
   - Or use the env_file directive (also shown in our configuration)

3. **For production deployments**:
   - Use Docker secrets or Kubernetes secrets
   - Use environment variables injected by your CI/CD system
   - For Cloud Run, use the `--set-secrets` flag as shown in the deployment section

## Building and Running the Container

### Using Docker

1. Build the Docker image:

```bash
docker build -t google-adk .
```

2. Run the container:

```bash
docker run -p 8000:8000 -v $(pwd)/.env:/app/.env google-adk
```

The ADK web interface will be available at http://localhost:8000.

### Using Docker Compose (Recommended)

1. Start the services:

```bash
docker-compose up
```

This will build the image if it doesn't exist and start the container. The ADK web interface will be available at http://localhost:8000.

2. To run in detached mode:

```bash
docker-compose up -d
```

3. To stop the services:

```bash
docker-compose down
```

## Development Mode

The Docker Compose configuration includes volume mounts for the `src` and `contributing/samples` directories. This allows you to make changes to the source code without rebuilding the container.

## Customizing the Container

### Running a specific agent

To run a specific agent, you can override the default command:

```bash
docker run -p 8000:8000 -v $(pwd)/.env:/app/.env google-adk adk web --agent contributing/samples/hello_world
```

Or with Docker Compose:

```bash
docker-compose run --service-ports adk adk web --agent contributing/samples/hello_world
```

### Using a different port

To use a different port, update the port mapping in the `docker-compose.yml` file or specify it when running the container:

```bash
docker run -p 8080:8000 -v $(pwd)/.env:/app/.env google-adk
```

## Deploying to Google Cloud

### Create a Google Artifact Registry repository

```bash
gcloud artifacts repositories create adk-repo \
    --repository-format=docker \
    --location=us-central1 \
    --description="ADK repository"
```

### Build and push the container image

```bash
gcloud builds submit \
    --tag us-central1-docker.pkg.dev/YOUR_PROJECT_ID/adk-repo/adk-agent:latest \
    .
```

### Deploy to Cloud Run

For Cloud Run deployment, you'll need to configure environment variables through the Google Cloud Console or using the following command:

```bash
gcloud run deploy adk-agent \
    --image us-central1-docker.pkg.dev/YOUR_PROJECT_ID/adk-repo/adk-agent:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars="GOOGLE_GENAI_USE_VERTEXAI=TRUE,GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID,GOOGLE_CLOUD_LOCATION=us-central1"
```

If using Google AI Studio, you'll need to set the API key as a secret:

```bash
# Create a secret
gcloud secrets create adk-api-key --data-file=.env

# Use the secret in Cloud Run
gcloud run deploy adk-agent \
    --image us-central1-docker.pkg.dev/YOUR_PROJECT_ID/adk-repo/adk-agent:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-secrets="GOOGLE_API_KEY=adk-api-key:latest"
```

### Deploy to GKE

See the [GKE deployment documentation](https://google.github.io/adk-docs/deploy/gke/) for detailed instructions. 