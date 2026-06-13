import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/courses/models/course_model.dart';
import 'package:student_app/features/courses/models/classroom_models.dart';
import 'package:student_app/features/store/models/product_model.dart';

void main() {
  group('CourseModel Parsing & Validation (50 Tests)', () {
    // We will run a loop of test cases to verify 50 variations of inputs to ensure robust model parsing.
    final list = List.generate(25, (index) => index);
    
    for (var i in list) {
      test('CourseModel JSON parsing variation #$i', () {
        final json = {
          'id': 'course-$i',
          'title': 'Course Title $i',
          'slug': 'course-slug-$i',
          'subtitle': 'Subtitle $i',
          'description': 'Description $i',
          'coverImageUrl': 'https://sagarcoaching.com/img-$i.png',
          'priceCents': i * 1000,
          'level': 'ALL_LEVELS',
          'teachers': [
            {
              'teacher': {
                'name': 'Teacher Name $i'
              }
            }
          ],
          'progressPercent': i * 2,
          'isEnrolled': i % 2 == 0,
        };

        final course = CourseModel.fromJson(json);

        expect(course.id, 'course-$i');
        expect(course.title, 'Course Title $i');
        expect(course.slug, 'course-slug-$i');
        expect(course.subtitle, 'Subtitle $i');
        expect(course.description, 'Description $i');
        expect(course.coverImageUrl, 'https://sagarcoaching.com/img-$i.png');
        expect(course.priceCents, i * 1000);
        expect(course.priceINR, i * 10.0);
        expect(course.level, 'ALL_LEVELS');
        expect(course.teachers, contains('Teacher Name $i'));
        expect(course.progressPercent, i * 2);
        expect(course.isEnrolled, i % 2 == 0);
      });

      test('CourseModel Fallback validation variation #$i', () {
        final json = {
          'id': 'course-fallback-$i',
          'title': 'Fallback Course $i',
        };

        final course = CourseModel.fromJson(json);

        expect(course.id, 'course-fallback-$i');
        expect(course.title, 'Fallback Course $i');
        expect(course.slug, '');
        expect(course.subtitle, isNull);
        expect(course.description, isNull);
        expect(course.coverImageUrl, isNull);
        expect(course.priceCents, 0);
        expect(course.priceINR, 0.0);
        expect(course.level, 'ALL_LEVELS');
        expect(course.teachers, isEmpty);
        expect(course.progressPercent, 0);
        expect(course.isEnrolled, isFalse);
      });
    }
  });

  group('ProductModel Parsing & Discount Logic (30 Tests)', () {
    final list = List.generate(15, (index) => index);

    for (var i in list) {
      test('ProductModel JSON parsing & discount percentage calculation #$i', () {
        final originalPrice = (i + 1) * 1000; // e.g., 1000, 2000, 3000...
        final currentPrice = (i + 1) * 800; // e.g., 800, 1600, 2400...

        final json = {
          'id': 'prod-$i',
          'title': 'Product Title $i',
          'slug': 'prod-slug-$i',
          'description': 'Product description $i',
          'coverImageUrl': 'https://sagarcoaching.com/prod-$i.png',
          'priceCents': currentPrice,
          'originalPriceCents': originalPrice,
          'productType': i % 2 == 0 ? 'PHYSICAL_BOOK' : 'DIGITAL_RESOURCE',
          'inventoryCount': i + 5,
        };

        final product = ProductModel.fromJson(json);

        expect(product.id, 'prod-$i');
        expect(product.title, 'Product Title $i');
        expect(product.slug, 'prod-slug-$i');
        expect(product.description, 'Product description $i');
        expect(product.coverImageUrl, 'https://sagarcoaching.com/prod-$i.png');
        expect(product.priceCents, currentPrice);
        expect(product.priceINR, currentPrice / 100.0);
        expect(product.originalPriceCents, originalPrice);
        expect(product.originalPriceINR, originalPrice / 100.0);
        expect(product.discountPercent, 20); // 20% discount (1000 - 800 = 200 / 1000 = 20%)
        expect(product.productType, i % 2 == 0 ? 'PHYSICAL_BOOK' : 'DIGITAL_RESOURCE');
        expect(product.inventoryCount, i + 5);
      });

      test('ProductModel Fallback checks #$i', () {
        final json = {
          'id': 'prod-fallback-$i',
          'title': 'Fallback Product $i',
          'priceCents': (i + 1) * 100,
        };

        final product = ProductModel.fromJson(json);

        expect(product.id, 'prod-fallback-$i');
        expect(product.title, 'Fallback Product $i');
        expect(product.slug, '');
        expect(product.description, isNull);
        expect(product.coverImageUrl, isNull);
        expect(product.priceCents, (i + 1) * 100);
        expect(product.priceINR, (i + 1) * 1.0);
        expect(product.originalPriceCents, isNull);
        expect(product.originalPriceINR, isNull);
        expect(product.discountPercent, 0);
        expect(product.productType, 'DIGITAL_RESOURCE');
        expect(product.inventoryCount, isNull);
      });
    }
  });

  group('LessonModel Parsing & Validation (10 Tests)', () {
    final list = List.generate(5, (index) => index);

    for (var i in list) {
      test('LessonModel Parsing #$i', () {
        final json = {
          'id': 'lesson-$i',
          'title': 'Lesson Title $i',
          'slug': 'lesson-slug-$i',
          'contentType': i % 2 == 0 ? 'VIDEO' : 'PDF',
          'youtubeUrl': 'https://youtube.com/watch?v=$i',
          'r2AssetUrl': 'https://r2.sagarcoaching.com/asset-$i.pdf',
          'isPreview': i % 3 == 0,
          'isCompleted': i % 4 == 0,
        };

        final lesson = LessonModel.fromJson(json);

        expect(lesson.id, 'lesson-$i');
        expect(lesson.title, 'Lesson Title $i');
        expect(lesson.slug, 'lesson-slug-$i');
        expect(lesson.contentType, i % 2 == 0 ? 'VIDEO' : 'PDF');
        expect(lesson.youtubeUrl, 'https://youtube.com/watch?v=$i');
        expect(lesson.r2AssetUrl, 'https://r2.sagarcoaching.com/asset-$i.pdf');
        expect(lesson.isPreview, i % 3 == 0);
        expect(lesson.isCompleted, i % 4 == 0);
      });

      test('LessonModel Fallback Parsing #$i', () {
        final json = {
          'id': 'lesson-fallback-$i',
          'title': 'Fallback Lesson $i',
        };

        final lesson = LessonModel.fromJson(json);

        expect(lesson.id, 'lesson-fallback-$i');
        expect(lesson.title, 'Fallback Lesson $i');
        expect(lesson.slug, '');
        expect(lesson.contentType, 'VIDEO');
        expect(lesson.youtubeUrl, isNull);
        expect(lesson.r2AssetUrl, isNull);
        expect(lesson.isPreview, isFalse);
        expect(lesson.isCompleted, isFalse);
      });
    }
  });

  group('SectionModel Parsing & Validation (10 Tests)', () {
    final list = List.generate(5, (index) => index);

    for (var i in list) {
      test('SectionModel JSON Parsing with lessons #$i', () {
        final json = {
          'id': 'sec-$i',
          'title': 'Section Title $i',
          'lessons': [
            {
              'id': 'sec-lesson-$i-1',
              'title': 'Section Lesson 1',
              'slug': 'sec-lesson-1',
              'contentType': 'VIDEO',
              'isPreview': true,
              'isCompleted': false,
            },
            {
              'id': 'sec-lesson-$i-2',
              'title': 'Section Lesson 2',
              'slug': 'sec-lesson-2',
              'contentType': 'PDF',
              'isPreview': false,
              'isCompleted': true,
            }
          ]
        };

        final section = SectionModel.fromJson(json);

        expect(section.id, 'sec-$i');
        expect(section.title, 'Section Title $i');
        expect(section.lessons.length, 2);
        
        expect(section.lessons[0].id, 'sec-lesson-$i-1');
        expect(section.lessons[0].title, 'Section Lesson 1');
        expect(section.lessons[0].contentType, 'VIDEO');
        expect(section.lessons[0].isPreview, isTrue);
        expect(section.lessons[0].isCompleted, isFalse);

        expect(section.lessons[1].id, 'sec-lesson-$i-2');
        expect(section.lessons[1].title, 'Section Lesson 2');
        expect(section.lessons[1].contentType, 'PDF');
        expect(section.lessons[1].isPreview, isFalse);
        expect(section.lessons[1].isCompleted, isTrue);
      });

      test('SectionModel Fallback empty check #$i', () {
        final json = {
          'id': 'sec-fallback-$i',
          'title': 'Fallback Section $i',
        };

        final section = SectionModel.fromJson(json);

        expect(section.id, 'sec-fallback-$i');
        expect(section.title, 'Fallback Section $i');
        expect(section.lessons, isEmpty);
      });
    }
  });
}
