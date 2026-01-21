#!/bin/bash

# --- BMad Deployment Script ---

# 1. Check for .env file
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo "Please create a .env file based on the documentation before deploying."
    exit 1
fi

# 2. Pull latest changes (optional, if in git repo)
# git pull origin main

# 3. Build and restart containers
echo "Starting deployment..."
docker compose up -d --build

# 4. Cleanup old images
docker image prune -f

echo "Deployment complete! Services are starting."
echo "Check logs with: docker compose logs -f"
