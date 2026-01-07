# BUT TC Skills Tracking Application - Project Home

## 🎯 Project Overview
**Goal:** Create a unified platform for tracking student progress across the 3-year BUT curriculum, designed for multi-department deployment and collaborative pedagogy.
**Key Features:** 
*   **Multi-Tenancy & Branding:** Independent deployments with custom identity (Logo, Colors).
*   **Extensive Configuration:** 100% of external parameters configurable (LDAP, Nextcloud, Mattermost).
*   **Multi-Device Fluidity:** Optimized for PC, Tablet, and Smartphone (Single URL access).
*   **Strong Governance:** Responsibility matrix for SAÉ and Internship validation.
*   **Collaborative Ecosystem:** Integrated real-time communication via Mattermost.
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
*   **Epic 3: [Portfolio & Nextcloud Integration](docs/epics/epic-3-portfolio-nextcloud.md)**
*   **Epic 4: [The Evaluation Cycle](docs/epics/epic-4-evaluation-cycle.md)**
*   **Epic 5: [Visual Analytics & Reporting](docs/epics/epic-5-analytics-reporting.md)**
*   **Epic 6: [PDF Import (AI)](docs/epics/epic-6-pdf-import.md)**
*   **Epic 7: [Mattermost Integration](docs/epics/epic-7-mattermost-integration.md)**
*   **[Brainstorming: Repeating Students Workflow](docs/brainstorming-redoublants-results.md):** Summary of decisions for capitalization.

## 🚀 Quick Start
The project is now fully containerized for a seamless development experience.

```bash
# 1. Clone & Enter
git clone <repo>
cd but-tc-skills

# 2. Start Everything (Infra + App + Seeding)
# This command builds the app, starts all services, and populates the DB.
npm run infra:up

# 3. Access
# Frontend (Web): http://localhost:3000
# Backend API:   http://localhost:8000/docs
# Mattermost:    http://localhost:8065
# Nextcloud:     http://localhost:8082
# Mailpit UI:    http://localhost:8025
```

## 🛠 Local Development Infrastructure

The project includes a full Dockerized stack mimicking production.

### Components
*   **Application (Web & API):** React + FastAPI containerized.
*   **PostgreSQL:** `localhost:5432` (Main DB) & Mattermost DB.
*   **OpenLDAP:** `localhost:389` (Seeded with test users).
*   **Nextcloud:** `localhost:8082` (WebDAV proxy storage).
*   **Mattermost:** `localhost:8065` (Collaborative hub).
*   **Mailpit:** `localhost:8025` (SMTP Capture).

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