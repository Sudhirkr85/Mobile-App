import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  final http.Client _client;
  final FlutterSecureStorage _storage;
  
  ApiClient({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  // Retrieve stored token
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Common Headers
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET Request
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client.get(uri, headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.', 503);
    } catch (e) {
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  // POST Request
  Future<dynamic> post(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await _client.post(uri, headers: headers, body: jsonBody);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.', 503);
    } catch (e) {
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await _client.put(uri, headers: headers, body: jsonBody);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.', 503);
    } catch (e) {
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client.delete(uri, headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.', 503);
    } catch (e) {
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  // Process Response status codes
  dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    // Attempt parsing JSON
    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    }

    // Handle standard API errors
    String errorMessage = 'Something went wrong';
    if (responseBody is Map && responseBody.containsKey('message')) {
      errorMessage = responseBody['message'];
    } else if (responseBody is Map && responseBody.containsKey('error')) {
      errorMessage = responseBody['error'];
    }

    switch (statusCode) {
      case 400:
        throw ApiException('Bad Request: $errorMessage', statusCode);
      case 401:
        throw ApiException('Unauthorized: Please login again.', statusCode);
      case 403:
        throw ApiException('Forbidden: You do not have permission.', statusCode);
      case 404:
        throw ApiException('Not Found: $errorMessage', statusCode);
      case 500:
        throw ApiException('Server Error: Internal system failure.', statusCode);
      default:
        throw ApiException('Error ($statusCode): $errorMessage', statusCode);
    }
  }
}
