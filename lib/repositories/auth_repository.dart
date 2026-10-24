import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/login_request.dart';
import '../models/photo_record.dart';
import '../models/register_request.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository({required this.apiClient, required this.tokenStorage});

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  Future<void> register(RegisterRequest request) async {
    final profilePhoto = request.profilePhoto;

    if (profilePhoto != null) {
      await apiClient.sendMultipart(
        'POST',
        ApiConstants.register,
        fileField: 'profilePhoto',
        file: profilePhoto,
        fields: Map<String, String>.from(request.toJson()),
      );
      return;
    }

    await apiClient.post(ApiConstants.register, body: request.toJson());
  }

  Future<void> uploadProfilePhoto(XFile image) async {
    await apiClient.sendMultipart(
      'PUT',
      ApiConstants.profilePhoto,
      fileField: 'photo',
      file: image,
    );
  }

  Future<PhotoRecord> uploadPhotoRecord(XFile image) async {
    final response = await apiClient.sendMultipart(
      'POST',
      ApiConstants.photoRecords,
      fileField: 'photo',
      file: image,
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Invalid photo upload response',
      );
    }

    return PhotoRecord.fromJson(response);
  }

  Future<List<PhotoRecord>> getPhotoRecords() async {
    final response = await apiClient.get(ApiConstants.photoRecords);

    if (response is! List) {
      throw const ApiException(
        statusCode: 500,
        message: 'Invalid photo list response',
      );
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(PhotoRecord.fromJson)
        .toList();
  }

  Future<Uint8List> getProfilePhoto() {
    return apiClient.getBytes(ApiConstants.profilePhoto);
  }

  Future<Uint8List> getPhotoImage(int id) {
    return apiClient.getBytes(ApiConstants.photoImage(id));
  }

  Future<User> login(LoginRequest request) async {
    final response = await apiClient.post(
      ApiConstants.login,
      body: request.toJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Invalid login response',
      );
    }

    final token = response['access_token'] ?? response['accessToken'];

    if (token is! String || token.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Login succeeded but no access token was returned.',
      );
    }

    await tokenStorage.saveToken(token);

    try {
      final userData = response['user'];

      if (userData is Map<String, dynamic>) {
        return User.fromJson(userData);
      }

      return await getCurrentUser();
    } catch (error) {
      await tokenStorage.deleteToken();
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.currentUser);

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Invalid user response.',
      );
    }

    return User.fromJson(response);
  }

  Future<bool> hasStoredToken() {
    return tokenStorage.hasToken();
  }

  Future<void> logout() {
    return tokenStorage.deleteToken();
  }
}
