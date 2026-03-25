// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


class FormRegisterUser extends StatefulWidget {
  const FormRegisterUser({super.key});

  @override
  State<FormRegisterUser> createState() => _FormRegisterUserState();
}

class _FormRegisterUserState extends State<FormRegisterUser> {
  GeneralMethods general = GeneralMethods();
    final GlobalKey<FormState> registerForm = GlobalKey<FormState>();
    //final TextEditingController _nombre = TextEditingController();
  final TextEditingController _dui = TextEditingController();
  //final TextEditingController _afiliacion = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _email = TextEditingController();
  //final TextEditingController _usuario = TextEditingController();
  //final TextEditingController _password = TextEditingController();
  //final TextEditingController _password2 = TextEditingController();
  String? _selectedCountry;
  String? _selectedCountryCode;
  String? _selectedPhoneCode;

  Map<String, MaskTextInputFormatter> mascarasEspeciales = {
  'US': MaskTextInputFormatter(
      mask: '+1 (###) ###-####', filter: {"#": RegExp(r'[0-9]')}),
  'CA': MaskTextInputFormatter(
      mask: '+1 (###) ###-####', filter: {"#": RegExp(r'[0-9]')}),
  'BR': MaskTextInputFormatter(
      mask: '+55 (##) ####-####', filter: {"#": RegExp(r'[0-9]')}),
  'MX': MaskTextInputFormatter(
      mask: '+52 ## #### ####', filter: {"#": RegExp(r'[0-9]')}),
  'JP': MaskTextInputFormatter(
      mask: '+81 ##-####-####', filter: {"#": RegExp(r'[0-9]')}),
  'GB': MaskTextInputFormatter(
      mask: '+44 #### ######', filter: {"#": RegExp(r'[0-9]')}),
  'AU': MaskTextInputFormatter(
      mask: '+61 # #### ####', filter: {"#": RegExp(r'[0-9]')}),
  'DE': MaskTextInputFormatter(
      mask: '+49 #### #######', filter: {"#": RegExp(r'[0-9]')}),
  'FR': MaskTextInputFormatter(
      mask: '+33 # ## ## ## ##', filter: {"#": RegExp(r'[0-9]')}),
};
  //bool _obscureText = true;
  //bool _obscureText2 = true;
  bool _isLoging = false;

MaskTextInputFormatter telefonoFormatter =
    MaskTextInputFormatter(mask: '##########', filter: {"#": RegExp(r'[0-9]')});

MaskTextInputFormatter duiFormater =
    MaskTextInputFormatter(mask: '########-#', filter: {"#": RegExp(r'[0-9]')});

MaskTextInputFormatter afiliacionFormater =
    MaskTextInputFormatter(mask: '########', filter: {"#": RegExp(r'[0-9]')});
  
void actualizarFormatter() {
  if (_selectedCountry != null) {
    if (mascarasEspeciales.containsKey(_selectedCountryCode)) {
      telefonoFormatter = mascarasEspeciales[_selectedCountryCode]!;
    } else {
      telefonoFormatter = MaskTextInputFormatter(
        mask: '+$_selectedPhoneCode ####-####',
        filter: {"#": RegExp(r'[0-9]')},
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              'Formulario de registro',
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
                key: registerForm,
                child: Center(
                  child: Column( 
                    children:[

                        /*Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            inputFormatters: [
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                return TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection,
                                );
                              }),
                            ],
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _nombre,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              hintText: 'Nombre Completo',
                              icon: const Icon(Icons.person_outline, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete nombre completo';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 25,),*/
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            keyboardType:  TextInputType.number,
                            inputFormatters: [duiFormater],
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _dui,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              labelText: 'Numero de DUI',
                              labelStyle: TextStyle(fontSize: 0.07 * screenWidth),
                              icon: const Icon(Icons.assignment_ind, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete numero de DUI';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        
                       /* const SizedBox(height: 25,),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            keyboardType:  TextInputType.number,
                            inputFormatters: [afiliacionFormater],
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _afiliacion,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              hintText: 'Numero de AFILIACION',
                              icon: const Icon(Icons.contact_page, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete numero de AFILIACION';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),*/
                        const SizedBox(height: 25,),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: 
                          TextFormField(
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: TextEditingController(text:_selectedCountry),
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              labelText: 'Seleccione Pais',
                              labelStyle: TextStyle(fontSize: 0.07 * screenWidth),
                              icon: const Icon(Icons.public, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            onTap: () {
                              showCountryPicker(
                                  context: context,
                                  showPhoneCode: true,
                                  onSelect: (Country country) {
                                    setState(() {
                                      _selectedCountry = country.name;
                                      _selectedCountryCode = country.countryCode;
                                      _selectedPhoneCode = country.phoneCode;
                                      actualizarFormatter();
                                      _telefono.clear();
                                    });
                                  },
                                );
                            },
                            readOnly: true,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Favor seleccionar un PAIS';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 25,),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            keyboardType:  TextInputType.number,
                            inputFormatters: [telefonoFormatter],
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _telefono,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              labelText: 'Numero de TELEFONO',
                              labelStyle: TextStyle(fontSize: 0.07 * screenWidth),
                              icon: const Icon(Icons.contact_phone, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete numero de TELEFONO';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 25,),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _email,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              labelText: 'Correo electronico',
                              labelStyle: TextStyle(fontSize: 0.07 * screenWidth),
                              icon: const Icon(Icons.email, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete correo electronico';
                              } else if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
                                return 'Correo no válido. Ejemplo: miCorreo@dominio.com';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        /*
                        const SizedBox(height: 25,),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _usuario,
                            decoration: InputDecoration(
                              focusColor: Theme.of(context).colorScheme.primary,
                              hintText: 'Nombre de Usuario',
                              icon: const Icon(Icons.person, size: 50),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintStyle:
                                  TextStyle(fontSize: 0.07 * screenWidth),
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete Nombre de Usuario';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 25,),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _password,obscureText: _obscureText,
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
                              icon: const Icon(
                                Icons.password,
                                size: 50,
                              ),
                              iconColor:
                                  Provider.of<ThemeProvider>(context,listen: false).iconColor,
                              hintText: 'Ingrese contraseña',
                              errorStyle:
                                  TextStyle(fontSize: 0.045 * screenWidth),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Complete Contraseña';
                              } else {
                                if(value!=_password2.text){
                                  return 'Las contraseñas no coinciden';
                                }else{
                                  return null;
                                }
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 25,),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                            style: TextStyle(fontSize: 0.07 * screenWidth),
                            cursorHeight: 0.07 * screenWidth,
                            controller: _password2,
                            obscureText: _obscureText2,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText2
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () async {
                                  await Future.delayed(
                                      const Duration(milliseconds: 125));
                                  _obscureText2 = !_obscureText2;
                                  setState(() {});
                                },
                              ),
                              hintText: 'Repita contraseña',
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
                                return 'Complete Repetir Contraseña';
                              } else {
                                if(value!=_password.text){
                                  return 'Las contraseñas no coinciden';
                                }else{
                                  return null;
                                }
                              }
                            },
                          ),
                        ),*/

                        const SizedBox(height: 25,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (registerForm.currentState!.validate()) {
                                
                                  _registrar(context);
                                  setState(() {
                                    _isLoging = true;
                                  });
                              }
                              
                            },
                            child: 
                              _isLoging?
                                    Padding(
                                      padding: const EdgeInsetsGeometry.all(5),
                                      child: SizedBox(
                                        height: screenWidth * 0.122,
                                        width: screenWidth * 0.122,
                                        child: CircularProgressIndicator(
                                          color:Provider.of<ThemeProvider>(context,listen:false).iconColor,
                                      )),
                                    ):
                            Text(
                                    'Enviar Formulario',
                                    style: TextStyle(
                                        fontSize: 0.1 * screenWidth,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ) ,
                          ),
                        ),
                      ]
                    ),
                  ),
                )
              ),
          ),
            
      );
  }
  void _registrar(BuildContext context)async{
    //print(_dui.text);
    try {
        const url =
            'https://app.ipsfa.gob.sv/sac/api/insert';
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode({
            "name"     : '',
            "email"    : _email.text,
            "pais": _selectedCountry,
            "id_afiliado"    : '',
            "dui"    : _dui.text,
            "username"    : _dui.text,
            "password" : _dui.text,
            "telefono"   : _telefono.text,
            "is_enabled"   : true
          }),
          headers: {'Content-Type': 'application/json'},
        );
        final data = jsonDecode(response.body);
        String text='';
        if (data['statusCode'] == '201') {
        showOverlaySnack('REGISTRO EXITOSO. BIENVENIDO','');
          //general.showSnackBar(context, 'REGISTRO EXITOSO. BIENVENIDO');
          Future.delayed(const Duration(seconds: 3), () {
            general.redirigir(
            context,
            const Login()
            );
          });
        } else {
        //print(data['message'].containsKey('dui'));
          if(data['message'].containsKey('email')&& data['message']['email'][0]!=''){
            text=data['message']['email'][0];
          }else if(data['message'].containsKey('dui')&& data['message']['dui'][0]!=''){
            text=data['message']['dui'][0];
          }else{
            text=data['message']['error'][0];
          }
        showOverlaySnack(text,'error');
          //general.showSnackBar(context, text,color: "true");
        }
          
      _isLoging = false;
       
      } on http.ClientException {
        showOverlaySnack('Error de conexion. Favor revisar su conexion a internet','error');
        /*general.showSnackBar(
            context, 'Error de conexion. Favor revisar su conexion a internet',
            color: 'error');*/
      _isLoging = false;
      } on TimeoutException {
        showOverlaySnack('La solicitud está tardando demasiado. Intenta de nuevo.','error');
        /*general.showSnackBar(
            context, 'La solicitud está tardando demasiado. Intenta de nuevo.',
            color: 'error');*/
      _isLoging = false;
      } catch (e) {
      await general.logError('Insert User laravel error catch:', e.toString()) ;
        showOverlaySnack('ERROR: Favor comunicarse con el IPSFA','error');
        /*general.showSnackBar(
            context, 'ERROR: Favor comunicarse con el IPSFA',
            color: 'error');*/
      _isLoging = false;
      }
      setState(() {
        
      });
  }
}