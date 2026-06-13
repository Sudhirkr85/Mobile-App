import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/course_model.dart';
import '../models/classroom_models.dart';

class CourseProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  List<CourseModel> _courses = [];
  List<CourseModel> _enrolledCourses = [];
  List<String> _wishlistedIds = [];
  List<SectionModel> _syllabusSections = [];
  bool _isLoading = false;

  CourseProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  List<CourseModel> get courses => _courses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<String> get wishlistedIds => _wishlistedIds;
  List<SectionModel> get syllabusSections => _syllabusSections;
  bool get isLoading => _isLoading;

  List<CourseModel> get wishlistCourses {
    return _courses.where((course) => _wishlistedIds.contains(course.id)).toList();
  }

  // 1. Fetch catalog
  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.courseDetails, requiresAuth: false);
      if (response != null && response['courses'] != null && response['courses'] is List && (response['courses'] as List).isNotEmpty) {
        _courses = (response['courses'] as List)
            .map((c) => CourseModel.fromJson(c))
            .toList();
      } else {
        _courses = [];
      }
    } catch (e) {
      _courses = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch enrolled courses
  Future<void> fetchEnrolledCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.enrolledCourses, requiresAuth: true);
      if (response != null && response['courses'] != null && response['courses'] is List && (response['courses'] as List).isNotEmpty) {
        _enrolledCourses = (response['courses'] as List)
            .map((c) => CourseModel.fromJson(c))
            .toList();
      } else {
        _enrolledCourses = [];
      }
    } catch (e) {
      _enrolledCourses = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Fetch wishlist
  Future<void> fetchWishlist() async {
    try {
      final response = await _apiClient.get('/api/wishlist', requiresAuth: true);
      if (response != null && response['wishlist'] != null && response['wishlist'] is List) {
        _wishlistedIds = (response['wishlist'] as List)
            .map((item) => item['courseId'].toString())
            .toList();
      }
    } catch (e) {
      // Handle error
    }
    notifyListeners();
  }

  // 4. Toggle wishlist status
  Future<void> toggleWishlist(String courseId) async {
    // Optimistic UI update
    final wasWishlisted = _wishlistedIds.contains(courseId);
    if (wasWishlisted) {
      _wishlistedIds.remove(courseId);
    } else {
      _wishlistedIds.add(courseId);
    }
    notifyListeners();

    try {
      await _apiClient.post(
        '/api/wishlist',
        body: {'courseId': courseId},
        requiresAuth: true,
      );
    } catch (e) {
      // Revert state on network fail
      if (wasWishlisted) {
        _wishlistedIds.add(courseId);
      } else {
        _wishlistedIds.remove(courseId);
      }
      notifyListeners();
    }
  }

  // 5. Fetch Syllabus Sections
  Future<void> fetchCourseSyllabus(String slug) async {
    _isLoading = true;
    _syllabusSections = [];
    notifyListeners();

    try {
      final response = await _apiClient.get('${ApiConstants.courseDetails}/$slug/learn', requiresAuth: true);
      if (response != null && response['course'] != null && response['course']['sections'] != null) {
        final List sectionsJson = response['course']['sections'];
        _syllabusSections = sectionsJson.map((s) => SectionModel.fromJson(s)).toList();
      }
    } catch (e) {
      // Fallback: check if we can fetch from course details directly
      try {
        final response = await _apiClient.get('${ApiConstants.courseDetails}/$slug', requiresAuth: false);
        if (response != null && response['course'] != null && response['course']['sections'] != null) {
          final List sectionsJson = response['course']['sections'];
          _syllabusSections = sectionsJson.map((s) => SectionModel.fromJson(s)).toList();
        }
      } catch (_) {}
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
