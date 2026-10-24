import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import '../models/register_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _professionController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  String? _gender;
  DateTime? _dateOfBirth;
  XFile? _profilePhoto;
  Uint8List? _profilePhotoBytes;

  Future<void> _selectProfilePhoto(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1400,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _profilePhoto = image;
      });
      _profilePhotoBytes = await image.readAsBytes();
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the camera or gallery.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _professionController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = RegisterRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
      profession: _professionController.text.trim(),
      gender: _gender,
      dateOfBirth: _dateOfBirth == null ? null : _formatDate(_dateOfBirth!),
      country: _countryController.text.trim(),
      state: _stateController.text.trim(),
      city: _cityController.text.trim(),
      profilePhoto: _profilePhoto,
    );

    final success = await widget.controller.register(request);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    final message = widget.controller.errorMessage;

    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundImage: _profilePhotoBytes == null
                        ? null
                        : MemoryImage(_profilePhotoBytes!),
                    child: _profilePhotoBytes == null
                        ? const Icon(Icons.person_outline, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Profile photo (optional)')),
                  IconButton(
                    tooltip: 'Take profile photo',
                    onPressed: widget.controller.isLoading
                        ? null
                        : () => _selectProfilePhoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  IconButton(
                    tooltip: 'Choose profile photo',
                    onPressed: widget.controller.isLoading
                        ? null
                        : () => _selectProfilePhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return _required(value, 'Name');
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Email is required';
                  }

                  if (!email.contains('@')) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final mobile = value?.trim() ?? '';

                  if (mobile.isEmpty) {
                    return 'Mobile is required';
                  }

                  if (mobile.length < 7) {
                    return 'Enter a valid mobile number';
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

                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _professionController,
                decoration: const InputDecoration(
                  labelText: 'Profession',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return _required(value, 'Profession');
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: widget.controller.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: widget.controller.isLoading ? null : _selectDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select date'
                        : _formatDate(_dateOfBirth!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FormField<String>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) {
                  if (_countryController.text.isEmpty) {
                    return 'Country is required';
                  }
                  if (_stateController.text.isEmpty) {
                    return 'State is required';
                  }
                  if (_cityController.text.isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectState(
                        showFlag: false,
                        countryHint: 'Country',
                        stateHint: 'State',
                        cityHint: 'City',
                        spacing: 16,
                        onCountryChanged: (value) {
                          _countryController.text = value.trim();
                          _stateController.clear();
                          _cityController.clear();
                          field.didChange(value);
                        },
                        onStateChanged: (value) {
                          _stateController.text = value.trim();
                          _cityController.clear();
                          field.didChange(value);
                        },
                        onCityChanged: (value) {
                          _cityController.text = value.trim();
                          field.didChange(value);
                        },
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.controller.isLoading ? null : _register,
                      child: widget.controller.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
