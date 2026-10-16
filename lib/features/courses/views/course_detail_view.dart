import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'classroom_view.dart';

class CourseDetailView extends StatefulWidget {
  final CourseModel course;

  const CourseDetailView({super.key, required this.course});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  bool _isProcessingEnrollment = false;

  // 1. Free Course In-App 1-Click Enrollment (Zero Browser)
  Future<void> _handleFreeEnrollment() async {
    setState(() => _isProcessingEnrollment = true);
    final courseProvider = context.read<CourseProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final success = await courseProvider.enrollFreeCourse(widget.course.id);
      if (!mounted) return;

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('🎉 Congratulations! You have been enrolled in ${widget.course.title}!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Directly open classroom
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClassroomView(course: widget.course),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not complete enrollment. Please check your connection.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Enrollment: ${e.toString().replaceAll("ApiException: ", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingEnrollment = false);
    }
  }

  // 2. Paid Course UPI-Only In-App Checkout (Zero Browser)
  Future<void> _showUpiPaymentSheet() async {
    final course = widget.course;
    final upiAmount = course.priceINR.toStringAsFixed(2);
    final upiNote = Uri.encodeComponent('Course: ${course.title.length > 25 ? course.title.substring(0, 25) : course.title}');
    final upiVpa = ApiConstants.upiVpa;
    final upiName = Uri.encodeComponent(ApiConstants.upiName);

    // Standard NPCI UPI URI Scheme
    final upiUriString = 'upi://pay?pa=$upiVpa&pn=$upiName&am=$upiAmount&cu=INR&tn=$upiNote';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with UPI badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B9F1).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF00B9F1), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  'UPI ONLY',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF00B9F1),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Course Checkout',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '₹${course.priceINR}',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment Method',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              'Direct UPI / QR',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1-Tap UPI Apps Launcher
                  Text(
                    'Choose Your UPI App (अपना UPI ऐप चुनें):',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(upiUriString);
                      try {
                        final canLaunch = await canLaunchUrl(uri);
                        if (canLaunch) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          // Try launching intent directly
                          await launchUrl(uri, mode: LaunchMode.platformDefault);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please pay using the UPI ID below or copy: $upiVpa'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.flash_on, color: Colors.white, size: 20),
                    label: Text(
                      'PAY ₹${course.priceINR} VIA ANY UPI APP',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // UPI VPA Copy Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Official UPI ID / VPA:',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              upiVpa,
                              style: GoogleFonts.firaMono(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: upiVpa));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('UPI ID copied to clipboard! (UPI ID कॉपी हो गई)'),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 14, color: Colors.white),
                          label: Text(
                            'Copy',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Confirm & Unlock Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      final courseProvider = context.read<CourseProvider>();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Verifying your UPI payment... (भुगतान जांच रहे हैं)'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                      await courseProvider.fetchEnrolledCourses();
                      if (mounted) {
                        nav.pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ClassroomView(course: course),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                    label: Text(
                      'I Have Paid — Unlock Classroom (कक्षा खोलें)',
                      style: GoogleFonts.inter(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.success, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final isEnrolled = courseProvider.enrolledCourses.any((c) => c.id == widget.course.id);
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Course Details',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image with fallback
            AspectRatio(
              aspectRatio: 16 / 9,
              child: course.coverImageUrl != null && course.coverImageUrl!.isNotEmpty
                  ? Image.network(
                      course.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Level
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  if (course.subtitle != null && course.subtitle!.isNotEmpty) ...[
                    Text(
                      course.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Text(
                          course.level.replaceAll('_', ' '),
                          style: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          course.teachers.isNotEmpty
                              ? 'Teacher: ${course.teachers.join(", ")}'
                              : 'Sagar Coaching Faculty',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // What you will get card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Included In This Course (पाठ्यक्रम में शामिल):',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(Icons.play_circle_filled, 'Full Video Lectures & Chapter Discussions'),
                        const SizedBox(height: 8),
                        _buildFeatureRow(Icons.description, 'Study Material & Revision Playbook PDFs'),
                        const SizedBox(height: 8),
                        _buildFeatureRow(Icons.quiz, 'Mock Tests & Chapter-wise Quizzes with State Rank'),
                        const SizedBox(height: 8),
                        _buildFeatureRow(Icons.workspace_premium, 'Certificate of Completion upon 100% progress'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About This Course (विवरण)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description ?? 'Complete preparation course by Sagar Coaching Centre with full syllabus coverage.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Action Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Course Fee',
                                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  Text(
                                    course.priceCents == 0 ? 'FREE (मुफ़्त)' : '₹${course.priceINR}',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              if (course.priceCents > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green, width: 0.8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flash_on, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        'UPI ONLY',
                                        style: GoogleFonts.inter(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (_isProcessingEnrollment)
                            const Center(
                              child: CircularProgressIndicator(color: AppColors.accent),
                            )
                          else if (isEnrolled)
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClassroomView(course: course),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.school, color: Colors.white),
                              label: Text(
                                'GO TO CLASSROOM (कक्षा में जाएं)',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          else if (course.priceCents == 0)
                            ElevatedButton.icon(
                              onPressed: _handleFreeEnrollment,
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                              label: Text(
                                'ENROLL FREE (मुफ़्त दाखिला लें)',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: _showUpiPaymentSheet,
                              icon: const Icon(Icons.payment, color: Colors.white),
                              label: Text(
                                'PAY ₹${course.priceINR} VIA UPI (UPI से खरीदें)',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.school, size: 60, color: AppColors.textMuted),
      ),
    );
  }
}
