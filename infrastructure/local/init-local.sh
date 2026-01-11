#!/bin/bash
set -e

echo "🚀 [Global] Starting Local Infrastructure Initialization..."

# 1. LDAP Seeding
echo "🌱 [LDAP] Seeding data..."
until docker exec but-tc-ldap ldapsearch -x -H ldap://localhost -b "dc=univ-lehavre,dc=fr" -D "cn=admin,dc=univ-lehavre,dc=fr" -w Rangetachambre76* > /dev/null 2>&1; do
  echo "Waiting for LDAP..."
  sleep 2
done
docker cp infrastructure/local/ldap/seed.ldif but-tc-ldap:/tmp/seed.ldif
docker exec but-tc-ldap ldapadd -c -x -D "cn=admin,dc=univ-lehavre,dc=fr" -w Rangetachambre76* -f /tmp/seed.ldif || echo "LDAP partially seeded or entries already exist"

# 2. Nextcloud & OnlyOffice Configuration
echo "☁️ [Nextcloud] Waiting for service..."
until docker exec but_tc_nextcloud php occ status > /dev/null 2>&1; do
  sleep 5
done

echo "⚙️ [Nextcloud] Configuring Apps..."
# Basic Apps
APPS="user_oidc onlyoffice terms_of_service contacts mail spreed collectives integration_mattermost"
for app in $APPS; do
    docker exec -u www-data but_tc_nextcloud php occ app:install $app || echo "$app already installed"
    docker exec -u www-data but_tc_nextcloud php occ app:enable $app
done

# LDAP in Nextcloud
docker exec -u www-data but_tc_nextcloud php occ ldap:create-empty-config || echo "LDAP config exists"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapHost "but-tc-ldap"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapPort 389
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapBase "dc=univ-lehavre,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentName "cn=admin,dc=univ-lehavre,dc=fr"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapAgentPassword "Rangetachambre76*"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUserFilter "(objectClass=inetOrgPerson)"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapLoginFilter "(uid=%uid)"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapUuidUserAttribute "uid"
docker exec -u www-data but_tc_nextcloud php occ ldap:set-config s01 ldapConfigurationActive 1

# OIDC in Nextcloud
echo "🔑 [Nextcloud] Configuring OIDC Provider..."
docker exec -u www-data but_tc_nextcloud php occ user_oidc:provider \
  --clientid=nextcloud-app \
  --clientsecret=nextcloud_secret_sso \
  --discoveryuri=https://keycloak.educ-ai.fr/realms/but-tc/.well-known/openid-configuration \
  --mapping-uid=preferred_username \
  Keycloak || true
docker exec -u www-data but_tc_nextcloud php occ config:app:set user_oidc auto_redirect --value="1"

# OnlyOffice in Nextcloud
echo "📄 [Nextcloud] Linking OnlyOffice..."
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerUrl --value="https://only-office.educ-ai.fr/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://but_tc_onlyoffice/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice StorageUrl --value="http://but_tc_nextcloud/"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice jwt_secret --value="onlyoffice_secret"
docker exec -u www-data but_tc_nextcloud php occ config:app:set onlyoffice verify_peer_off --value="true"

# Trusted Domains & Proxies
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 1 --value="localhost"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 2 --value="educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 3 --value="nextcloud.educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_domains 4 --value="home.educ-ai.fr"
docker exec -u www-data but_tc_nextcloud php occ config:system:set trusted_proxies 0 --value="172.16.0.0/12"
docker exec -u www-data but_tc_nextcloud php occ config:system:set overwriteprotocol --value="https"

# 3. Mattermost
echo "💬 [Mattermost] Initializing Admin..."
bash -c "until docker exec but_tc_mattermost mmctl --local system version > /dev/null 2>&1; do sleep 5; done"
if ! docker exec but_tc_mattermost mmctl --local user search admin@projet-edu.eu > /dev/null 2>&1; then
    docker exec but_tc_mattermost mmctl --local user create --email admin@projet-edu.eu --username admin --password "Rangetachambre76*" --system-admin
    docker exec but_tc_mattermost mmctl --local team create --name but-tc --display-name "BUT TC"
    docker exec but_tc_mattermost mmctl --local team add but-tc admin@projet-edu.eu
fi

# 4. Keycloak Specific Config
bash infrastructure/local/keycloak/init-keycloak.sh

echo "✅ [Global] All systems initialized and unified!"
echo "---------------------------------------------------"
echo "Portal:    https://home.educ-ai.fr"
echo "Nextcloud: https://nextcloud.educ-ai.fr"
echo "Keycloak:  https://keycloak.educ-ai.fr"
echo "---------------------------------------------------"