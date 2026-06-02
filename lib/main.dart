import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/presentation/app/app.dart';

void main() {
  runApp(const ProviderScope(child: SimpleMoneyManagerApp()));
}
