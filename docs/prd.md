# Product Requirements Document (PRD)

**Project Name:** BUT TC Skills Tracking Application
**Date:** Tuesday, January 6, 2026
**Version:** 0.2
**Status:** Draft

---

## 1. Goals and Background Context

### 1.1 Goals
*   **Centralize Skills Tracking:** Create a unified platform for tracking student progress across the 3-year BUT TC curriculum (Common Core + 5 Pathways).
*   **Streamline Evaluation:** Enable a seamless 3-way evaluation flow: Student Self-Eval -> Tutor Feedback (Magic Link) -> Professor Validation (0-100% slider).
*   **Ensure Data Sovereignty:** Store all student evidence (multimedia) securely on the IUT Nextcloud instance via API.
*   **Simplify External Access:** Remove authentication barriers for external tutors using a secure "Magic Link" system.
*   **Inclusive & Mobile-First:** Deliver a mobile-responsive interface compliant with WCAG AA standards for accessibility.
*   **Standardize Curriculum:** Allow admins to deploy and update curriculum templates for student groups.
*   **Multi-Tenancy & White-Labeling:** Enable independent deployment per department (Docker-based) with full customization (Logo, UI colors, welcome messages, contact info).
*   **Strong Governance & RBAC:** Implement a rigid responsibility matrix (SAÉ Leads, Internship Leads) to ensure accountability in the evaluation process.
*   **Robust Development Environment:** Provide a full local Docker stack (Nextcloud, LDAP) for realistic testing.

### 1.2 Background Context
The IUT Le Havre is implementing the new BUT "Techniques de Commercialisation" curriculum, which mandates a Competency-Based Approach (APC). The current landscape is fragmented, with student evaluations, evidence storage, and tutor feedback scattered across disparate systems. This fragmentation creates administrative friction, "password fatigue" for external tutors, and a lack of a consolidated view of student progress.

The proposed solution, "Skills Hub," addresses these issues by acting as an orchestration layer. It bridges the gap between the rigid LDAP infrastructure and the flexible storage of Nextcloud, providing a modern, accessible interface for all stakeholders. This system is critical for the academic validation of the new curriculum.

### 1.3 Change Log
| Date | Version | Description | Author |
| :--- | :--- | :--- | :--- |
| 2026-01-06 | 0.2 | Added PDF Ingestion & Local Dev Infra | Winston |
| 2026-01-06 | 0.1 | Initial Draft based on Project Brief | John (PM) |

---

## 2. Requirements

### 2.1 Functional Requirements (FR)
*   **FR1 - Auth & User Management:** The system must authenticate Students and Professors via university LDAP. Supports specialized roles: SuperAdmin (global), DeptAdmin (local), SAE_Lead, Internship_Lead.
*   **FR2 - Curriculum Templates:** Admins must be able to create, version, and assign curriculum templates (Skills, SAÉs) to specific student groups.
*   **FR3 - Evidence Upload:** Students must be able to upload multimedia evidence (PDF, Video, Audio) which the system acts as a proxy to store securely on Nextcloud.
*   **FR4 - 3-Way Evaluation:** The system must support a specific workflow: Student Self-Eval -> Tutor Comment/Review -> Professor Validation.
*   **FR5 - Sliding Scale Validation:** Professors must use a 0-100% sliding scale to validate skills, with visual indicators for "Acquired" vs. "In Progress".
*   **FR6 - Mobile Dashboard:** Students must have a mobile-responsive dashboard showing their progress (e.g., Radar Charts) and pending tasks.
*   **FR7 - Group Management:** The system must allow creating custom groups/pathways that may differ from the strict LDAP hierarchy.
*   **FR8 - Notification System:** Users should receive notifications (email/in-app) for pending evaluations or expired magic links.
*   **FR9 - PDF Curriculum Ingestion:** Admins must be able to upload an official "Programme National" PDF, and the system must parse and extract Competencies, SAÉs, and Learning Outcomes to auto-generate a Curriculum Template.
*   **FR10 - Multi-Tenant Customization:** Each deployment must be configurable via Environment Variables or a config file for branding (Logo, Home Page Text, Support Contact).
*   **FR11 - Responsibility Assignment:** Ability to assign specific Professors as "Leads" for specific SAÉs or Internships. Only assigned leads (or admins) can perform the final validation for those items.
*   **FR12 - Repeating Student Management (Capitalization):** The system must handle students repeating a year, allowing them to carry over previously validated skills while starting new attempts for others.
*   **FR13 - Advanced Reporting:** Generate PDF/CSV reports for Students (individual progress), Groups (cohort level), and Internships (tutor/prof summary).

### 2.2 Non-Functional Requirements (NFR)
*   **NFR1 - Data Sovereignty:** 100% of user-uploaded files must be stored on the designated IUT Nextcloud instance, not on the application server.
*   **NFR2 - Accessibility:** The application UI must be compliant with WCAG 2.1 AA standards (High Contrast, Screen Reader compatible).
*   **NFR3 - Performance:** Mobile uploads of evidence (up to 50MB) must complete or fail gracefully within 60 seconds on a standard 4G connection.
*   **NFR4 - Security:** Magic Links must expire after a configurable period (default 7 days) and be one-time use or device-bound if possible.
*   **NFR5 - Responsiveness:** The interface must be fully functional on mobile devices (360px width min) without horizontal scrolling.
*   **NFR6 - Stack:** The backend must be built with Python (FastAPI), frontend with React/Vue, and database with PostgreSQL, containerized for CapRover.
*   **NFR7 - Local Development Parity:** The local development environment must include Dockerized instances of Nextcloud and LDAP (OpenLDAP) pre-seeded with test data (2-3 students, 2-3 profs) to fully simulate the production environment offline.
*   **NFR8 - Multi-Instance Deployment:** The application architecture must support being deployed in multiple isolated Docker containers (one per department) sharing the same codebase but different configurations.

---

## 3. User Interface Design Goals

### 3.1 Overall UX Vision
The "Skills Hub" should feel like a modern personal fitness tracker for education. It needs to be encouraging, clear, and highly visual. The interface must be "Academic but Approachable"—clean lines, sufficient whitespace, and clear typographic hierarchy to reduce cognitive load. For external tutors, the experience must be "Zero Friction": they click a link, see the form, fill it, and leave.

### 3.2 Key Interaction Paradigms
*   **Mobile-First Actions:** Primary actions (Upload Proof, Validate Skill) must be reachable with a thumb (bottom navigation or floating action buttons).
*   **Visual Feedback:** Immediate visual confirmation for uploads (progress bars) and validations (celebratory animations or clear state changes).
*   **Progressive Disclosure:** Complex curriculum details should be hidden by default, revealing deeper levels (SAÉ -> Skill -> Indicators) only upon interaction.
*   **Slider Interactions:** The validation slider should provide haptic feedback (if possible) or snap-to-grid behavior for common increments (25%, 50%, 75%, 100%).

### 3.3 Core Screens and Views
1.  **Student Dashboard:** A visual summary (Radar Chart or Progress Rings) of the 5 pathways, with "Quick Add" buttons for evidence.
2.  **Evidence Gallery:** A media-rich grid view of uploaded proofs, linked to Nextcloud.
3.  **Evaluation Form (Tutor View):** A simplified, focused view accessible via Magic Link, stripped of all non-essential navigation.
4.  **Professor Validation Hub:** A desktop-optimized list view to batch-review student self-evaluations and tutor feedback.
5.  **Curriculum Manager:** An admin interface to build and structure the competence tree, including the **PDF Import Wizard**.

### 3.4 Accessibility
*   **Standard:** WCAG 2.1 AA (Target).
*   **Visual Adaptations:** 
    *   Global toggles for "High Contrast Mode" and "Dyslexia-Friendly Font" (OpenDyslexic).
    *   Support for browser-level zooming and text scaling without breaking layouts.
*   **Auditory & Multimedia Adaptations:**
    *   Media players (Video/Audio) must include speed control (0.5x - 2.0x).
    *   Support for captions/transcripts where available in Nextcloud.
    *   Visual-only alternatives for any system-critical auditory alerts.
*   **Universal Design:** These accessibility features must be available to all user roles, including Professors and Administrators, not just Students.

---

### 3.5 Branding
*   **Style:** Clean, professional, using IUT Le Havre colors (presumably) or a neutral academic palette (Blues/Greys) with distinct accent colors for the 5 pathways.
*   **Tone:** Encouraging, Official, Transparent.

### 3.6 Target Device and Platforms
*   **Primary:** Web Responsive (Mobile-First focus for Students).
*   **Secondary:** Desktop (Rich interaction for Professors/Admins).

---

## 4. Technical Assumptions

### 4.1 Repository Structure: Monorepo
*   **Decision:** A single repository containing both the FastAPI backend and the React/Vue frontend.
*   **Rationale:** Simplifies CI/CD pipelines on CapRover, ensures synchronized deployments, and keeps documentation/assets alongside code.

### 4.2 Service Architecture: Monolith (Decoupled Frontend/Backend)
*   **Decision:** A FastAPI backend acting as a REST/GraphQL API, and a separate SPA (Single Page Application) for the frontend.
*   **Rationale:** Best balance of performance (FastAPI speed) and flexibility. A monolith is easier to manage and deploy on a single CapRover instance compared to microservices, minimizing infrastructure overhead.

### 4.3 Testing Requirements: Full Testing Pyramid
*   **Decision:** Comprehensive unit tests for business logic (FastAPI/Pytest), integration tests for Nextcloud/LDAP API interactions, and critical path E2E tests (e.g., Magic Link flow).
*   **Rationale:** Ensures stability for a long-lived academic project that may be maintained by rotating staff or different developers over time.

### 4.4 Additional Technical Assumptions and Requests
*   **Nextcloud API:** Assumes the university's Nextcloud instance has the necessary APIs enabled and accessible from the app's server environment.
*   **LDAP Auth:** Assumes standard LDAP/OpenLDAP protocols. The application will need a service account to query groups and synchronize memberships.
*   **Email Service:** Requires a reliable SMTP server to send Magic Links without being flagged as spam.
*   **Containerization:** The app must be fully Dockerized, using a `docker-compose.yml` or standard `Dockerfile` compatible with CapRover.
*   **Data Migration:** The system must handle "Capitalization" (repeating students), implying a schema that can transfer progress between academic years/templates.
*   **Local Infrastructure:** The `docker-compose.yml` must include `nextcloud` and `openldap` images for local development, configured to mimic the production environment.

---

## 5. Epic List

*   **Epic 1: Foundation, Infrastructure & Branding:** Project setup, multi-tenant config, branding customization, and LDAP auth.
*   **Epic 2: Curriculum & Advanced Governance:** Template management and the Responsibility Matrix (SAÉ/Internship Leads).
*   **Epic 3: Evidence Portfolio & Nextcloud Integration:** Implement student interface for evidence upload and gallery management (Nextcloud).
*   **Epic 4: The Evaluation Cycle (Magic Links & Sliders):** Complete the 3-way evaluation workflow (Student Self-Eval -> Tutor -> Prof).
*   **Epic 5: Visual Analytics & Comprehensive Reporting:** Progress visualizations and specialized reports (Student/Group/Repeating).
*   **Epic 6: Multi-Tenant Expansion (PDF Import):** Enable automated curriculum ingestion from official PDF documents to support other departments.

---

## 6. Epic Details

### Epic 1: Foundation & Infrastructure
**Goal:** Establish the core project architecture, database schema, and university-wide authentication. This epic ensures the application is deployable on CapRover and accessible to authorized users.

#### Story 1.1: Project Scaffolding & DevOps
*   **As a** developer,
*   **I want** a containerized project structure with a health check,
*   **so that** I can deploy the foundation to CapRover immediately.
    *   **Acceptance Criteria:**
        1.  FastAPI (Backend) and React/Vue (Frontend) scaffolded in a monorepo.
        2.  `docker-compose.yml` configured for local development and CapRover deployment.
        3.  PostgreSQL database connected and a basic migration system (Alembic) initialized.
        4.  `/health` endpoint returns 200 OK.

#### Story 1.2: LDAP Authentication Integration
*   **As a** Student or Professor,
*   **I want** to log in using my university credentials,
*   **so that** I don't have to create a new account.
    *   **Acceptance Criteria:**
        1.  Login page accepts LDAP username/password.
        2.  Backend successfully authenticates against the university LDAP server.
        3.  JWT (JSON Web Token) issued upon successful login for session management.
        4.  Failed logins provide clear, secure error messages.

#### Story 1.3: User Roles & Profile Management (Local Authority)
*   **As a** system,
*   **I want** to decouple authentication (LDAP) from authorization (Roles),
*   **so that** I can assign Student/Professor/Admin roles regardless of the messy LDAP data.
    *   **Acceptance Criteria:**
        1.  LDAP is used ONLY for password verification and fetching Name/Email.
        2.  Roles (Student, Prof, Admin) are stored strictly in the local PostgreSQL database.
        3.  Default role for new users is "Guest" or "Unassigned" until validated by an Admin.

#### Story 1.4: "User Dispatcher" Interface (Classroom Builder)
*   **As a** Admin,
*   **I want** a drag-and-drop interface to organize raw LDAP users into Classes and Parcours,
*   **so that** I can build my promotions manually.
    *   **Acceptance Criteria:**
        1.  **Left Panel:** List of "Unassigned" users imported from LDAP (Searchable).
        2.  **Right Panel:** List of created Groups/Classes (e.g., "TC1 - Marketing").
        3.  **Action:** Drag user from Left to Right to assign Group AND Role (Student).
        4.  **Professors:** Specific toggle to promote a user to "Professor" or "Super Admin".
        5.  **Bulk Actions:** Ability to select multiple users and assign them to a group in one click.

#### Story 1.5: Local Development Environment Setup
*   **As a** developer,
*   **I want** a local Docker environment with Nextcloud and LDAP,
*   **so that** I can test integrations without relying on production servers.
    *   **Acceptance Criteria:**
        1.  `docker-compose.yml` includes an `openldap` service with 2 students and 2 professors pre-seeded.
        2.  `docker-compose.yml` includes a `nextcloud` service reachable via API.
        3.  Scripts provided to reset/seed these environments easily.

---

### Epic 2: Curriculum & Template Management
**Goal:** Provide administrators with the tools to translate the official BUT TC program into a digital format. This epic establishes the competency framework.

#### Story 2.1: Competency & SAÉ Framework Management
*   **As a** Admin,
*   **I want** to define the core Competencies and Learning Situations (SAÉ),
*   **so that** they can be reused across different pathways.
    *   **Acceptance Criteria:**
        1.  CRUD interface for "Competencies" (Title, Code, Description).
        2.  CRUD interface for "SAÉ" (Situation d'Apprentissage et d'Évaluation).
        3.  Ability to link multiple SAÉs to a single Competency.
        4.  Data stored in a relational schema supporting a hierarchical tree structure.

#### Story 2.2: Curriculum Template Builder
*   **As a** Admin,
*   **I want** to create curriculum templates for each of the 5 pathways and 3 levels,
*   **so that** I can standardize the tracking for specific cohorts.
    *   **Acceptance Criteria:**
        1.  Interface to create a "Template" (e.g., "Pathway: Digital Marketing - Level 1").
        2.  Ability to select and add specific Skills/SAÉs to the template.
        3.  Define the official metadata/description for the pathway.
        4.  Preview mode to see the curriculum as a student would.

#### Story 2.3: Template Versioning & Deployment
*   **As a** Admin,
*   **I want** to version my templates and "publish" them,
*   **so that** existing student data isn't corrupted by curriculum changes mid-year.
    *   **Acceptance Criteria:**
        1.  Templates can be in "Draft" or "Published" status.
        2.  Once published, a template is "locked" to prevent accidental deletion of linked student evaluations.
        3.  Ability to duplicate an existing template to create a "v2" for the next academic year.

#### Story 2.4: Group-to-Template Assignment
*   **As a** Admin,
*   **I want** to assign a specific Curriculum Template to a Promotion Group,
*   **so that** students in that group automatically see their required skills.
    *   **Acceptance Criteria:**
        1.  Admin can select a Group and link it to a Published Template.
        2.  System generates individual "Skill Tracking Instances" for every student in the group.
        3.  Validation logic to ensure a group can only have one active template at a time.

---

### Epic 3: Evidence Portfolio & Nextcloud Integration
**Goal:** Enable the core "Portfolio" functionality where students gather proof of their skills. This epic focuses on the seamless (and sovereign) storage of multimedia files.

#### Story 3.1: Nextcloud Proxy Service
*   **As a** Developer,
*   **I want** a secure backend service that handles file uploads to Nextcloud via API,
*   **so that** the application server remains stateless and no student files are stored locally.
    *   **Acceptance Criteria:**
        1.  Backend service implements the Nextcloud WebDAV or OCS API.
        2.  Secure handling of Nextcloud service account credentials.
        3.  Upload function accepts file streams and forwards them to Nextcloud.
        4.  Error handling for timeouts, quota limits, or API failures.

#### Story 3.2: Student Evidence Gallery
*   **As a** Student,
*   **I want** to see a gallery of all my uploaded files (PDFs, Videos),
*   **so that** I can easily reuse them for different skills.
    *   **Acceptance Criteria:**
        1.  Grid view of user's remote Nextcloud files (within a designated app folder).
        2.  Thumbnail generation (or retrieval from Nextcloud) for images/PDFs.
        3.  Ability to delete or rename files (mirrored on Nextcloud).
        4.  "Add New" button triggers the upload flow.

#### Story 3.3: Mobile-Friendly File Upload
*   **As a** Student,
*   **I want** to upload a video or photo directly from my phone's camera roll,
*   **so that** I can capture evidence in the classroom.
    *   **Acceptance Criteria:**
        1.  Responsive upload component supporting drag-and-drop and mobile native file picker.
        2.  Progress bar showing real-time upload status.
        3.  Client-side validation for file types (PDF, MP4, MP3, JPG) and max size (50MB).
        4.  Mobile UI optimized for touch targets (min 44px).

#### Story 3.4: Linking Evidence to Skills
*   **As a** Student,
*   **I want** to attach a specific piece of evidence to a specific SAÉ/Skill,
*   **so that** my tutor knows what to evaluate.
    *   **Acceptance Criteria:**
        1.  "Select Proof" modal accessible from the Skill detail view.
        2.  User can select 1 or more files from their Gallery.
        3.  Database stores the link (URL/ID) between the Skill attempt and the File.
        4.  Visual indicator on the Skill card showing "1 file attached".

---

### Epic 4: The Evaluation Cycle (Magic Links & Sliders)
**Goal:** Close the feedback loop by allowing Tutors and Professors to validate student work. This epic implements the "Zero Friction" access and the nuanced 0-100% evaluation system.

#### Story 4.1: Student Self-Evaluation
*   **As a** Student,
*   **I want** to rate my own level of competence and provide a short reflective comment,
*   **so that** I can initiate the evaluation process.
    *   **Acceptance Criteria:**
        1.  Form allowing students to write a justification/reflection.
        2.  Self-rating selection (e.g., Novice, Intermediate, Advanced).
        3.  Submit button locks the evidence and reflection for tutor review.
        4.  Visual "Pending Tutor Review" status on the skill.

#### Story 4.2: Magic Link Generator & Dispatcher
*   **As a** system,
*   **I want** to generate a secure, time-limited link for an external tutor,
*   **so that** they can access the evaluation form without an account.
    *   **Acceptance Criteria:**
        1.  Mechanism to generate cryptographically secure, unique URLs.
        2.  Configuration for link expiration (e.g., 7 days).
        3.  Automatic email dispatch to the tutor's email address when the student submits.
        4.  Tracking of link status (Sent, Opened, Used, Expired).

#### Story 4.3: Frictionless Tutor Evaluation Form
*   **As a** External Tutor,
*   **I want** to review the student's evidence and provide feedback via a simple link,
*   **so that** I can evaluate them in under 60 seconds.
    *   **Acceptance Criteria:**
        1.  Public route accessible via Magic Link (no LDAP login required).
        2.  Display of Student Name, Evidence (PDF viewer/Video player), and Student Reflection.
        3.  Simplified feedback form: Qualitative comment + "Recommended Level."
        4.  Submission invalidates the Magic Link (one-time use).

#### Story 4.4: Professor Validation Hub (The Slider)
*   **As a** Professor,
*   **I want** to review both student and tutor feedback and set the final validation percentage,
*   **so that** I can officially record their progress.
    *   **Acceptance Criteria:**
        1.  Dashboard showing "Pending Validations" across all assigned groups.
        2.  Comparison view: Student Self-Eval vs. Tutor Feedback.
        3.  **The Slider:** A horizontal input to set the validation from 0-100%.
        4.  "Finalize" button which officially records the competency in the student's record.

---

### Epic 5: Visual Analytics & Accessibility Polish
**Goal:** Provide high-level insights into student progress and ensure the application is inclusive and professionally polished.

#### Story 5.1: Student Progress Visualization (Radar Charts)
*   **As a** Student,
*   **I want** a visual map of my 5 pathways,
*   **so that** I can see at a glance which competencies are acquired and which need work.
    *   **Acceptance Criteria:**
        1.  Interactive Radar Chart (or similar visualization) showing progress across the 5 main pathways.
        2.  Drill-down capability: Clicking a pathway segment reveals the specific skills/SAÉs within it.
        3.  Color-coding based on the Professor's 0-100% validation.
        4.  Dashboard is fully responsive and optimized for mobile screens.

#### Story 5.2: Professor Cohort Analytics
*   **As a** Professor,
*   **I want** to see a progress overview for an entire group,
*   **so that** I can identify students who are falling behind.
    *   **Acceptance Criteria:**
        1.  Heatmap or list view of a Promotion Group showing average validation percentages across competencies.
        2.  Filters to sort by "Most At Risk" or "Ready for Validation."
        3.  Export functionality (CSV/Excel) for administrative reporting.

#### Story 5.3: Inclusive Design & Accessibility Implementation
*   **As a** User (Student, Professor, or Tutor) with specific needs,
*   **I want** to customize the interface and media playback,
*   **so that** I can access information and evaluate work effectively regardless of visual or auditory impairments.
    *   **Acceptance Criteria:**
        1.  Global settings for "High Contrast Mode", "Dyslexia-Friendly Font", and "Increased Line Spacing" accessible to all roles.
        2.  Full keyboard navigation support (Focus states, Tab order) and ARIA labels for screen readers.
        3.  Multimedia player supports variable playback speed and visual indicators for audio levels.
        4.  Visual alerts/notifications to complement or replace any critical auditory signals.
        5.  Passed accessibility audit for WCAG 2.1 AA compliance.

#### Story 5.4: Career Passport (Basic PDF Export)
*   **As a** Student,
*   **I want** to export a summary of my validated skills,
*   **so that** I can share it with potential employers or for my graduation file.
    *   **Acceptance Criteria:**
        1.  "Generate Passport" button on the student dashboard.
        2.  PDF generation containing the student's name, validated competencies (%), and selected evidence titles.
        3.  Branded with IUT Le Havre logo and official BUT TC metadata.

---

### Epic 6: Multi-Tenant Expansion (PDF Import)
**Goal:** Enable the rapid deployment of the solution to other departments by automating the curriculum setup process via PDF ingestion.

#### Story 6.1: PDF Curriculum Parsing
*   **As a** Admin,
*   **I want** to upload an official "Programme National" PDF,
*   **so that** the system automatically extracts the structure (Competencies, Critical Learnings, SAÉs).
    *   **Acceptance Criteria:**
        1.  Drag-and-drop upload for PDF documents.
        2.  Backend service (Python/LLM) that parses the PDF text.
        3.  Heuristic extraction of key entities: "Compétence", "Apprentissage Critique" (AC), "SAÉ", "Attendu".
        4.  Presentation of a "Review & Import" screen where the Admin can verify the extracted tree before saving.

#### Story 6.2: Internship Requirements Extractor
*   **As a** Admin,
*   **I want** the system to specifically identify internship learning goals from the PDF,
*   **so that** I can automatically generate evaluation forms for internship tutors.
    *   **Acceptance Criteria:**
        1.  Specific parsing rules for "Stage" or "Période en Entreprise" sections.
        2.  Creation of specific "Stage" SAÉs in the database with these requirements attached.

---

## 8. Checklist Results Report

### Executive Summary
The PRD is **95% complete** and **Ready for Architecture**. The scope is tightly focused on the MVP ("Skills Hub"), with clear boundaries around what is built vs. what is out of scope. The technical constraints (Nextcloud/LDAP/CapRover) are well-defined, and the user stories are vertically sliced to deliver value incrementally.

### Category Analysis
| Category | Status | Critical Issues |
| :--- | :--- | :--- |
| **1. Problem Definition** | **PASS** | None. Context is clear. |
| **2. MVP Scope** | **PASS** | Tightly scoped. Capitalization logic is the only complex edge case. |
| **3. UX Requirements** | **PASS** | Mobile-first and Accessibility goals are explicit. |
| **4. Functional Reqs** | **PASS** | Clear FRs for all key user flows. |
| **5. Non-Functional Reqs** | **PASS** | Sovereignty and Performance constraints are solid. |
| **6. Epic Structure** | **PASS** | Logical progression from infra to features. |
| **7. Technical Guidance** | **PASS** | Monorepo/FastAPI decision is documented. |
| **8. Cross-Functional** | **PASS** | Nextcloud API integration is the key dependency. |
| **9. Clarity** | **PASS** | Document is readable and structured. |

### Top Issues & Recommendations
1.  **Capitalization Logic (High):** The schema design for handling repeating students (Capitalization) is mentioned but will require careful architectural thought. *Recommendation: Flag this for the Architect.*
2.  **Magic Link Security (Medium):** The specific implementation (JWT vs. Database token) is left open. *Recommendation: Architect to define.*

### Final Decision
**READY FOR ARCHITECT.** The document provides a solid foundation for the engineering phase.

---

## 9. Next Steps

### 9.1 UX Expert Prompt
"Using the PRD for the BUT TC Skills Tracking Application, design a mobile-first, universally accessible (WCAG 2.1 AA) interface. Focus on the 'Student' dashboard (Radar Charts) and the 'External Tutor' evaluation screen. Crucially, the interface must provide visual and auditory adaptations (Contrast, Dyslexia-fonts, Speed control for media) available to all roles, including Professors. Create a style guide that is 'Academic but Approachable' and ensures all primary actions are thumb-friendly."

### 9.2 Architect Prompt
"Using the PRD for the BUT TC Skills Tracking Application, design a Monolith architecture using FastAPI and React/Vue within a Monorepo. Key constraints: Data Sovereignty (Files must go to Nextcloud via API), LDAP Authentication, and Dockerization for CapRover. Prioritize the database schema to handle the 'Capitalization' of student progress across years and the flexible assignment of templates to groups."