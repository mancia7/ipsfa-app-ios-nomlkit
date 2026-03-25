import 'package:flutter/material.dart';
//import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
//import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:provider/provider.dart';

class DialogoConfirmacion extends StatelessWidget {
  const DialogoConfirmacion(
      {super.key,
      required this.context,
      required this.title,
      required this.content,
      required this.txtBtn,
      required this.widgetDestino,
      required this.tipo});

  final String title;
  final BuildContext context;
  final String content;
  final String txtBtn;
  final Widget widgetDestino;
  final String tipo;

  @override
  Widget build(BuildContext context) {
    //GeneralMethods general = GeneralMethods();
    final auth = Provider.of<AuthController>(context, listen: false);
    final textScale = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: txtBtn=='Si' ?true:false,
      child: AlertDialog(
        title: Text(title,style: TextStyle(fontSize:  0.08 * textScale)),
        content: Text(content,style: TextStyle(fontSize:  0.055 * textScale)),
        actions: [
          
          if(txtBtn=='Si')
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child:txtBtn=='Si' ?  Text('No' ,style: TextStyle(fontSize:  0.09 * textScale,color:  Theme.of(context).colorScheme.secondary),):const Text(''),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              if (tipo == 'logout') {
                auth.logout();
              }
              Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil('/login', (route) => false);
              },
            child:  Text(txtBtn,style: TextStyle(fontSize:  0.09 * textScale,color:  Provider.of<ThemeProvider>(context).iconColor)),
          ),
        ],
      ),
    );
  }
}
