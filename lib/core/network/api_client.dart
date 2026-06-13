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
        headers['Cookie'] = token;
      }
    }

    return headers;
  }

  // NextAuth Credentials Login flow (CSRF token exchange + Cookie capture)
  Future<Map<String, dynamic>?> authenticateCredentials(String email, String password) async {
    try {
      // 1. Get CSRF Token and cookie
      final csrfUri = Uri.parse('${ApiConstants.baseUrl}/api/auth/csrf');
      final csrfRes = await _client.get(csrfUri);
      if (csrfRes.statusCode != 200) {
        throw ApiException('Failed to retrieve security token', csrfRes.statusCode);
      }

      final csrfData = jsonDecode(csrfRes.body);
      final String? csrfToken = csrfData['csrfToken'];
      final String? csrfCookie = csrfRes.headers['set-cookie'];

      if (csrfToken == null || csrfCookie == null) {
        throw ApiException('Security parameters missing from server');
      }

      // Extract the specific CSRF cookie name/value
      final csrfCookieParsed = csrfCookie.split(';').first;

      // 2. Submit credentials and capture session cookie
      final callbackUri = Uri.parse('${ApiConstants.baseUrl}/api/auth/callback/credentials');
      final loginHeaders = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': csrfCookieParsed,
      };

      final loginBody = {
        'email': email,
        'password': password,
        'csrfToken': csrfToken,
        'redirect': 'false',
        'json': 'true',
      };

      final loginRes = await _client.post(
        callbackUri,
        headers: loginHeaders,
        body: loginBody,
      );

      if (loginRes.statusCode != 200 && loginRes.statusCode != 302) {
        throw ApiException('Login failed', loginRes.statusCode);
      }

      final setCookieHeader = loginRes.headers['set-cookie'];
      if (setCookieHeader == null) {
        throw ApiException('Login was unsuccessful: session cookie not received.');
      }

      // Check if redirect points to error
      final locationHeader = loginRes.headers['location'];
      if (locationHeader != null && locationHeader.contains('error=')) {
        throw ApiException('Invalid credentials. Please try again.');
      }

      // Extract session token
      String? sessionToken;
      final cookies = setCookieHeader.split(',');
      for (var cookie in cookies) {
        final cleanCookie = cookie.trim();
        if (cleanCookie.contains('session-token=')) {
          sessionToken = cleanCookie.split(';').first;
          break;
        }
      }

      if (sessionToken == null) {
        if (setCookieHeader.contains('session-token')) {
          sessionToken = setCookieHeader.split(';').first;
        } else {
          throw ApiException('Authentication cookie not found in response');
        }
      }

      // 3. Fetch User Profile using the session token to verify & return profile details
      final isSecure = ApiConstants.baseUrl.startsWith('https');
      final cookieKey = isSecure ? '__Secure-authjs.session-token' : 'next-auth.session-token';
      
      final finalCookieString = sessionToken.contains('=') ? sessionToken : '$cookieKey=$sessionToken';

      final profileUri = Uri.parse('${ApiConstants.baseUrl}/api/profile');
      final profileRes = await _client.get(
        profileUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': finalCookieString,
        },
      );

      if (profileRes.statusCode != 200) {
        throw ApiException('Session verification failed', profileRes.statusCode);
      }

      final profileData = jsonDecode(profileRes.body);
      final user = profileData['user'];

      if (user == null) {
        throw ApiException('User profile could not be loaded');
      }

      return {
        'token': finalCookieString,
        'user': user,
      };
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.', 503);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected network error occurred: $e');
    }
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
