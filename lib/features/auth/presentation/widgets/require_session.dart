import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

/// Sends visitors without a session to the login page.
class RequireSession extends StatefulWidget {
  const RequireSession({super.key, required this.child, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  @override
  State<RequireSession> createState() => _RequireSessionState();
}

class _RequireSessionState extends State<RequireSession> {
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final hasSession = await context.read<AuthRepository>().hasSession;
    if (!mounted) return;

    if (hasSession) {
      setState(() => _allowed = true);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed) return widget.child;
    return Scaffold(backgroundColor: widget.backgroundColor);
  }
}
