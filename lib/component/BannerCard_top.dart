import 'dart:async';
import 'package:flutter/material.dart';
import '../model/banner_model.dart';

class BannerTop extends StatefulWidget {
  final List<Banners> images;
  const BannerTop({
    required this.images,
    super.key,
  });

  @override
  State<BannerTop> createState() => _BannerTopState();
}

class _BannerTopState extends State<BannerTop> {
  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.95);

    // 3초마다 자동 슬라이드
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.hasClients && widget.images.isNotEmpty) {
        final nextPage = (_controller.page?.round() ?? 0) + 1;
        final targetPage = nextPage % widget.images.length;
        _controller.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        padEnds: false,
        itemCount: widget.images.length,
        itemBuilder: (context, i) {
          final m = widget.images[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                m.ImagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }
}