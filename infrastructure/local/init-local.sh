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

# 2. Nextcloud & OnlyOffice (Wait for readiness)
echo "☁️  Waiting for Nextcloud..."
until docker exec but_tc_nextcloud php occ status > /dev/null 2>&1; do
  sleep 5
done

# 3. Application Database Restoration (CRITICAL)
echo "🌱 Restoring Application Database..."
if [ -f "backup_full_descriptions.sql" ]; then
    echo "💾 Detected backup_full_descriptions.sql. Performing clean restoration..."
    
    # Stop API to release DB locks
    docker stop but_tc_api
    
    # Drop and recreate DB for a clean import
    docker exec but_tc_db dropdb -U app_user skills_db || echo "DB did not exist"
    docker exec but_tc_db createdb -U app_user skills_db
    
    # Import SQL
    docker exec -i but_tc_db psql -U app_user skills_db < backup_full_descriptions.sql
    
    # Restart API
    docker start but_tc_api
    echo "✅ Database restored successfully."
else
    echo "⚠️  No backup found, running basic seeding..."
    docker exec but_tc_api python -m app.seed_db
fi

# 4. Final readiness check
echo "✅ Initialization Complete!"
echo "---------------------------------------------------"
echo "Frontend: http://localhost:3000"
echo "API:      http://localhost:8000"
echo "---------------------------------------------------"