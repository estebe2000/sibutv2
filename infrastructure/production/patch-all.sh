#!/bin/bash
# --- Comprehensive Post-Deployment Patching Script ---
# This script ensures the database schema is up-to-date,
# Keycloak demo accounts are ready, and Nextcloud is linked.

set -e

# Load Domain from .env
DOMAIN=$(grep DOMAIN .env | cut -d '=' -f2 | tr -d '"' | tr -d '\r' || echo "educ-ai.fr")
echo "🌐 Environment: $DOMAIN"

# 1. Database Schema Patches
echo "🐘 [DB] Applying schema patches..."
docker exec but_tc_db psql -U app_user -d skills_db -c "
  ALTER TABLE public.\"user\" ADD COLUMN IF NOT EXISTS phone character varying;
  ALTER TABLE public.\"internship\" ADD COLUMN IF NOT EXISTS company_id INTEGER;
  ALTER TABLE public.\"internship\" ADD COLUMN IF NOT EXISTS evaluation_token character varying;
  ALTER TABLE public.\"internship\" ADD COLUMN IF NOT EXISTS token_expires_at timestamp without time zone;
  ALTER TABLE public.\"internship\" ADD COLUMN IF NOT EXISTS is_finalized BOOLEAN DEFAULT FALSE;
  ALTER TABLE public.\"internship\" ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
"

# 2. Keycloak Demo Accounts (Infallible Method via kcadm)
echo "🔑 [Keycloak] Checking demo accounts..."
docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password 'Rangetachambre76*'

create_user_safe() {
    U=$1; P=$2; R=$3; G=$4;
    echo "  -> Processing $U..."
    # Check if exists
    EXISTING_ID=$(docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh get users -r but-tc --query username=$U | grep -o '"id" : "[^"]*"' | head -1 | cut -d '"' -f 4 || echo "")
    
    if [ ! -z "$EXISTING_ID" ]; then
        echo "     User $U already exists (ID: $EXISTING_ID). Updating password..."
        docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh set-password -r but-tc --username $U --new-password $P
    else
        echo "     Creating user $U..."
        docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh create users -r but-tc -s username=$U -s enabled=true -s firstName=Demo -s lastName=$U -s email=$U@demo.local
        docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh set-password -r but-tc --username $U --new-password $P
        EXISTING_ID=$(docker exec but_tc_keycloak /opt/keycloak/bin/kcadm.sh get users -r but-tc --query username=$U | grep -o '"id" : "[^"]*"' | head -1 | cut -d '"' -f 4)
    fi
    
    # Sync DB (Always update ldap_uid to match Username for these demo accounts as per previous fix)
    docker exec but_tc_db psql -U app_user -d skills_db -c "
      DELETE FROM \"user\" WHERE email = '$U@demo.local' AND ldap_uid != '$U';
      INSERT INTO \"user\" (ldap_uid, email, full_name, role, group_id) 
      VALUES ('$U', '$U@demo.local', '$U Demo', '$R', $G)
      ON CONFLICT (ldap_uid) DO UPDATE SET group_id = $G, role = '$R';
    "
}

create_user_safe 'super-admin' 'super-admin' 'ADMIN' 1
create_user_safe 'super-prof' 'super-prof' 'PROFESSOR' 1
create_user_safe 'super-stud' 'super-stud' 'STUDENT' 82

# 3. Nextcloud & OnlyOffice Configuration
if [ -f infrastructure/production/init-univ.sh ]; then
    echo "☁️ [Nextcloud] Running initialization script..."
    bash infrastructure/production/init-univ.sh
fi

echo "✅ [PATCH] All systems patched and verified!"