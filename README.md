# Simple Money Manager

A local-first personal finance app built with Flutter. It tracks income and
expense transactions, groups them by period, computes balances, period
summaries, and category statistics, and supports recurring transaction rules —
all stored on-device in SQLite via Drift. There is **no backend, network, or
account**: every required flow works fully offline.

## Features

- Dark-themed app shell with bottom navigation (Transaction, Calendar, Add,
  Statistic, Wallet) and a center Add button.
- **Transaction home:** current balance, period summary (Income / Expense /
  Total), and transactions grouped by date with computed daily totals.
- **Calendar:** month grid (Sunday-first) with computed per-day income/expense
  totals and the current date highlighted.
- **Statistic:** opening/ending balance, period overview, and an
  income/expense category structure chart that toggles between donut and bar.
- **Statistic structure detail:** Income/Expense tabs, donut chart with
  computed percentages, and a category breakdown with amount and count.
- **Add Transaction:** Income/Expense tabs, date/time, amount (whole Rupiah),
  description, category selection, single-wallet display, memo, and an optional
  recurring rule.
- **Category selection:** Income/Expense tabs with the fixed seed categories.
- **Wallet:** recurring rule list with `+ Add Recurring`.
- **Recurring rules:** none/daily/weekly/monthly/yearly with interval,
  repeat-position, and end condition (forever / count / end date). Due
  occurrences appear in the transaction list and generation is idempotent.

Balances, period summaries, statistics, chart percentages, and date-group
totals are **always computed from stored transactions** — they are never
persisted as their own tables.

## Architecture

Clean architecture with the dependency direction `Presentation -> Domain <- Data`:

```text
lib/src/
  core/        App theme, formatters, category seeds, and the Riverpod
               dependency-wiring composition root (core/di).
  domain/      Pure Dart entities, repository interfaces, and use cases.
               No Flutter, Riverpod, Drift, SQLite, or generated classes.
  data/
    internal/  Drift database, tables, DAOs, mappers (local SQLite).
    external/  Reserved placeholder for future remote integrations (empty).
    repository/Concrete repositories implementing domain interfaces; map
               Drift rows to domain entities.
  presentation/Flutter screens, widgets, and Riverpod view-state providers.
               Calls use cases / providers only — never Drift or DAOs directly.
```

- **State management & DI:** [Riverpod](https://riverpod.dev) only (no GetIt).
  `lib/src/core/di/` is the single composition root that wires the Drift
  database, repositories, and use cases as providers.
- **Persistence:** [Drift](https://drift.simonbinder.eu) over embedded SQLite.
  Persisted source tables: `transactions`, `categories`, `recurring_rules`,
  `recurring_occurrences` (idempotency metadata), and `wallet_settings`.
- **Charts:** `fl_chart`. **Formatting:** `intl`. **IDs:** `uuid`.

Layer boundaries are enforced by a static guard test —
`test/architecture/layer_boundary_test.dart`.

## Requirements

- Flutter `3.44.0` (Dart `3.12.0`) or compatible.
- Android SDK / toolchain for building and running the Android app.
- An Android device or emulator (validated on AVD `smm_pixel_6_api_35`).

## Setup

```bash
flutter pub get
# Regenerate Drift code (only needed after changing tables/DAOs):
dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
# List available devices/emulators
flutter devices

# Launch the project emulator (optional)
flutter emulators --launch smm_pixel_6_api_35

# Run the app on the connected device/emulator
flutter run
```

## Test & Validate

Run these from the project root:

```bash
# Format check (no files written)
dart format --output=none --set-exit-if-changed lib test

# Static analysis / lint
flutter analyze

# Full test suite (domain, data/Drift, presentation, architecture guards)
flutter test --concurrency=4

# Build a debug APK (Android gate)
flutter build apk --debug
```

### Notes on the test suite

- Drift-backed tests use `test/data/helpers/test_database.dart`
  (`createTestDatabase()` / `openFileDatabase()`), which redirects the SQLite
  loader to `libsqlite3.so.0` on hosts that lack the unversioned
  `libsqlite3.so` dev symlink. Use these helpers instead of constructing
  `NativeDatabase.memory()` directly.
- `test/architecture/layer_boundary_test.dart` statically verifies the clean
  architecture boundaries: domain stays infrastructure-free, presentation never
  imports Drift/SQLite/`data/internal` or concrete repositories, no GetIt, no
  remote/network packages, and the `data/internal`+`data/external` split holds.

## Project Scope

This is intentionally a focused income/expense tracker. Out of scope: multiple
wallets, transfers, search, Pro/subscription, Budget/Goal/Debt sections, custom
category creation, and any backup/sync/auth or remote API.
