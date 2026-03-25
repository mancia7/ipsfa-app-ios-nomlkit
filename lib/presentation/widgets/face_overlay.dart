import 'package:flutter/widgets.dart';

class FaceOverlay extends StatelessWidget {
  final String assetPath;

  const FaceOverlay({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(bottom: 55, 
      child: IgnorePointer(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 1,
            child: Opacity(
              opacity: 0.35,
              child: assetPath!=''?Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ):null,
            ),
          ),
        ),
      ),
    );
  }
}