class ApiConstants {
  // Reads compile-time environment config from .env.json using:
  // flutter run --dart-define-from-file=.env.json
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sudhir-sa.vercel.app',
  );
  static const String apiVersion = '/api';

  // Support & Branding configurations (from env)
  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+91 91101 13671',
  );
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'noreply@sagarcoachingcentre.com',
  );
  static const String officialWebsite = String.fromEnvironment(
    'OFFICIAL_WEBSITE',
    defaultValue: 'https://sagarcoachingcentre.com',
  );
  static const String coachingAddress = String.fromEnvironment(
    'COACHING_ADDRESS',
    defaultValue: 'NH 106, Bhagwanpur, Supaul, Bihar - 854338',
  );

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
