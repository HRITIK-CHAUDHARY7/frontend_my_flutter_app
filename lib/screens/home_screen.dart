import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasProfilePhoto = false;
  late Future<Uint8List?> _profilePhoto;
  final Map<int, Future<Uint8List?>> _photoImages = {};

  @override
  void initState() {
    super.initState();
    _hasProfilePhoto = widget.controller.user?.profilePhotoUrl != null;
    _profilePhoto = _loadProfilePhoto();
    widget.controller.loadPhotoRecords();
  }

  Future<Uint8List?> _loadProfilePhoto() {
    if (!_hasProfilePhoto) return Future.value(null);
    return widget.controller.loadProfilePhoto();
  }

  Future<void> _capturePhoto(
    ImageSource source, {
    required bool profile,
  }) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      final uploaded = profile
          ? await widget.controller.uploadProfilePhoto(image)
          : await widget.controller.uploadPhotoRecord(image);

      if (!mounted) return;

      if (!uploaded) {
        _showMessage(
          widget.controller.errorMessage ?? 'Unable to upload photo.',
        );
        return;
      }

      if (profile) {
        setState(() {
          _hasProfilePhoto = true;
          _profilePhoto = _loadProfilePhoto();
        });
      } else {
        _photoImages.removeWhere(
          (id, _) =>
              !widget.controller.photoRecords.any((photo) => photo.id == id),
        );
      }

      _showMessage(profile ? 'Profile photo updated.' : 'Photo saved.');
    } catch (_) {
      if (mounted) _showMessage('Unable to open the camera or gallery.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              tooltip: 'Log out',
              onPressed: widget.controller.logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                FutureBuilder<Uint8List?>(
                  future: _profilePhoto,
                  builder: (context, snapshot) => CircleAvatar(
                    radius: 36,
                    backgroundImage: snapshot.data == null
                        ? null
                        : MemoryImage(snapshot.data!),
                    child: snapshot.data == null
                        ? const Icon(Icons.person_outline, size: 34)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Welcome, ${user.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Take profile photo',
                  onPressed: widget.controller.isUploadingPhoto
                      ? null
                      : () => _capturePhoto(ImageSource.camera, profile: true),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                IconButton(
                  tooltip: 'Choose profile photo',
                  onPressed: widget.controller.isUploadingPhoto
                      ? null
                      : () => _capturePhoto(ImageSource.gallery, profile: true),
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Photo records',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Take a photo record',
                  onPressed: widget.controller.isUploadingPhoto
                      ? null
                      : () => _capturePhoto(ImageSource.camera, profile: false),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                IconButton(
                  tooltip: 'Choose a photo record',
                  onPressed: widget.controller.isUploadingPhoto
                      ? null
                      : () =>
                            _capturePhoto(ImageSource.gallery, profile: false),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                ),
              ],
            ),
            if (widget.controller.isLoadingPhotos)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (widget.controller.photoRecords.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('No photo records yet.'),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.controller.photoRecords.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final photo = widget.controller.photoRecords[index];
                  final image = _photoImages.putIfAbsent(
                    photo.id,
                    () => widget.controller.loadPhotoImage(photo.id),
                  );

                  return FutureBuilder<Uint8List?>(
                    future: image,
                    builder: (context, snapshot) => InkWell(
                      onTap: snapshot.data == null
                          ? null
                          : () => _showPhotoViewer(context, snapshot.data!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child:
                              snapshot.connectionState != ConnectionState.done
                              ? const Center(child: CircularProgressIndicator())
                              : snapshot.data == null
                              ? const Icon(Icons.broken_image_outlined)
                              : Image.memory(snapshot.data!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),
            _InfoRow(label: 'Email', value: user.email),
            _InfoRow(label: 'Mobile', value: user.mobile),
            _InfoRow(label: 'Profession', value: user.profession),
            _InfoRow(label: 'Gender', value: user.gender ?? 'Not provided'),
            _InfoRow(
              label: 'Date of Birth',
              value: user.dateOfBirth ?? 'Not provided',
            ),
            _InfoRow(label: 'Country', value: user.country),
            _InfoRow(label: 'State', value: user.state),
            _InfoRow(label: 'City', value: user.city),
          ],
        ),
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, Uint8List imageBytes) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Photo'),
            leading: IconButton(
              tooltip: 'Close photo',
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
