import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../courses/providers/course_provider.dart';
import '../../courses/views/course_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
      context.read<CourseProvider>().fetchWishlist();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final filteredCourses = courseProvider.courses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Explore Courses',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              // Open cart (handled in Module 11)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Course Grid / List
          Expanded(
            child: courseProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : filteredCourses.isEmpty
                    ? Center(
                        child: Text(
                          'No courses found.',
                          style: GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await courseProvider.fetchCourses();
                        },
                        color: AppColors.accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];
                            final isWishlisted = courseProvider.wishlistedIds.contains(course.id);
                            
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Thumbnail with lock/level labels
                                    Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: course.coverImageUrl != null
                                              ? Image.network(
                                                  course.coverImageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                                                )
                                              : _buildPlaceholderImage(),
                                        ),
                                        Positioned(
                                          top: 12,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.surface.withOpacity(0.85),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              course.level.replaceAll('_', ' '),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: CircleAvatar(
                                            backgroundColor: AppColors.surface.withOpacity(0.85),
                                            child: IconButton(
                                              icon: Icon(
                                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                                color: isWishlisted ? Colors.pink : Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                courseProvider.toggleWishlist(course.id);
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    // Content details
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.title,
                                            style: Theme.of(context).textTheme.titleLarge,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          if (course.subtitle != null) ...[
                                            Text(
                                              course.subtitle!,
                                              style: Theme.of(context).textTheme.bodySmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                          ],
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                course.teachers.isNotEmpty
                                                    ? 'By ${course.teachers.join(", ")}'
                                                    : 'Sagar Instructor',
                                                style: GoogleFonts.inter(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                course.priceCents == 0 ? 'FREE' : '₹${course.priceINR}',
                                                style: GoogleFonts.outfit(
                                                  color: AppColors.success,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.school, size: 50, color: AppColors.textMuted),
      ),
    );
  }
}
