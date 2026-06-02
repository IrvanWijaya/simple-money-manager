import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:sqlite3/open.dart';

bool _sqliteResolverConfigured = false;

/// Some Linux environments ship only the versioned `libsqlite3.so.0` without
/// the unversioned `libsqlite3.so` dev symlink. Point the sqlite3 loader at a
/// versioned library when the default name cannot be opened, so Drift's native
/// executor works in tests without extra system packages.
void _ensureSqliteResolver() {
  if (_sqliteResolverConfigured) return;
  _sqliteResolverConfigured = true;

  if (!Platform.isLinux) return;

  open.overrideForAll(() {
    const candidates = <String>[
      'libsqlite3.so',
      'libsqlite3.so.0',
      '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
      '/lib/x86_64-linux-gnu/libsqlite3.so.0',
    ];
    for (final name in candidates) {
      try {
        return DynamicLibrary.open(name);
      } on ArgumentError {
        continue;
      }
    }
    // Fall back to the default name so the original error surfaces.
    return DynamicLibrary.open('libsqlite3.so');
  });
}

/// Creates a fresh, fully isolated in-memory [AppDatabase] for a single test.
///
/// Each call returns an independent database with no shared state, so tests do
/// not leak rows into one another. Close it in tearDown with `db.close()`.
AppDatabase createTestDatabase() {
  _ensureSqliteResolver();
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Opens a file-backed [AppDatabase] at [file], using the same native sqlite
/// loader override as [createTestDatabase].
///
/// Unlike the in-memory database, the SQLite file on disk survives closing the
/// `AppDatabase`. Closing one instance and opening a new one against the same
/// [file] models a real app force-stop/relaunch: persisted source data
/// (transactions, recurring rules, occurrence metadata, wallet settings) is
/// reloaded from disk by the fresh instance. Use this for persistence /
/// restart assertions where in-memory isolation would hide the round-trip.
AppDatabase openFileDatabase(File file) {
  _ensureSqliteResolver();
  return AppDatabase.forTesting(NativeDatabase(file));
}
