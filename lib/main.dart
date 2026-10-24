import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'core/constants/api_constants.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth_gate.dart';

void main() {
  final tokenStorage = TokenStorage();

  final apiClient = ApiClient(
    baseUrl: ApiConstants.baseUrl,
    tokenStorage: tokenStorage,
  );

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final authController = AuthController(
    repository: authRepository,
  );

  runApp(
    MyApp(
      authController: authController,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Nest App',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      home: AuthGate(
        controller: authController,
      ),
    );
  }
}