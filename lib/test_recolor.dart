import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:recolor_svg/recolor_svg.dart';

class TestRecolorScreen extends StatefulWidget {
  const TestRecolorScreen({super.key});

  @override
  State<TestRecolorScreen> createState() => _TestRecolorScreenState();
}

class _TestRecolorScreenState extends State<TestRecolorScreen> with TickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
    reverseDuration: const Duration(seconds: 3),
    animationBehavior: AnimationBehavior.preserve,
    // lowerBound: -.5,
    // upperBound: .5,
  );
  AnimationStatus _lastStatus = AnimationStatus.dismissed;
  double _seed = generateValue(min: 0, max: .3);

  @override
  void initState() {
    super.initState();

    _anim.addStatusListener((status) {
      if (status != _lastStatus) {
        setState(() {
          _lastStatus = status;
          _seed += generateValue(
            min: -.05,
            max: .05,
            excludeMax: .01,
            excludeMin: -.01,
          );
          print('New seed "$_seed"');
        });
      }
    });

    _anim
      ..forward()
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/brain.svg'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final value = _anim.value;
              final newSvg = recolorSvgRandom(
                svgContent: snapshot.data!,
              );

              final si = ScalableImage.fromSvgString(newSvg.newSvgContent);

              return ScalableImageWidget(
                si: si,
              );
            },
          );
        },
      ),
    );
  }
}
