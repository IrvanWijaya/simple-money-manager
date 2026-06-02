import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static guards for the approved clean-architecture boundaries
/// (VAL-ARCH-001..006, VAL-PERSIST-009). These scan the real `lib/` source so a
/// future change that violates a layer boundary, reintroduces a service locator,
/// or adds a remote/network call to a required flow fails fast in CI.
void main() {
  final libDir = Directory('lib');

  List<File> dartFilesUnder(String relativePath) {
    final dir = Directory(relativePath);
    if (!dir.existsSync()) return const [];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
  }

  /// Import targets from `import '...'` / `export '...'` statements in [file].
  List<String> importsOf(File file) {
    final content = file.readAsStringSync();
    final regex = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    return regex.allMatches(content).map((m) => m.group(1)!).toList();
  }

  test('domain layer is infrastructure-independent (VAL-ARCH-002)', () {
    const forbidden = [
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:riverpod/',
      'package:drift/',
      'package:sqlite3/',
      'package:fl_chart/',
    ];
    final violations = <String>[];
    for (final file in dartFilesUnder('lib/src/domain')) {
      for (final import in importsOf(file)) {
        for (final bad in forbidden) {
          if (import.startsWith(bad)) {
            violations.add('${file.path} -> $import');
          }
        }
        if (import.endsWith('.g.dart')) {
          violations.add('${file.path} -> $import (generated Drift class)');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Domain must be pure Dart:\n${violations.join('\n')}',
    );
  });

  test('domain does not depend on presentation or data (VAL-ARCH-006)', () {
    final violations = <String>[];
    for (final file in dartFilesUnder('lib/src/domain')) {
      for (final import in importsOf(file)) {
        if (import.contains('/presentation/') ||
            import.contains('/data/') ||
            import.contains('presentation/') && import.startsWith('package:') ||
            import.startsWith('package:simple_money_manager/src/data/') ||
            import.startsWith(
              'package:simple_money_manager/src/presentation/',
            )) {
          violations.add('${file.path} -> $import');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Domain imports a higher/sibling layer:\n${violations.join('\n')}',
    );
  });

  test('presentation does not import Drift, SQLite, or data/internal '
      '(VAL-ARCH-001)', () {
    final violations = <String>[];
    for (final file in dartFilesUnder('lib/src/presentation')) {
      for (final import in importsOf(file)) {
        if (import.startsWith('package:drift/') ||
            import.startsWith('package:sqlite3/') ||
            import.contains('/data/internal/') ||
            import.contains('data/internal/') ||
            import.endsWith('app_database.dart') ||
            import.endsWith('.g.dart')) {
          violations.add('${file.path} -> $import');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Presentation reaches into data/internal or Drift:\n'
          '${violations.join('\n')}',
    );
  });

  test('presentation does not depend on concrete repository implementations '
      '(VAL-ARCH-006)', () {
    final violations = <String>[];
    for (final file in dartFilesUnder('lib/src/presentation')) {
      for (final import in importsOf(file)) {
        if (import.contains('/data/repository/') ||
            import.contains('data/repository/') ||
            import.endsWith('_repository_impl.dart')) {
          violations.add('${file.path} -> $import');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Presentation depends on a concrete repository impl:\n'
          '${violations.join('\n')}',
    );
  });

  test('no GetIt / service locator anywhere in lib (VAL-ARCH-004)', () {
    final violations = <String>[];
    for (final file in dartFilesUnder('lib')) {
      // Detect a real GetIt dependency/usage, not prose like "(no GetIt)".
      for (final import in importsOf(file)) {
        if (import.startsWith('package:get_it/')) violations.add(file.path);
      }
      final content = file.readAsStringSync();
      if (RegExp(r'\bGetIt\s*[.(<]').hasMatch(content)) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'GetIt/service locator detected:\n${violations.join('\n')}',
    );
  });

  test('required flows make no remote/network calls (VAL-PERSIST-009)', () {
    const forbidden = [
      'package:http/',
      'package:dio/',
      'package:firebase',
      'package:supabase',
      'package:googleapis',
      'package:web_socket',
    ];
    final violations = <String>[];
    for (final file in dartFilesUnder('lib')) {
      final content = file.readAsStringSync();
      for (final import in importsOf(file)) {
        for (final bad in forbidden) {
          if (import.startsWith(bad)) violations.add('${file.path} -> $import');
        }
      }
      if (RegExp(r'\bHttpClient\b').hasMatch(content) ||
          RegExp(r'\bSocket\.connect\b').hasMatch(content)) {
        violations.add('${file.path} (raw network API)');
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Remote/network usage detected in required flows:\n'
          '${violations.join('\n')}',
    );
  });

  test('data layer keeps internal/external split (VAL-ARCH-005)', () {
    expect(Directory('lib/src/data/internal').existsSync(), isTrue);
    expect(Directory('lib/src/data/external').existsSync(), isTrue);
    // External must contain no current remote behavior (placeholder only).
    final externalDartFiles = dartFilesUnder('lib/src/data/external');
    expect(
      externalDartFiles,
      isEmpty,
      reason:
          'data/external should hold no active implementations yet:\n'
          '${externalDartFiles.map((f) => f.path).join('\n')}',
    );
  });

  test('only the composition root imports data/internal (VAL-ARCH-006)', () {
    // Outside data/ itself, the Riverpod composition root (core/di) is the only
    // place allowed to know about Drift/data internals.
    final violations = <String>[];
    for (final file in dartFilesUnder('lib')) {
      final path = file.path.replaceAll(r'\', '/');
      if (path.startsWith('lib/src/data/')) continue;
      if (path.startsWith('lib/src/core/di/')) continue;
      for (final import in importsOf(file)) {
        if (import.contains('/data/internal/') ||
            import.contains('data/internal/')) {
          violations.add('$path -> $import');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'data/internal leaked outside data/ and core/di:\n'
          '${violations.join('\n')}',
    );
  });

  test('lib directory exists (sanity)', () {
    expect(libDir.existsSync(), isTrue);
  });
}
