import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/course_provider.dart';
import 'classroom_view.dart';

class MyLearningView extends StatefulWidget {
  const MyLearningView({super.key});

  @override
  State<MyLearningView> createState() => _MyLearningViewState();
}

class _MyLearningViewState extends State<MyLearningView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final enrolledCourses = courseProvider.enrolledCourses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Classroom',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: courseProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : enrolledCourses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await courseProvider.fetchEnrolledCourses();
                  },
                  color: AppColors.accent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: enrolledCourses.length,
                    itemBuilder: (context, index) {
                      final course = enrolledCourses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassroomView(course: course),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Course cover image
                              AspectRatio(
                                aspectRatio: 20 / 9,
                                child: course.coverImageUrl != null
                                    ? Image.network(
                                        course.coverImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                      )
                                    : _buildPlaceholder(),
                              ),

                              // Info & Progress bar
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Progress bar with indicator
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: course.progressPercent / 100.0,
                                              backgroundColor: AppColors.border,
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${course.progressPercent}%',
                                          style: GoogleFonts.inter(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          course.progressPercent == 100
                                              ? '🏆 Completed'
                                              : '📚 Continue Learning',
                                          style: GoogleFonts.inter(
                                            color: course.progressPercent == 100
                                                ? AppColors.success
                                                : AppColors.accent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: AppColors.textMuted,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎓', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'No enrolled courses',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Explore our course catalog under the Explore tab to purchase or enroll in your first course!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
        child: Icon(Icons.school_outlined, size: 40, color: AppColors.textMuted),
      ),
    );
  }
}
