import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/classes/detect_gama.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/option_card.dart';
import 'package:ipsfa/presentation/widgets/my_app_bar.dart';
import 'package:ipsfa/presentation/widgets/tabla_vivencias.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:provider/provider.dart';


class ControlVivencia extends StatefulWidget {
  const ControlVivencia({super.key});

  @override
  State<StatefulWidget> createState() => _ControlVivencia();
}


  
class _ControlVivencia extends State<ControlVivencia> {
  GeneralMethods general = GeneralMethods();
  late DeviceLevel deviceLevel;
  bool lowEnd = false;
  late Future<bool> estadoServicio;
  @override
  void initState() {
    super.initState();
    initDevice();
      estadoServicio=  general.serviceVivenciaMaintenance();
  }

  Future<void> initDevice() async {
    deviceLevel = await DeviceClassifier.getDeviceLevel();
    lowEnd = deviceLevel == DeviceLevel.low;
    setState((){});
  }
  @override
  Widget build(BuildContext context)  {

    final sessionManager = Provider.of<AuthController>(context);

    final textScale = MediaQuery.of(context).size.width;
    
    User usuario = context.watch<UserProvider>().user!;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionManager.startTimer(context);
    });
    return Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: MyAppBar(
              title: 'Control vivencia',
            ),
          ),
          body: FutureBuilder(
            future: estadoServicio,
            /*Future.wait({
              general.isLowEndDevice(),
              general.serviceVivenciaMaintenance()
            }), */
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text("Error al validar el dispositivo");
              }

              final  inMaintenance = snapshot.data!;
              return SingleChildScrollView(
                  child: inMaintenance ? Center(
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
                      )
                      :
                      Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      SizedBox(
                        height: 0.05 * textScale,
                      ),
                      if(usuario.disponibleFotos=='S' && !lowEnd)
                      OptionCard(
                        text: 'Registrar rostro',
                        logoPath: 'lib/assets/checklist.png',
                        ruta: '/indicaciones'
                      ),
                      if(usuario.disponibleFotos=='S' && !lowEnd)
                      SizedBox(
                        height: 0.05 * textScale,
                      ),
                      if(usuario.disponibleFotos=='N' && usuario.aprobadoFotos=='N' && !lowEnd) 
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary, // Fondo claro
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary),
                        ),
                        child: Text(
                                "Esta pendiente la aprobacion de su enrolamiento.\n Luego podra realizar su vivencia y se le habilitara la opcion.\nGracias.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 0.09 * textScale,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                      ),
                      /*OptionCard(
                        text: 'Documentacion',
                        logoPath: 'lib/assets/folder.png',
                        ruta: '/cargarDocumentos'
                      ),
                      const SizedBox(
                        height: 50,
                      ), */
                      if(usuario.validoVivencia=='S'&& usuario.aprobadoFotos=='S' && !lowEnd && usuario.realizoVivencia=='N')
                      OptionCard(
                        text: 'Realizar Vivencia',
                        logoPath: 'lib/assets/facial_recognition_2.png',
                        ruta: '/validarVivencia'
                      ),
              
              
                      if(usuario.validoVivencia=='N' && usuario.aprobadoFotos=='S' && !lowEnd || usuario.realizoVivencia=='S')
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary, // Fondo claro
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary),
                        ),
                        child:  Row(
                          children: [
                            SizedBox(width: 0.05 * textScale),
                            Expanded(
                              child: Text(
                                "Usted esta al dia con su Control Vivencia.\nLa opcion se le habilitara nuevamente al estar en la fecha que debera realizar su Control Vivencia nuevamente.\nGracias.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:  0.09 * textScale,
                                  
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 0.05 * textScale,
                      ),
              
                      if(!lowEnd)
                        Center(
                        child:  Text( 
                                    'Mis Controles Vivencias',
                                    style: TextStyle(fontSize:  0.09 * textScale,fontWeight:FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                      ),
              
                      
                      if(!lowEnd)
                      TablaVivencias(afiliacion: usuario.afiliacion),  
                      
                      if(lowEnd)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary, // Fondo claro
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "¡Gracias por instalar nuestra app¡\n Lastimosamente su dispositivo no cuenta con los requisitos necesarios para utilizar este servicio.\nLe invitamos a utilizar otros medios para realizar su control de vivencia.\nGracias por su comprension.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 0.09 * textScale,
                                  
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
              
                      SizedBox(
                        height: 0.2 * textScale,
                      )    
                          
                    ]),
                );
            }
          ),
      );
  }
}
