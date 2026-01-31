#!/bin/bash
ADMIN="admin"
PASS="Rangetachambre76*"
HOST="http://localhost:8080"

# 1. Get Token
TOKEN=$(curl -s -d "client_id=admin-cli" -d "username=$ADMIN" -d "password=$PASS" -d "grant_type=password" "$HOST/realms/master/protocol/openid-connect/token" | grep -o '"access_token":"[^" ]*"' | cut -d '"' -f 4)

if [ -z "$TOKEN" ]; then
    echo "Failed to get token"
    exit 1
fi

# 2. Get LDAP ID
LDAP_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "$HOST/admin/realms/but-tc/components?providerId=ldap&parent=but-tc" | grep -o '"id":"[^" ]*"' | head -1 | cut -d '"' -f 4)

echo "LDAP ID: $LDAP_ID"

if [ -z "$LDAP_ID" ]; then
    echo "LDAP component not found."
    exit 1
fi

# 3. Create Mappers function using temp files
create_mapper() {
    NAME=$1
    LDAP_ATTR=$2
    USER_ATTR=$3
    MANDATORY=$4
    
    cat <<EOF > /tmp/mapper_$NAME.json
{
    "name": "$NAME",
    "providerId": "user-attribute-ldap-mapper",
    "providerType": "org.keycloak.storage.ldap.mappers.LDAPStorageMapper",
    "parentId": "$LDAP_ID",
    "config": {
      "ldap.attribute": "$LDAP_ATTR",
      "is.mandatory.in.ldap": "$MANDATORY",
      "user.model.attribute": "$USER_ATTR"
    }
}
EOF

    echo "Creating mapper: $NAME..."
    curl -s -X POST "$HOST/admin/realms/but-tc/components" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d @/tmp/mapper_$NAME.json
    echo ""
}

create_mapper "username-mapper" "uid" "username" "true"
create_mapper "email-mapper" "mail" "email" "false"
create_mapper "first-name-mapper" "givenName" "firstName" "true"
create_mapper "last-name-mapper" "sn" "lastName" "true"
