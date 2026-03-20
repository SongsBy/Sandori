import 'package:handori/features/bus/data/data_source/bus_image_api.dart';
import 'package:handori/features/bus/domain/repository/bus_image_repository.dart';

class BusImageRepositoryImpl implements BusImageRepository {
  final BusImageApi _api;

  const BusImageRepositoryImpl(this._api);

  @override
  Future<List<String>> getAllBusImageUrls() async {
    final response = await _api.getAllBusImages();
    return response.toDomain();
  }

  @override
  Future<String> getBusImageUrl(int index) async {
    final response = await _api.getBusImageByIndex(index);
    return response.imageUrl;
  }
}
