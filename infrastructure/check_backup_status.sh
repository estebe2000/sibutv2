#!/bin/bash

# Configuration (Clé SSH)
REMOTE_HOST="172.16.95.98"
REMOTE_PORT="4660"
REMOTE_USER="steeve"
REMOTE_DEST="/srv/tc-data/backups"

echo "==============================================================="
echo "   ÉTAT DES SAUVEGARDES SUR TC-PORTAIL (4 To)"
echo "==============================================================="
echo ""

# Fonction pour exécuter une commande à distance par clé SSH
run_remote() {
    ssh -p $REMOTE_PORT -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "$1"
}

echo "--- 5 DERNIÈRES ARCHIVES ---"
run_remote "ls -lh $REMOTE_DEST | grep backup_full_ | tail -n 5"
echo ""

echo "--- OCCUPATION DISQUE DU DOSSIER BACKUP ---"
run_remote "du -sh $REMOTE_DEST"
echo ""

echo "--- ESPACE DISPONIBLE SUR LA PARTITION 4 TO ---"
run_remote "df -h $REMOTE_DEST | grep -v Filesystem"
echo ""

echo "==============================================================="