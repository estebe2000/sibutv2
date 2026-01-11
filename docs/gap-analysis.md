# Gap Analysis: Fonctionnalités Non Déployées vs Vision Cible

**Date :** 11 Janvier 2026
**Version :** 1.0
**Auteur :** Architecte Winston

## Introduction
Ce document recense les écarts (gaps) entre les Epics définies dans `docs/epics/` et l'état actuel de la base de code (Janvier 2026). Il sert de feuille de route pour les développements à venir.

---

## 🚨 Priorité 1 : Infrastructure & Sécurité (Bloquants)

### Epic 1 : Fondation & Branding (Portail Unifié)
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Unified SSO** | Auth isolée (API vs Nextcloud vs Mattermost). | **Single Sign-On (CAS/OAuth)** : Connexion unique sur le Dashboard propageant l'accès à tous les services. | 🔥 Haute |
| **Gateway Unifiée** | Nginx sert des fichiers statiques. Ports séparés (8082, 8065...). | **Reverse Proxy** : Routing centralisé (`/nextcloud`, `/api`) pour éviter les problèmes CORS et simplifier l'accès. | ⚡ Moyenne |
| **Rôles RBAC** | LDAP basique (`ou=People`). | Gestion fine des rôles (`RESP_SAE`, `DEPT_ADMIN`) dans les middlewares API. | ⚡ Moyenne |
| **Branding** | Thème hardcodé dans React. | Injection dynamique (Config JSON/API) des logos et couleurs par instance. | 🟢 Basse |

---

## 🛠️ Priorité 2 : Cœur de Métier (Workflow d'Évaluation)

### Epic 2 : Gouvernance & Responsabilités
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Matrice Responsabilité** | N'existe pas. Tout prof peut tout éditer. | Table de liaison `User` <-> `SAE` pour définir le "Propriétaire" légitime. | ⚡ Moyenne |
| **Verrouillage Validation** | Pas de contrôle backend. | Middleware interdisant la validation finale si l'utilisateur n'est pas "Owner". | 🟢 Basse |

### Epic 4 : Cycle d'Évaluation (Tuteurs Externes)
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Magic Links** | Inexistant. | Génération de tokens temporaires sécurisés pour accès sans compte (Tuteurs). | 🔥 Haute |
| **Formulaire Tuteur** | Inexistant. | UI Mobile-first simplifiée pour la saisie rapide d'avis tuteur via token. | ⚡ Moyenne |
| **Validation Finale** | Simple champ note ? | Interface "Slider" avec signature numérique (Timestamp + UserID) en base. | 🟢 Basse |

---

## 📊 Priorité 3 : Expérience Utilisateur & Analytics

### Epic 3 : Portfolio & Intégration Nextcloud
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Proxy WebDAV** | Upload direct ou manuel ? | Service Backend API pour uploader/lister fichiers sans exposer les crédentials Nextcloud au front. | 🔥 Haute |
| **Création Auto** | Script manuel ? | Création automatique du dossier étudiant à la première connexion/inscription. | ⚡ Moyenne |

### Epic 5 : Analytics & Reporting
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Radar Charts** | Inexistant. | Composant React (ex: Recharts) pour visualiser les 5 compétences. | 🟢 Basse |
| **Passeport PDF** | Scripts d'import existants, mais pas d'export. | Génération PDF côté serveur du bilan de compétences stylisé. | ⚡ Moyenne |

---

## 🔌 Priorité 4 : Automatisation & Scale (Nice to Have)

### Epic 6 : Import PDF Automatisé
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Admin UI Import** | Scripts python en ligne de commande. | Interface Drag & Drop + Validation visuelle des données extraites avant injection. | ⚡ Moyenne |

### Epic 7 : Mattermost ChatOps
| Fonctionnalité | État Actuel | Manquant / À faire | Complexité |
| :--- | :--- | :--- | :--- |
| **Auto-Channels** | Mattermost installé "nu". | Webhook/API Call à la création d'un groupe pour créer le canal privé associé. | 🟢 Basse |
| **Notifications** | Aucune. | Bot postant les "Nouvelles preuves déposées" dans le canal du prof responsable. | 🟢 Basse |

---

## Recommandation de Roadmap Technique

1.  **Sprint 1 : Fondation "Unified Portal"**
    *   Mettre en place le Reverse Proxy Nginx complet (Gateway).
    *   Implémenter l'Auth unifiée (Session partagée ou JWT propagé).
    *   *Livrable :* Une URL unique, un login unique.

2.  **Sprint 2 : Refactoring & Responsabilités**
    *   Refactoring du `CompetencyEditor` (Dette technique).
    *   Implémentation de la Matrice de Responsabilité (Backend).
    *   *Livrable :* Codebase saine et sécurisée (plus de modifications sauvages).

3.  **Sprint 3 : Workflow Tuteur (Magic Links)**
    *   Système de token temporaire.
    *   UI Tuteur Mobile.
    *   *Livrable :* La boucle d'évaluation complète (Étudiant -> Tuteur -> Prof).

4.  **Sprint 4 : Intégrations Riches**
    *   Proxy Nextcloud & Visualisation Radar.
    *   *Livrable :* Expérience utilisateur riche et fluide.
