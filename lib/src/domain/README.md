# Domain Layer

Pure Dart business core. The dependency center of the app.

- `entities/` — entities and value objects (e.g. `MoneyTransaction`, `Category`,
  `RecurringRule`, `PeriodRange`, `Timeframe`, `PeriodSummary`).
- `repositories/` — repository interfaces implemented by the data layer.
- `use_cases/` — application behaviors (add/update/delete transactions, period
  summaries, category statistics, recurring generation, etc.).

Must NOT import Flutter, Riverpod, Drift, SQLite, generated database classes,
API clients, presentation code, or data implementations.
