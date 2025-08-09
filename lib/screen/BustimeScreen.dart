import 'package:flutter/material.dart';

class Bustimescreen extends StatelessWidget {
  const Bustimescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;


    final List<Map<String , dynamic>>nextBus = [
      {'busNumber':'assets/img/bus33.png' , 'goTo':'정왕역 방면', 'time': '2분'},
      {'busNumber':'assets/img/bus21.png' , 'goTo':'정왕역 방면', 'time': '5분'},
    ];
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '셔틀버스 ',
                    style: mediumText!.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      textStyle: mediumText
                    ),
                    onPressed: () {},
                    child: Text('버스 시간표 상세보기'),
                  ),
                ],
              ),
              Text('15분 후 출발 ', style: mediumText?.copyWith(color: Colors.red)),
              SizedBox(height: 10),
              Text('정문 버스정류장', style: mediumText?.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),

              Column(
                children: nextBus.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Image.asset(item['busNumber']),
                      SizedBox(width: 9),
                      Text(item['goTo'], style: mediumText?.copyWith(color: Colors.grey)),
                      SizedBox(width: 9),
                      Text(item['time'], style:mediumText?.copyWith(color: Colors.red))
                    ],
                  ),
                )).toList()
              ),
            ],
          ),
        ),
      ),
    );
  }
}
