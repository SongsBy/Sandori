// lib/repository/empty_class_repository.dart
import '../model/class_model.dart';


abstract class EmptyClassRepository {
  Future<List<EmptyClass>> fetchEmptyClassesStatically();
}

/// 목(Mock) 데이터용 구현체
class FakeEmptyClassRepository implements EmptyClassRepository {
  @override
  Future<List<EmptyClass>> fetchEmptyClassesStatically() async {
    return [
      EmptyClass(
        className: 'E동 : ',
        classCount: '24',
        trafficIcon: 'assets/img/green.png',
        classIcons: 'assets/img/tukorea_computer.png',
        classList: ['E234', 'E303', 'E402', 'E220', 'E321', 'E502',],
        latitude: 37.33968,
        longitude: 126.7348,
      ),
      EmptyClass(
        className: 'C동 : ',
        classCount: '18',
        trafficIcon: 'assets/img/orange.png',
        classIcons: 'assets/img/tukorea_Energy.png',
        classList: ['C234', 'C303', 'C402', 'C220', 'C321', 'C502'],
        latitude: 37.34002,
        longitude:126.7339,
      ),
      EmptyClass(
        className: 'B동 : ',
        classCount: '10',
        trafficIcon: 'assets/img/red.png',
        classIcons: 'assets/img/tukorea_Materials.png',
        classList: ['B234', 'B303', 'B402', 'B220', 'B321', 'B502'],
        latitude: 37.34041,
        longitude: 126.7335,
      ),
      EmptyClass(
        className: 'G동 : ',
        classCount: '13',
        trafficIcon: 'assets/img/orange.png',
        classIcons: 'assets/img/tukorea_Mechanical.png',
        classList: ['G234', 'G303', 'G402', 'G220', 'G321', 'G502'],
        latitude: 37.34024,
        longitude:126.7347,
      ),
      EmptyClass(
        className: 'D동 : ',
        classCount: '20',
        trafficIcon: 'assets/img/green.png',
        classIcons: 'assets/img/tukorea_Electronic.png',
        classList: ['D234', 'D303', 'D402', 'D220', 'D321', 'D502'],
        latitude: 37.33968,
        longitude:126.7340
      ),
    ];
  }
}