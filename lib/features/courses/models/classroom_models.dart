class LessonModel {
  final String id;
  final String title;
  final String slug;
  final String contentType;
  final String? youtubeUrl;
  final String? r2AssetUrl;
  final bool isPreview;
  final bool isCompleted;

  LessonModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.contentType,
    this.youtubeUrl,
    this.r2AssetUrl,
    this.isPreview = false,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      contentType: json['contentType'] ?? 'VIDEO',
      youtubeUrl: json['youtubeUrl'],
      r2AssetUrl: json['r2AssetUrl'],
      isPreview: json['isPreview'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class SectionModel {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  SectionModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    List<LessonModel> lessonsList = [];
    if (json['lessons'] != null && json['lessons'] is List) {
      lessonsList = (json['lessons'] as List)
          .map((l) => LessonModel.fromJson(l))
          .toList();
    }

    return SectionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      lessons: lessonsList,
    );
  }
}
