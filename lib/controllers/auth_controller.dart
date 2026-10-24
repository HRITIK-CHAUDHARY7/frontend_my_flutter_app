import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/photo_record.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({required this.repository});

  final AuthRepository repository;

  AuthStatus status = AuthStatus.checking;
  User? user;
  String? errorMessage;
  bool isLoading = false;
  bool isLoadingPhotos = false;
  bool isUploadingPhoto = false;
  List<PhotoRecord> photoRecords = [];

  Future<void> initialize() async {
    status = AuthStatus.checking;
    notifyListeners();

    try {
      final hasToken = await repository.hasStoredToken();

      if (!hasToken) {
        status = AuthStatus.unauthenticated;
        return;
      }

      user = await repository.getCurrentUser();
      status = AuthStatus.authenticated;
    } on ApiException catch (error) {
      await repository.logout();
      user = null;
      errorMessage = error.message;
      status = AuthStatus.unauthenticated;
    } catch (_) {
      await repository.logout();
      user = null;
      errorMessage = 'Unable to restore your session.';
      status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await repository.login(
        LoginRequest(email: email, password: password),
      );

      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Unable to login. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(RegisterRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repository.register(request);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Unable to create your account.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.logout();

    user = null;
    status = AuthStatus.unauthenticated;
    errorMessage = null;

    notifyListeners();
  }

  Future<void> loadPhotoRecords() async {
    isLoadingPhotos = true;
    notifyListeners();

    try {
      photoRecords = await repository.getPhotoRecords();
    } catch (error) {
      errorMessage = error is ApiException
          ? error.message
          : 'Unable to load photos.';
    } finally {
      isLoadingPhotos = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> loadProfilePhoto() async {
    try {
      return await repository.getProfilePhoto();
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> loadPhotoImage(int id) async {
    try {
      return await repository.getPhotoImage(id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> uploadProfilePhoto(XFile image) async {
    return _uploadPhoto(() => repository.uploadProfilePhoto(image));
  }

  Future<bool> uploadPhotoRecord(XFile image) async {
    isUploadingPhoto = true;
    errorMessage = null;
    notifyListeners();

    try {
      final record = await repository.uploadPhotoRecord(image);
      photoRecords = [record, ...photoRecords];
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Unable to upload photo.';
      return false;
    } finally {
      isUploadingPhoto = false;
      notifyListeners();
    }
  }

  Future<bool> _uploadPhoto(Future<void> Function() upload) async {
    isUploadingPhoto = true;
    errorMessage = null;
    notifyListeners();

    try {
      await upload();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Unable to upload photo.';
      return false;
    } finally {
      isUploadingPhoto = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
