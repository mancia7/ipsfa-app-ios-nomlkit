// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/option_card.dart';
import 'package:ipsfa/presentation/widgets/my_app_bar.dart';
import 'package:ipsfa/presentation/widgets/update_required.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:provider/provider.dart';

class PaginaPrincipal extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final loginHuella;
  final String mostroMsj;
  const PaginaPrincipal({super.key, this.loginHuella=false,required this.mostroMsj});
  @override
  State<StatefulWidget> createState() => _PaginaPrincipal();
}

class _PaginaPrincipal extends State<PaginaPrincipal> { 
  GeneralMethods general = GeneralMethods();
    bool updateRequired = false;
  late Future<bool> estadoServicio;
  //final TextEditingController _afiliacion = TextEditingController();
  //final GlobalKey<FormState> afiliacionForm = GlobalKey<FormState>();

  

  @override
  void initState() {
    final context = navigatorKey.currentState?.overlay?.context;
    super.initState();
    _checkVersion();
    if (context == null) return;
      estadoServicio=  general.serviceAppMaintenance();
    //validarLogin(context);
  }
  Future<void> _checkVersion() async {
    updateRequired = await checkForUpdate();
    if(!updateRequired &&widget.mostroMsj=='0'){
      Future.microtask(() {
        general.showPolicy(context);
      });
    }
    setState(() {});
  }
  Future<bool> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability ==
          UpdateAvailability.updateAvailable;
    } catch (e) {
      return false;
    }
  }
  /*void _login(
    BuildContext context,
  ) async {
    final auth = Provider.of<AuthController>(context, listen: false);
    await auth.login(
        context: context, loginHuella: true, afiliacion: _afiliacion.text);
    if (auth.noData) {
      general.showSnackBar(context, 'No se encuentra afiliacion, o usuario aun NO APROBADO',
          color: 'Error');
      setState(() {});
    } else {
      general.showSnackBar(context, 'Afiliacion correcta. Bienvenido');
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.of(context).pop();
    }
  }

  void _backToLogin(BuildContext context) {
    Navigator.push(
      context,
    MaterialPageRoute(builder: (context) => const Login())
    );
  }*/

  void validarLogin(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);
    //print(auth);
    if (!auth.isLoggedIn) {
      Future.microtask(() {
        general.redirigir(context, const Login());
      });
    } 
  }

  /*void _showVerificationDialog() {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    User usuario = Provider.of<UserProvider>(context,listen: false).user!;
    showDialog(
      context: context,
      barrierDismissible: false, // 👈 obligatorio verificar
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Verificación Requerida'),
            content: SizedBox(
                      width: 0.25 * screenHeight,
                      height: 0.10 * screenHeight,
                      child: Column(children: [
                        Form(
                          key: afiliacionForm,
                          child: TextFormField(
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _afiliacion,
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
                                return 'Favor ingresar afiliacion';
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
                  navigatorKey.currentState?.pushNamed('/paginaPrincipal');
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (afiliacionForm.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                    if(_afiliacion.text==usuario.afiliacion){
                      Navigator.of(context).pop();
                    }else{
                      showOverlaySnack('AFILIACION INGRESADA NO PERTENECE AL USUARIO','error');
                      
                    }
                  }
                },
                child: const Text('Validar'),
              ),
            ],
          ),
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<AuthController>(context);

    final textScale = MediaQuery.of(context).size.width;
    
    User usuario = Provider.of<UserProvider>(context,listen: false).user!;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionManager.startTimer(context);
    });



    return updateRequired?
    const UpdateRequired()
    :Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(75.0),
          child: MyAppBar(
            title: 'Menu principal',
          ),
        ),
        body: PopScope(
          canPop: false,
            child: SingleChildScrollView(
              child: Center(
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50, // Fondo claro
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.celebration, color: Colors.blue.shade400, size: 0.09 * textScale,),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "¡Bienvenido a nuestra app!\nPuedes seleccionar los siguientes servicios.",
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontSize: 0.05 * textScale,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 0.008 * textScale,
                          ),
                          if(int.parse(usuario.esReafiliado)>0 )
                          OptionCard(
                            text: 'Control Vivencia',
                            logoPath: 'lib/assets/control_vivencia.png',
                            ruta: '/controlVivencia'
                          ),
                    
                          if(int.parse(usuario.validoConstancias)>0)
                          const SizedBox(
                            height: 20,
                          ),
                          if(int.parse(usuario.validoConstancias)>0 )
                          OptionCard(
                            text: 'Constancias',
                            logoPath: 'lib/assets/constancias_img.png',
                            ruta: '/constancias'
                          ),
                    
                          if(int.parse(usuario.creditoService)>0 )
                          const SizedBox(
                            height: 20,
                          ),
                          if(int.parse(usuario.creditoService)>0 )
                          OptionCard(
                              text: 'Solicitud de prestamos',
                              logoPath: 'lib/assets/prestamos.png',
                              ruta: '/prestamos'
                              ),
                          
                          if(int.parse(usuario.carneService)>0 )
                          const SizedBox(
                            height: 20,
                          ),
                          if(int.parse(usuario.carneService)>0 )
                          OptionCard(
                              text: 'Carnet digital',
                              logoPath: 'lib/assets/carne_img.png',
                              ruta: '',
                              pdfUrl: 'https://app.ipsfa.gob.sv/sac/carneApi/${usuario.afiliacion}',
                              ),
                          const SizedBox(
                            height: 20,
                          ),
                    
                        ]),
                      ),
            ),
                  ),
                );
  }
}