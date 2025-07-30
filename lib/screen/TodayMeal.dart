import 'package:flutter/material.dart';
class Todaymeal extends StatelessWidget {
  const Todaymeal({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color(0XFFF5F8FC),
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
                  style: TextTheme.of(
                    context,
                  ).displayLarge!.copyWith(fontSize: 22),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 15)
                  ),
                  onPressed: () {},
                  child: Text('전체식당보기'),
                ),
              ],
            ),
            Text('대표메뉴: 제육덮밥',
                style:smallText),
            SizedBox(height: 10),
            Text('두부 미소국',
              style: smallText,),
            Text('배추김치',
              style: smallText,),
            Text('요구르트',
              style: smallText,),
          ],
        ),
      ),
    );
  }
}
