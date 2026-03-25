import 'package:flutter/material.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:provider/provider.dart';

class SessionWrapper extends StatefulWidget {
  final Widget child;

  const SessionWrapper({super.key, required this.child});

  @override
  State<SessionWrapper> createState() => _SessionWrapperState();
}

class _SessionWrapperState extends State<SessionWrapper>
    with WidgetsBindingObserver {
  late AuthController sessionManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionManager = Provider.of<AuthController>(context, listen: false);
    sessionManager.startTimer(context); // inicia el timer aquí
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
    final expired = await sessionManager.hasSessionExpired();
    if (expired) {
      sessionManager.onTimeout();
    } else {
      sessionManager.resetTimer();
    }
  }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<AuthController>(context, listen: false);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => sessionManager.resetTimer(),
      child: widget.child,
    );
  }
}
