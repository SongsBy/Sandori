import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:handori/core/network/static_info_dio_provider.dart';
import 'package:handori/features/bus/data/data_source/bus_image_api.dart';
import 'package:handori/features/bus/data/repository/bus_image_repository_impl.dart';
import 'package:handori/features/bus/domain/repository/bus_image_repository.dart';

part 'bus_image_provider.g.dart';

@riverpod
BusImageApi busImageApi(Ref ref) {
  final dio = ref.watch(staticInfoDioProvider);
  return BusImageApi(dio);
}

@riverpod
BusImageRepository busImageRepository(Ref ref) {
  final api = ref.watch(busImageApiProvider);
  return BusImageRepositoryImpl(api);
}

@riverpod
Future<List<String>> busImages(Ref ref) {
  final repo = ref.watch(busImageRepositoryProvider);
  return repo.getAllBusImageUrls();
}
