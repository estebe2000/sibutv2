#!/bin/bash

# Configuration (Sécurisée par clé SSH)
BACKUP_DIR="/tmp/skills_hub_backups"
REMOTE_HOST="172.16.95.98"
REMOTE_PORT="4660"
REMOTE_USER="steeve"
REMOTE_DEST="/srv/tc-data/backups"
DATE=$(date +%Y-%m-%d_%H-%M)

echo "--- DÉBUT DE LA SAUVEGARDE SKILLS HUB ($DATE) ---"

# 1. Création des dossiers locaux
mkdir -p $BACKUP_DIR/$DATE/db

# 2. Sauvegarde des Bases de Données (Postgres)
echo "Extraction des bases de données..."
docker exec but_tc_db pg_dump -U app_user skills_db > $BACKUP_DIR/$DATE/db/skills_db.sql
docker exec but_tc_db_keycloak pg_dump -U keycloak keycloak > $BACKUP_DIR/$DATE/db/keycloak.sql
docker exec but_tc_db_odoo pg_dump -U odoo postgres > $BACKUP_DIR/$DATE/db/odoo.sql
docker exec but_tc_db_mattermost pg_dump -U mmuser mattermost > $BACKUP_DIR/$DATE/db/mattermost.sql

# 3. Sauvegarde des Fichiers (Preuves Portfolio)
echo "Collecte des fichiers étudiants..."
mkdir -p $BACKUP_DIR/$DATE/uploads
docker cp but_tc_api:/app/uploads $BACKUP_DIR/$DATE/uploads/

# 4. Compression du pack
echo "Compression de l'archive..."
cd $BACKUP_DIR
tar -czf backup_full_$DATE.tar.gz $DATE
rm -rf $DATE

# 5. Transfert vers le serveur tc-portail (4 To) via Clé SSH
echo "Transfert sécurisé vers tc-portail..."
rsync -avz -e "ssh -p $REMOTE_PORT -o StrictHostKeyChecking=no" backup_full_$DATE.tar.gz $REMOTE_USER@$REMOTE_HOST:$REMOTE_DEST/

# 6. RÉTENTION SUR LE SERVEUR DE SAUVEGARDE (5 ANS)
echo "Nettoyage des archives de plus de 5 ans sur tc-portail..."
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "find $REMOTE_DEST -name 'backup_full_*.tar.gz' -mtime +1825 -delete"

# 7. Nettoyage local
echo "Nettoyage local (uniquement le dernier conservé)..."
find $BACKUP_DIR -name "*.tar.gz" -mtime +1 -delete

echo "--- OPÉRATION TERMINÉE ---"
