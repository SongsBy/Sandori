import 'package:flutter/material.dart';

class Meal {
  final String Name;
  final String mainDIsh;
  final List<String> sideDish;
  Meal({required this.Name, required this.mainDIsh, required this.sideDish});
}

class Todaymeal extends StatelessWidget {
  final List<Meal> meals;
  const Todaymeal({required this.meals, super.key});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: meals.length,
        itemBuilder: (context, i) {
          final m = meals[i];
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
                      '대표메뉴: ${m.mainDIsh}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: mediumText?.copyWith(color: Color(0xFFFF6F00),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(m.sideDish.join(' . '),
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
