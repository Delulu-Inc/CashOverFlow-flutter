import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CashOverflowApp(dependencies: AppDependencies.create()));
}
