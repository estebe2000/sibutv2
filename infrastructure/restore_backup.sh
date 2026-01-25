#!/bin/bash

# Usage: ./restore_backup.sh <nom_archive.tar.gz>

ARCHIVE=$1

if [ -z "$ARCHIVE" ]; then
    echo "Usage: $0 <nom_archive.tar.gz>"
    echo "Exemple: $0 backup_full_2026-01-25_20-48.tar.gz"
    exit 1
fi

if [ ! -f "$ARCHIVE" ]; then
    echo "Erreur: Fichier $ARCHIVE non trouvé."
    exit 1
fi

read -p "ATTENTION: Cette opération va écraser les données actuelles. Continuer ? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo "--- DÉBUT DE LA RESTAURATION ---"

# 1. Extraction temporaire
echo "Extraction de l'archive..."
mkdir -p /tmp/restore_temp
tar -xzf $ARCHIVE -C /tmp/restore_temp
DATE_DIR=$(ls /tmp/restore_temp)

# 2. Restauration SQL
echo "Injection des bases de données..."
cat /tmp/restore_temp/$DATE_DIR/db/skills_db.sql | docker exec -i but_tc_db psql -U app_user -d skills_db
cat /tmp/restore_temp/$DATE_DIR/db/keycloak.sql | docker exec -i but_tc_db_keycloak psql -U keycloak -d keycloak
cat /tmp/restore_temp/$DATE_DIR/db/odoo.sql | docker exec -i but_tc_db_odoo psql -U odoo -d postgres
cat /tmp/restore_temp/$DATE_DIR/db/mattermost.sql | docker exec -i but_tc_db_mattermost psql -U mmuser -d mattermost

# 3. Restauration des Fichiers
echo "Restauration des fichiers étudiants..."
docker cp /tmp/restore_temp/$DATE_DIR/uploads/. but_tc_api:/app/uploads/

# 4. Nettoyage
rm -rf /tmp/restore_temp

echo "--- RESTAURATION TERMINÉE ---"
echo "Note: Il est recommandé de redémarrer les containers pour rafraîchir les connexions."
