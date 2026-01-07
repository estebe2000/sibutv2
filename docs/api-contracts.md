# API & Integration Contracts

## 1. Nextcloud Integration (WebDAV)

**Strict Rule:** The backend acts as a proxy. The frontend NEVER talks to Nextcloud directly.

### 1.1 Connection Details
*   **Protocol:** WebDAV (via `webdav4` python library or similar).
*   **Auth:** Basic Auth (Service Account).
*   **Root Path:** `/remote.php/dav/files/{service_account}/BUT-TC-Skills/{year}/`

### 1.2 Folder Structure
```text
/BUT-TC-Skills/
  ├── 2025/
  │   ├── {student_uid}/
  │   │   ├── evidence/
  │   │   │   ├── proof_1.pdf
  │   │   │   └── video_demo.mp4
  │   │   └── exports/
```

### 1.3 Key Operations
*   **Upload:** Stream chunks from Frontend -> Backend -> Nextcloud. Do not buffer >10MB in RAM.
*   **Preview:** Backend generates a temporary pre-signed URL or streams the file content with correct MIME type.

---

## 2. LDAP Authentication

### 2.1 Connection Details
*   **Protocol:** LDAPv3.
*   **Library:** `ldap3` (Python).

### 2.2 User Mapping
| LDAP Attribute | App Field | Notes |
| :--- | :--- | :--- |
| `uid` | `username` | Unique ID |
| `mail` | `email` | - |
| `displayName` | `full_name` | - |
| `eduPersonAffiliation` | `role` | `student` -> STUDENT, `faculty` -> PROF |
| `supannEtuInscription` | `group` | Parse year/dept to auto-assign group |

---

## 3. Magic Links (External Tutors)

### 3.1 Token Logic
*   **Generation:** `HMAC_SHA256(evaluation_id + secret + timestamp)`.
*   **Format:** `https://app.univ.fr/eval/tutor?token=xyz123...`
*   **Validity:** 7 days OR until `status` becomes `SUBMITTED`.

### 3.2 Security
*   Tokens DO NOT grant login sessions.
*   Tokens grant specific READ access to **one** student's specific evidence and WRITE access to **one** feedback form.
