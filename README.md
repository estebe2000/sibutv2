# BUT TC Skills Tracking Application - Project Home

## 🎯 Project Overview
**Goal:** Create a unified platform for tracking student progress across the 3-year BUT TC curriculum.
**Key Features:** 3-way evaluation (Student/Tutor/Prof), Data Sovereignty (Nextcloud), Mobile-First UI.
**Stack:** Python (FastAPI), React (Vite/TypeScript), PostgreSQL, Docker.

## 📚 Documentation Index
*   **[Product Requirements (PRD)](docs/prd.md):** Detailed feature breakdown and user stories.
*   **[System Architecture](docs/architecture.md):** Technical design, database schema, and component map.
*   **[Development Guide](docs/development-guide.md):** Standards, workflows, and setup instructions.
*   **[API Contracts](docs/api-contracts.md):** External integration specifics (LDAP, Nextcloud).

## 🚀 Quick Start
*(Note: Project is in initial setup phase)*

```bash
# 1. Clone & Enter
git clone <repo>
cd but-tc-skills

# 2. Start Infrastructure
# Starts DB, LDAP, Nextcloud, and OnlyOffice
npm run infra:up

# 3. Access
# Frontend: http://localhost:3000
# Backend Docs: http://localhost:8000/docs
# Nextcloud: http://localhost:8082 (admin/adminpassword)
# LDAP Admin: http://localhost:8081 (admin/adminpassword)
```

## 🛠 Local Development Infrastructure

The project includes a full Dockerized stack to mimic production services locally.

### Components
*   **PostgreSQL:** `localhost:5432`
*   **OpenLDAP:** `localhost:389` (Seeded with test users)
*   **Nextcloud:** `localhost:8082` (Pre-configured with Service Account)
*   **OnlyOffice:** `localhost:8083` (Linked to Nextcloud)
*   **Mailpit:** `localhost:8025` (SMTP Capture & Web UI)

### Setup Commands
To start the infrastructure and automatically configure it (seed LDAP, link OnlyOffice):

```bash
# Start containers and run init script
npm run infra:up

# Or manually:
docker-compose up -d
./infrastructure/local/init-local.sh
```

### Test Accounts (LDAP)
| Role | User | Password |
| :--- | :--- | :--- |
| **Student** | `s.dupont` | `password` |
| **Student** | `s.martin` | `password` |
| **Professor** | `p.durand` | `password` |

## 🏗 Repository Structure
```text
/
├── apps/
│   ├── api/          # FastAPI Backend
│   └── web/          # React Frontend
├── packages/         # Shared Libraries
├── docs/             # Project Documentation
└── docker-compose.yml
```

## 🤝 Contribution
Please refer to the [Development Guide](docs/development-guide.md) before pushing code.
**Strict Monorepo & TypeScript policies apply.**
