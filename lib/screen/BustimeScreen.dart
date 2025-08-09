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
      {'busImage':'assets/img/bus.png' , 'busNumber' : '33', 'goTo':'정왕역 방면', 'time': '2분'},
      {'busImage':'assets/img/bus.png' , 'busNumber' : '20-1','goTo':'정왕역 방면', 'time': '5분'},
    ];
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(
                    '셔틀버스 ',
                    style: mediumText!.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
              Text('15분 후 출발 ', style: mediumText?.copyWith(color: Colors.red)),
              SizedBox(height: 10),
              Text('정문 버스정류장', style: mediumText?.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),

              Column(
                children: nextBus.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Image.asset(item['busImage']),
                      SizedBox(width: 5),
                      Text(item['busNumber'], style: mediumText?.copyWith(color: Colors.green)),
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
