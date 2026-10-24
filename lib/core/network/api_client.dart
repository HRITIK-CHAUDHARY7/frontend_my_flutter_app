import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../storage/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final TokenStorage tokenStorage;
  final http.Client _client;

  Future<Map<String, String>> _buildHeaders() async {
    return {'Content-Type': 'application/json', ...await _buildAuthHeaders()};
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final token = await tokenStorage.getToken();

    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _buildHeaders(),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<dynamic> get(String endpoint) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$endpoint'), headers: await _buildHeaders())
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<dynamic> sendMultipart(
    String method,
    String endpoint, {
    required String fileField,
    required XFile file,
    Map<String, String> fields = const {},
  }) async {
    final request = http.MultipartRequest(
      method,
      Uri.parse('$baseUrl$endpoint'),
    )..headers.addAll(await _buildAuthHeaders());
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        await file.readAsBytes(),
              filename: file.name,
              contentType: _imageContentType(file),
      ),
    );

    final streamedResponse = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  http.MediaType _imageContentType(XFile file) {
    final mimeType = file.mimeType?.split(';').first.trim().toLowerCase();
    if (mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/webp') {
      return http.MediaType.parse(mimeType!);
    }

    final extension = file.name.toLowerCase().split('.').last;
    return switch (extension) {
      'jpg' || 'jpeg' => http.MediaType('image', 'jpeg'),
      'png' => http.MediaType('image', 'png'),
      'webp' => http.MediaType('image', 'webp'),
      _ => http.MediaType('application', 'octet-stream'),
    };
  }

  Future<Uint8List> getBytes(String endpoint) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$endpoint'), headers: await _buildAuthHeaders())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    _handleResponse(response);
    throw const ApiException(statusCode: 500, message: 'Unable to load image');
  }

  dynamic _handleResponse(http.Response response) {
    dynamic data;

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = 'Something went wrong';

    if (data is Map<String, dynamic>) {
      final serverMessage = data['message'];

      if (serverMessage is String) {
        message = serverMessage;
      } else if (serverMessage is List) {
        message = serverMessage.join(', ');
      }
    }

    throw ApiException(statusCode: response.statusCode, message: message);
  }
}
