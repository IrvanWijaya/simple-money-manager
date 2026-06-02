import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell_tab.dart';

/// Holds the currently selected main-shell tab.
///
/// The Transaction tab is the default landing destination. Opening Add
/// Transaction via the center add button does not change this value, so the
/// originating tab is preserved and restored when the user returns.
class ShellTabController extends StateNotifier<ShellTab> {
  ShellTabController() : super(ShellTab.transaction);

  void select(ShellTab tab) => state = tab;
}

final shellTabControllerProvider =
    StateNotifierProvider<ShellTabController, ShellTab>(
      (ref) => ShellTabController(),
    );
