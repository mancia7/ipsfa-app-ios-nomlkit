// ignore_for_file: use_build_context_synchronously

//import 'dart:async';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:ipsfa/db/database_helper.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/widgets/my_app_bar.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:ipsfa/presentation/widgets/update_required.dart';
import 'package:ipsfa/screens/frm_registro_afiliado.dart';
import 'package:ipsfa/screens/pagina_principal.dart';
import 'package:ipsfa/screens/politica_huella.dart';
import 'package:ipsfa/shared/auth/auth_biometric.dart';
//import 'package:ipsfa/screens/reestablecer_contrasenia.dart';
//import 'package:ipsfa/shared/auth/auth_biometric.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';

class Login extends StatefulWidget {
  final bool? timeOut;
  const Login({super.key, this.timeOut});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _dui = TextEditingController();
  //final TextEditingController _password = TextEditingController();
    final GlobalKey<FormState> loginForm = GlobalKey<FormState>();
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _resIsNotEmpty = false;
  bool _isHuella = true;
  String _ingresarCon='Dui';
  String _labelCheck='Activar';

  GeneralMethods general = GeneralMethods();
  //bool _obscureText = true;
  bool _isLoging = false;
  //bool _errorLogin = false;
  late Future<bool> estadoServicio;
  
  //MaskTextInputFormatter afiliacionFormater =
  //  MaskTextInputFormatter(mask: '########', filter: {"#": RegExp(r'[0-9]')});
  bool _aceptoHuella = false;
  MaskTextInputFormatter duiFormater =
    MaskTextInputFormatter(mask: '########-#', filter: {"#": RegExp(r'[0-9]')});
    bool updateRequired = false;

  final Uri playStoreUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=ipsfa.gob.sv.app',
  );


  @override
  void initState() {
    super.initState();
    estadoServicio=  general.serviceAppMaintenance();
    _checkBiometrics();
  _checkVersion();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkVersion() async {
    updateRequired = await checkForUpdate();
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

  void _checkBiometrics() async {
    bool available = await _biometricService.isBiometricAvailable();

    final db = await DatabaseHelper.instance.database;
    final res = await db.query(
      'huella',
        where: 'aceptoHuella = ?',
        whereArgs: ['1']
    );
    String aceptoHuella='0';
    if(res.isNotEmpty){
      aceptoHuella=res.first['aceptoHuella'].toString();
    }
    if(aceptoHuella=='1'){
      _resIsNotEmpty=true;
    }else{
      _isHuella=false;
    }
   
    if (available) {
      _biometricAvailable = available;
    }
    setState(() {
    });
  }

  void _loginWithFingerprint() async {
    final context = navigatorKey.currentState!.overlay!.context;
    bool authenticated = await _biometricService.authenticate();
    //bool dispositivoConectado = await tieneConexion();
    //print("Resultado autenticación: $authenticated");
  
    if (authenticated) {
      //print(dispositivoConectado);
      /*if (!dispositivoConectado) {
        general.showSnackBar(
            context, 'Error de conexion. Favor revisar su conexion a internet.',
            color: 'error');
        return; // No hay conexión a ninguna red
      }*/
      final db = await DatabaseHelper.instance.database;
      final res = await db.query(
        'huella',
        where: 'aceptoHuella = ?',
        whereArgs: ['1']
      );
      final idAfiliado=res.first['dui'].toString();
      final mostroMsj=res.first['mostroMsj'].toString();
      //print(idAfiliado);
      if (res.isNotEmpty) {
        if (!context.mounted) return;
        final auth = Provider.of<AuthController>(context, listen: false);
        await auth.login(context: context,username: idAfiliado,password: idAfiliado, loginHuella: authenticated,afiliacion: idAfiliado, );
      //print(auth.isLoggedIn);
      
      if(!auth.isLoggedIn) return;
      // Redirige al usuario a la pantalla principal o haz login
      general.redirigir(context, PaginaPrincipal(loginHuella: authenticated, mostroMsj: mostroMsj,));
      }
      
    } else {if (!context.mounted) return;
      setState(() {_isLoging=false;});
      showOverlaySnack('Autenticacion fallida.','error');
      //general.showSnackBar(context, 'Autenticacion fallida.', color: 'error');
    }
  }

  /*Future<bool> tieneConexion() async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();
    // Verifica si hay al menos una conexión válida
    if (!results.contains(ConnectivityResult.mobile) &&
        !results.contains(ConnectivityResult.wifi) &&
        !results.contains(ConnectivityResult.ethernet)) {
      return false;
    } else {
      try {
        final response = await http.get(Uri.parse("https://app.ipsfa.gob.sv")).timeout(const Duration(seconds: 3));
        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    //final _obscureText = context.read<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return updateRequired?
    const UpdateRequired()
    :Scaffold(
                              resizeToAvoidBottomInset: true,
                              appBar: const PreferredSize(
                                preferredSize: Size.fromHeight(75.0),
                                child: MyAppBar(
                  title: 'Inicio de sesion',
                                ),
                              ),
                              body: SingleChildScrollView(
                                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Form(
                    key: loginForm,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            'lib/assets/logo_ipsfa.png',
                            width: 200,
                            height: 200,
                          ),
                          
                          const SizedBox(
                            height: 50,
                          ),
                            if(!_isHuella)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: TextFormField(
                              inputFormatters: [duiFormater],
                              keyboardType:  TextInputType.number,
                              style: TextStyle(fontSize: 0.07 * screenWidth),
                              cursorHeight: 0.07 * screenWidth,
                              controller: _dui,
                              decoration: InputDecoration(
                                focusColor: Theme.of(context).colorScheme.primary,
                                labelText: 'Ingrese DUI',
                                labelStyle: TextStyle(fontSize: 0.09 * screenWidth),
                                icon: const Icon(Icons.person_outline, size: 50),
                                iconColor:
                                    Provider.of<ThemeProvider>(context,listen: false).iconColor,
                                hintStyle:
                                    TextStyle(fontSize: 0.09 * screenWidth),
                                errorStyle:
                                    TextStyle(fontSize: 0.065 * screenWidth),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Favor ingresar Dui';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          /*Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextFormField(
                              style: TextStyle(fontSize: 0.07 * screenWidth),
                              cursorHeight: 0.07 * screenWidth,
                              obscureText: _obscureText,
                              controller: _password,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () async {
                                    await Future.delayed(
                                        const Duration(milliseconds: 125));
                                    _obscureText = !_obscureText;
                                    setState(() {});
                                  },
                                ),
                                hintText: 'Ingrese contraseña',
                                icon: const Icon(
                                  Icons.password,
                                  size: 50,
                                ),
                                focusColor: Theme.of(context).colorScheme.primary,
                                iconColor:
                                    Provider.of<ThemeProvider>(context,listen: false).iconColor,
                                hintStyle:
                                    TextStyle(fontSize: 0.07 * screenWidth),
                                errorStyle:
                                    TextStyle(fontSize: 0.045 * screenWidth),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Favor completar contraseña';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),*/
                          const SizedBox(
                            height: 10,
                          ),
                            if(!_isHuella)
                          ElevatedButton( 
                            style: ElevatedButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 30),),
                              onPressed: () {
                                if (loginForm.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                  
                                  setState(() {
                                    _isLoging = true;
                                    //_errorLogin = false;
                                  });
                                  _submit(context);
                                }
                              },
                              child: SizedBox(
                                width:  0.55 * screenWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                  if (!_isLoging)
                                    Icon( 
                                      color: Colors.white,
                                      Icons.login,
                                      size: 0.12 * screenWidth,
                                    ),
                                    const SizedBox(width: 10,),
                                    if (_isLoging)
                                      Padding(
                                        padding: const EdgeInsetsGeometry.all(5),
                                        child: SizedBox(
                                          height: screenWidth * 0.122,
                                          width: screenWidth * 0.122,
                                          child: CircularProgressIndicator(
                                            color:Provider.of<ThemeProvider>(context,listen:false).iconColor,
                                        )),
                                      ),
                                    if (!_isLoging)
                                      Flexible(
                                        child: Text(
                                          'Ingresar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 0.11 * screenWidth,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                        ),
                                      )
                                  ] 
                                ),
                              )
                            ),
                            if(_biometricAvailable && !_isHuella)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10), 
                                Transform.scale(
                                  scale: 0.0035 * screenWidth, // 🔹 Aumenta el tamaño del checkbox
                                  child: Checkbox(
                                    value: _aceptoHuella,
                                    activeColor: Theme.of(context).colorScheme.primary, // Color cuando está seleccionado
                                    onChanged: (value) {
                                      setState(() {
                                        _aceptoHuella = value!;
                                      });
                                    },
                                  ),
                                ),
                                Center(
                                    child: Text(
                                      '$_labelCheck huella',
                                      style: TextStyle(
                                        fontSize: 0.080 * screenWidth, // 🔹 Tamaño del texto
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    textAlign: TextAlign.justify,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if(_biometricAvailable)
                          const SizedBox(
                            height: 10,
                          ),
                          _resIsNotEmpty && _isHuella
                              ? ElevatedButton(
                  
                                    child: _isLoging ?
                                      Padding(
                                        padding: const EdgeInsetsGeometry.all(0),
                                        child: SizedBox(
                                          height: screenWidth * 0.1222,
                                          width: screenWidth * 0.122,
                                          child: CircularProgressIndicator(
                                            color:Provider.of<ThemeProvider>(context,listen:false).iconColor,
                                        )),
                                      )
                                      :Icon(
                                      Icons.fingerprint,
                                      size: 0.15 * screenWidth,
                                    ),
                                    onPressed: () {
                                      _loginWithFingerprint();
                                      setState(() {
                                        _isLoging = true;
                                      });
                                      },
                                  )
                              : const SizedBox(
                                height: 0,
                              ),
                              const SizedBox(
                                height: 1,
                              ),
                          if(_resIsNotEmpty)
                            Text('O',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                fontSize: 0.08 * screenWidth
                                ,fontWeight: FontWeight.bold),
                  
                          ),
                          if(_resIsNotEmpty)
                              Center(
                                child: InkWell(
                                  child: Text(
                                    'Ingresar con $_ingresarCon',
                                    style: TextStyle(
                                        fontSize: 0.080 * screenWidth,
                                        color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                                  ),
                                  onTap: () {
                                    if(_ingresarCon=='Huella'){
                                      
                                      _loginWithFingerprint();
                                      setState(() {
                                        _isLoging = true;
                                        _isHuella=true;
                                      });
                                    }else{
                                      _labelCheck=_labelCheck=='Activar'?'Desactivar':_labelCheck;
                                      //_biometricAvailable=!_biometricAvailable;
                                      //_resIsNotEmpty=!_resIsNotEmpty;
                                      _isHuella=false;
                                    }
                                    setState(() {
                                      _ingresarCon=_isHuella?'Dui':'Huella';
                                    });
                                  })
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          
                          /*Center(
                              child: InkWell(
                                  child: Text(
                                    '¿Olvide la contraseña?',
                                    style: TextStyle(
                                        fontSize: 0.080 * screenWidth,
                                        color: Colors.blue),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                           ReestablecerContrasenia(),
                                      ),
                                    );
                                  })),
                          const SizedBox(height: 25,),
                          Text(
                              textAlign: TextAlign.center,
                              'Si no posee ACCESO ',
                              style: TextStyle(
                                  fontSize: 0.075 * screenWidth,
                                  color: Provider.of<ThemeProvider>(context,listen: false).iconColor,
                                  fontWeight: FontWeight.bold),
                          ),*/
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                           const FormRegisterUser(),
                                      ),
                                    );
                              },
                              child:SizedBox(
                                width:  0.75 * screenWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Icon(
                                      Icons.app_registration,
                                      size: 0.11 * screenWidth,
                                    ),
                                    const SizedBox(width: 10,),
                                    Flexible(
                                      child: Text(
                                        'Registrarme',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 0.11 * screenWidth,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                      ),
                                    )
                                  ] 
                                ),
                              )
                              ),
                              /*if (_errorLogin)
                            Center(
                              child: Text(
                                'Dui no registrado',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 0.08 * screenWidth,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),*/
                        ],
                      ),
                    ),
                  ),
                ),
              )
            );
  }

  void _submit(BuildContext context) async {
    /*ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content:  const Text('text',
          style: TextStyle(fontSize: 20),) ,backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,margin: const EdgeInsets.all(16), // separación de bordes
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // 🔥 esquinas redondeadas
    ),duration: const Duration(seconds: 5),
    ),
      );*/
      final db = await DatabaseHelper.instance.database;
      final res = await db.query(
        'huella',
        where: 'dui = ?',
        whereArgs: [_dui.text]
      );
      final huella = {
      'aceptoHuella': 0,
      'dui': _dui.text,
      'mostroMsj':0
    };
    String mostroMsj='0';
    if(res.isEmpty){
      await DatabaseHelper().insertHuella(huella);
    }else{
      /*final id=res.first['id'].toString();
      final huella = {
        'id':id,
        //'dui': _dui.text,
        'mostroMsj':1
      };
      await DatabaseHelper().updateHuella(huella);*/
      mostroMsj=res.first['mostroMsj'].toString();
    }
    final auth = Provider.of<AuthController>(context, listen: false);
    await auth.login(
        context: context, username: _dui.text, password: _dui.text);
    //print(auth.noAuthError);
    if (auth.isLoggedIn) {
      if(_aceptoHuella && _labelCheck=='Activar'){
        bool authenticated = await _biometricService.authenticate();
      
        if (authenticated) {
          general.redirigir(
          context,
          const PoliticaHuellaScreen());
        }else{
          _isLoging = false;
          setState(() {});
          showOverlaySnack('Autenticacion fallida. No se activo la huella.','error');
          return;
        }
        
      }else if (_aceptoHuella){

      final filasEliminadas = await DatabaseHelper().deleteHuella(_dui.text);
      //print(filasEliminadas);
      String background;
      String text='';
      if(filasEliminadas>0){
        background='';
        text='Funcion Iniciar con Huella DESACTIVADA';
      }else{
        background='error';
        text='El DUI no coincide. Funcion NO DESACTIVADA';
      }
      showOverlaySnack(text,background!=''?'error':'');
      /*ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content:  Text(text,
          style: const TextStyle(fontSize: 20),) ,backgroundColor: background,),
      );*/
      _isLoging = false;
       general.redirigir(
          context,
          PaginaPrincipal(
            loginHuella: false,
            mostroMsj:mostroMsj
          ));
      }else{
        general.redirigir(
          context,
          PaginaPrincipal(
            loginHuella: false,
            mostroMsj:mostroMsj
          ));
      }
      
    } else if (!auth.noAuthError) {
      _isLoging = false;
      //_errorLogin = true;
      showOverlaySnack('Dui no REGISTRADO. Favor registrar.','error');
    } else {
      _isLoging = false;
    }
    setState(() {});
  }
}
