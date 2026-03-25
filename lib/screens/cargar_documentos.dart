// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/screens/validar_biometricos.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CargarDocumentos extends StatefulWidget {
  bool proviene = true;
  CargarDocumentos({super.key, required this.proviene});

  @override
  State<CargarDocumentos> createState() => _CargarDocumentosState();
}

class _CargarDocumentosState extends State<CargarDocumentos> {
  String? _pais;
  bool _cargando = true;
  String? _error;
  GeneralMethods general = GeneralMethods();
  bool cargando = false;
  String idAfiliado = '';
  String numBeneficiario = '';
  XFile? nomDocDui, nomDocDj, nomDocPn;
  bool subiendo = false;
  bool sended = false;
  bool _vivenciaAnual = false;

  Future<void> obtenerPais() async {
    try {
      // Paso 1: Verificar permisos

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.deniedForever) {
         /*general.showSnackBar(
              context, 'La aplicacion necesita permisos de su ubicacion',
              color: 'error');*/
          Future.delayed(const Duration(seconds: 4), () {
            navigatorKey.currentState?.pushNamed('/controlVivencia');
            openAppSettings();
          });
        }
      }

      // Paso 2: Obtener posición
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Paso 3: Obtener país a partir de coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(
        posicion.latitude,
        posicion.longitude,
      );

      if (placemarks.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _pais = placemarks.first.country;
          _cargando = false;
          _validarFechaVivencia();
        });
      } else {
        _error = "No se encontró información geográfica";
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> seleccionarArchivo(
      String tipoDoc, String afiliado, String beneficiario) async {
    idAfiliado = afiliado;
    numBeneficiario = beneficiario;
    final resultado = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDFs', extensions: ['pdf']),
      ],
    );

    if (resultado != null) {
      if (tipoDoc == 'dui') {
        nomDocDui = resultado;
      } else if (tipoDoc == 'dj') {
        nomDocDj = resultado;
      } else {
        nomDocPn = resultado;
      }
      setState(() {});
    }
  }

  Future<void> subirArchivo(XFile archivo, String tDoc) async {
    if (!mounted) return;
    if (archivo.name == '') return;
    setState(() {
      subiendo = true;
      sended = true;
    });
    final password =
        Provider.of<UserProvider>(context, listen: false).user!.password;

    final uri = Uri.parse(
        'https://app.ipsfa.gob.sv/appMovil/controlVivencia/cargarDoc');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('archivo', archivo.path),
    );
    request.fields['tipoDoc'] = tDoc;
    request.fields['idAfiliado'] = idAfiliado;
    request.fields['numBeneficiario'] = numBeneficiario;
    request.fields['pais'] = _pais!;
    request.fields['password'] = password;

    final response = await request.send();
    //var responseBody = await response.stream.bytesToString();
    //print(responseBody);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: const Duration(seconds: 1),
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text('$tDoc subido exitosamente')),
      );
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        general.redirigir(context, const ValidarVivencia());
        //context.read<UserProvider>().updDisponibilidad('N');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error al subir archivo: ${response.statusCode}')),
      );
    }

    if (!mounted) return;
    setState(() {
      subiendo = false;
    });
  }

  Future<void> _validarFechaVivencia() async {
    final idAfiliado =
        Provider.of<UserProvider>(context, listen: false).user!.afiliacion;
    final numBeneficiario =
        Provider.of<UserProvider>(context, listen: false).user!.numBeneficiario;
    const url =
        'https://app.ipsfa.gob.sv/appMovil/controlVivencia/validarFechaVivencia'; // URL API
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(
            {'id_afiliado': idAfiliado, 'numBeneficiariom': numBeneficiario}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
      //print(response.body);
      if (respuesta['fechaCumple'] == 'SI') {
        if (!mounted) return;
        setState(() {
          _vivenciaAnual = true;
        });
      }
    } on http.ClientException {
      /*

      general.showSnackBar(
          context, 'Error de conexion.Favor volver a entrar a la pantalla.',
          color: 'error');
      //return {'status': false,'message':'Error de conexion. Favor revisar su conexion a internet'};
    } on TimeoutException {
      general.showSnackBar(context,
          'La solicitud está tardando demasiado. Intenta de nuevo entrar a la pantalla.',
          color: 'error');
      //return {'status': false,'message':'La solicitud está tardando demasiado. Intenta de nuevo.'};
      //throw Exception('La solicitud está tardando demasiado. Intenta de nuevo.');
    } catch (e) {
      general.showSnackBar(context, 'Error: $e', color: 'error');           */
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerPais();
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<AuthController>(context);
    final textScale = MediaQuery.of(context).size.width;
    User usuario = context.watch<UserProvider>().user!;
    /*final denegadoDoc = context.watch<UserProvider>().user!.denegadoDoc;
    final disponibleDoc = context.watch<UserProvider>().user!.disponibleDoc;
    final beneficiario = context.watch<UserProvider>().user!.numBeneficiario;
    final afiliado = context.watch<UserProvider>().user!.afiliacion;*/
   
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          sessionManager.resetTimer();
        }
        return false;
      },
      child: PopScope(
        canPop: widget.proviene,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Carga de documentos',
              style: TextStyle(fontSize: 0.07 * textScale),
            ),
            automaticallyImplyLeading: widget.proviene,
          ),
          body: _cargando && !_vivenciaAnual
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? const Center(child: Text('Ocurrió un error.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text('Indicacion general',
                              style: TextStyle(
                                  fontSize: 0.1 * textScale,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            'Favor cargar los documentos que se le solicitan para realizar su control vivencia ',
                            style: TextStyle(fontSize: 0.059 * textScale),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 75),

                          // DUI
                          if (usuario.disponibleDoc == 'S' &&
                              usuario.realizoVivencia == 'N')
                            Center(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await seleccionarArchivo(
                                          'dui',
                                          usuario.afiliacion,
                                          usuario.numBeneficiario);
                                    },
                                    child: Text(
                                      'Cargar DUI',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (nomDocDui != null)
                                    Text(
                                      nomDocDui!.name,
                                      style: TextStyle(
                                          color: Provider.of<ThemeProvider>(
                                                  context,
                                                  listen: false)
                                              .iconColor,
                                          fontSize: 20,
                                          fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 60),

                          // Declaración jurada o partida
                          if (usuario.numBeneficiario != 'null' &&
                              usuario.disponibleDoc == 'S' &&
                              usuario.realizoVivencia == 'N' &&
                              _vivenciaAnual)
                            (_pais != 'El Salvador')
                                ? Center(
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await seleccionarArchivo(
                                                'dj',
                                                usuario.afiliacion,
                                                usuario.numBeneficiario);
                                          },
                                          child: Text(
                                            'Cargar Declaración Jurada',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (nomDocDj != null)
                                          Text(
                                            nomDocDj!.name,
                                            style: TextStyle(
                                                color:
                                                    Provider.of<ThemeProvider>(
                                                            context,
                                                            listen: false)
                                                        .iconColor,
                                                fontSize: 20,
                                                fontStyle: FontStyle.italic),
                                          ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await seleccionarArchivo(
                                                'pn',
                                                usuario.afiliacion,
                                                usuario.numBeneficiario);
                                          },
                                          child: Text(
                                            'Cargar Partida de Nacimiento',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (nomDocPn != null)
                                          Text(
                                            nomDocPn!.name,
                                            style: TextStyle(
                                                color:
                                                    Provider.of<ThemeProvider>(
                                                            context,
                                                            listen: false)
                                                        .iconColor,
                                                fontSize: 20,
                                                fontStyle: FontStyle.italic),
                                          ),
                                      ],
                                    ),
                                  ),

                          if (usuario.disponibleDoc == 'N' && !_cargando)
                            const Text(
                              'Usted está al día con su vivencia. Gracias.',
                              style: TextStyle(fontSize: 34),
                            ),

                          const SizedBox(height: 30),

                          if (subiendo)
                            Center(
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: CircularProgressIndicator(
                                  color: Provider.of<ThemeProvider>(context)
                                      .iconColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: (nomDocDui != null && numBeneficiario == 'null') ||
                        (numBeneficiario != 'null' &&
                            (nomDocDj != null || nomDocPn != null) &&
                            !sended)
                    ? () async {
                        if (nomDocDui != null) {
                          await subirArchivo(nomDocDui!, 'Dui');
                        }
                        if (nomDocDj != null) {
                          await subirArchivo(nomDocDj!, 'Declaracion_Jurada');
                        }
                        if (nomDocPn != null) {
                          await subirArchivo(nomDocPn!, 'Partida_Nacimiento');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 30)
                ),
                child: const Text(
                  'Cargar documentos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
