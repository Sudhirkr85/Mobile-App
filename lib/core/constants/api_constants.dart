class ApiConstants {
  // Reads compile-time environment config from .env.json using:
  // flutter run --dart-define-from-file=.env.json
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const String apiVersion = '/api';

  // Auth Endpoints
  static const String login = '$apiVersion/auth/callback/credentials'; // NextAuth endpoint
  static const String register = '$apiVersion/auth/register'; 
  
  // Student Dashboard & Learning Endpoints
  static const String enrolledCourses = '$apiVersion/student/courses';
  static const String courseDetails = '$apiVersion/courses'; // path + /[courseSlug]
  static const String lessonProgress = '$apiVersion/student/progress/update';
  
  // Library Endpoints
  static const String library = '$apiVersion/student/library';
  static const String pdfProxy = '$apiVersion/student/orders'; // path + /[orderId]/pdf-access
  
  // Store Endpoints
  static const String storeProducts = '$apiVersion/store/products';
  static const String validateCoupon = '$apiVersion/coupons/validate';
  static const String checkout = '$apiVersion/checkout';
  
  // Profile, Orders & Certificates
  static const String profile = '$apiVersion/profile';
  static const String uploadAvatar = '$apiVersion/profile/avatar';
  static const String orders = '$apiVersion/student/orders';
  static const String verifyCertificate = '$apiVersion/certificates'; // path + /[certificateId]/verify
  static const String downloadCertificate = '$apiVersion/certificates'; // path + /[certificateId]/download
}
