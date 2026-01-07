# BUT TC Skills Tracking Application - Fullstack Architecture

**Date:** Tuesday, January 6, 2026
**Version:** 1.1
**Status:** Draft
**Author:** Winston (Architect Agent)

---

## 1. Introduction

This document outlines the complete fullstack architecture for the **BUT TC Skills Tracking Application**, including backend systems, frontend implementation, and their integration. It serves as the single source of truth for AI-driven development, ensuring consistency across the entire technology stack.

This architecture is designed to meet the core goals of centralizing skills tracking, streamlining evaluations (Student -> Tutor -> Professor), and ensuring data sovereignty via Nextcloud integration.

### 1.1 Change Log
| Date | Version | Description | Author |
| :--- | :--- | :--- | :--- |
| 2026-01-06 | 1.1 | Added PDF Ingestion & Local Dev Infrastructure | Winston |
| 2026-01-06 | 1.0 | Initial Architecture based on PRD v0.1 | Winston |

---

## 2. High Level Architecture

### 2.1 Technical Summary
The system follows a **Monolithic Architecture** (Modular Monolith) logic within a **Monorepo** structure, deployed as containerized services on **CapRover**. The frontend is a Single Page Application (SPA) built with **React** (TypeScript) interacting with a **FastAPI** (Python) backend via RESTful APIs.

Key integration points include:
*   **Authentication:** JWT-based session management bridging University LDAP (for internal users) and specialized "Magic Links" (for external tutors).
*   **Storage:** A stateless backend proxying file uploads directly to the IUT's **Nextcloud** instance via WebDAV, ensuring strict data sovereignty.
*   **Curriculum Ingestion:** A specialized service to parse official PDFs and extract structured data (Competencies, SAÉs) for rapid multi-tenant deployment.
*   **Database:** PostgreSQL serving as the relational backbone for user data, curriculum structures, and evaluations.

### 2.2 Platform and Infrastructure
*   **Platform:** Self-Hosted PaaS (**CapRover**)
*   **Key Services:**
    *   **App Service:** Docker container running FastAPI + React (served via Nginx or similar).
    *   **Database:** PostgreSQL Container.
    *   **External Storage:** IUT Nextcloud (connected via WebDAV API).
    *   **SMTP:** External SMTP server for Magic Links.
*   **Local Development Infrastructure:**
    *   **Mock LDAP:** OpenLDAP container with test seeds.
    *   **Mock Nextcloud:** Nextcloud AIO container for local file testing.
*   **Deployment:** Docker-based deployment managed via `docker-compose.yml` for local dev and CapRover for production.

### 2.3 Repository Structure
We will use a **Monorepo** approach to keep frontend and backend in sync, especially for shared types and rapid development cycles.

*   **Structure:** Turborepo (or simple npm workspaces if preferred, but Turbo is recommended for speed).
*   **Package Organization:**
    *   `apps/web`: React Frontend
    *   `apps/api`: FastAPI Backend
    *   `packages/shared`: Shared TypeScript interfaces (generated from Pydantic models or manually synced).

### 2.4 High Level Architecture Diagram

```mermaid
graph TD
    User[User (Student/Prof)] -->|HTTPS| Nginx[Nginx / CapRover Router]
    ExtTutor[External Tutor] -->|Magic Link| Nginx
    Admin[Admin] -->|PDF Upload| Nginx

    subgraph "Docker Application Container"
        Nginx -->|Static Assets| ReactApp[React Frontend SPA]
        Nginx -->|API Requests| FastAPI[FastAPI Backend]
        
        subgraph "Backend Services"
            FastAPI --> AuthSvc[Auth Service]
            FastAPI --> PDFSvc[PDF Parser Service]
            FastAPI --> EvalSvc[Evaluation Service]
        end
    end
    
    subgraph "Data Layer"
        FastAPI -->|SQL| DB[(PostgreSQL)]
    end
    
    subgraph "External Integrations"
        AuthSvc -->|LDAP| LDAP[University LDAP / Mock LDAP]
        EvalSvc -->|WebDAV| Nextcloud[IUT Nextcloud / Mock Nextcloud]
        EvalSvc -->|SMTP| MailServer[SMTP Server]
    end
```

### 2.5 Architectural Patterns
-   **REST API:** Standard resource-oriented API for clear separation of concerns.
-   **Repository Pattern (Backend):** Decouple business logic from database access (SQLAlchemy/SQLModel).
-   **Component-Based UI (Frontend):** Atomic Design principles using React functional components.
-   **Service Layer (Backend):** Encapsulate business logic (e.g., `EvaluationService`, `CurriculumService`) separate from HTTP transport.
-   **Proxy Pattern:** Backend acts as a secure proxy for Nextcloud files, never storing them locally.
-   **Adapter Pattern:** For PDF Ingestion to allow swapping the parsing engine (Regex vs LLM) without changing the core service.

---

## 3. Tech Stack

| Category | Technology | Version | Purpose | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **Frontend Language** | TypeScript | 5.x | Type Safety | Critical for maintainability in large curriculums. |
| **Frontend Framework** | React | 18.x | UI Library | Robust ecosystem, component reusability. |
| **Build Tool** | Vite | Latest | Bundler | Extremely fast HMR and build times. |
| **UI Library** | Mantine or MUI | Latest | Components | Accessible (WCAG AA) pre-built components. |
| **State Management** | TanStack Query | Latest | Server State | Best-in-class for async API state management. |
| **Backend Language** | Python | 3.11+ | Server Logic | Required for FastAPI; great for data processing (PDF). |
| **Backend Framework** | FastAPI | Latest | API Framework | High performance, auto-documentation (Swagger). |
| **PDF Processing** | PyMuPDF / LangChain | - | Ingestion | Extract text/structure from PDFs. |
| **Database** | PostgreSQL | 15+ | Relational DB | Robust, supports complex relationships (Curriculum). |
| **ORM** | SQLModel / SQLAlchemy | Latest | Data Access | Pythonic DB interaction, seamless Pydantic integration. |
| **Authentication** | OAuth2 / JWT | - | Security | Stateless auth, standard for SPA + API. |
| **File Storage** | Nextcloud (WebDAV) | - | Data Sovereignty | Mandatory requirement (NFR1). |
| **Containerization** | Docker | - | Deployment | CapRover compatibility. |
| **Testing** | Pytest (BE) / Vitest (FE) | - | QA | Industry standards for Python/JS. |

---

## 4. Data Models

### 4.1 User
*   **Purpose:** Represents any actor in the system.
*   **Key Attributes:** `id`, `ldap_uid` (Immutable link to LDAP), `email`, `full_name`, `role` (Managed Locally: STUDENT, PROF, ADMIN, GUEST), `group_id` (Managed Locally).
*   **Note:** The `role` and `group_id` are NOT synchronized from LDAP attributes due to data quality issues. They are mastered by the application.

### 4.2 Group (Promotion)
*   **Purpose:** A cohort of students (e.g., "TC1 2026").
*   **Key Attributes:** `id`, `name`, `year`, `template_id` (Linked Curriculum).

### 4.3 CurriculumTemplate
*   **Purpose:** Defines the structure of a specific academic program.
*   **Key Attributes:** `id`, `name`, `version`, `is_published`, `source_pdf_hash` (for tracking origin).
*   **Relationships:** HasMany `Competencies`.

### 4.4 Competency & SAE
*   **Purpose:** The atomic units of the curriculum.
*   **Key Attributes:** `id`, `code` (e.g., "C1"), `title`, `description`, `type` (COMPETENCY or SAE), `learning_outcome_ref` (from PDF).

### 4.5 StudentEvaluation
*   **Purpose:** Tracks the state of a specific skill for a specific student.
*   **Key Attributes:** `student_id`, `competency_id`, `status` (NOT_STARTED, PENDING_TUTOR, PENDING_PROF, VALIDATED), `self_eval_level`, `professor_score` (0-100).

### 4.6 EvaluationToken (Magic Link)
*   **Purpose:** Secure access for external tutors.
*   **Key Attributes:** `token_hash`, `expiration`, `associated_evaluation_id`, `tutor_email`, `status` (SENT, USED).

### 4.7 Evidence
*   **Purpose:** Metadata for files stored in Nextcloud.
*   **Key Attributes:** `id`, `student_id`, `nextcloud_path`, `filename`, `mime_type`.

---

## 5. Components

### 5.1 Frontend Components
*   **StudentDashboard:** Radar chart visualization, quick actions.
*   **EvidenceUploader:** Drag-and-drop zone handling file streams.
*   **EvaluationFlow:** Multi-step wizard (Self-eval -> Submit).
*   **TutorView:** Simplified, token-gated view for external feedback.
*   **ProfessorHub:** Data grid with bulk validation tools (Sliders).
*   **PDFImporter:** Admin wizard to upload PDF, review extracted tree, and confirm import.
*   **AdminUserDispatcher:** Drag-and-drop interface. Left: "Unassigned Users" (LDAP search). Right: "Groups/Classes". Actions: Assign Role, Assign Group.

### 5.2 Backend Services
*   **AuthService:** LDAP connection, JWT issuance, Magic Link generation.
*   **NextcloudService:** WebDAV client wrapper for file operations.
*   **CurriculumService:** Tree traversal logic for skills/SAEs.
*   **PDFParserService:**
    *   Input: Raw PDF file.
    *   Logic: Text extraction -> Keyword Heuristics (Regex) OR LLM Extraction -> JSON Tree.
    *   Output: `CurriculumTemplate` Pydantic model.
*   **NotificationService:** SMTP wrapper for sending emails.

---

## 6. API Specification (REST)

The API will follow **OpenAPI 3.0** standards. Auto-generated via FastAPI at `/docs`.

### Key Endpoints
*   `POST /auth/login`: LDAP Auth -> Returns JWT.
*   `POST /auth/magic-link/{token}`: Validate token -> Returns temp session.
*   `GET /me/dashboard`: Aggregated progress data for logged-in student.
*   `POST /evidence/upload`: Streaming upload to Nextcloud.
*   `POST /evaluation/{id}/submit`: Student submission.
*   `POST /evaluation/{id}/feedback`: Tutor feedback (Magic Link protected).
*   `PATCH /evaluation/{id}/validate`: Professor validation (0-100).
*   `POST /admin/curriculum/import-pdf`: Upload PDF -> Returns preview JSON structure.
*   `POST /admin/curriculum/confirm-import`: Save JSON structure to DB as Template.

---

## 7. Security & Performance

### 7.1 Security
*   **Magic Links:** Short-lived (7 days), one-time use preferred (invalidate after submission). Cryptographically secure random tokens.
*   **LDAP:** Read-only bind service account.
*   **File Proxy:** Backend verifies file type (MIME sniffing) before streaming to Nextcloud. No local execution of uploaded files.

### 7.2 Performance
*   **Mobile Uploads:** Chunked uploads if possible, or simple streaming to avoid memory pressure on the server.
*   **Dashboard Loading:** Aggregated SQL queries to fetch full tree status in < 200ms.
*   **PDF Parsing:** Async task (Background Worker) if PDF is large, though sync might suffice for typical 20-page docs.

---

## 8. Development Workflow (Monorepo)

### 8.1 Structure
```text
/
├── apps/
│   ├── api/ (FastAPI)
│   └── web/ (React + Vite)
├── packages/
│   └── shared/ (Types)
├── infrastructure/
│   ├── local/ (Docker Compose overrides)
│   │   ├── ldap/ (LDIF seeds)
│   │   └── nextcloud/ (Config)
│   └── caprover/ (Captain definitions)
├── docker-compose.yml
└── README.md
```

### 8.2 Standard Commands
*   `npm run dev`: Starts both frontend (Vite) and backend (Uvicorn with reload).
*   `npm run infra:up`: Starts DB + Mock LDAP + Mock Nextcloud.
*   `npm run build`: Builds React app and preps Python container.
*   `npm run test`: Runs Pytest and Vitest.

---

## 9. Coding Standards (Critical)

1.  **Strict Typing:** Frontend MUST use defined TypeScript interfaces. Backend MUST use Pydantic models.
2.  **No Logic in Views:** React components should only display data. Logic goes to Custom Hooks or TanStack Query.
3.  **Service Isolation:** API routes in FastAPI should be thin wrappers calling a `Service` class.
4.  **English Only:** Code, comments, and commit messages in English. (User-facing text in French via i18n if needed, though PRD implies French UI).
5.  **Accessibility First:** All input fields MUST have labels. All interactive elements MUST be keyboard accessible.