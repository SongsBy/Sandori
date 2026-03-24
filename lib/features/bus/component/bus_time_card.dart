import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/features/bus/presentation/provider/bus_image_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final busImagesAsync = ref.watch(busImagesProvider);
    final List<String?> imageUrls = busImagesAsync.valueOrNull ?? [];

    String? imageUrl(int index) =>
        index < imageUrls.length ? imageUrls[index] : null;

    final String from = _isReverse ? '정왕역' : '학교';
    final String to = _isReverse ? '학교' : '정왕역';
    final String stopName = _isReverse ? '정왕역 버스정류장' : '정문 버스정류장';
    final String destination = _isReverse ? '학교 방면' : '정왕역 방면';

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
                        style: mediumText?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: _primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '반대 방면',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                    '15분 후 출발',
                    style: mediumText?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
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
                    style: mediumText?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5A6B7A),
                          fontSize: 11.5,
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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
        style: TextStyle(
          color: fg,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
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
    final mediumText = Theme.of(context).textTheme.displayMedium;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F9FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBDE8F6)),
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
                  style: mediumText?.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF2F8C3B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mediumText?.copyWith(
                    fontSize: 14,
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
            style: mediumText?.copyWith(
              fontSize: 13.5,
              color: const Color(0xFFD63B3B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
