import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || success) {
      return;
    }

    final message = widget.controller.errorMessage;

    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(controller: widget.controller),
      ),
    );

    if (!mounted) return;

    if (registered == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. You can now login.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email or mobile number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final identifier = value?.trim() ?? '';

                        if (identifier.isEmpty) {
                          return 'Email or mobile number is required';
                        }

                        if (identifier.contains('@')) {
                          final emailParts = identifier.split('@');
                          if (emailParts.length != 2 ||
                              !emailParts.last.contains('.')) {
                            return 'Enter a valid email or mobile number';
                          }
                        } else {
                          final digits = identifier.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          if (!RegExp(r'^[0-9+().\-\s]+$')
                                  .hasMatch(identifier) ||
                              digits.length < 7 ||
                              digits.length > 15) {
                            return 'Enter a valid email or mobile number';
                          }
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.controller.isLoading ? null : _login,
                        child: widget.controller.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: widget.controller.isLoading
                          ? null
                          : _openRegister,
                      child: const Text('Create an account'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
