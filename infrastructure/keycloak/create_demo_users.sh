#!/bin/bash
ADMIN_USER="admin"
ADMIN_PASS="Rangetachambre76*"
HOST="http://localhost:8080"
REALM="but-tc"

# 1. Get Token
TOKEN=$(curl -s -d "client_id=admin-cli" -d "username=$ADMIN_USER" -d "password=$ADMIN_PASS" -d "grant_type=password" "$HOST/realms/master/protocol/openid-connect/token" | grep -o '"access_token":"[^"”]*"' | cut -d '"' -f 4)

if [ -z "$TOKEN" ]; then echo "Failed to get token"; exit 1; fi

create_role() {
    ROLE_NAME=$1
    echo "Creating role: $ROLE_NAME"
    curl -s -X POST "$HOST/admin/realms/$REALM/roles" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"name\": \"$ROLE_NAME\"}"
}

create_user() {
    USERNAME=$1
    PASSWORD=$2
    ROLE_NAME=$3
    EMAIL="$USERNAME@educ-ai.fr"
    
    echo "Creating user: $USERNAME"
    # Create User
    curl -s -X POST "$HOST/admin/realms/$REALM/users" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "{\"username\": \"$USERNAME\", \"email\": \"$EMAIL\", \"enabled\": true, \"emailVerified\": true}"
    
    # Get User ID
    USER_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "$HOST/realms/$REALM/users?username=$USERNAME" | grep -o '"id":"[^"”]*"' | head -1 | cut -d '"' -f 4)
    
    # Set Password
    curl -s -X PUT "$HOST/admin/realms/$REALM/users/$USER_ID/reset-password" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "{\"type\": \"password\", \"value\": \"$PASSWORD\", \"temporary\": false}"
    
    # Get Role representation
    ROLE_REP=$(curl -s -H "Authorization: Bearer $TOKEN" "$HOST/admin/realms/$REALM/roles/$ROLE_NAME")
    
    # Assign Role
    curl -s -X POST "$HOST/admin/realms/$REALM/users/$USER_ID/role-mappings/realm" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "[$ROLE_REP]"
    
    echo "User $USERNAME created and configured with role $ROLE_NAME."
}

# Create Roles
create_role "ADMIN"
create_role "PROFESSOR"
create_role "STUDENT"

# Create Users
create_user "superprof" "superprof" "ADMIN"
create_user "prof" "prof" "PROFESSOR"
create_user "tc" "tc" "STUDENT"

echo "Demo accounts ready."
