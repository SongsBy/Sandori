abstract class BusImageRepository {
  Future<List<String>> getAllBusImageUrls();
  Future<String> getBusImageUrl(int index);
}
