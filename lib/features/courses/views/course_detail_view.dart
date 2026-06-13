import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'classroom_view.dart';

class CourseDetailView extends StatelessWidget {
  final CourseModel course;

  const CourseDetailView({super.key, required this.course});

  Future<void> _launchCheckout(BuildContext context) async {
    // Open web payment checkout using url_launcher
    final url = Uri.parse('http://10.0.2.2:3000/courses/${course.slug}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open checkout page.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final isEnrolled = courseProvider.enrolledCourses.any((c) => c.id == course.id);

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
            // Cover Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: course.coverImageUrl != null
                  ? Image.network(
                      course.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
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
                  if (course.subtitle != null) ...[
                    Text(
                      course.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
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
                      Text(
                        course.teachers.isNotEmpty
                            ? 'Instructor: ${course.teachers.first}'
                            : 'Sagar Instructor',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About This Course',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description ?? 'No description provided.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Purchase / Go to Classroom Action Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price',
                                style: GoogleFonts.inter(color: AppColors.textSecondary),
                              ),
                              Text(
                                course.priceCents == 0 ? 'FREE' : '₹${course.priceINR}',
                                style: GoogleFonts.outfit(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          isEnrolled
                              ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClassroomView(course: course),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'GO TO CLASSROOM',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () => _launchCheckout(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    course.priceCents == 0 ? 'ENROLL NOW' : 'BUY NOW',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.border,
      child: const Center(
        child: Icon(Icons.school, size: 60, color: AppColors.textMuted),
      ),
    );
  }
}
