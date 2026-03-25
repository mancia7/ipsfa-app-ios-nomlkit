import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:ipsfa/infrastucture/classes/app_routes.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:ipsfa/screens/pdf_viewer.dart';
import 'package:provider/provider.dart';
//import 'package:ipsfa/presentation/widgets/snackbar_message.dart';

// ignore: must_be_immutable
class OptionCard extends StatelessWidget {
  final String text;
  final String? logoPath;
  final String ruta;
  final String pdfUrl;
  
  GeneralMethods general = GeneralMethods();
  
  AppRoutes routes = AppRoutes();
  OptionCard(
      {super.key, required this.text, this.logoPath, required this.ruta,this.pdfUrl = ''});
  
  final TextEditingController _afiliacion = TextEditingController();
  final GlobalKey<FormState> afiliacionForm = GlobalKey<FormState>();
  
  Future<void> _navigateToScreen(BuildContext context) async {
    
       navigatorKey.currentState?.pushNamed(ruta);
    
  }

  Future<void> _abrirPdf(BuildContext context) async {
    
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(
          pdfUrl:
              pdfUrl,
          /*headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },*/
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
  
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    User usuario = Provider.of<UserProvider>(context,listen: false).user!;
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Verificación Requerida'),
            content: SizedBox(
                      width: 0.25 * screenHeight,
                      height: 0.12 * screenHeight,
                      child: Column(children: [
                        Form(
                          key: afiliacionForm,
                          child: TextFormField(
                            autofocus: true,
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _afiliacion,
                            keyboardType:  TextInputType.number,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              //label: Text('Ingresar afiliacion',style: TextStyle(fontSize: 0.07 * screenWidth),),
                              hintText: 'Afiliacion', 
                              icon: const Icon(Icons.numbers, size: 35),
                              iconColor:
                                  Provider.of<ThemeProvider>(context).iconColor,
                              hintStyle: TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresar afiliacion';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                       
                      ]),
                    ),
            actions: [
              TextButton(
                onPressed: () {
                  navigatorKey.currentState?.pop();
                },
                child: Text('Cancelar', style: TextStyle(fontSize: 0.055 * screenWidth)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (afiliacionForm.currentState!.validate()) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    if(_afiliacion.text==usuario.afiliacion){
                      navigatorKey.currentState?.pop();
                      _navigateToScreen(context);
                    }else{
                      showOverlaySnack('AFILIACION INGRESADA NO PERTENECE AL USUARIO','error');
                      
                    }
                  }
                },
                child:  Text('Validar', style: TextStyle(fontSize: 0.055 * screenWidth)),
              ),
            ],
          ),
        );
      },
    );
  }

  Offset? pointerDownPosition;
  bool isDragging = false;
  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    return Listener(

      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        pointerDownPosition = event.position;
        isDragging = false;
      },
      onPointerMove: (event) {
        if (pointerDownPosition == null) return;

        final distance =
            (event.position - pointerDownPosition!).distance;

        if (distance > 10) {
          isDragging = true; // 👈 el usuario está scrolleando
        }
      },
      onPointerUp: (event) {
        if (isDragging) return;
        if(pdfUrl.isNotEmpty && ruta!='/constancias'){
          _abrirPdf(context);  
        }else if(ruta=='/constancias'){
          _showVerificationDialog(context);
        }else{
          _navigateToScreen(context);
        }
      },
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.0),
        ),
        elevation: 20,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(width: 10),
              Image.asset(
                logoPath!,
                width: 90,
                height: 120,
              ),
              //Icon(Icons.tab,color: Theme.of(context).colorScheme.primary,size: 45,),
              const SizedBox(width: 20),
              Flexible(
                child: Text(
                  text,
                  style:
                      TextStyle(fontSize: 0.1 * textScale, color: Colors.white),
                  //overflow: TextOverflow.ellipsis,
                  //maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
