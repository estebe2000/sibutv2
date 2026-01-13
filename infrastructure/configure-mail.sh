#!/bin/bash

# Configuration Mail OVH pour Nextcloud
# Usage: ./configure-mail.sh <email_complet> <mot_de_passe>

EMAIL=$1
PASSWORD=$2

if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <email_complet> <mot_de_passe>"
    exit 1
fi

echo "--- Configuration Mail OVH pour Nextcloud ---"

# Set Mail Mode to SMTP
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpmode --value="smtp"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtphost --value="ssl0.ovh.net"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpport --value="465"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpsecure --value="ssl"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpauth --value="true" --type=boolean
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpname --value="$EMAIL"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtppassword --value="$PASSWORD"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_from_address --value="${EMAIL%%@*}"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_domain --value="${EMAIL#*@}"

echo "✅ Configuration Nextcloud terminée."
