import 'package:flutter/material.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/widgets/bullet_list.dart';
import 'package:ipsfa/screens/get_biometricos.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Indicaciones extends StatelessWidget {
  const Indicaciones({super.key});

  Future<void> _handleCameraAccess(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GetBiometricos(),
          ),
        );
      }
    } else {
      final newStatus = await Permission.camera.request();
      if (newStatus.isGranted) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GetBiometricos(),
            ),
          );
        }
      } else {
        await openAppSettings();
        // ignore: use_build_context_synchronously
        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '⚠️ Permiso denegado. Por favor, habilítalo en configuración.'),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => _handleCameraAccess(context),
            ),
          ),
        );*/
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<AuthController>(context);
    final textScale = MediaQuery.of(context).size.width;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          sessionManager.resetTimer(); // Reinicia el temporizador cuando el usuario hace scroll
        }
        return false; // Propaga la notificación
      },
      child: Scaffold(
        appBar: AppBar(title:  Text('Instrucciones',style: TextStyle(fontSize: 0.07 * textScale),)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('lib/assets/Instrucciones.png', height: 200),
              const SizedBox(height: 20),
              Text(
                'Bienvenido',
                style: TextStyle(
                    fontSize: 0.1 * textScale, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Favor seguir paso a paso las siguientes indicaciones para su registro de rostro para su control vivencia.',
                style: TextStyle(
                  fontSize: 0.059 * textScale,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Text(
                'Indicaciones:',
                style: TextStyle(
                    fontSize: 0.07 * textScale, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BulletList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _handleCameraAccess(context);
                  },
                  child: Text(
                    'Tomar fotografias',
                    style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).iconColor,
                        fontSize: 0.06 * textScale),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
