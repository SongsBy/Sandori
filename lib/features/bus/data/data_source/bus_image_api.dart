import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:handori/features/bus/data/dto/bus_image_response.dart';
import 'package:handori/features/bus/data/dto/bus_images_response.dart';

part 'bus_image_api.g.dart';

@RestApi()
abstract class BusImageApi {
  factory BusImageApi(Dio dio, {String? baseUrl}) = _BusImageApi;

  @GET('/bus/images')
  Future<BusImagesResponse> getAllBusImages();

  @GET('/bus/image/{index}')
  Future<BusImageResponse> getBusImageByIndex(@Path('index') int index);
}
