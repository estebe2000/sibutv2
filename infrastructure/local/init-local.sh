#!/bin/bash
set -e

echo "🚀 Starting Local Infrastructure Initialization..."

# 1. LDAP Seeding
echo "🌱 Seeding LDAP..."
until docker exec but_tc_ldap ldapsearch -x -H ldap://localhost -b "dc=univ,dc=fr" -D "cn=admin,dc=univ,dc=fr" -w Rangetachambre76* > /dev/null 2>&1; do
  echo "Waiting for LDAP..."
  sleep 2
done
docker cp infrastructure/local/ldap/seed.ldif but_tc_ldap:/tmp/seed.ldif
docker exec but_tc_ldap ldapadd -x -D "cn=admin,dc=univ,dc=fr" -w Rangetachambre76* -f /tmp/seed.ldif || echo "LDAP already seeded"

# 2. Nextcloud & OnlyOffice Configuration
echo "☁️  Waiting for Nextcloud..."
until docker exec but_tc_nextcloud php occ status > /dev/null 2>&1; do
  sleep 5
done

echo "⚙️  Configuring Nextcloud Apps & OnlyOffice..."
# Install and Enable OnlyOffice
docker exec -u www-data but_tc_nextcloud php occ app:install onlyoffice || echo "OnlyOffice already installed"
docker exec -u www-data but_tc_nextcloud php occ app:enable onlyoffice

# Configure OnlyOffice URLs
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerUrl --value="http://projet-edu.eu:8083/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://but_tc_onlyoffice/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice StorageUrl --value="http://but_tc_nextcloud/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_secret --value="onlyoffice_secret"

# Install other collaborative apps
APPS="terms_of_service contacts mail spreed collectives integration_mattermost"
for app in $APPS; do
    docker exec -u www-data but_tc_nextcloud php occ app:install $app || echo "$app already installed"
    docker exec -u www-data but_tc_nextcloud php occ app:enable $app
done

# Enable LDAP app and configure connection
docker exec -u www-data but_tc_nextcloud php occ app:enable user_ldap
docker exec -u www-data but_tc_nextcloud php occ ldap:create-empty-config || echo "LDAP config already exists"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapHost "but_tc_ldap"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapPort 389
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapBase "dc=univ,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentName "cn=admin,dc=univ,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentPassword "Rangetachambre76*"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserDisplayName "displayname"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapEmailAttribute "mail"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserFilter "(|(objectclass=inetOrgPerson))"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(|(uid=%uid)(mail=%uid)))"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapExpertUsernameAttr "uid"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapExpertUUIDUserAttr "uid"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapConfigurationActive 1

# 3. Application Database Restoration
echo "🌱 Restoring Application Database..."
docker stop but_tc_api || true
docker exec but_tc_db psql -U app_user postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'skills_db' AND pid <> pg_backend_pid();"
docker exec but_tc_db dropdb -U app_user skills_db || echo "DB did not exist"
docker exec but_tc_db createdb -U app_user skills_db

if [ -f "backup_full_descriptions.sql" ]; then
    echo "💾 Restoring from backup_full_descriptions.sql..."
    docker exec -i but_tc_db psql -U app_user skills_db < backup_full_descriptions.sql
    docker exec but_tc_db psql -U app_user skills_db -c "ALTER TABLE resource ADD COLUMN IF NOT EXISTS responsible VARCHAR DEFAULT '(inconnu)';"
    docker exec but_tc_db psql -U app_user skills_db -c "ALTER TABLE resource ADD COLUMN IF NOT EXISTS contributors VARCHAR DEFAULT '(inconnu)';"
    docker exec but_tc_db psql -U app_user skills_db -c "ALTER TABLE activity ADD COLUMN IF NOT EXISTS responsible VARCHAR DEFAULT '(inconnu)';"
    docker exec but_tc_db psql -U app_user skills_db -c "ALTER TABLE activity ADD COLUMN IF NOT EXISTS contributors VARCHAR DEFAULT '(inconnu)';"
else
    echo "⚠️  No backup found, running basic seeding..."
    docker start but_tc_api
    sleep 5
    docker exec but_tc_api python -m app.seed_db
fi

docker start but_tc_api

# 4. Final settings (Trusted Domains)
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 1 --value="localhost"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 2 --value="projet-edu.eu"
docker exec -u www-data but_tc_nextcloud php occ config:system:set allow_local_remote_servers --value=true --type=bool

echo "✅ Initialization Complete!"
echo "---------------------------------------------------"
echo "Dashboard:  http://projet-edu.eu/"
echo "Skills Hub: http://projet-edu.eu:3000/"
echo "Nextcloud:  http://projet-edu.eu:8082/"
echo "---------------------------------------------------"
