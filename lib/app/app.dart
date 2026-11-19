import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/cubit/session_cubit.dart';
import 'app_dependencies.dart';
import 'router/app_router.dart';

/// Root widget: dependency injection, session state, theme and routing.
class CashOverflowApp extends StatelessWidget {
  const CashOverflowApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: dependencies.providers,
      child: BlocProvider(
        create: (_) => SessionCubit(dependencies.authRepository),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: AppTheme.light,
          onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
