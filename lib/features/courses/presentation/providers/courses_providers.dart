import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/article_course_repository.dart';
import '../../../../data/repositories/repository_providers.dart';

/// Tous les articles de la liste de courses (à acheter + achetés), groupés
/// côté UI (cahier-des-charges.md §7.6). MVP v1 : origine manuelle
/// uniquement.
final articlesCourseProvider = StreamProvider<List<ArticleCourseDetail>>((ref) {
  return ref.watch(articleCourseRepositoryProvider).watchAll();
});
