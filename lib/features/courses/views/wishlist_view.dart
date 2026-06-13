import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/course_provider.dart';
import 'course_detail_view.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final wishlist = courseProvider.wishlistCourses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Wishlist',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: wishlist.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final course = wishlist[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailView(course: course),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 100,
                              height: 60,
                              child: course.coverImageUrl != null
                                  ? Image.network(
                                      course.coverImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                    )
                                  : _buildPlaceholder(),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course.teachers.isNotEmpty
                                      ? 'By ${course.teachers.first}'
                                      : 'Sagar Instructor',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course.priceCents == 0 ? 'FREE' : '₹${course.priceINR}',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delete Icon
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.pink),
                            onPressed: () {
                              courseProvider.toggleWishlist(course.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
            Text(
              'Your Wishlist is Empty',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Bookmark courses by tapping the heart icon on any course details or overview card.',
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
      color: AppColors.border,
      child: const Center(
        child: Icon(Icons.school, size: 24, color: AppColors.textMuted),
      ),
    );
  }
}
