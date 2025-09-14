import 'package:flutter/material.dart';
import '../model/meal_model.dart';
import '../screen/maain_shell.dart';

class Todaymeal extends StatefulWidget {
  final List<Meal> meals;
  const Todaymeal({required this.meals, super.key});

  @override
  State<Todaymeal> createState() => _TodaymealState();
}

class _TodaymealState extends State<Todaymeal> {
  late final PageController _controller;
  double _pageValue = 0.0;

  @override
  void initState() {
    _controller = PageController(viewportFraction: 0.78);
    _controller.addListener(() {
      if (!mounted) return;
      setState(() => _pageValue = _controller.page ?? 0.0);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.meals.isEmpty) return const SizedBox.shrink();
    final mediumText = Theme.of(context).textTheme.displayMedium;

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.meals.length,
        itemBuilder: (context, index) {
          final m = widget.meals[index];

          final dist = (_pageValue - index).abs();
          final scale = 1 - (dist * 0.1).clamp(0.0, 0.1);
          final elevation = (8 - dist * 6).clamp(2.0, 8.0);

          return Transform.scale(
            scale: scale,
            child: Card(
              elevation: elevation,
              shadowColor: Colors.black.withOpacity(0.12),
              color: const Color(0xFFFDFEFE), // ✨ 은은한 배경색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: const Color(0xFF89DAF0).withOpacity(0.6),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 이름 + 보기 버튼
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.Name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: mediumText?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF005BBB),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () { MainShell.of(context)?.jumpTo(2);},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('보기',
                              style: TextStyle(color: Color(0xFF7A8FA6))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 메인 메뉴 강조
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F9FF),
                        borderRadius: BorderRadius.circular(8),
                        border:
                        Border.all(color: const Color(0xFF89DAF0), width: 1),
                      ),
                      child: Text(
                        m.mainDish,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mediumText?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0088CC),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 사이드 메뉴 칩 → 겹치지 않도록 runSpacing 수정
                    Wrap(
                      spacing: 6,
                      runSpacing: 6, // ✅ 겹침 제거
                      children: m.sideDishes.map((e) {
                        return Chip(
                          backgroundColor: const Color(0xFFF5F9FA),
                          label: Text(
                            e,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          visualDensity: const VisualDensity(
                              horizontal: -2, vertical: -2), // 조금 컴팩트
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        );
                      }).toList(),
                    ),
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