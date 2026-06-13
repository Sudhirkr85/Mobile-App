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

  static final List<CourseModel> _fallbackCatalog = [
    CourseModel(
      id: 'nmms-exam',
      title: 'NMMS Scholarship Exam 2026',
      slug: 'nmms-exam-prep',
      subtitle: 'Class 8 Students - ₹12,000/year Govt Scholarship Tayari',
      description: 'National Means-cum-Merit Scholarship (NMMS) ki complete SAT & MAT preparation course. Shrvan Kumar Sagar Sir dwara detailed interactive video classes aur model test series.',
      coverImageUrl: 'assets/images/logo.png',
      priceCents: 49900,
      level: 'BEGINNER',
      teachers: ['Shrvan Kumar Sagar'],
      progressPercent: 65,
      isEnrolled: true,
    ),
    CourseModel(
      id: 'navodaya-jnvst',
      title: 'Navodaya Vidyalaya JNVST Entrance',
      slug: 'navodaya-entrance-prep',
      subtitle: 'Class 5 to 6 Entrance - Free Residential School Selection',
      description: 'Jawahar Navodaya Vidyalaya Selection Test (JNVST) ki full course package for Class 5 to 6 aspirants.',
      coverImageUrl: 'assets/images/logo.png',
      priceCents: 99900,
      level: 'INTERMEDIATE',
      teachers: ['Shrvan Kumar Sagar', 'Vinod Kumar'],
      isEnrolled: true,
    ),
    CourseModel(
      id: 'sainik-school',
      title: 'Sainik School AISSEE Preparation',
      slug: 'sainik-school-prep',
      subtitle: 'Class 5 to 6 - Military School Entrance Test',
      description: 'All India Sainik School Entrance Examination (AISSEE) target prep course with mock exams and past year papers.',
      coverImageUrl: 'assets/images/logo.png',
      priceCents: 149900,
      level: 'ADVANCED',
      teachers: ['Vinod Kumar', 'Ajay Kumar'],
    ),
    CourseModel(
      id: 'simultala-awasiya',
      title: 'Simultala Awasiya Vidyalaya Test',
      slug: 'simultala-bihar-prep',
      subtitle: 'Class 5 to 6 Entrance - Bihar Top Residential School',
      description: 'Simultala residential entrance exam complete coverage including prelims and mains guidance.',
      coverImageUrl: 'assets/images/logo.png',
      priceCents: 79900,
      level: 'INTERMEDIATE',
      teachers: ['Shrvan Kumar Sagar'],
    ),
    CourseModel(
      id: 'shrestha-nets',
      title: 'Shrestha NETS Scholarship Exam',
      slug: 'shrestha-nets-prep',
      subtitle: 'Class 8 & 10 (SC Students) - Full CBSE Schooling',
      description: 'Complete syllabus guide for Shrestha NETS to get admission in top CBSE schools with full scholarship.',
      coverImageUrl: 'assets/images/logo.png',
      priceCents: 29900,
      level: 'BEGINNER',
      teachers: ['Ajay Kumar'],
    ),
    CourseModel(
      id: 'cmmss-exam',
      title: 'CMMSS Scholarship Exam 2026',
      slug: 'cmmss-exam-prep',
      subtitle: 'Class 8 Students - ₹12,000/year Scholarship prep',
      description: 'Chief Minister Merit Scholarship Exam (CMMSS) structured course featuring SAT & MAT sections.',
      coverImageUrl: 'assets/images/logo.png',
      priceCents: 39900,
      level: 'BEGINNER',
      teachers: ['Shrvan Kumar Sagar', 'Ajay Kumar'],
    ),
  ];

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
        _courses = List.from(_fallbackCatalog);
      }
    } catch (e) {
      _courses = List.from(_fallbackCatalog);
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
        _enrolledCourses = _fallbackCatalog.where((c) => c.isEnrolled).toList();
      }
    } catch (e) {
      _enrolledCourses = _fallbackCatalog.where((c) => c.isEnrolled).toList();
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
