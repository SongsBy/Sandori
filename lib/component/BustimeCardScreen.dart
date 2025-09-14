import 'package:flutter/material.dart';

class Bustimescreen extends StatelessWidget {
  const Bustimescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;


    final List<Map<String, dynamic>> nextBus = [
      {
        'busImage': 'assets/img/bus.png',
        'busNumber': '33',
        'goTo': '정왕역 방면',
        'time': '2분'
      },
      {
        'busImage': 'assets/img/bus.png',
        'busNumber': '20-1',
        'goTo': '정왕역 방면',
        'time': '5분'
      },
    ];

    const primary = Color(0xFF0088CC);
    const subtleBg = Color(0xFFF7FBFD);
    const border = Color(0xFFE2EEF3);

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: subtleBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.directions_bus_rounded, color: primary, size: 20),
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
                  bg: const Color(0xFFE6F9FF),
                  fg: primary,
                  borderColor: const Color(0xFFBDE8F6),
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
            const Divider(height: 1, color: border),
            const SizedBox(height: 10),


            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18, color: primary),
                const SizedBox(width: 6),
                Text(
                  '정문 버스정류장',
                  style: mediumText?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),


            ...nextBus.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _BusTile(
                imagePath: item['busImage'],
                number: item['busNumber'],
                destination: item['goTo'],
                etaText: item['time'],
              ),
            )),

            const SizedBox(height: 4),


            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: subtleBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '도착 시간은 교통 상황에 따라 달라질 수 있어요.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }
}

/// 작은 배지
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

/// 버스 한 줄
class _BusTile extends StatelessWidget {
  final String imagePath;
  final String number;
  final String destination;
  final String etaText;

  const _BusTile({
    required this.imagePath,
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
          child: Image.asset(imagePath, fit: BoxFit.contain),
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