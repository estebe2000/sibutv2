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
*   **Universal Accessibility (WCAG 2.1 AA):** Deliver an inclusive interface with support for high contrast, dyslexia-friendly fonts (OpenDyslexic), screen readers, and a "Zen Mode" (distraction-free) across all roles and devices.

---

## 2. Requirements

### 2.1 Functional Requirements (FR)
...
*   **FR16 - Accessibility Toolbox:** A global settings menu available to all users to toggle:
    *   **Visual:** High Contrast, Greyscale mode, Font Scaling.
    *   **Layout:** Choice of display styles (Grid/Tiles, Detailed List, or Banner/Compact views) across all data-heavy interfaces.
    *   **Reading:** OpenDyslexic font integration, increased line spacing, text-to-speech support.
    *   **Focus:** "Zen Mode" to hide non-essential UI elements during evaluation or proof-reading.

### 2.2 Non-Functional Requirements (NFR)
...
*   **NFR2 - Accessibility Standards:** 100% compliance with WCAG 2.1 AA. All interactive elements must have clear ARIA labels and logical tab ordering.
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
