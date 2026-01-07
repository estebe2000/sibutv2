# Development Guide

## 1. Workflow & Standards

### 1.1 Branching Strategy
*   **Main Branch:** `main` (Production-ready).
*   **Feature Branches:** `feature/epic-number-description` (e.g., `feature/epic1-scaffolding`).
*   **Bug Fixes:** `fix/bug-description`.

### 1.2 Commit Messages (Conventional Commits)
*   `feat: add login endpoint`
*   `fix: resolve nextcloud timeout`
*   `docs: update architecture diagram`
*   `refactor: simplify evaluation service`

---

## 2. Coding Standards (Strict)

### 2.1 General
*   **English Only:** Code, comments, commit messages.
*   **No Magic Numbers:** Use constants or config variables.
*   **Linting:** Pre-commit hooks must pass (`black` for Python, `eslint` for JS).

### 2.2 Frontend (React/TypeScript)
*   **Strict Mode:** `strict: true` in `tsconfig.json`. No `any` types allowed.
*   **Functional Components:** Use React Hooks only. No class components.
*   **State Management:**
    *   Server State: `TanStack Query` (mandatory for API data).
    *   Global UI State: `Zustand` (if needed).
    *   Form State: `React Hook Form` + `Zod` validation.
*   **Styling:** CSS-in-JS or Utility-first (Tailwind/Mantine). No global CSS files.

### 2.3 Backend (FastAPI/Python)
*   **Type Hints:** 100% coverage required. Use `Pydantic` for everything.
*   **Service Layer Pattern:**
    *   ❌ **Bad:** Logic in Routes (`@app.get(...)`).
    *   ✅ **Good:** Routes call `EvaluationService.process(...)`.
*   **Async/Await:** All I/O bound operations (DB, Nextcloud) must be `async`.

---

## 3. Testing Strategy

### 3.1 Requirements
*   **Backend:** `pytest`. Min 80% coverage for business logic.
*   **Frontend:** `vitest`. Test complex hooks and utilities. Component tests for core flows.
*   **E2E:** `Playwright` for "Happy Paths" (Login -> Upload -> Validate).

### 3.2 Running Tests
```bash
# Backend
docker-compose exec api pytest

# Frontend
cd apps/web && npm test
```

---

## 4. Environment Setup

### 4.1 Prerequisites
*   Docker & Docker Compose
*   Node.js 18+
*   Python 3.11+

### 4.2 Local Config (`.env`)
Copy `.env.example` to `.env`. Required keys:
```ini
DATABASE_URL=postgresql://user:pass@db:5432/skills_db
NEXTCLOUD_URL=https://ncloud.iut.fr
NEXTCLOUD_USER=service_account
NEXTCLOUD_PASS=secret
LDAP_SERVER=ldap://ldap.univ.fr
```
