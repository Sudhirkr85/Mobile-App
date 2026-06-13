# Sagar Coaching Centre Student Mobile App (Premium LMS & Store)

A production-grade, high-performance Flutter mobile application (supporting Android & iOS) designed for students of the Sagar Coaching Centre. The app provides a premium, immersive dark cybernetic environment that coordinates course learning, timed quizzes, secure bookshelf playbooks, product purchases, shipping timelines, and graduation certificates.

This application is built in a completely isolated directory, linking dynamically to the Next.js web application backend via REST APIs.

---

## 🛠️ Complete System Architecture (Feature-First)

The codebase is structured using a **Feature-First Architecture** to isolate components, features, and views:

```
student_app/
├── lib/
│   ├── main.dart                      # App entrypoint (Root MultiProvider tree)
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart         # Design System: HSL Dark Obsidian, glows, Google Fonts
│   │   ├── constants/
│   │   │   └── api_constants.dart     # Next.js endpoint mapper (.env.json configurable)
│   │   └── network/
│   │       └── api_client.dart        # Core Network Helper (GET, POST, PUT, intercepts JWT)
│   └── features/
│       ├── auth/
│       │   ├── providers/
│       │   │   └── auth_provider.dart  # Session check, login, registration logic
│       │   └── views/
│       │       ├── splash_view.dart    # App launch check & route gateway
│       │       ├── onboarding_view.dart# 3-slide PageView system
│       │       ├── login_view.dart     # Credentials controller
│       │       └── register_view.dart  # Sign-up page with password strength meters
│       ├── home/
│       │   └── views/
│       │       ├── main_layout.dart    # Shell holding the BottomNavigationBar
│       │       └── home_view.dart      # Catalog browser & optimistic wishlists
│       ├── courses/
│       │   ├── models/
│       │   │   ├── course_model.dart   # Course JSON parser
│       │   │   └── classroom_models.dart# Chapters sections & lessons parser
│       │   ├── providers/
│       │   │   └── course_provider.dart# Syllabus fetcher, enrollment logs, wishlist hooks
│       │   └── views/
│       │       ├── course_detail_view.dart# Description page & web checkout triggers
│       │       ├── my_learning_view.dart# Enrolled classes list & progress indicators
│       │       ├── classroom_view.dart # Custom Multi-Format player (Video/Live/PDF/Quiz)
│       │       ├── quiz_view.dart      # Timed MCQ quiz sheets & Results breakdown
│       │       └── wishlist_view.dart  # Saved course bookmarks
│       ├── library/
│       │   └── views/
│       │       ├── library_view.dart   # Bookshelf grid with hash-based color gradients
│       │       └── secure_pdf_view.dart# Watermark-protected temp-file PDF viewer
│       └── profile/
│           └── views/
│               ├── profile_view.dart   # Edit settings & R2 upload avatar stubs
│               ├── order_history_view.dart# Receipt cards & 5-stage shipment timeline
│               └── certificates_view.dart# Earned credential drawer & native sharing
```

---

## ⚡ Detail Breakdown of System Flows & Logic

### 1. Authentication & Session Persistence
*   **Splash Router Logic:** On app boot, `SplashView` triggers the `checkAuthStatus()` provider. If a valid JWT security token is found in the device's `flutter_secure_storage`, the app fetches profile details. If successful, it bypasses authentication entirely and redirects to `MainLayout`. If no token exists, the app checks if `completed_onboarding` is true to route either to `OnboardingView` or `LoginView`.
*   **Password Strength Meter:** Inside `RegisterView`, a dynamic listener tracks input variations. It evaluates length (>=6), upper-case letters, digits, and special characters. It updates a progress value from `0.0` to `1.0` and colors a strength bar dynamically (Weak=Red, Fair=Amber, Good=Blue, Strong=Green).

### 2. LMS Course Player & Lock Controller
*   **Curriculum Parsing:** When entering a course classroom, `classroom_view.dart` requests `fetchCourseSyllabus(slug)`. The API returns a nested JSON list containing Sections (Chapters) and Lessons.
*   **Curriculum Lock Logic:** If a student tries to select a lesson, the app checks two parameters: `lesson.isPreview` and `course.isEnrolled`. If both are false, a customized locked popup appears explaining they need to purchase the course. If either is true, the viewport switches to render the player.

### 3. Multi-Format Lesson Viewers
*   **Video Lessons:** Integrates `youtube_player_flutter`. Direct streaming loads YouTube videos using their unique IDs, hides native recommendation overlays, and enforces fullscreen landscape auto-rotation.
*   **Live Classes:** Renders schedule details in Indian Standard Time (IST). If a live class is active, it displays a countdown banner and launches the stream via the YouTube Live player widget.
*   **PDF Playbooks:** Mounts a reader that displays reading playbooks and reference files in-app.
*   **MCQ Quizzes:** Directs students to the timed assessment sheets.

### 4. Timed Quiz & Grading Portal
*   **Countdown Loop:** Displays a mandatory timer (e.g. 2 minutes) powered by a `Timer.periodic`. If the timer hits zero, the app calls `_submitQuiz()` to force-grade the selections.
*   **Visual MCQ Cards:** Layout maps exactly 4 options (A, B, C, D) in custom button shapes. Tapping options highlights them in a purple glassmorphic style.
*   **Grading Calculation:** Upon submission, the app loops through `_userAnswers` and compares them with correct option indexes. If the final score is `>= 70%`, it transitions to a success screen displaying a green badge; otherwise, it shows a retry/fail card.

### 5. Secure Bookshelf & PDF Reader (Anti-Theft)
*   **Temporary File Decryption:** In `secure_pdf_view.dart`, playbooks are requested via the Next.js `/api/pdf-proxy` endpoint. The app downloads the raw bytes and writes them to a temporary file locally in the cache directory with a randomized prefix (e.g. `secure_ref_[timestamp].pdf`).
*   **Watermark Overlay:** A semi-transparent text label (`SECURE LEARNER PORTAL - COPY PROTECTED`) is rotated and overlayed on top of the document using an `IgnorePointer` stack.
*   **Atomicity Clean Up:** On disposing of the viewer screen (when the user taps back), the app triggers `file.deleteSync()`, deleting the PDF from the device storage.

### 6. Store, Cart, & Web-Checkout
*   **Zustand-like Cart State:** Cart selections are stored in the `CartProvider` list. It calculates dynamic subtotal sums.
*   **Coupon Validations:** When a code is entered, the app calls `/api/coupons/validate`. The server verifies limits, dates, and returns discount data.
*   **Razorpay Redirection:** Instead of writing complex mobile payment gateways that risk App Store policies for digital items, tapping checkout uses `url_launcher` to redirect students to Chrome/Safari pointing to `yoursite.com/checkout?items=[ids]&coupon=[code]`. Once paid, the web database unlocks the resources.

### 7. Profile cabinet, History, & Certificates
*   **Avatar Picker:** Using `image_picker`, students select custom pictures from their camera or gallery. The app converts the file into multipart bytes and calls the Cloudflare R2 proxy upload API.
*   **5-Stage Timeline Tracker:** Maps order tracking codes. For physical items, it renders a horizontal track with completed and active green/blue indicators representing `PENDING` $\rightarrow$ `PROCESSING` $\rightarrow$ `SHIPPED` $\rightarrow$ `OUT_FOR_DELIVERY` $\rightarrow$ `DELIVERED`.
*   **Certificates Drawer:** Displays earned course completion records. Students can tap to initiate a browser download or click Share to generate verified URL messages to LinkedIn/WhatsApp.

---

## 💻 Development & Build Setup

### 1. Requirements
*   Flutter SDK (3.12.0 or higher)
*   Android Studio / Xcode (for simulators)

### 2. Configure Environment URL
Create a `.env.json` file in the root of the project:
```json
{
  "API_BASE_URL": "http://10.0.2.2:3000"
}
```
*(Point this to your local web server port or production domain)*

### 3. Run the App
To run the app with the env settings:
```bash
flutter run --dart-define-from-file=.env.json
```
