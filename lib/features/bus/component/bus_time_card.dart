import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';
import 'package:handori/features/bus/presentation/provider/bus_image_provider.dart';
import 'package:handori/features/bus/presentation/provider/next_shuttle_provider.dart';

const _primary = AppColors.primary;
const _subtleBg = AppColors.subtleBg;
const _border = AppColors.cardBorder;

class Bustimescreen extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  final bool showHeader;
  const Bustimescreen({this.onTap, this.showHeader = true, super.key});

  @override
  ConsumerState<Bustimescreen> createState() => _BustimescreenState();
}

class _BustimescreenState extends ConsumerState<Bustimescreen> {
  bool _isReverse = false; // false: 학교→정왕역 / true: 정왕역→학교

  /// 상세 화면과 동일한 [nextShuttleProvider] 결과를 홈 카드용 한 줄 텍스트로 변환.
  String _arrivalText(NextShuttle next) {
    final remain = next.remainMinutes;
    if (next.showsMinutes && remain != null && remain > 0) {
      return '$remain분 후 출발';
    }
    // 15분보다 멀면 분 숫자를 신뢰할 수 없어 안내하지 않는다.
    if (next.isBeyondCountdown) return '도착정보없음';
    if (next.status == ShuttleStatus.upcoming) return '곧 도착';
    return next.statusLabel ?? '운행 정보 없음';
  }

  @override
  Widget build(BuildContext context) {
    final busImagesAsync = ref.watch(busImagesProvider);
    final List<String?> imageUrls = busImagesAsync.valueOrNull ?? [];

    String? imageUrl(int index) =>
        index < imageUrls.length ? imageUrls[index] : null;

    final String from = _isReverse ? '정왕역' : '학교';
    final String to = _isReverse ? '학교' : '정왕역';
    final String stopName = _isReverse ? '정왕역 버스정류장' : '정문 버스정류장';
    final String destination = _isReverse ? '학교 방면' : '정왕역 방면';

    // 상세 화면과 동일한 방향 매핑 → 동일한 다음 셔틀 결과.
    final direction = _isReverse
        ? ShuttleDirection.jeongwangToSchool
        : ShuttleDirection.schoolToJeongwang;
    final nextShuttle = ref.watch(
      nextShuttleProvider(
        route: ShuttleRoute.route1,
        direction: direction,
      ),
    );

    final List<Map<String, dynamic>> nextBus = [
      {
        'busImage': imageUrl(0),
        'busNumber': '33',
        'goTo': destination,
        'time': '2분',
      },
      {
        'busImage': imageUrl(1),
        'busNumber': '20-1',
        'goTo': destination,
        'time': '5분',
      },
    ];

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _subtleBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '셔틀버스',
                        style: AppTextStyles.title03,
                      ),
                    ),
                    _Badge(
                      text: '운행 중',
                      bg: AppColors.primaryLight,
                      fg: _primary,
                      borderColor: AppColors.primaryBorder,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // 방향 표시 + 토글
              Row(
                children: [
                  _DirectionChip(label: from, isOrigin: true),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  _DirectionChip(label: to, isOrigin: false),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _isReverse = !_isReverse),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _subtleBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: _primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '반대 방면',
                            style: AppTextStyles.caption04.copyWith(
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    _arrivalText(nextShuttle),
                    style: AppTextStyles.caption01.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18, color: _primary),
                  const SizedBox(width: 6),
                  Text(
                    stopName,
                    style: AppTextStyles.caption01,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...nextBus.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _BusTile(
                    imageUrl: item['busImage'] as String?,
                    number: item['busNumber'] as String,
                    destination: item['goTo'] as String,
                    etaText: item['time'] as String,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _subtleBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: _primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '도착 시간은 교통 상황에 따라 달라질 수 있어요.',
                        style: AppTextStyles.caption04.copyWith(
                          color: const Color(0xFF5A6B7A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionChip extends StatelessWidget {
  final String label;
  final bool isOrigin;
  const _DirectionChip({required this.label, required this.isOrigin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOrigin ? _primary : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption02.copyWith(
          color: isOrigin ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color borderColor;

  const _Badge({
    required this.text,
    required this.bg,
    required this.fg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption04.copyWith(color: fg),
      ),
    );
  }
}

class _BusTile extends StatelessWidget {
  final String? imageUrl;
  final String number;
  final String destination;
  final String etaText;

  const _BusTile({
    required this.imageUrl,
    required this.number,
    required this.destination,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryBorder),
          ),
          padding: const EdgeInsets.all(6),
          child:
              imageUrl != null
                  ? Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, _, _) => Image.asset(
                          'assets/img/bus.png',
                          fit: BoxFit.contain,
                        ),
                  )
                  : Image.asset('assets/img/bus.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF9F0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCFEAD2)),
                ),
                child: Text(
                  number,
                  style: AppTextStyles.caption02.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption03.copyWith(
                    color: const Color(0xFF6B7A89),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFD1D1)),
          ),
          child: Text(
            etaText,
            style: AppTextStyles.caption02.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}
