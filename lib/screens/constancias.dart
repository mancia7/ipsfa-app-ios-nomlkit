// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/constancia.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/option_card.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:provider/provider.dart';


class Constancias extends StatefulWidget {
  const Constancias({super.key});
  @override
  State<StatefulWidget> createState() => _Constancias();
}

class _Constancias extends State<Constancias> {
  GeneralMethods general = GeneralMethods();
    late Future<bool> estadoServicio;
    late Future<List> getConstancias;
  @override
  void initState() {
    final context = navigatorKey.currentState?.overlay?.context;
    super.initState();
    if (context == null) return;
    estadoServicio=  general.serviceConstanciaMaintenance();
    getConstancias=general.getConstancias();
    //validarLogin(context);
  }

  


  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<AuthController>(context);

    final textScale = MediaQuery.of(context).size.width;
    
    User usuario = context.watch<UserProvider>().user!;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionManager.startTimer(context);
    });
    return Scaffold(
        appBar: AppBar(title:  Text('Constancias',style: TextStyle(fontSize: 0.07 * textScale),)),
        body: FutureBuilder(
              future: estadoServicio,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                final inMaintenance = snapshot.data as bool;
                return  inMaintenance ? Center(
                        child: Column(
                          children: [
                            SizedBox(height: 0.1 * textScale),
                            Icon(Icons.build_circle, size: 0.2 * textScale, color: Colors.orange.shade400,),
                            SizedBox(height: 0.03 * textScale),
                            Text(
                              "Servicio en mantenimiento",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 0.07 * textScale,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(height: 0.02 * textScale),
                            Text(
                              "Disculpe las molestias, estamos trabajando para mejorar nuestros servicios.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 0.05 * textScale,
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),
                      ):
                  FutureBuilder(
                    future: getConstancias,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }


                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      final constancias = snapshot.data as List<Constancia>;
                      return ListView.builder(
                        itemCount: constancias.length,
                        itemBuilder: (context, index) {
                        final item = constancias[index];
                        return OptionCard(
                              text: item.text,
                              logoPath: item.logoPath,
                              ruta: '',
                              pdfUrl: '${item.pdfUrl}${usuario.afiliacion}',
                              );
                    });
                    }
                  );
              }
            ),
    );
  }
}
