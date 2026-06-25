import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:handori/features/empty_class/model/class_model.dart';
import 'package:handori/features/empty_class/repository/empty_class_repository.dart';

part 'empty_class_provider.g.dart';

// ── Repository ─────────────────────────────────────────────────────────────

@riverpod
EmptyClassRepository emptyClassRepository(Ref ref) {
  return FakeEmptyClassRepository();
}

// ── 빈 강의실 목록 ──────────────────────────────────────────────────────────

@riverpod
Future<List<EmptyClass>> emptyClasses(Ref ref) {
  return ref.watch(emptyClassRepositoryProvider).fetchEmptyClassesStatically();
}
