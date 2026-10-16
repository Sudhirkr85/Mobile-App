# Sagar Coaching Centre - Mobile App Development & Audit Task Document

> **Last Updated:** October 2026  
> **Repository:** `https://github.com/Sudhirkr85/Mobile-App.git` (`main` branch)  
> **App Path:** `D:\Work\student_app`  
> **Production Backend:** `https://www.sagarcoaching.tech`  

---

## 📌 1. Project Overview & Objectives (उद्देश्य)

Is project ka main goal Sagar Coaching Centre ke students ke liye ek lightweight, fast aur completely native mobile app maintain karna tha.

### Core Problems Identified & Solved:
1. **External Browser Redirects Removed:** Pehle login, forgot password, social login aur course checkout ke liye app user ko Google Chrome / external browser me redirect kar deti thi. Isko band karke **100% In-App** kar diya gaya hai.
2. **UPI-Only In-App Payment:** Web checkout / Razorpay browser redirect hata kar mobile app me direct **UPI-Only Payment BottomSheet** implement kiya gaya (`upi://pay` deep link + manual VPA copy + Transaction UTR verification).
3. **Course Learning & Classroom Experience:** Main focus mobile app me student ki padhai (Courses, Videos, Notes/PDFs, Quizzes) seamlessly handle karne par rakha gaya. Student ko access lock hone ka false bug fix kiya gaya.
4. **Low MB APK Generation:** Default fat APK (60MB+) ke badle `--split-per-abi` release build banaya gaya, jisse APK size **~23 MB se 27 MB** par aa gaya.

---

## 📋 2. Comprehensive Functionality & Audit Checklist (फीचर्स की स्थिति)

| Feature / Module | Status | Details & In-App Implementation |
| :--- | :---: | :--- |
| **Authentication (Login/Register)** | ✅ Complete | Native token-based JWT session, SecureStorage me save hota hai. |
| **Forgot Password / Social Login** | ✅ Complete | External browser redirect hata diya gaya. Native Support Dialog diya gaya jisme Call, WhatsApp, Email aur Office Address in-app khulta hai. |
| **Home & Course Catalog** | ✅ Complete | Featured courses, categories, banners aur relative image URLs (`/images/...`) auto-format hokar properly render hote hain. |
| **Free Course Enrollment** | ✅ Complete | Direct 1-Tap in-app enrollment. Server par `enrollFree` endpoint hit hota hai aur course instant unlock ho jata hai. |
| **Paid Course Enrollment (UPI Only)** | ✅ Complete | In-app UPI Bottom Sheet: Auto-opens Google Pay, PhonePe, Paytm ya UPI app. VPA: `9110113671@okbizaxis` copy karne ka button bhi hai. UTR daalne par instant access milta hai. |
| **Classroom & Course Player** | ✅ Complete | Video playback, Chapter/Lesson syllabus tree, Attached PDFs viewer aur Live stream support. |
| **Interactive Timed Quizzes** | ✅ Complete | Timer countdown, radio MCQ selection, automatic grading aur score breakdown dialog. |
| **Digital Library / Bookshelf** | ✅ Complete | Study materials & Notes list, Watermarked PDF view inside app. |
| **Store & Cart (E-Commerce)** | ✅ Complete | Physical books/stationery cart management + In-app UPI order placement (no web checkout redirect). |
| **Student Profile & Certificates** | ✅ Complete | Profile details, certificates viewer with native sharing, order history status. |
| **Low-MB Release APK** | ✅ Complete | Optimized split APK built (`app-arm64-v8a-release.apk` ~27.7MB, `app-armeabi-v7a-release.apk` ~23.1MB). |

---

## 🛠️ 3. Technical Changes & Code Architecture (किए गए बदलाव)

### 3.1. API & Backend Integration (`lib/core/constants/api_constants.dart`)
- Broken Vercel URL (`https://sudhir-sa.vercel.app`) se switch karke production URL set kiya gaya:
  ```dart
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://www.sagarcoaching.tech',
  );
  ```
- **Image URL Resolver:** Next.js se aane wale relative URLs (`/images/products/...` ya `/images/courses/...`) ko handle karne ke liye `ApiConstants.formatImageUrl(url)` banaya gaya jo domain prepend karta hai.
- **UPI Configuration:**
  - VPA: `9110113671@okbizaxis`
  - Name: `Sagar Coaching Centre`
- **Course Enrollment Endpoints:**
  - Free: `/api/courses/{id}/enroll`
  - Paid Checkout: `/api/courses/{id}/checkout`
  - Payment Verify: `/api/courses/verify-payment`

### 3.2. Removed Browser Kickout in Auth (`lib/features/auth/views/login_view.dart`)
- Pehle `_launchForgotPassword` aur `_launchSocialAuth` Chrome browser kholte the.
- Inhe replace karke native `_showHelpSupportDialog` banaya gaya jo student ko in-app Support Center options deta hai:
  - 📞 Direct Call (`tel:+919110113671`)
  - 💬 Direct WhatsApp (`whatsapp://send?phone=919110113671`)
  - ✉️ Direct Email (`mailto:noreply@sagarcoachingcentre.com`)
  - 📍 Coaching Address Display

### 3.3. In-App Course Enrollment & UPI Sheet (`lib/features/courses/views/course_detail_view.dart`)
- **Free Courses:** Seedhe "Enroll for Free" button se API call hoti hai aur loader ke sath student enroll hokar direct Classroom me navigate hota hai.
- **Paid Courses:** "Pay via UPI & Enroll" button dabane par modal bottom sheet khulta hai:
  1. Amount aur Course Name display hota hai.
  2. "Open Any UPI App (GPay / PhonePe / Paytm)" button `upi://pay?pa=9110113671@okbizaxis&pn=Sagar+Coaching+Centre&am=...&cu=INR` trigger karta hai.
  3. UPI ID copy karne ke liye dedicated 1-click button aur QR guidance diya gaya hai.
  4. Student payment ke baad apna 12-digit UPI Reference / UTR Number enter karta hai aur "Submit & Unlock Course Instantly" par tap karta hai.
  5. State turant refresh hokar classroom open ho jata hai bina kisi browser redirect ke.

### 3.4. Classroom Lock Fix (`lib/features/courses/views/classroom_view.dart`)
- Pehle `course.isEnrolled` static model field par depend hone ke karan freshly enrolled courses lock show ho sakte the.
- Isko dynamic method `_isStudentEnrolled(courseProvider, courseId)` se replace kiya gaya jo `courseProvider.enrolledCourses` state ko live check karta hai.

### 3.5. Store Cart UPI Checkout (`lib/features/store/views/cart_view.dart`)
- Cart se web checkout button hata kar native UPI Payment bottom sheet integrate kiya gaya jisme delivery address aur UPI UTR verification ke sath order create hota hai.

### 3.6. Android Intent Queries (`android/app/src/main/AndroidManifest.xml`)
- Android 11 (API level 30) aur usse upar UPI apps discover karne ke liye `<queries>` me UPI scheme add kiya gaya:
  ```xml
  <queries>
      <intent>
          <action android:name="android.intent.action.VIEW" />
          <data android:scheme="upi" />
      </intent>
      <intent>
          <action android:name="android.intent.action.VIEW" />
          <data android:scheme="tel" />
      </intent>
      <intent>
          <action android:name="android.intent.action.VIEW" />
          <data android:scheme="mailto" />
      </intent>
  </queries>
  ```

---

## 📱 4. How to Build & Test (एप्लिकेशन चलाने और बिल्ड करने का तरीका)

### 4.1. Run in Debug / Development Mode
```powershell
cd D:\Work\student_app
flutter pub get
flutter run --dart-define-from-file=.env.json
```

### 4.2. Build Optimized Low-MB Release APK
Standard single FAT APK 60MB+ ka banta hai. Play Store / distribution ke liye split ABI APK build karein:
```powershell
cd D:\Work\student_app
flutter build apk --release --split-per-abi --dart-define-from-file=.env.json
```
**Output Files:**
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~27.7 MB) *(Modern Android phones ke liye - 95%+ devices)*
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (~23.1 MB) *(Purane 32-bit Android phones ke liye)*
- Ready-to-install copy: `D:\Work\sagar_student_app_release.apk`

---

## 🔄 5. Future Maintenance & Key Notes (भविष्य के लिए जरूरी बातें)

1. **UPI Verification Backend:**
   - Abhi student ka UTR save hota hai aur student instant learning start kar sakta hai.
   - Future me agar automatic bank statement reconciliation ya webhooks chahiye ho, toh Next.js backend ke `/api/courses/verify-payment` route par automated UPI verification gateway (jaise Cashfree, Razorpay UPI intent, ya Decentro) connect kiya ja sakta hai.
2. **Environment Variables:**
   - Default configurations `lib/core/constants/api_constants.dart` me hardcoded fallback ke sath mojood hain, isliye `.env.json` na hone par bhi app hamesha production URL (`https://www.sagarcoaching.tech`) se connect rahegi.
3. **Course Content Updates:**
   - Next.js Admin Panel se add kiye gaye chapters, videos (YouTube/Direct/HLS), PDFs aur Quizzes seedhe mobile app me without app update reflect hote hain.

---
**Repository Status:** All changes committed and pushed to `main` (`https://github.com/Sudhirkr85/Mobile-App.git`).
