#!/bin/bash
set -e

# --- Configuration ---
CAPROVER_SERVER="https://captain.your-domain.com"
APP_NAME_API="skills-api"
APP_NAME_WEB="skills-web"

echo "🚀 Starting CapRover Deployment..."

# Vérification de la CLI CapRover
if ! command -v caprover &> /dev/null; then
    echo "❌ Error: CapRover CLI not found. Please install it with: npm install -g caprover"
    exit 1
fi

# 1. Déploiement du Backend
echo "📦 Deploying API..."
caprover deploy -h $CAPROVER_SERVER -a $APP_NAME_API -d ./infrastructure/caprover/api-captain-definition

# 2. Déploiement du Frontend
echo "📦 Deploying Web Frontend..."
caprover deploy -h $CAPROVER_SERVER -a $APP_NAME_WEB -d ./infrastructure/caprover/web-captain-definition

echo "✅ CapRover Deployment Triggered!"
echo "Check your CapRover dashboard for progress: $CAPROVER_SERVER"
