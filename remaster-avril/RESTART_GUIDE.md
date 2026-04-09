# Guide de Reprise : Remaster Skills Hub (Avril 2026)

## 1. État des Lieux
Le projet est situé dans `/remaster-avril`. 
L'infrastructure Docker est opérationnelle avec les services suivants :
- **PostgreSQL 15** (Bases `skills_db` et `keycloak` séparées).
- **Keycloak 26** (Connecté avec succès au LDAP `ldap.univ-lehavre.fr`).
- **FastAPI Backend** (Avec route `/api/v1/auth/me` pour les profils).
- **React 19 Frontend** (Service `skills-web-v2` sur le port 3000).

## 2. Accès de Test
Les trois comptes suivants sont configurés avec le mot de passe : `Rangetachambre76*`
1.  **Admin :** `admin-iutlh`
2.  **Enseignant :** `prof-iutlh`
3.  **Élève :** `eleve-iutlh` (ou votre compte LDAP `pytels`)

## 3. Le problème du "Cache Fantôme"
Si vous voyez le même tableau de bord pour tous les comptes demain matin, suivez cette procédure de nettoyage radicale :

### A. Nettoyage Docker
```bash
cd remaster-avril
docker compose down
# Supprimer les conteneurs orphelins et les images de build
docker container prune -f
docker image rm remaster-avril-skills-web-v2
```

### B. Relance Propre
```bash
docker compose up -d --build
# Attendre 30s que Keycloak et Vite finissent
```

### C. Nettoyage Navigateur (Crucial)
Vite et Docker Desktop sur Mac peuvent garder des fichiers en cache.
1.  Ouvrir **Chrome en Navigation Privée**.
2.  Aller sur `http://localhost:3000`.
3.  Si besoin, faire `Cmd + Shift + R`.

## 4. Prochaines Étapes Techniques
1.  **Valider les couleurs :** Une fois que vous voyez les fonds Rouge (Admin), Bleu (Prof) et Violet (Élève), on pourra supprimer ces tests et remettre le design "Bento Grid" poli.
2.  **Persistance DB :** Actuellement, le rôle est simulé par l'API. Il faudra coder la création automatique dans la table `User` lors du premier login.
3.  **Données Réelles :** Connecter les composants du Dashboard aux données du référentiel (déjà seedées dans Postgres).

## 5. Rappel Configuration LDAP (Valide)
- **URL :** `ldap://ldap.univ-lehavre.fr:389`
- **Bind DN :** `cn=ldapbindusr-caucri2,ou=DSA,dc=univ-lehavre,dc=fr`
- **Search Base :** `dc=univ-lehavre,dc=fr`
- **Mapper :** `uid` -> `username`
