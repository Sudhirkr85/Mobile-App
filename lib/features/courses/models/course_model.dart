class CourseModel {
  final String id;
  final String title;
  final String slug;
  final String? subtitle;
  final String? description;
  final String? coverImageUrl;
  final int priceCents;
  final String level;
  final List<String> teachers;
  final int progressPercent;
  final bool isEnrolled;

  CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    this.subtitle,
    this.description,
    this.coverImageUrl,
    required this.priceCents,
    required this.level,
    required this.teachers,
    this.progressPercent = 0,
    this.isEnrolled = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Parse teachers display name
    List<String> teachersList = [];
    if (json['teachers'] != null && json['teachers'] is List) {
      for (var teacherItem in json['teachers']) {
        if (teacherItem['teacher'] != null && teacherItem['teacher']['name'] != null) {
          teachersList.add(teacherItem['teacher']['name']);
        }
      }
    }

    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      subtitle: json['subtitle'],
      description: json['description'],
      coverImageUrl: json['coverImageUrl'],
      priceCents: json['priceCents'] ?? 0,
      level: json['level'] ?? 'ALL_LEVELS',
      teachers: teachersList,
      progressPercent: json['progressPercent'] ?? 0,
      isEnrolled: json['isEnrolled'] ?? false,
    );
  }

  double get priceINR => priceCents / 100.0;
}
