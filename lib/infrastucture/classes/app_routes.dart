import 'package:flutter/material.dart';
import 'package:ipsfa/screens/constancias.dart';
import 'package:ipsfa/screens/control_vivencia.dart';
import 'package:ipsfa/screens/get_biometricos.dart';
import 'package:ipsfa/screens/indicaciones.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:ipsfa/screens/pagina_principal.dart';
import 'package:ipsfa/screens/prestamos.dart';
import 'package:ipsfa/screens/validar_biometricos.dart';
//import 'package:ipsfa/screens/verify_face_id_BK.dart';

class AppRoutes {

  static const String login = '/login';
  static const String paginaPrincipal = '/paginaPrincipal';
  static const String controlVivencia = '/controlVivencia';
  static const String indicaciones = '/indicaciones';
  static const String getBiometricos = '/getBiometricos';
  static const String validarVivencia = '/validarVivencia';
  static const String cargarDocumentos = '/cargarDocumentos';
  static const String documentCameraPage = '/documentCameraPage';
  static const String constancias = '/constancias';
  static const String prestamos = '/prestamos';
  //static const String verifyId = '/verifyId';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const Login(),
    paginaPrincipal: (_) => const PaginaPrincipal(mostroMsj: '1',),
    controlVivencia: (_) => const ControlVivencia(),
    indicaciones: (_) => const Indicaciones(),
    getBiometricos: (_) => const GetBiometricos(positionCapture: 0,),
    validarVivencia: (_) => const ValidarVivencia(),
    constancias: (_) => const Constancias(),
    prestamos: (_) => const PrestamoScreen(),
    //verifyId: (_) => const FaceVerificationPage(),
  };

  static void navegar(BuildContext context,String ruta) {
    
    switch (ruta) {
      case 'login':
        Navigator.pushNamed(context, login);
        break;
      case 'paginaPrincipal':
        Navigator.pushNamed(context, paginaPrincipal);
        break;
      case 'controlVivencia':
        Navigator.pushNamed(context, controlVivencia);
        break;
      case 'getBiometricos':
        Navigator.pushNamed(context, getBiometricos);
        break;
      case 'validarVivencia':
        Navigator.pushNamed(context, validarVivencia);
        break;
      case 'constancias':
        Navigator.pushNamed(context, constancias);
        break;
      case 'prestamos':
        Navigator.pushNamed(context, prestamos);
        break;
      /*case 'verifyId':
        Navigator.pushNamed(context, verifyId);
        break;*/
      default:
        Navigator.pushNamed(context, login);
        break;
    }
  }
}
