import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:handori/common/repository/static_repository.dart';
import 'package:handori/features/home/model/banner_model.dart';

part 'home_static_provider.g.dart';

// ── 홈 배너 (정적 데이터) ────────────────────────────────────────────────────

@riverpod
List<Banners> banners(Ref ref) {
  return StaticDataRepository().banners;
}
