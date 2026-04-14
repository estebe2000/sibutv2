#!/bin/bash
set -e

echo "☁️ [Nextcloud] Configuration de l'intégration OnlyOffice..."

# Ajout des containers internes et du domaine externe OnlyOffice aux domaines de confiance (règle université)
# Configure Nextcloud to generate external HTTPS URLs for OnlyOffice callbacks
docker exec -u www-data but_tc_nextcloud php occ config:system:set overwritehost --value="nextcloud.educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set overwrite.cli.url --value="https://nextcloud.educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set overwriteprotocol --value="https"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 6 --value="but_tc_onlyoffice"
# Ajout du nom de service Docker interne
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 7 --value="nextcloud"
# Ajout du domaine externe public
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 8 --value="nextcloud.educ-ai.fr"

# Configuration de l'application OnlyOffice
docker exec -u www-data but_tc_nextcloud php occ app:install onlyoffice || echo "L'application onlyoffice est déjà installée"
docker exec -u www-data but_tc_nextcloud php occ app:enable onlyoffice

# Définition des URLs en suivant la règle: DocumentServerInternalUrl pour OnlyOffice
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerUrl --value="https://only-office.educ-ai.fr/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice:80/"
# URL du serveur Nextcloud accessible par OnlyOffice (callback de sauvegarde).
# Utiliser l'URL publique du proxy HTTPS afin que le token d'accès soit transmis.
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice StorageUrl --value="https://nextcloud.educ-ai.fr/"

# Sécurité et autres paramètres
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_secret --value="onlyoffice_secret"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice verify_peer_off --value="true"

echo "✅ Intégration OnlyOffice configurée avec succès dans Nextcloud !"
