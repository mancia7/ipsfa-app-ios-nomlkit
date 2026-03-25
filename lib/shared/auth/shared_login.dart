// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/message_dialog.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _noAuthError = false;

  GeneralMethods general = GeneralMethods();
  Timer? _timer;
  final sessionDuration = const Duration(minutes: 5); // Tiempo de sesión
  static const _lastActivityKey = 'last_activity';

  bool get isLoggedIn => _isLoggedIn;
  bool get noAuthError => _noAuthError;

  Future<void> login(
      {required BuildContext context,
      String username = '',
      String password = '',
      bool loginHuella = false,
      String? afiliacion = ''
      }) async {
        //print(username);
    final respuesta =
        await general.sendCredencialsLoginApi(context, username, password);
       
    if ((respuesta['status'] && respuesta['user']['is_enabled']==1) ) {
      String? idAfiliado = afiliacion; 
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      idAfiliado =respuesta['user']['id_afiliado'].toString();
      final beneficiario = respuesta['user']['num_beneficiario'].toString();
      //print(beneficiario);
      var usuario = username = respuesta['user']['username'].toString();

      var contra = respuesta['user']['password'].toString();

      var email = respuesta['user']['email'].toString();
        final duii = respuesta['user']['dui'].toString();
        
      try {
        const url =
            'https://app.ipsfa.gob.sv/appMovil/controlVivencia/getDatosAfi';
        final response2 = await http.post(
          Uri.parse(url),
          body: jsonEncode({
            'idAfiliado': idAfiliado.toString(),
            'beneficiario': beneficiario.toString()
          }),
          headers: {'Content-Type': 'application/json'},
        );
        final disponibleDoc = jsonDecode(response2.body)['disponibleDoc'];
        final realizoVivencia = jsonDecode(response2.body)['realizoVivencia'];
        final disponibleFotos = jsonDecode(response2.body)['disponibleFotos'];
        final aprobadoFotos = jsonDecode(response2.body)['aprobadoFotos'];
        final esReafiliado = jsonDecode(response2.body)['esReafiliado'].toString();
        final validoVivencia = jsonDecode(response2.body)['validoVivencia'].toString();
        final validoConstancias = jsonDecode(response2.body)['validoConstancias'].toString();
        final estadoAfiliado = jsonDecode(response2.body)['estadoAfiliado'].toString();
        final creditoService = jsonDecode(response2.body)['creditoService'].toString();
        final carneService = jsonDecode(response2.body)['carneService'].toString();
        final user = User(
            dui: duii,
            afiliacion: idAfiliado,
            username: usuario,
            password: contra,
            email: email,
            numBeneficiario: beneficiario.toString(),
            validoVivencia: validoVivencia,
            validoConstancias:validoConstancias,
            disponibleFotos: disponibleFotos,
            disponibleDoc: disponibleDoc,
            realizoVivencia: realizoVivencia,
            aprobadoFotos:aprobadoFotos,
            esReafiliado:esReafiliado,
            estadoAfiliado:estadoAfiliado,
            creditoService:creditoService,
            carneService:carneService
            );

        _isLoggedIn = true;
        // Guardar el usuario en el provider
        context.read<UserProvider>().setUser(user);
      } on http.ClientException {
        showOverlaySnack('Error de conexion. Favor revisar su conexion a internet','error');
        //general.showSnackBar(context, 'Error de conexion. Favor revisar su conexion a internet',color: 'error');
      } on TimeoutException {
        showOverlaySnack('La solicitud está tardando demasiado. Intenta de nuevo.','error');
        //general.showSnackBar(context, 'La solicitud está tardando demasiado. Intenta de nuevo.',color: 'error');
      } catch (e) {
        //print(e);
      await general.logError('getDatosAfi.php error catch:', e.toString()) ;
        showOverlaySnack('Hubo un error inesperado. Favor volver a intentar: $e','error');
        //general.showSnackBar(context, 'Hubo un error inesperado. Favor volver a intentar2',color: 'error');
      }
    } else if (respuesta['message'] != 'Credenciales incorrectas' ) {
      
      _noAuthError = true;
        //showOverlaySnack(respuesta['user']['is_enabled']==0?'Usuario no habilitado. Comunicarse con Servicio al Cliente':respuesta['message'],'error');
        showOverlaySnack(respuesta['message'],'error');
      //general.showSnackBar(context, respuesta['message'], color: 'error');
    }else {
      _noAuthError = false;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  Future<void> startTimer(BuildContext context) async {
    _timer?.cancel();
    _timer = Timer(sessionDuration, onTimeout);
    await _saveLastActivity(); // guarda el tiempo actual
  }

  Future<void> resetTimer() async {
    _timer?.cancel();
    _timer = Timer(sessionDuration, onTimeout);
    await _saveLastActivity(); 
  }

  Future<void> _saveLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> hasSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_lastActivityKey);

    if (lastActivity == null) return true;

    final lastActivityTime = DateTime.fromMillisecondsSinceEpoch(lastActivity);
    final currentTime = DateTime.now();

    return currentTime.difference(lastActivityTime) > sessionDuration;
  }

  void onTimeout() async {
    final context = navigatorKey.currentState!.overlay!.context;
    final auth = Provider.of<AuthController>(context, listen: false).isLoggedIn;

    //print(auth);
    if (!auth) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return DialogoConfirmacion(
            context: context,
            title: 'Sesion Expirada',
            content: 'Por inactividad, se cerro sesion',
            txtBtn: 'Aceptar',
            widgetDestino: const Login(),
            tipo: 'logout');
      },
    );
    logout();
  }
}
