import 'package:flutter/material.dart';

class Banners {
  final List<String> banner;

  Banners({
    required this.banner});
}

class BannerTop extends StatefulWidget {
  final List<Banners> images;
  const BannerTop({
  required this.images,super.key,
});

  @override
  State<BannerTop> createState() => _BannerTopState();
}

class _BannerTopState extends State<BannerTop> {
  late final PageController _controller;
  @override
  void initState() {
    _controller = PageController(viewportFraction: 0.98);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty)return SizedBox.shrink();
    return SizedBox(
      height: 150,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          padEnds: false,
          itemCount: widget.images.length,
          itemBuilder: (context, i) {
            final m = widget.images[i];
            return SizedBox(
              width: 320,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.asset(m.banner.first, fit: BoxFit.fill),
                ),
              ),
            );
          }
      )
    );
  }
}