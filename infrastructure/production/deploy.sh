#!/bin/bash
set -e

# --- Configuration (A modifier selon le département) ---
REMOTE_HOST=$1
REMOTE_PATH="/opt/but-tc-skills"
ENV_FILE=".env.prod"

if [ -z "$REMOTE_HOST" ]; then
    echo "Usage: ./deploy.sh [user@hostname]"
    exit 1
fi

echo "🚀 Starting Deployment to $REMOTE_HOST..."

# 1. Préparation du répertoire distant
echo "📂 Preparing remote directory..."
ssh $REMOTE_HOST "mkdir -p $REMOTE_PATH"

# 2. Synchronisation des fichiers nécessaires
echo "📦 Syncing files..."
# On n'envoie que le nécessaire pour le déploiement
rsync -avz --exclude 'node_modules' --exclude 'venv' --exclude '.git' \
    ./docker-compose.yml ./apps ./infrastructure ./package.json \
    $REMOTE_HOST:$REMOTE_PATH

# 3. Gestion des variables d'environnement
if [ -f "$ENV_FILE" ]; then
    echo "🔑 Uploading environment variables..."
    scp $ENV_FILE $REMOTE_HOST:$REMOTE_PATH/.env
else
    echo "⚠️  Warning: No $ENV_FILE found. Using default values (not recommended for prod)."
fi

# 4. Lancement de Docker Compose sur le serveur distant
echo "🐋 Starting containers on remote..."
ssh $REMOTE_HOST "cd $REMOTE_PATH && docker-compose down && docker-compose up -d --build"

# 5. Initialisation des services (LDAP, Nextcloud, Seeding)
echo "⚙️  Initializing services (this may take a few minutes)..."
ssh $REMOTE_HOST "cd $REMOTE_PATH && ./infrastructure/local/init-local.sh"

# 6. Vérification finale
echo "✅ Deployment Successful!"
echo "---------------------------------------------------"
echo "Frontend: http://$REMOTE_HOST:3000"
echo "API Docs: http://$REMOTE_HOST:8000/docs"
echo "Nextcloud: http://$REMOTE_HOST:8082"
echo "Mattermost: http://$REMOTE_HOST:8065"
echo "---------------------------------------------------"
