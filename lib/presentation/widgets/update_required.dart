import 'package:flutter/material.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class UpdateRequired extends StatelessWidget {
  const UpdateRequired({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri playStoreUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=ipsfa.gob.sv.app',
  );
    final textScale = MediaQuery.of(context).size.width;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // Fondo claro
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Column(
          children: [
            SizedBox(height: 0.1 * textScale),
            Icon(Icons.system_update, size: 0.2 * textScale, color: Colors.orange,),
            SizedBox(height: 0.03 * textScale),
            Text(
              "Actualizacion requerida",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 0.11 * textScale,
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeProvider>(context,listen: false).iconColor
              ),
            ),
        
            SizedBox(height: 0.02 * textScale),
        
            Text(
              "Hay una actualizacion disponible, para brindarle un mejor servicio, favor actualizar la aplicacion. Gracias.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 0.07 * textScale,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 0.02*textScale,),

            InkWell(
              onTap: () async {
                if (await canLaunchUrl(playStoreUrl)) {
                  await launchUrl(
                    playStoreUrl,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text(
                  'Actualizar ahora',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.08 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}