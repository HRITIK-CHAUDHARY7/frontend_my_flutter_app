import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.controller,
  });

  final AuthController controller;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        switch (widget.controller.status) {
          case AuthStatus.checking:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case AuthStatus.authenticated:
            return HomeScreen(
              controller: widget.controller,
            );

          case AuthStatus.unauthenticated:
            return LoginScreen(
              controller: widget.controller,
            );
        }
      },
    );
  }
}