#!/bin/bash
set -e

echo "🚀 Starting Local Infrastructure Initialization (Hybrid Mode)..."

# 1. LDAP Seeding
echo "🌱 Seeding LDAP..."
until docker exec but-tc-ldap ldapsearch -x -H ldap://localhost -b "dc=univ-lehavre,dc=fr" -D "cn=admin,dc=univ-lehavre,dc=fr" -w Rangetachambre76* > /dev/null 2>&1; do
  echo "Waiting for LDAP..."
  sleep 2
done
docker cp infrastructure/local/ldap/seed.ldif but-tc-ldap:/tmp/seed.ldif
docker exec but-tc-ldap ldapadd -x -D "cn=admin,dc=univ-lehavre,dc=fr" -w Rangetachambre76* -f /tmp/seed.ldif || echo "LDAP already seeded"

# 2. Nextcloud & OnlyOffice Configuration
echo "☁️  Waiting for Nextcloud..."
until docker exec but_tc_nextcloud php occ status > /dev/null 2>&1; do
  sleep 5
done

echo "⚙️  Configuring Nextcloud Apps & OnlyOffice..."
# Install and Enable OnlyOffice
docker exec -u www-data but_tc_nextcloud php occ app:install onlyoffice || echo "OnlyOffice already installed"
docker exec -u www-data but_tc_nextcloud php occ app:enable onlyoffice

# Configure OnlyOffice URLs (DIRECT ACCESS MODE)
# We use the PUBLIC host URL with PORT 8083 for browser access
# We use INTERNAL container URL for Server-to-Server communication (if possible) or Public IP
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerUrl --value="http://projet-edu.eu:8083/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://but_tc_onlyoffice/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice StorageUrl --value="http://but-tc-ldap/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_secret --value="onlyoffice_secret"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_header --value="Authorization"

# Install other collaborative apps
APPS="terms_of_service contacts mail spreed collectives integration_mattermost"
for app in $APPS; do
    docker exec -u www-data but_tc_nextcloud php occ app:install $app || echo "$app already installed"
    docker exec -u www-data but_tc_nextcloud php occ app:enable $app
done

# Mattermost Admin User Creation
echo "💬 Configuring Mattermost Admin..."
until docker exec but_tc_mattermost mmctl --local system version > /dev/null 2>&1; do
  echo "Waiting for Mattermost..."
  sleep 5
done

# Check if admin exists, if not create it
if ! docker exec but_tc_mattermost mmctl --local user search admin@projet-edu.eu > /dev/null 2>&1; then
    echo "Creating Mattermost Admin user..."
    docker exec but_tc_mattermost mmctl --local user create --email admin@projet-edu.eu --username admin --password "Rangetachambre76*" --system-admin
else
    echo "Mattermost Admin already exists"
fi

# Create Team if not exists
if ! docker exec but_tc_mattermost mmctl --local team search but-tc > /dev/null 2>&1; then
    echo "Creating Mattermost Team..."
    docker exec but_tc_mattermost mmctl --local team create --name but-tc --display-name "BUT Techniques de Commercialisation"
    docker exec but_tc_mattermost mmctl --local team add but-tc admin@projet-edu.eu
else
    echo "Mattermost Team already exists"
fi

# Enable LDAP app and configure connection
docker exec -u www-data but_tc_nextcloud php occ app:enable user_ldap
docker exec -u www-data but_tc_nextcloud php occ ldap:create-empty-config || echo "LDAP config already exists"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapHost "but-tc-ldap"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapPort 389
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapBase "dc=univ-lehavre,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentName "cn=admin,dc=univ-lehavre,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentPassword "Rangetachambre76*"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserDisplayName "displayname"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapEmailAttribute "mail"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserFilter "(&(uid=%uid)(objectClass=posixAccount))"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapLoginFilter "(&(uid=%uid)(objectClass=posixAccount))"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapGroupFilter "(&(objectClass=groupOfNames)(member=%dn))"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapExpertUsernameAttr "uid"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapExpertUUIDUserAttr "uid"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapConfigurationActive 1

# 3. Application Database Restoration
echo "🌱 Restoring Application Database..."
# docker exec but_tc_api python -m app.seed_db

# 4. Final settings (Clean up overwrites for Direct Access)
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 1 --value="localhost"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 2 --value="projet-edu.eu"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 3 --value="but_tc_nextcloud"

# Clean up Overwrites from previous attempts
docker exec -u www-data but_tc_nextcloud php occ config:system:delete overwrite.cli.url || true
docker exec -u www-data but_tc_nextcloud php occ config:system:delete overwritehost || true
docker exec -u www-data but_tc_nextcloud php occ config:system:delete overwriteprotocol || true
docker exec -u www-data but_tc_nextcloud php occ config:system:delete overwritewebroot || true

echo "✅ Initialization Complete!"
echo "---------------------------------------------------"
echo "Dashboard:  https://projet-edu.eu/"
echo "Skills Hub: https://projet-edu.eu/app/"
echo "Nextcloud:  http://projet-edu.eu:8082/"
echo "OnlyOffice: http://projet-edu.eu:8083/"
echo "---------------------------------------------------"
bash infrastructure/local/keycloak/init-keycloak.sh
