#!/bin/bash
set -e

KC_ADMIN_USER=${KEYCLOAK_ADMIN:-admin}
KC_ADMIN_PASS=${KEYCLOAK_ADMIN_PASSWORD:-Rangetachambre76*}
KC_URL="http://localhost:8080/auth"

echo "🔑 Initializing Keycloak Configuration..."

# Wait for Keycloak to be ready
until docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh config credentials --server $KC_URL --realm master --user $KC_ADMIN_USER --password "$KC_ADMIN_PASS" > /dev/null 2>&1; do
  echo "Waiting for Keycloak API..."
  sleep 5
done

# 1. Disable SSL for Master Realm
echo "🔓 Disabling SSL for Master realm..."
docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE

# 2. Create BUT-TC Realm if not exists
if ! docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh get realms/but-tc > /dev/null 2>&1; then
    echo "🌍 Creating BUT-TC realm..."
    docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh create realms -s realm=but-tc -s enabled=true -s sslRequired=NONE
else
    echo "BUT-TC realm already exists, ensuring SSL is disabled..."
    docker exec but_tc_keycloak /opt/api/bin/kcadm.sh update realms/but-tc -s sslRequired=NONE || true
fi

# 3. Configure LDAP Federation
echo "🔌 Configuring LDAP Federation..."
LDAP_ID=$(docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh get components -r but-tc --query name=univ-lehavre-ldap --fields id --format csv | tail -n 1 | tr -d '"')

if [ -z "$LDAP_ID" ]; then
    echo "Creating LDAP component..."
    docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh create components -r but-tc -s name=univ-lehavre-ldap -s providerId=ldap -s providerType=org.keycloak.storage.UserStorageProvider -s 'config={
      "editMode": ["READ_ONLY"],
      "host": ["ldap://but-tc-ldap:389"],
      "usernameLDAPAttribute": ["uid"],
      "rdnLDAPAttribute": ["uid"],
      "uuidLDAPAttribute": ["entryUUID"],
      "userObjectClasses": ["inetOrgPerson"],
      "usersDn": ["ou=People,dc=univ-lehavre,dc=fr"],
      "bindDn": ["cn=admin,dc=univ-lehavre,dc=fr"],
      "bindCredential": ["Rangetachambre76*"],
      "connectionUrl": ["ldap://but-tc-ldap:389"],
      "vendor": ["other"],
      "useTruststoreSpi": ["ldapsOnly"],
      "priority": ["0"],
      "batchSizeForSync": ["1000"],
      "fullSyncPeriod": ["-1"],
      "changedSyncPeriod": ["-1"],
      "cachePolicy": ["DEFAULT"]
    }'
    LDAP_ID=$(docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh get components -r but-tc --query name=univ-lehavre-ldap --fields id --format csv | tail -n 1 | tr -d '"')
fi

# 4. Trigger Full Sync
echo "🔄 Triggering LDAP User Sync..."
docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh create "user-storage/$LDAP_ID/sync?action=triggerFullSync" -r but-tc

echo "✅ Keycloak Initialization Complete!"
