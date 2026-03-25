import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipsfa/Config/theme/app_theme.dart';
import 'package:ipsfa/infrastucture/classes/app_routes.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/widgets/session_wrapper.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  GeneralMethods general = GeneralMethods();

void main() {
  runZonedGuarded(() async {

    // 🔥 Ahora SÍ en la MISMA zona de runApp
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // 🔥 También en la misma zona
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      general.logError(details.exceptionAsString(), details.stack.toString());
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthController()),
        ],
        child: const AppIpsfa(),
      ),
    );

  }, (error, stackTrace) {
    general.logError(error.toString(), stackTrace.toString());
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Hubo un error. Favor comunicarlo al área correspondiente.'),
        backgroundColor: Colors.red,
      ),
    );
  });
}



class AppIpsfa extends StatelessWidget {
  const AppIpsfa({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionWrapper(
      child: MaterialApp(
        theme: AppTheme(
          selectedColor: context.watch<ThemeProvider>().themeSelector,
        ).theme(),
        initialRoute: '/login',
        routes: AppRoutes.routes,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
