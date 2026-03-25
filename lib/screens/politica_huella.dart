// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ipsfa/db/database_helper.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:ipsfa/screens/pagina_principal.dart';
import 'package:provider/provider.dart';

class PoliticaHuellaScreen extends StatelessWidget {
  const PoliticaHuellaScreen({super.key});

  void _guardarRegistroHuella(BuildContext context) async{
    
  
    GeneralMethods general = GeneralMethods();
    User usuario = Provider.of<UserProvider>(context,listen:false).user!;

    final huella = {
      'aceptoHuella': 1,
      'dui': usuario.dui,
      'mostroMsj':0
    };
    final db = await DatabaseHelper.instance.database;
    final res = await db.query(
        'huella',
        where: 'dui = ?',
        whereArgs: [general.agregarGuionDui(usuario.dui)]
      );
      String mostroMsj='0';
    if(res.isEmpty){
      await DatabaseHelper().insertHuella(huella);
    }else{
       mostroMsj=res.first['mostroMsj'].toString();
      final huella = {
        'aceptoHuella': 1,
        'dui': general.agregarGuionDui(usuario.dui),
      };
      await DatabaseHelper().updateHuella(huella);
    }
      

      showOverlaySnack("Muchas Gracias. Bienvenido",'');
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Muchas Gracias. Bienvenido",
          style:  TextStyle(fontSize: 20),) ,backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,margin: const EdgeInsets.all(16), // separación de bordes
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 🔥 esquinas redondeadas
          ),
          duration: const Duration(seconds: 3),
        ),
      );*/
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaginaPrincipal(
        loginHuella: false,
            mostroMsj:mostroMsj
            )),
    );
      //Navigator.pushNamed(context, '/paginaPrincipal');
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false,title: const Text('Política de uso de huella digital')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Política de uso del inicio de sesión por huella digital',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Al habilitar la opción de inicio de sesión mediante huella digital, '
                  'el usuario reconoce y acepta que dicho método utiliza información biométrica '
                  'almacenada en su dispositivo. Esta aplicación no recopila, almacena ni transmite '
                  'datos biométricos en ningún momento, ya que la verificación se realiza de forma local '
                  'a través de los mecanismos de seguridad del sistema operativo.\n\n'
                  'El usuario comprende y acepta que:\n\n'
                  '1. El acceso mediante huella digital depende de la configuración y seguridad del dispositivo.\n\n'
                  '2. La aplicación no se hace responsable por accesos no autorizados derivados del uso compartido, '
                  'pérdida o manipulación del dispositivo.\n\n'
                  '3. Es responsabilidad del usuario mantener el control físico del dispositivo y de su información biométrica.\n\n'
                  '4. Si el usuario sospecha que su información ha sido comprometida, debe desactivar de inmediato esta función desde el incio de sesion.\n\n'
                  'Al continuar y habilitar el inicio de sesión por huella digital, el usuario declara haber leído, comprendido '
                  'y aceptado esta política y los riesgos asociados.',
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _guardarRegistroHuella(context);
                    },
                    child: const Text('Acepto y deseo continuar',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
