import 'package:flutter/material.dart';
import 'package:ipsfa/main.dart';


void showOverlaySnack(String message,String error) {
  final overlay = navigatorKey.currentState?.overlay;
  if (overlay == null) return;

  // Declarar la variable late
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _FadeOverlaySnack(
      message: message,
      overlayEntry: overlayEntry, // Pasar referencia para removerlo
      error:error
    ),
  );

  // Insertar en el overlay
  overlay.insert(overlayEntry);
}

class _FadeOverlaySnack extends StatefulWidget {
  final String message;
  final OverlayEntry overlayEntry;
  final String error;

  const _FadeOverlaySnack({
    required this.message,
    required this.overlayEntry,
    required this.error,
  });

  @override
  State<_FadeOverlaySnack> createState() => _FadeOverlaySnackState();
}

class _FadeOverlaySnackState extends State<_FadeOverlaySnack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward(); // Fade in

    Future.delayed(const Duration(seconds: 4), () async {
      await _controller.reverse(); // Fade out
      widget.overlayEntry.remove(); // ✅ Remover correctamente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          color: widget.error==''?Theme.of(context).colorScheme.primary:Colors.red,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(widget.error!=''?Icons.error_outline:Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

