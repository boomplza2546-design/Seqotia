# Seqotia API

## Start PostgreSQL

From the project root:

```powershell
docker compose up -d postgres
```

## Install and run the API

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r app\requirements.txt
$env:DATABASE_URL = 'postgresql+psycopg://seqotia:seqotia@localhost:5432/seqotia'
$env:JWT_SECRET = 'change-this-development-secret'
cd app
uvicorn main:app --reload --port 8000
```

The first startup creates the `users` table and seeds:

- Email: `admin@seqotia.com`
- Password: `admin123`

If you already created an older development database before the document
columns were added, recreate the development volume once with
`docker compose down -v` followed by `docker compose up -d postgres`.

The Flutter app uses `POST /auth/login` and the protected `GET /dashboard/summary` endpoint.

## Document and AI workflow

The document workflow supports UTF-8 TXT, Markdown, and DOCX files:

1. `POST /documents` with a multipart `file` field.
2. `POST /ai/predict` with `{"document_id": 1, "command": "replace X with Y"}`.
3. Show the returned match, proposal, confidence, and explanation for approval.
4. `POST /ai/apply?document_id=1` with `{"matched_text":"X", "proposed_text":"Y"}`.
5. `POST /ai/feedback` with the user's accepted result or correction.
6. Download `GET /documents/1/export?format=docx|pdf|png|jpg`.

Feedback is stored in PostgreSQL as training/evaluation data. It is not used to
silently retrain a model in production. This keeps document changes explainable
and gives Seqotia a trustworthy path toward a future model provider.

The original upload is retained. DOCX exports currently return the original
formatting when no edit is applied, and preserve run formatting for basic edits.
PDF and image exports use a clean text rendering in this first slice. Full
layout-preserving conversion and cross-run editing should be added before
promising Word/PDF fidelity for complex documents.

## Structured-document foundation

Structured documents are additive to existing uploads: startup creates the
`document_structures` table without changing the legacy `documents` table.
Raw uploads continue to use the original upload/edit workflow.

1. Request a guarded, reviewable draft with `POST /ai/generate`.
2. Review the returned `data` and `validation`; nothing is stored at this step.
3. Create it with `POST /documents/structured` using a template from
   `GET /documents/templates`.
4. Read and update the same schema at `GET` / `PUT
   /documents/{document_id}/structure`.
5. Check `GET /documents/{document_id}/validation`; structured documents with
   validation errors cannot be exported.

Totals are calculated by `services/document_rules.py`, rather than accepted
from AI or client input. The initial templates are code-defined adapters so the
template/data boundary is stable while visual DOCX layout adapters evolve.
