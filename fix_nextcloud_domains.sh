#!/bin/bash
set -e

echo "⚠️ Annulation des modifications des domaines de confiance..."

# Suppression des entrées 5 et 6 qui ont causé le problème
docker exec -u www-data but_tc_nextcloud php occ config:system:delete trusted_domains 5 || echo "L'entrée 5 n'existait pas."
docker exec -u www-data but_tc_nextcloud php occ config:system:delete trusted_domains 6 || echo "L'entrée 6 n'existait pas."

# Assurance que les domaines de base sont bien présents
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 0 --value="localhost"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 1 --value="educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 2 --value="nextcloud.educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 3 --value="home.educ-ai.fr"

echo "✅ Le fichier de configuration a été restauré. Veuillez rafraîchir la page."
