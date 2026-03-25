import 'package:flutter/material.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/widgets/message_dialog.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:provider/provider.dart';

import '../../infrastucture/classes/app_routes.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});
  final String title;
  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _MyAppBarState extends State<MyAppBar> {

  

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;

    return AppBar(automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: widget.title == 'Inicio de sesion'
                ?  IconButton(
                  iconSize: 40,
                  color: Colors.white,
                    onPressed: () {
                      context.read<ThemeProvider>().selectTheme();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.color_lens,
                    ))
                : null,
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: 
          Center(
              child: Row(
            
                  children: [
                    
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 2),
                      child: widget.title=='Menu principal'?
                        IconButton(onPressed: (){
                            if (!mounted) return;
                              //Future.delayed(const Duration(seconds: 3), () {
                                // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                        return DialogoConfirmacion(
                                          context:context,title:'¿Cerrar Sesión?',
                                          content:'¿Estás seguro de que deseas cerrar sesión?',
                                          txtBtn:'Si',
                                          widgetDestino:const Login(),
                                          tipo:'logout');
                                        },
                            );
                          // });
                          },
                          icon: const Icon(Icons.logout),
                          color: Colors.white,iconSize: 40,
                        )
                        :widget.title!='Inicio de sesion'?
                        IconButton(
                          icon: const Icon(Icons.arrow_back ,color: Colors.white,),iconSize:40,
                          onPressed: () {
                            //Navigator.pop(context);
                            //AppRoutes.navigatorKey.currentState?.pushReplacementNamed('/paginaPrincipal');// Regresa a la pantalla anterior
                            /*Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.navigatorKey.currentState!.pushReplacementNamed('/paginaPrincipal') as String,
                              (Route<dynamic> route) => false,
                            );*/
                            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              AppRoutes.paginaPrincipal,
                              (route) => false,
                            );
                          },
                        )
                        :null
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10),
                            child: Text(
                              widget.title,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 0.1 * textScale,fontWeight: FontWeight.bold),
                            ),
                        ),
                      )
                  ]
                )
            )
        );
  }
}
