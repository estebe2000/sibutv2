# Product Requirements Document (PRD)

**Project Name:** BUT TC Skills Tracking Application
**Date:** Wednesday, January 7, 2026
**Version:** 0.3
**Status:** Draft

---

## 1. Goals and Background Context

### 1.1 Goals
*   **Centralize Skills Tracking:** Create a unified platform for tracking student progress across the 3-year BUT curriculum.
*   **Streamline Evaluation:** Enable a seamless 3-way evaluation flow: Student Self-Eval -> Tutor Feedback (Magic Link) -> Professor Validation (0-100% slider).
*   **Ensure Data Sovereignty:** Store all student evidence (multimedia) securely on the IUT Nextcloud instance via API.
*   **Simplify External Access:** Remove authentication barriers for external tutors using a secure "Magic Link" system.
*   **Inclusive & Multi-Device:** Deliver a responsive web interface (PC, Tablet, Smartphone) accessible via a single URL, compliant with WCAG AA standards.
*   **Standardize Curriculum:** Allow admins to deploy and update curriculum templates for student groups.
*   **Multi-Tenancy & White-Labeling:** Enable independent deployment per department (Docker-based) with full customization (Logo, UI colors, welcome messages, contact info).
*   **Extensive Configuration:** Ensure 100% of external dependencies (LDAP, Nextcloud, APIs, Mattermost) are configurable per instance without code changes.
*   **Strong Governance & RBAC:** Implement a rigid responsibility matrix (SAÉ Leads, Internship Leads) to ensure accountability in the evaluation process.
*   **Integrated Collaboration:** Leverage Mattermost for real-time pedagogical exchanges, integrated via API and Nextcloud widgets.
*   **Robust Development Environment:** Provide a full local Docker stack (Nextcloud, LDAP) for realistic testing.

### 1.2 Background Context
The IUT Le Havre is implementing the new BUT curriculum, which mandates a Competency-Based Approach (APC). The proposed solution, "Skills Hub," acts as an orchestration layer, bridging the gap between university infrastructure (LDAP, Nextcloud) and the pedagogical needs of various departments.

---

## 2. Requirements

### 2.1 Functional Requirements (FR)
*   **FR1 - Auth & User Management:** The system must authenticate Students and Professors via university LDAP. Supports specialized roles: SuperAdmin (global), DeptAdmin (local), SAE_Lead, Internship_Lead.
*   **FR2 - Curriculum Templates:** Admins must be able to create, version, and assign curriculum templates to specific student groups.
*   **FR3 - Evidence Upload:** Students must be able to upload multimedia evidence which the system acts as a proxy to store securely on Nextcloud.
*   **FR4 - 3-Way Evaluation:** The system must support a specific workflow: Student Self-Eval -> Tutor Comment/Review -> Professor Validation.
*   **FR5 - Sliding Scale Validation:** Professors must use a 0-100% sliding scale to validate skills.
*   **FR6 - Mobile Dashboard:** Students must have a responsive dashboard showing their progress (e.g., Radar Charts).
*   **FR10 - Multi-Tenant Customization:** Full white-labeling and configuration of all system parameters:
    *   **UI:** Logo, Colors, Welcome Text, Contact.
    *   **Infrastructure:** LDAP URL/BaseDN, Nextcloud WebDAV URL/Credentials, SMTP settings.
    *   **Collaboration:** Mattermost API keys and Channel IDs for notifications.
*   **FR11 - Responsibility Assignment:** Ability to assign specific Professors as "Leads" for specific SAÉs or Internships. Only assigned leads can perform final validation.
*   **FR12 - Repeating Student Management (Capitalization):** Handle students repeating a year, allowing carry-over of previously validated skills via a formal advisor-led interview process.
*   **FR13 - Advanced Reporting:** Generate PDF/CSV reports for Students (individual progress), Groups (cohort level), and Internships.
*   **FR14 - Real-Time Collaboration (Mattermost):** Integration of a communication layer for pedagogical exchanges.

### 2.2 Non-Functional Requirements (NFR)
*   **NFR1 - Data Sovereignty:** 100% of user-uploaded files on Nextcloud.
*   **NFR2 - Accessibility:** WCAG 2.1 AA compliance.
*   **NFR5 - Responsiveness:** Interface must be fully fluid across all screen sizes (PC, Tablet, Smartphone) with no loss of functionality.
*   **NFR8 - Multi-Instance Deployment:** Support for isolated Docker containers sharing the same codebase but different configurations.
*   **NFR9 - Sovereign Collaboration:** All exchange data (Mattermost) must be self-hosted.

---

## 5. Epic List

*   **Epic 1: Foundation, Infrastructure & Branding:** Project setup, multi-tenant config, branding customization, and LDAP auth.
*   **Epic 2: Curriculum & Advanced Governance:** Template management and the Responsibility Matrix (SAÉ/Internship Leads).
*   **Epic 3: Evidence Portfolio & Nextcloud Integration:** Implement student interface for evidence upload and gallery management (Nextcloud).
*   **Epic 4: The Evaluation Cycle (Magic Links & Sliders):** Complete the 3-way evaluation workflow (Student Self-Eval -> Tutor -> Prof).
*   **Epic 5: Visual Analytics & Comprehensive Reporting:** Progress visualizations and specialized reports (Student/Group/Repeating).
*   **Epic 6: Multi-Tenant Expansion (PDF Import):** Enable automated curriculum ingestion from official PDF documents.
*   **Epic 7: Collaborative Ecosystem (Mattermost):** Integration of real-time communication tools.
