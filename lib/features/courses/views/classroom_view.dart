import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../models/course_model.dart';
import '../models/classroom_models.dart';
import '../providers/course_provider.dart';
import 'quiz_view.dart'; // We will build this in Module 9

class ClassroomView extends StatefulWidget {
  final CourseModel course;

  const ClassroomView({super.key, required this.course});

  @override
  State<ClassroomView> createState() => _ClassroomViewState();
}

class _ClassroomViewState extends State<ClassroomView> {
  LessonModel? _selectedLesson;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourseSyllabus(widget.course.slug);
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _selectLesson(LessonModel lesson) {
    if (!lesson.isPreview && !widget.course.isEnrolled) {
      // Show locked dialog
      _showLockedDialog();
      return;
    }

    setState(() {
      _selectedLesson = lesson;
    });

    if (lesson.contentType == 'VIDEO' && lesson.youtubeUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(lesson.youtubeUrl!);
      if (videoId != null) {
        if (_youtubeController != null) {
          _youtubeController!.load(videoId);
        } else {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              disableDragSeek: false,
              enableCaption: true,
            ),
          );
        }
      }
    } else {
      _youtubeController?.pause();
    }
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('🔒 Lesson Locked', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
          'This lesson is premium. Please enroll or purchase the course to unlock access.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final sections = courseProvider.syllabusSections;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.course.title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Player Viewport (Top half)
          _buildPlayerViewport(),

          const Divider(height: 1, color: AppColors.border),

          // 2. Syllabus Accordion list (Bottom half)
          Expanded(
            child: courseProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : sections.isEmpty
                    ? Center(
                        child: Text(
                          'No lectures available in this syllabus.',
                          style: GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final section = sections[index];
                          return ExpansionTile(
                            title: Text(
                              section.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            initiallyExpanded: index == 0,
                            children: section.lessons.map((lesson) {
                              final isSelected = _selectedLesson?.id == lesson.id;
                              final isLocked = !lesson.isPreview && !widget.course.isEnrolled;
                              
                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: AppColors.primary.withOpacity(0.08),
                                leading: Icon(
                                  _getIconForType(lesson.contentType),
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isLocked ? AppColors.textMuted : AppColors.textSecondary),
                                  size: 20,
                                ),
                                title: Text(
                                  lesson.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isLocked ? AppColors.textMuted : Colors.white),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: isLocked
                                    ? const Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted)
                                    : (lesson.isPreview
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: AppColors.accent, width: 0.8),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'FREE',
                                              style: GoogleFonts.inter(fontSize: 8, color: AppColors.accent, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        : null),
                                onTap: () => _selectLesson(lesson),
                              );
                            }).toList(),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerViewport() {
    if (_selectedLesson == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline, size: 50, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'Select a lesson below to start learning',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              )
            ],
          ),
        ),
      );
    }

    final lesson = _selectedLesson!;

    switch (lesson.contentType) {
      case 'VIDEO':
        if (lesson.youtubeUrl != null && _youtubeController != null) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primary,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primary,
                handleColor: AppColors.accent,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.video_camera_back_outlined, color: Colors.white, size: 40),
            ),
          ),
        );
        
      case 'LIVE':
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: const Color(0xFF1E1E2C),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.live_tv, size: 44, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  'Upcoming Live Session',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Check schedule details and join live stream link.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Open YouTube Live directly
                    if (lesson.youtubeUrl != null) {
                      launchUrl(Uri.parse(lesson.youtubeUrl!), mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: Text('JOIN LIVE NOW', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );

      case 'RESOURCE':
      case 'ARTICLE':
        // Simple PDF or resource preview stub
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description, size: 44, color: AppColors.accent),
                const SizedBox(height: 12),
                Text(
                  lesson.title,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'This lesson includes a study playbook PDF or workbook document.',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // In-app PDF view or download
                    _openPDF(lesson.r2AssetUrl ?? '');
                  },
                  icon: const Icon(Icons.chrome_reader_mode, color: Colors.white),
                  label: Text('Read document', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                )
              ],
            ),
          ),
        );

      case 'QUIZ':
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz, size: 44, color: AppColors.success),
                const SizedBox(height: 12),
                Text(
                  'Chapter Quiz / Test',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizView(lessonId: lesson.id, lessonTitle: lesson.title),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: Text('TAKE TEST NOW', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );

      default:
        return Container();
    }
  }

  void _openPDF(String url) {
    if (url.isEmpty) return;
    // Route to secure viewer (Module 10) or download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF view will stream securely inside Module 10.')),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'VIDEO':
        return Icons.play_circle_filled;
      case 'LIVE':
        return Icons.live_tv;
      case 'RESOURCE':
      case 'ARTICLE':
        return Icons.description;
      case 'QUIZ':
        return Icons.quiz;
      default:
        return Icons.school;
    }
  }
}
