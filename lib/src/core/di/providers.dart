/// Central Riverpod dependency-wiring entry point.
///
/// Riverpod is the sole dependency-injection and state-management mechanism for
/// this app (no GetIt). Data sources, repositories, use cases, and view-state
/// controllers are registered as providers and re-exported from here as the
/// graph grows in later features.
///
/// Database, repository, and data-initialization providers live in
/// `database_providers.dart` and are re-exported here so the rest of the app
/// has a single dependency-wiring entry point.
library;

export 'database_providers.dart';
export 'use_case_providers.dart';
