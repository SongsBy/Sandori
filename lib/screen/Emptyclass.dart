import 'package:flutter/material.dart';

class classStateInfo {
  final String className;
  final String classCount;
  final String trfficIcon;
  final List<String> classList;
  classStateInfo({
    required this.className,
    required this.classCount,
    required this.trfficIcon,
    required this.classList,
  });
}

class Emptyclass extends StatefulWidget {
  final List<classStateInfo> classstate;
  const Emptyclass({required this.classstate, super.key});

  @override
  State<Emptyclass> createState() => _EmptyclassState();
}

class _EmptyclassState extends State<Emptyclass> {
  late final PageController _controller;

  @override
  void initState() {
    _controller = PageController(viewportFraction: 0.49);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;
    if (widget.classstate.isEmpty) return SizedBox.shrink();
    return SizedBox(
      height: 300,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: _controller,

        padEnds: false,
        itemCount: widget.classstate.length,
        itemBuilder: (context, i) {
          final c = widget.classstate[i];
          return SizedBox(
            width: 220,
            child: Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          c.className,
                          style: mediumText?.copyWith(fontSize: 20),
                        ),

                        Text(
                          maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            c.classCount, style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Image.asset(
                            c.trfficIcon,
                            width: 30,
                            height: 22,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                        children: c.classList.map((item) => Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(item, style: TextStyle(color: Colors.black54),),
                        )).toList(),
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
