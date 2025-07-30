import 'package:flutter/material.dart';

class Emptyclass extends StatelessWidget {
  const Emptyclass({super.key});

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
                  '지금 비어 있는 강의실  ',
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
                  child: Text('강의실 보기'),
                ),
              ],
            ),
            Row(
              children: [
                Text('E동:',
                    style:smallText),
                SizedBox(width: 5,),
                Text('24',
                style: smallText,),
                SizedBox(width: 9,),
                Image.asset('assets/img/green.png')
              ],
            ),
            Row(
              children: [
                Text('G동:',
                    style:smallText),
                SizedBox(width: 5,),
                Text('14',
                  style: smallText,),
                SizedBox(width: 9,),
                Image.asset('assets/img/orange.png')
              ],
            ),
            Row(
              children: [
                Text('C동:',
                    style:smallText),
                SizedBox(width: 5,),
                Text('5',
                  style: smallText,),
                SizedBox(width: 9,),
                Image.asset('assets/img/red.png')
              ],
            ),

          ],
        ),
      ),
    );
  }
}
