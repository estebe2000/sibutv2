import pandas as pd
import unicodedata
import re
import os

def clean_string(s):
    if not isinstance(s, str): return ""
    s = s.strip()
    s = "".join(c for c in unicodedata.normalize('NFD', s) if unicodedata.category(c) != 'Mn')
    s = re.sub(r'[^a-zA-Z0-9.-]', '', s)
    return s

def generate_uid(firstname, lastname):
    f = clean_string(firstname).lower()
    l = clean_string(lastname).lower()
    if not f or not l: return None
    return f"{f}.{l}"

# Load Excel
print("Loading Excel file...")
df = pd.read_excel('/tmp/etudiants.xlsx')
print(f"Excel loaded: {len(df)} rows found.")

# Base Structure
ldif = """dn: ou=People,dc=univ-lehavre,dc=fr
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=univ-lehavre,dc=fr
objectClass: organizationalUnit
ou: Groups

dn: ou=DSA,dc=univ-lehavre,dc=fr
objectClass: organizationalUnit
ou: DSA

dn: cn=ldapbindusr-caucri2,ou=DSA,dc=univ-lehavre,dc=fr
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: ldapbindusr-caucri2
userPassword: Fctldap-8%caucri2_30688
description: Compte de service pour bind LDAP
"""

unique_uids = set()
student_dns = []

# Process Students
print("Processing students...")
for index, row in df.iterrows():
    last = row.get('Nom', row.get('NOM', ''))
    first = row.get('Prénom', row.get('PRENOM', ''))
    email = row.get('Email', row.get('EMAIL', row.get('mail', '')))
    
    uid = generate_uid(first, last)
    if not uid: continue
    
    # Handle duplicate UIDs by adding index
    base_uid = uid
    counter = 1
    while uid in unique_uids:
        uid = f"{base_uid}.{counter}"
        counter += 1
    
    unique_uids.add(uid)
    dn = f"uid={uid},ou=People,dc=univ-lehavre,dc=fr"
    student_dns.append(dn)
    
    ldif += f"""
dn: {dn}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: {uid}
sn: {clean_string(last).upper()}
givenName: {clean_string(first)}
cn: {clean_string(first)} {clean_string(last).upper()}
displayName: {clean_string(first)} {clean_string(last).upper()}
mail: {email}
userPassword: password
uidNumber: {20000 + index}
gidNumber: 5001
homeDirectory: /home/{uid}
"""

print(f"Students processed: {len(student_dns)}")

# Process 10 Teachers
print("Processing teachers...")
teacher_dns = []
for i in range(1, 11):
    uid = f"prof.{i}"
    dn = f"uid={uid},ou=People,dc=univ-lehavre,dc=fr"
    teacher_dns.append(dn)
    ldif += f"""
dn: {dn}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: {uid}
sn: PROFESSEUR{i}
givenName: Prof{i}
cn: Prof{i} PROFESSEUR{i}
displayName: Prof{i} PROFESSEUR{i}
mail: prof.{i}@univ-lehavre.fr
userPassword: password
uidNumber: {30000 + i}
gidNumber: 5002
homeDirectory: /home/{uid}
"""

# Groups with members
ldif += """
dn: cn=etu,ou=Groups,dc=univ-lehavre,dc=fr
objectClass: groupOfNames
cn: etu
"""
for dn in student_dns:
    ldif += f"member: {dn}\n"

ldif += """
dn: cn=prof,ou=Groups,dc=univ-lehavre,dc=fr
objectClass: groupOfNames
cn: prof
"""
for dn in teacher_dns:
    ldif += f"member: {dn}\n"

with open('/tmp/seed_generated.ldif', 'w') as f:
    f.write(ldif)

print(f"LDIF saved to /tmp/seed_generated.ldif. Total lines: {len(ldif.splitlines())}")
