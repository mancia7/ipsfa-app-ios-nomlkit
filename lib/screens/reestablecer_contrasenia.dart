import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class ReestablecerContrasenia extends StatelessWidget {
    final GlobalKey<FormState> _resetForm = GlobalKey<FormState>();
    final TextEditingController correo = TextEditingController();
   ReestablecerContrasenia({super.key});
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    GeneralMethods general = GeneralMethods();
    String email='';
    return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              'Reestablecer contraseña',
              style: TextStyle(
                  fontSize: 0.075 * screenWidth,
                  color: Theme.of(context).colorScheme.primary),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                general.redirigir(context,
                    const Login()); // Esto vuelve a la pantalla anterior
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _resetForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 0.07 * screenWidth),
                        cursorHeight: 0.07 * screenWidth,
                        controller: correo,
                        decoration: InputDecoration(
                          focusColor: Theme.of(context).colorScheme.primary,
                          hintText: 'Ingrese su correo electronico',
                          icon: const Icon(Icons.email, size: 50),
                          iconColor:
                              Provider.of<ThemeProvider>(context).iconColor,
                          hintStyle: TextStyle(fontSize: 0.07 * screenWidth),
                          errorStyle: TextStyle(fontSize: 0.045 * screenWidth),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Favor ingresar correo electronico';
                          } else if (!EmailValidator.validate(value.trim())) {
                            return 'Favor ingresar correo electronico valido';
                          } else {
                            email=value;
                            return null;
                          }
                          
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_resetForm.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              general.sendEmailResetApi(context, email);
                            }
                          },
                          child: Icon(
                            Icons.send_rounded,
                            size: 0.12 * screenWidth,
                          )),
                    ],
                  )),
            ),
          ),
        );
  }
}
