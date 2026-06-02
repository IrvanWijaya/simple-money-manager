# Data Layer

Implements domain repository interfaces and maps all storage rows to domain
entities before returning them.

- `internal/` — app-owned local infrastructure.
  - `database/` — Drift database setup and table definitions.
  - `dao/` — Drift DAOs.
  - `local_source/` — local data sources over the DAOs.
  - `mapper/` — mappers between Drift rows and domain entities.
- `external/` — reserved for outside integrations (API clients, remote sources,
  DTOs). Placeholder only for this mission; no remote behavior is in scope.
- `repository/` — concrete implementations of domain repository interfaces.

Presentation must never reach into `data/internal` directly.
