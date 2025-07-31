import 'package:flutter/material.dart';

class Todaymeal extends StatelessWidget {
  const Todaymeal({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;
    final List<Map<String, dynamic>> Meal = [
      {
        'mainDish': '재육 덮밥',
        'sideDish': ['두부 미소국', '배추김치', '요구르트'],
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color(0xFFF5F8FC),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'E동 학생식당 ',
                  style: mediumText?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    textStyle: mediumText,
                  ),
                  onPressed: () {},
                  child: Text('전체식당보기'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  Meal.map((item) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '대표메뉴: ${item['mainDish']}',
                          style: mediumText?.copyWith(color: Color(0XFFFF6F00)),
                        ),
                        SizedBox(height: 10),
                        ...(item['sideDish'] as List<String>).map(
                          (dish) => Text(
                            dish,
                            style: mediumText?.copyWith(color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
