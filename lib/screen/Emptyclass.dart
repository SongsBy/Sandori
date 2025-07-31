import 'package:flutter/material.dart';

class Emptyclass extends StatelessWidget {
  const Emptyclass({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;
    final List<Map<String , dynamic>>emptyBuilding = [
      {'buildingName': 'E동' , 'emptyCount':'24', 'trafficLight': 'assets/img/green.png'},
      {'buildingName': 'G동' , 'emptyCount':'14', 'trafficLight': 'assets/img/orange.png'},
      {'buildingName': 'C동' , 'emptyCount':'5', 'trafficLight': 'assets/img/red.png'},
    ];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color(0xFFF5F8FC),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '지금 비어 있는 강의실  ',
                  style: mediumText?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      textStyle: mediumText
                  ),
                  onPressed: () {},
                  child: Text('강의실 보기'),
                ),
              ],
            ),
            Column(
              children: emptyBuilding.map((item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text((item['buildingName']),
                        style:mediumText),
                    SizedBox(width: 5,),
                    Text(item['emptyCount'],
                        style: mediumText),
                    SizedBox(width: 9,),
                    Image.asset(item['trafficLight'])
                  ],
                ),
              ),).toList()
            ),
          ],
        ),
      ),
    );
  }
}
