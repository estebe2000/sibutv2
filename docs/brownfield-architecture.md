# But TC Skills - Brownfield Architecture Document

## Introduction

This document captures the **CURRENT STATE** (As-Is) of the "But TC Skills" project codebase as of January 2026. It serves as a reference for the planned refactoring towards a unified student portal.

### Document Scope

Comprehensive documentation of the entire system, with a focus on:
- Infrastructure (Docker, Network, Services)
- Integration Points (LDAP, Nextcloud, OnlyOffice)
- Frontend Architecture & Technical Debt
- Backend Data Flow

### Change Log

| Date       | Version | Description                 | Author     |
| ---------- | ------- | --------------------------- | ---------- |
| 2026-01-11 | 1.0     | Initial brownfield analysis | Architect  |

## Quick Reference - Key Files and Entry Points

### Critical Files

- **Infrastructure**: `docker-compose.yml` (Service orchestration)
- **Frontend Entry**: `apps/web/src/App.tsx` (Main Routing & Layout)
- **Frontend Logic**: `apps/web/src/views/CompetencyEditor.tsx` (Core business logic, high complexity)
- **API Entry**: `apps/api/app/main.py` (FastAPI entry point)
- **Routing**: `apps/dashboard/nginx.conf` (Current Gateway configuration)

## High Level Architecture

### Technical Summary

The project is a **Service-Oriented Architecture** orchestrated via Docker Compose. It combines a custom developed Skills Hub (FastAPI/React) with off-the-shelf open-source platforms (Nextcloud, Mattermost, OnlyOffice, OpenLDAP).

### Actual Tech Stack

| Category      | Technology       | Version | Notes                                |
| ------------- | ---------------- | ------- | ------------------------------------ |
| **Frontend**  | React (Vite)     | 19.x    | Uses Mantine UI, Zustand, Tailwind   |
| **Backend**   | Python (FastAPI) | Latest  | Uses SQLModel, Pandas, ReportLab     |
| **Database**  | PostgreSQL       | 15      | Main DB for Skills & Mattermost      |
| **Auth**      | OpenLDAP         | Osixia  | Currently mocks University LDAP      |
| **Storage**   | Nextcloud        | Stable  | Apache image, currently on **SQLite**|
| **Office**    | OnlyOffice       | Latest  | Integrated via JWT                   |
| **Gateway**   | Nginx            | Latest  | Currently static file server only    |

## Repository Structure Reality Check

- **Type**: Monorepo (Apps + Infrastructure in one repo)
- **Package Manager**: NPM (Frontend), PIP (Backend)
- **Notable**: Infrastructure configuration is mixed between `infrastructure/` folder and `docker-compose.yml` root.

### Project Structure (Actual)

```text
project-root/
├── apps/
│   ├── api/             # FastAPI Backend
│   │   ├── app/         # Application code
│   │   └── requirements.txt
│   ├── web/             # React Frontend
│   │   ├── src/
│   │   │   ├── views/   # Page components (Heavy logic here)
│   │   │   ├── store/   # Zustand stores
│   │   │   └── App.tsx  # Main router
│   │   └── package.json
│   └── dashboard/       # Nginx Gateway (Incomplete)
│       └── nginx.conf   # Static config, missing proxy rules
├── infrastructure/      # Config files for services
│   ├── local/           # Local dev setup scripts
│   └── caprover/        # Deployment configs
├── docker-compose.yml   # Main orchestrator
└── .bmad-core/          # Project Management methodology
```

## Technical Debt and Known Issues

### 🔴 Critical Technical Debt

1.  **Dashboard / Gateway Routing**:
    - `apps/dashboard/nginx.conf` serves only static files.
    - **Issue**: Services (Nextcloud, Mattermost) are accessed via different ports (8082, 8065) instead of a unified domain/path strategy. This breaks the "Unified Portal" experience.

2.  **Frontend Monoliths**:
    - `apps/web/src/views/CompetencyEditor.tsx` (>600 lines) contains UI, API calls, and complex state logic mixed together.
    - **Risk**: Hard to maintain, test, or refactor.

3.  **Nextcloud Configuration**:
    - Running on **SQLite** (`SQLITE_DATABASE=nextcloud` in docker-compose).
    - **Risk**: Performance bottlenecks and locking issues in production. Must migrate to Postgres/MySQL.

4.  **API URL Hardcoding**:
    - Frontend relies on `window.location.hostname` sniffing to guess API URL.
    - **Fix**: Should use Environment Variables (`VITE_API_URL`) injected at build/runtime.

### ⚠️ Integration Fragility

- **OnlyOffice / Nextcloud**:
    - Integration relies on `extra_hosts` (`projet-edu.eu:host-gateway`) to loopback Docker networking.
    - Known issues with "Integration Error" often stem from Mixed Content (HTTP vs HTTPS) or unreachable internal URLs.

## Data Models and Flows

### Database (PostgreSQL)
- **Skills DB**: `but_tc_db` (User: app_user)
- **Mattermost DB**: `but_tc_db_mattermost` (User: mmuser)

### Authentication Flow (Current)
1.  **LDAP** is the source of truth (mocked).
2.  **API** connects to LDAP via `ldap3`.
3.  **Frontend** sends creds to API -> API validates vs LDAP -> Returns Token.
4.  **Nextcloud/Mattermost** have their own auth (currently separate, target is SSO).

## Infrastructure & Deployment

### Local Development
- Command: `npm run infra:up` (Wraps docker-compose + init scripts).
- Services exposed on localhost ports (3000, 8000, 8081, 8082, etc.).

### "Isolated" Server Deployment
- Constraint: Server has Outbound internet but **NO Inbound** (No public IP/DNS).
- **SSL Challenge**: Let's Encrypt HTTP-01 will fail.
- **Solution needed**: DNS-01 Challenge or manual certificate management.

## Refactoring Roadmap (Pre-requisites)

To achieve the "Unified Portal" vision, the following architectural changes are required:

1.  **Gateway Unification**:
    - Transform `apps/dashboard` into a true Reverse Proxy (Traefik or Nginx).
    - Map paths (`/nextcloud`, `/mattermost`, `/api`) to internal containers.

2.  **SSO Implementation**:
    - Centralize Auth. When user logs into Dashboard, they should be authenticated for all services (CAS or OAuth2).

3.  **Frontend Decomposition**:
    - Split `CompetencyEditor` into functional atoms (Data Fetcher, UI Presenter, State Manager).
    - Move API logic to a dedicated Service Layer or Custom Hooks.
