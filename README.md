# BUT TC Skills Tracking Application - Project Home

## 🎯 Project Overview
**Goal:** Create a unified platform for tracking student progress across the 3-year BUT curriculum, designed for multi-department deployment.
**Key Features:** 
*   **Multi-Tenancy & Branding:** Independent deployments with custom identity (Logo, Colors).
*   **Strong Governance:** Responsibility matrix for SAÉ and Internship validation.
*   **3-Way Evaluation:** Seamless flow between Students, Tutors (Magic Links), and Professors.
*   **Data Sovereignty:** 100% secure file storage via IUT Nextcloud proxy.
*   **Repeating Student Management:** Formal "Capitalization" workflow for academic progress.

## 📚 Documentation Index

### 🏁 Getting Started & Strategy
*   **[Product Requirements (PRD)](docs/prd.md):** The core "Source of Truth" for features and goals.
*   **[Functional Roadmap](docs/functional-roadmap.md):** Strategic milestones for product delivery.
*   **[Strategic Refactoring Plan](docs/refactoring-plan.md):** Technical plan to modularize the current codebase.

### 🏗 Architecture & Design
*   **[System Architecture](docs/architecture.md):** Technical design, database schema, and component map.
*   **[Development Guide](docs/development-guide.md):** Standards, workflows, and setup instructions.
*   **[API Contracts](docs/api-contracts.md):** External integration specifics (LDAP, Nextcloud).

### 📋 Planning & Execution (Epics & Stories)
*   **Epic 1: [Foundation, Infrastructure & Branding](docs/epics/epic-1-foundation-branding.md)** ([Detailed Stories](docs/stories/epic-1-stories.md))
*   **Epic 2: [Curriculum & Advanced Governance](docs/epics/epic-2-curriculum-governance.md)** ([Repeating Students Stories](docs/stories/epic-2-repeating-stories.md))
*   **[Brainstorming: Repeating Students Workflow](docs/brainstorming-redoublants-results.md):** Summary of decisions for capitalization.

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
```

## 🛠 Local Development Infrastructure

The project includes a full Dockerized stack to mimic production services locally.

### Components
*   **PostgreSQL:** `localhost:5432`
*   **OpenLDAP:** `localhost:389` (Seeded with test users)
*   **Nextcloud:** `localhost:8082` (Pre-configured with Service Account)
*   **Mailpit:** `localhost:8025` (SMTP Capture & Web UI)

## 🏗 Repository Structure
```text
/
├── apps/
│   ├── api/          # FastAPI Backend (Python)
│   └── web/          # React Frontend (TypeScript + Mantine)
├── docs/             # Comprehensive Documentation
├── infrastructure/   # Local & Production setup scripts
└── docker-compose.yml
```

## 🤝 Contribution
Please refer to the [Development Guide](docs/development-guide.md) before pushing code.
**Strict Monorepo & TypeScript policies apply.**