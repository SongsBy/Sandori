import 'package:flutter/material.dart';

import '../model/meal_model.dart';



class Todaymeal extends StatefulWidget {
  final List<Meal> meals;
  const Todaymeal({required this.meals, super.key});

  @override
  State<Todaymeal> createState() => _TodaymealState();
}

class _TodaymealState extends State<Todaymeal> {
  late final PageController _controller;

  @override
  void initState() {
    _controller = PageController(viewportFraction: 0.7);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    if (widget.meals.isEmpty)return SizedBox.shrink();
    return SizedBox(
      height: 150,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        padEnds: false,
        itemCount: widget.meals.length,
        itemBuilder: (context, i) {
          final m = widget.meals[i];
          return SizedBox(
            width: 260,
            child: Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.Name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: mediumText?.copyWith(fontSize: 16),
                          ),
                        ),
                        TextButton(
                            onPressed: () {},
                            child: Text('보기', style:TextStyle(color: Colors.grey),
                            ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '대표메뉴: ${m.mainDish}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: mediumText?.copyWith(color: Color(0xFFFF6F00),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(m.sideDishes.join(' . '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: mediumText?.copyWith(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
