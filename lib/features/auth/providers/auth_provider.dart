import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userProfile;

  AuthProvider({ApiClient? apiClient, FlutterSecureStorage? storage})
      : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get userProfile => _userProfile;

  // 1. Silent Check: Runs at app launch to check if user has active session
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await _storage.read(key: 'jwt_token');
      if (savedToken != null) {
        _token = savedToken;
        
        // Fetch profile data to verify token validity
        final response = await _apiClient.get(ApiConstants.profile, requiresAuth: true);
        if (response != null && response['user'] != null) {
          _userProfile = response['user'];
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Token expired or invalid: Clear it
      await logout();
    }

    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // 2. Login: Authenticates credentials and stores JWT
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.authenticateCredentials(email, password);

      if (response != null && response['token'] != null) {
        _token = response['token'];
        _userProfile = response['user'];
        
        // Save to secure storage
        await _storage.write(key: 'jwt_token', value: _token);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // 3. Register: Registers a new student account
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response != null && response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // 4. Logout: Clears JWT session
  Future<void> logout() async {
    _token = null;
    _userProfile = null;
    _isAuthenticated = false;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }

  // 5. Upload Avatar: Uploads profile picture and updates local state
  Future<bool> uploadProfilePicture(File file) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.postMultipart(
        ApiConstants.uploadAvatar,
        file,
        'avatar',
        requiresAuth: true,
      );

      if (response != null && response['image'] != null) {
        if (_userProfile != null) {
          _userProfile = Map<String, dynamic>.from(_userProfile!);
          _userProfile!['image'] = response['image'];
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
