#!/bin/bash
set -e

echo "🚀 Starting Local Infrastructure Initialization..."

# 1. LDAP Seeding
echo "🌱 Seeding LDAP..."
# Wait for LDAP to be ready
until docker exec but_tc_ldap ldapsearch -x -H ldap://localhost -b "dc=univ,dc=fr" -D "cn=admin,dc=univ,dc=fr" -w adminpassword > /dev/null 2>&1; do
  echo "Waiting for LDAP..."
  sleep 2
done

# Copy and Import Seed
docker cp infrastructure/local/ldap/seed.ldif but_tc_ldap:/tmp/seed.ldif
docker exec but_tc_ldap ldapadd -x -D "cn=admin,dc=univ,dc=fr" -w adminpassword -f /tmp/seed.ldif || echo "LDAP might already be seeded (ignoring error)"

# 2. Nextcloud Configuration
echo "☁️  Configuring Nextcloud & OnlyOffice..."
# Wait for Nextcloud
until docker exec but_tc_nextcloud php occ status > /dev/null 2>&1; do
  echo "Waiting for Nextcloud..."
  sleep 5
done

# Install OnlyOffice App
docker exec -u www-data but_tc_nextcloud php occ app:install onlyoffice --keep-disabled || echo "OnlyOffice already installed"
docker exec -u www-data but_tc_nextcloud php occ app:enable onlyoffice

# Configure Trusted Domains (Add 'but_tc_nextcloud')
# We check if it exists first to avoid duplicate entries growing infinitely
if ! docker exec -u www-data but_tc_nextcloud php occ config:system:get trusted_domains | grep -q "but_tc_nextcloud"; then
    NEXT_INDEX=$(docker exec -u www-data but_tc_nextcloud php occ config:system:get trusted_domains | wc -l)
    docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains $NEXT_INDEX --value="but_tc_nextcloud"
fi

# Enable Local Remote Servers (Crucial for Docker networking)
docker exec -u www-data but_tc_nextcloud php occ config:system:set allow_local_remote_servers --value=true --type=bool

# Configure OnlyOffice URLs
# Public URL (Browser Access)
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerUrl --value="http://localhost:8083/"
# Internal URL (Container Access)
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://but_tc_onlyoffice/"
# Storage URL (Callback Access)
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice StorageUrl --value="http://but_tc_nextcloud/"
# JWT Security
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_secret --value="onlyoffice_secret"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_header --value="Authorization"

# 3. Service Account & Folders
echo "👤 Creating Service Account..."
# Create User if not exists
if ! docker exec -u www-data but_tc_nextcloud php occ user:info service_account > /dev/null 2>&1; then
    docker exec -u www-data -e OC_PASS="ServiceAccountStrongPass123!" but_tc_nextcloud php occ user:add --password-from-env --display-name="Service Account" service_account
fi

echo "Gd Creating Folder Structure..."
# Create folders via WebDAV
curl -s -X MKCOL -u service_account:"ServiceAccountStrongPass123!" http://localhost:8082/remote.php/dav/files/service_account/BUT-TC-Skills > /dev/null
curl -s -X MKCOL -u service_account:"ServiceAccountStrongPass123!" http://localhost:8082/remote.php/dav/files/service_account/BUT-TC-Skills/2026 > /dev/null

# 4. LDAP Integration
echo "🔗 Configuring Nextcloud LDAP..."
docker exec -u www-data but_tc_nextcloud php occ app:enable user_ldap

# Bruteforce Reset of LDAP Config to ensure clean state
docker exec -u www-data but_tc_nextcloud php occ ldap:delete-config s01 || true
docker exec -u www-data but_tc_nextcloud php occ ldap:create-empty-config

# Configure Connection
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapHost "but_tc_ldap"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapPort 389
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapBase "dc=univ,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentName "cn=admin,dc=univ,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentPassword "adminpassword"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapConfigurationActive 1
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 turnOnPasswordChange 0

# Configure Filters (Login by UID or Email)
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserFilter "(|(objectclass=inetOrgPerson))"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(|(uid=%uid)(mail=%uid)))"

# Configure Attributes
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserDisplayName "displayname"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapEmailAttribute "mail"
# Expert: Use UID as Internal Username (Critical for API provisioning)
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapExpertUsernameAttr "uid"

# 5. Quotas
echo "💾 Setting Quotas..."
# Set Default Quota to 3GB (Applies to all new LDAP users, i.e., Students)
docker exec -u www-data but_tc_nextcloud php occ config:app:set files default_quota --value="3 GB"

# 6. Additional Apps (ToS, Contacts, Mail, Talk, Collectives)
echo "📦 Installing Additional Apps..."
APPS="terms_of_service contacts mail spreed collectives integration_mattermost"
for app in $APPS; do
    docker exec -u www-data but_tc_nextcloud php occ app:install $app --keep-disabled || echo "$app already installed"
    docker exec -u www-data but_tc_nextcloud php occ app:enable $app
done

# Configure Terms of Service
echo "📜 Configuring Terms of Service..."
TOS_TEXT="Bienvenue sur le Skills Hub du BUT TC.\n\nCeci est une plateforme à usage académique. Veuillez utiliser cet outil avec professionnalisme et respect.\nLe stockage de données personnelles sensibles non liées à votre scolarité est interdit.\n\nBonne réussite à tous !"
docker exec -u www-data but_tc_nextcloud php occ config:app:set terms_of_service content --value="$TOS_TEXT"
docker exec -u www-data but_tc_nextcloud php occ config:app:set terms_of_service terms_of_service_enabled --value="1"

# 7. Mail Configuration (SMTP)
echo "📧 Configuring SMTP (Mailpit)..."
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpmode --value="smtp"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_sendmailmode --value="smtp"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtphost --value="mailpit"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_smtpport --value="1025"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_from_address --value="admin"
docker exec -u www-data but_tc_nextcloud php occ config:system:set mail_domain --value="univ.fr"

# 8. Mattermost Configuration & Integration
echo "💬 Configuring Mattermost & Nextcloud Integration..."
# Wait for Mattermost
until docker exec but_tc_mattermost mattermost version > /dev/null 2>&1; do
  echo "Waiting for Mattermost..."
  sleep 5
done

# Configure Nextcloud to point to Mattermost (Using integration_mattermost settings)
docker exec -u www-data but_tc_nextcloud php occ config:app:set integration_mattermost mattermost_url --value="http://localhost:8065"

# 9. Mattermost User & Team Provisioning
echo "👤 Provisioning Mattermost Admin & Team..."
docker exec but_tc_mattermost mmctl user create --email admin@univ.fr --username admin --password "adminpassword" --system-admin --local || echo "Admin already exists"
docker exec but_tc_mattermost mmctl team create --name but-tc --display-name "BUT TC" --local || echo "Team already exists"
docker exec but_tc_mattermost mmctl team users add but-tc admin --local || echo "User already in team"

# 10. Application Seeding
echo "🌱 Seeding Application Database..."
until docker exec but_tc_api python -m app.seed_db; do
  echo "Waiting for API to be ready for seeding..."
  sleep 5
done

echo "✅ Initialization Complete!"
echo "---------------------------------------------------"
echo "LDAP Admin:   http://localhost:8081 (admin/adminpassword)"
echo "Nextcloud:    http://localhost:8082 (admin/adminpassword)"
echo "Mattermost:   http://localhost:8065"
echo "OnlyOffice:   http://localhost:8083 (Healthy)"
echo "Mailpit UI:   http://localhost:8025 (Check Emails)"
echo "---------------------------------------------------"
