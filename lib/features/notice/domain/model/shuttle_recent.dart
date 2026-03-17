import 'package:handori/features/notice/domain/model/shuttle.dart';

class ShuttleRecent {
  final Shuttle primary;
  final Shuttle second;

  const ShuttleRecent({
    required this.primary,
    required this.second,
  });
}
