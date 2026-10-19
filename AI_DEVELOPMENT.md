# Sequoia Development

## Architecture

- Flutter UI lives under `lib/` and uses `MaterialApp` named routes in `lib/app/routes.dart`.
- `WorkspaceStore` is the shared `ChangeNotifier` for session documents and theme preferences.
- API calls go through `ApiClient` and feature services such as `DocumentService`, `DashboardService`, and `AIWriterService`.
- FastAPI lives under `backend/app/`, with SQLAlchemy persistence, typed Pydantic schemas, deterministic document rules, and template rendering.
- Structured document data is stored separately from uploaded document bytes in `DocumentStructure`, so raw uploads remain compatible.

## Current Phase

The project is in the functional MVP phase: login, dashboard navigation, workspace pages, structured AI proposals, validation, document editing, import, and export are connected.

## Completed

- JWT login and PostgreSQL-compatible persistence.
- Structured document types, templates, validation, deterministic totals, and version increments.
- Reviewable AI document generation through `/ai/generate`.
- DOCX, TXT, Markdown, PDF, JPG, and PNG upload handling.
- DOCX, PDF, PNG, and JPG export adapters.
- Flutter dashboard responsive layout and real route actions.
- File picker uploads connected to the authenticated API and shared workspace state.
- Workspace repository management: search, type/status/archive filters, sorting, favorites, rename, duplicate, archive, delete confirmation, and export controls.
- Flutter upload and export service adapters connected to FastAPI.
- Dashboard aggregation is centralized in `backend/app/services/dashboard_service.py`; routes now remain thin and the service is covered by a persistence-backed test.
- Activity, tools, settings, theme state, document viewer, and structured editor screens.

## Known Limitations

- PDF and image imports currently retain metadata and a clear extraction notice; OCR/PDF text extraction provider integration is still required.
- PDF and image exports use a text renderer; complex original DOCX layout fidelity needs a dedicated rendering pipeline.
- AI generation is a deterministic structured baseline. A production model provider can replace `AIService.generate_document` while preserving its schema contract.
- Flutter export currently retrieves validated bytes from FastAPI and reports readiness; a platform file-save adapter is still needed for browser downloads and native save dialogs.
- `Base.metadata.create_all` is used for development initialization. Production needs versioned migrations.
- Session workspace state is in memory; production should persist user preferences and document lists through API reads after login.

## Next Task

Add an authenticated Flutter document repository sync and a real document workspace with command preview, apply, undo/version history, and export controls backed by the existing API routes.
