# Project Brief: BUT TC Skills Tracking Application

**Date:** Tuesday, January 6, 2026
**Author:** Mary (Business Analyst)
**Stakeholder:** Steeve (IUT Le Havre)

## 1. Executive Summary
The project aims to develop a centralized **Skills Tracking Application (Portfolio/LMS)** for the BUT "Techniques de Commercialisation" (TC) at IUT Le Havre. The platform will manage the complex evaluation lifecycle (Auto-evaluation, Tutor Feedback, Professor Validation) across the 3-year curriculum (Common Core + 5 Pathways). It addresses the need for a unified interface that connects Students, Teachers, and External Tutors, while providing a sovereign and secure storage solution for proof of skills (Multimedia) via Nextcloud.

## 2. Problem Statement
The implementation of the new BUT "Techniques de Commercialisation" curriculum requires a rigorous, skills-based approach (APC). Currently, tracking progress is fragmented.
- **Evaluation Fragmentation:** Difficulty in synchronizing student self-assessments, external tutor feedback, and final professor validation.
- **Infrastructure Gaps:** LDAP structure does not accurately reflect student groups and pathways.
- **External Access Barriers:** External tutors face "password fatigue" in university systems.
- **Evidence Management:** No centralized, secure way to link multimedia evidence to skills while ensuring data sovereignty.

## 3. Proposed Solution
A custom, responsive web application ("Skills Hub") acting as an orchestration layer between LDAP and Nextcloud.
- **Template-Driven:** Admin-created curriculum templates pushed to student groups.
- **Decoupled Storage:** Nextcloud API for secure, versioned storage of student evidence.
- **Frictionless Evaluation:** "Magic Link" system for company tutors (no accounts needed).
- **Nuanced Tracking:** 0-100% sliding scale for skills validation.
- **Inclusive Design:** Mobile-First with baked-in accessibility features (Dyslexia-friendly, High Contrast).

## 4. Target Users
- **Primary: BUT TC Students:** Needs visual progress maps and a secure "dumping ground" for multimedia evidence. Focus on mobile usability.
- **Secondary: Professors & Admins:** Desktop-focused; needs to manage large promotions and assign templates. Requires 0-100% validation tools.
- **Tertiary: External Tutors:** Extremely limited time; requires one-click access (Magic Links) to evaluation forms.

## 5. Goals & Success Metrics
- **Pedagogical:** 100% curriculum coverage for all 5 pathways in templates.
- **Participation:** >80% response rate from external tutors via Magic Links.
- **Sovereignty:** 100% of files stored in IUT Nextcloud.
- **Engagement:** Under 60 seconds to link a proof to a skill on mobile.
- **Accessibility:** Compliance with WCAG AA standards.

## 6. MVP Scope
**Must Have:**
- LDAP Auth + Internal Group Management.
- Admin Curriculum Templates (5 pathways, 3 levels).
- Evidence Gallery via Nextcloud API (PDF, Video, Audio).
- 3-Way Evaluation Flow (Student self-eval, Tutor Magic Link, Prof %-Slider).
- Inclusive Dashboard (Radar charts, Mobile-responsive).
- Capitalization for repeating students.

**Out of Scope:**
- Automated grade calculation (deferred to v2).
- Native Mobile Apps (using PWA instead).
- Integrated Appointment Scheduling.

## 7. Post-MVP Vision
- **Phase 2:** Automated grading algorithms and integrated oral validation scheduling.
- **Long-term:** "Career Passport" export for students to share their validated portfolio with employers.
- **Expansion:** Scaling the template system to other IUT departments.

## 8. Technical Considerations
- **Stack:** Python (FastAPI) Backend, React/Vue.js Frontend, PostgreSQL.
- **Infrastructure:** Docker/CapRover compatible.
- **Integrations:** LDAP (Auth), Nextcloud (Storage).
- **UX:** Mobile-first, High Accessibility (RGAA/WCAG).

## 9. Constraints & Assumptions
- **Constraints:** Use existing infrastructure (CapRover/Nextcloud) to minimize costs; must be highly documented for long-term maintenance.
- **Assumptions:** Nextcloud APIs are accessible; Magic Links will bypass "password fatigue" for tutors; LDAP gaps can be bridged with an internal module.

## 10. Risks & Open Questions
- **Risks:** Nextcloud API as a single point of failure; mobile data costs for large video uploads; email filters blocking Magic Links.
- **Questions:** Exact metadata for the 5 pathways (Official PDF needed); Nextcloud storage quotas; Magic Link expiration policy.

## 11. Appendices
- **A. Research Summary:** Based on brainstorming session Jan 6, 2026.
- **B. Stakeholder Input:** Requirements from Steeve (IUT Le Havre).
- **C. References:** BUT TC Program, Nextcloud API Docs, CapRover Docs.

## 12. Next Steps
1. Metadata Collection (Official BUT PDF).
2. Infrastructure POC (LDAP/Nextcloud).
3. UI/UX Prototyping (Sliders/Mobile Upload).
4. Database Design (Schema ERD).

---
*This Project Brief provides the full context for the BUT TC Skills Tracking Application. Please start in 'PRD Generation Mode', review the brief thoroughly to work with the user to create the PRD section by section.*
