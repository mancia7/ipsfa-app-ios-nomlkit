// ignore_for_file: use_build_context_synchronously, unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
//import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:ipsfa/db/database_helper.dart';
import 'package:ipsfa/infrastucture/models/constancia.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
//import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

enum DetectionStage {
  documentofrontal,
  documentotrasero,
  front,
  right,
  left,
  smile,
  exito,
}
enum DeviceTier { low, mid, midHigh, high }

class GeneralMethods {
    final ScrollController _scrollController = ScrollController();
   
  Future<void> showPolicy(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    User usuario = Provider.of<UserProvider>(context,listen:false).user!;
    return AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    title: 'Política de uso',
    body:  SingleChildScrollView(
              controller: _scrollController,
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Text(
                    'Datos personales que serán sometidos a tratamiento',
                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 0.09 * textScale),
                  ),
                  Text(
                    '\nEl IPSFA recopila y procesa datos personales de sus afiliados, pensionados, beneficiarios, empleados, proveedores y usuarios de servicios, tales como: \n\n• Nombre completo, domicilio y fecha de nacimiento.\n\n• Nacionalidad, estado familiar y profesión u oficio.\n\n• Canales de contacto (correo electrónico, teléfono, dirección física).\n\n• Documentos de identidad (DUI, NIT, pasaporte, carné de afiliación, licencia de conducir u otros medios de identificación).\n\n• En estricto cumplimiento de sus fines institucionales, realizara el tratamiento de datos sensibles, como información de salud, antecedentes laborales y datos financieros bajo las limitantes del artículo 38 de la ley.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 0.07 * textScale),
                  ),
                  Text(
                    '\nFundamento legal para el tratamiento de datos',
                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 0.09 * textScale),
                  ),
                  Text(
                    '\nEl IPSFA es responsable del tratamiento adecuado de los datos personales conforme a lo dispuesto en la Ley para la Protección de Datos Personales, especialmente en sus artículos 46 al 49, así como lo dispuesto en la Ley de Acceso a la Información Pública (LAIP).\n\nEl Instituto adoptará todas las medidas necesarias técnicas, administrativas, físicas y organizativas para el resguardo y protección de los datos personales, garantizando en todo momento su integridad, confidencialidad y disponibilidad, conforme a los principios de legalidad, finalidad, minimización, seguridad y transparencia.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 0.07 * textScale),
                  ),
                  Text(
                    '\nFinalidades del tratamiento de los datos personales',
                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 0.09 * textScale),
                  ),
                  Text(
                    '\n• Gestionar y brindar los servicios previsionales, financieros y sociales según las atribuciones institucionales.\n\n• Ejecutar trámites administrativos iniciados de oficio o a solicitud de los interesados.\n\n• Procesar solicitudes, beneficios, pagos y cualquier otra gestión relacionada con la afiliación o atención institucional.\n\n• Atender consultas, avisos, reclamos, denuncias o sugerencias.\n\n• Evaluar la calidad de los servicios prestados y realizar estudios de mejora institucional.\n\n• Cumplir obligaciones legales o contractuales con entidades públicas o privadas, en el marco de las atribuciones del IPSFA.\n\n• Evaluar los servicios brindados por la Institución.\n\nEl IPSFA no recopilará información innecesaria ni transferirá, difundirá, distribuirá o comercializará los datos personales a terceros, excepto cuando así lo exija una autoridad competente en el ejercicio de sus facultades legales.\n\nAsimismo, el IPSFA tratará los datos personales incluyendo su recolección, almacenamiento, procesamiento, uso, transmisión o transferencia con estricto apego a los deberes de seguridad y confidencialidad, establecidos por la Ley para la Protección de Datos Personales.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 0.07 * textScale),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: ()async {

                      final huella = {
                        'mostroMsj': 1,
                        'dui': agregarGuionDui(usuario.dui),
                      };
                      await DatabaseHelper().updateHuella(huella);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 30),
                              ),
                    child: Text('He leido y acepto',
                            style: TextStyle(fontSize: 0.09 * textScale,fontWeight: FontWeight.bold,color: Colors.white)
                          ),
                  ),
                  const SizedBox(height: 10),
                ] 
              ),
              
            )
  ).show();
  }

  String agregarGuionDui(String text) {
  if (text.contains('-')) return text; // ya tiene guion
  return '${text.substring(0, text.length - 1)}-${text.substring(text.length - 1)}';
}
  
  Future<bool> serviceAppMaintenance() async {
    const url = 'https://app.ipsfa.gob.sv/sac/api/app-status'; // URL API
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        //print(respuesta['maintenance']);
      }
      return respuesta['maintenance'] ?? false;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      await logError('app-status error catch:', e.toString()) ;
      return false;
    }
  }
  Future<bool> serviceVivenciaMaintenance() async {
    const url = 'https://app.ipsfa.gob.sv/sac/api/service-vivencia-status'; // URL API
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        //print(respuesta['maintenance']);
      }
      return respuesta['maintenance'] ?? false;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      await logError('Service-vivencia-status error catch:', e.toString()) ;
      return false;
    }
  }

  Future<bool> serviceConstanciaMaintenance() async {
    const url = 'https://app.ipsfa.gob.sv/sac/api/service-constancia-status'; // URL API
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        //print(respuesta['maintenance']);
      }
      return respuesta['maintenance'] ?? false;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      await logError('Service-constancia-status error catch:', e.toString()) ;
      return false;
    }
  }

   Future<bool> serviceCreditoMaintenance() async {
    const url = 'https://app.ipsfa.gob.sv/sac/api/service-credito-status'; // URL API
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        //print(respuesta['maintenance']);
      }
      return respuesta['maintenance'] ?? false;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      await logError('Service-vivencia-status error catch:', e.toString()) ;
      return false;
    }
  }

  Future<List<Constancia>> getConstancias() async {
    final response = await http.get(
      Uri.parse("https://app.ipsfa.gob.sv/appMovil/controlVivencia/getConstancias"),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Constancia.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar constancias");
    }
  }

    Future<bool> appMaintenance() async {
    const url = 'https://app.ipsfa.gob.sv/sac/api/app-status'; // URL API
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
     
      return respuesta['maintenance'] ?? false;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      
      await logError('app-status error catch:', e.toString()) ;
      return false;
    }
  }

  /*  Future<int> _getTotalRAM() async {
    try {
      final memInfo = await File('/proc/meminfo').readAsLines();
      final memTotalLine =
          memInfo.firstWhere((line) => line.startsWith('MemTotal'));
      final parts = memTotalLine.split(RegExp(r'\s+'));
      final kb = int.parse(parts[1]); // valor está en KB
      //print(kb ~/ 1024);
      return (kb ~/ 1024); // convertir a MB
    } catch (e) {
      return 0; // fallback si no se puede leer
    }
  }

  Future<bool> isLowEndDevice() async {
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;

    // CPU CORES
    int cores = Platform.numberOfProcessors;

    // RAM REAL desde /proc/meminfo
    int ramMB = await _getTotalRAM();

    // CRITERIOS DE DISPOSITIVO DÉBIL
    bool fewCores = cores < 4;           // Quad core = gama baja
    bool lowRam = ramMB < 2000;          // menos de 2.5 GB
    bool oldAndroid = android.version.sdkInt < 28; // Android 9 o menor

    return  fewCores && lowRam && oldAndroid;
  }*/

  void redirigir(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<void> sendDataToApi(BuildContext context,Map<String, dynamic> loginData) async {
    /*SE DESHABILITO LA UBICACION POR CAMBIOS DE REQUERIMIENTOS
    Position? position = await getUserLocation();
    if (!_serviceEnabled) {
      general.showSnackBar(context, 'Favor habilitar ubicacion del dispositivo',
          color: 'error');
    } else if (position == null) {
      general.showSnackBar(
          context, 'La aplicacion necesita permisos de su ubicacion',
          color: 'error');
      Future.delayed(const Duration(seconds: 4), () {
        openAppSettings();
      });
    } else {*/

      final client = http.Client();
      const url =
          'https://app.ipsfa.gob.sv/appMovil/controlVivencia/guardarRostro'; // URL API
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(url),
          //body: jsonEncode(faceData),
          //headers: {'Content-Type': 'application/json'},
        );
        request.headers.addAll({
          "Accept": "application/json",
          "User-Agent": "Mozilla/5.0",
          "Connection": "keep-alive",
        });
        request.fields['id_afiliado']=loginData['id_afiliado'];
        request.fields['numBeneficiario']=loginData['numBeneficiario'];
        request.fields['password']=loginData['password'];

        final Map<String, Uint8List> faces =Map<String, Uint8List>.from(loginData['faces']);
        faces.forEach((perfil, bytes) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'faces[]',          
              bytes,               
              filename: '$perfil.jpeg',
            ),
          );
        });
        /*for (int i = 0; i < _indices.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'rostro_$i',
              '${tempDir.path}/${_indices[i]}.jpeg',
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }*/

        final streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          logError(response.statusCode.toString(), response.body);
          //throw Exception('Error ${response.statusCode}');
        }
        //final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('STATUS: ${response.body}');
          debugPrint('RAW RESPONSE: ${response.body.substring(0, min(2000, response.body.length))}');
        final respuesta = jsonDecode(response.body);
        if (kDebugMode) {
          //print(request.fields);
          //print(respuesta);
          //print(loginData);
          //print(respuesta['error']);
          //print(respuesta);
        }
        if (respuesta['Success'] != null) {
          showOverlaySnack(respuesta['Success'],'');
          //general.showSnackBar(context, respuesta['Success']);
            /*setState(() {
            _saved = true;
          });
        setState(() {
              _allPositionsDetected = false;
              _isDetecting = true;
            });*/

          Provider.of<UserProvider>(context, listen: false)
              .updDisponibilidadFotos("N");
          Future.delayed(const Duration(seconds: 3), () {
            /*if(Provider.of<UserProvider>(context, listen: false).user!.disponibleDoc=='S'){
              general.redirigir(
                context,
                  CargarDocumentos(proviene: false,));
            }else{*/
            //general.redirigir(context, const ControlVivencia());
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/controlVivencia',
              (Route<dynamic> route) => route.isFirst, // deja la ruta inicial (root)
            );
            //}
          });
        } else {
          showOverlaySnack(respuesta['error'],'error');
          //general.showSnackBar(context, respuesta['error'], color: 'error');
        }
      } on http.ClientException {
          showOverlaySnack('Error de conexion','error');
        //general.showSnackBar(context, 'Error de conexion', color: 'error');
        //return {'status': false,'message':'Error de conexion. Favor revisar su conexion a internet'};
      } on TimeoutException {
          showOverlaySnack('La solicitud está tardando demasiado. Intenta de nuevo.','error');
        //general.showSnackBar(context, 'La solicitud está tardando demasiado. Intenta de nuevo.',color: 'error');
            //sendDataToApi(context,faceData);
        //return {'status': false,'message':'La solicitud está tardando demasiado. Intenta de nuevo.'};
        //throw Exception('La  solicitud está tardando demasiado. Intenta de nuevo.');
      } catch (e) {
          await logError('GuardarRostro.php error catch:', e.toString()) ;
          showOverlaySnack('Error: $e','error');
        //general.showSnackBar(context, 'Error: $e', color: 'error');
      }
  }


 /* void showSnackBar(BuildContext context, String message, {String? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 22),
        ),
        backgroundColor:
            color == null ? Theme.of(context).colorScheme.primary : Colors.red,
        duration: color == null
            ? const Duration(seconds: 3)
            : const Duration(seconds: 5),
      ),
    );
  }*/

  Future<void> sendEmailResetApi(BuildContext context, String correo) async {
    const url = 'https://app.ipsfa.gob.sv/sac/api/send-reset-link'; // URL API
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'email': correo}),
        headers: {'Content-Type': 'application/json'},
      );
      final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
      //print(respuesta['error']);

      
      showOverlaySnack(respuesta['error'] ?? respuesta['message'],'error');
      /*showSnackBar(context, respuesta['error'] ?? respuesta['message'],
          color: 'error');*/
    } catch (e) {
      showOverlaySnack('Error: $e','error');
      //showSnackBar(context, 'Error: $e', color: 'error');
    }
  }

  Future<Map<String, dynamic>> sendCredencialsLoginApi(
      BuildContext context, String username, String password) async {
        //print(password);
    const url = 'https://app.ipsfa.gob.sv/sac/api/login'; // URL API
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
        
      ).timeout(const Duration(seconds: 10));
      
      final respuesta = jsonDecode(response.body);
      //print(respuesta);
      return respuesta;
    }on http.ClientException {
      return {'status': false,'message':'Error de conexion. Favor revisar su conexion a internet'};
    } on TimeoutException {
      return {'status': false,'message':'La solicitud está tardando demasiado. Intenta de nuevo.'};
    } catch (e) {
      await logError('login.php laravel error catch:', e.toString()) ;
      //print(e);
        return {'status': false,'message':'Error: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getRegistrosVivencias(
    BuildContext context, String afiliacion
  ) async {
     User usuario = context.watch<UserProvider>().user!;
    const url ='https://app.ipsfa.gob.sv/appMovil/controlVivencia/getVivencias'; // URL API
    
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"afiliacion": afiliacion,
                            "num_beneficiario":usuario.numBeneficiario}),
        headers: {'Content-Type': 'application/json'},
      );
       //print(response.body);
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

        return [decoded]; // lo envolvemos en lista
      
    } catch (e) {
      await logError('getVivencias.php error catch:', e.toString()) ;
      //print(e);
      return [
        {
          "afiliacion": "Sin valores",
          "fecha_vivencia": "Sin valores",
          "fec_adicion": "Sin valores",
          "num_beneficiario": "Sin valores",
        },
      ];
    }
  }

  String getGuideImagePath(DetectionStage currentStage) {
    print('CurrentStage; $currentStage');
    switch (currentStage) {
      case DetectionStage.front:
        return 'lib/assets/front.png';
      case DetectionStage.right:
        return 'lib/assets/right.png';
      case DetectionStage.left:
        return 'lib/assets/left.png';
      case DetectionStage.smile:
        return 'lib/assets/smile.png';
      case DetectionStage.exito:
        return '';
      case DetectionStage.documentofrontal:
      return '';
      case DetectionStage.documentotrasero:
      return '';
    }
  }

  String getInstructionText(DetectionStage currentStage) {
    switch (currentStage) {
      case DetectionStage.front:
        return 'Alinea tu rostro con la guía frontal';
      case DetectionStage.right:
        return 'Gira tu rostro hacia la derecha';
      case DetectionStage.left:
        return 'Gira tu rostro hacia la izquierda';
      case DetectionStage.smile:
        return '¡Sonría!';
      case DetectionStage.exito:
        return 'DETECCION COMPLETA.';
      case DetectionStage.documentofrontal:
      return 'Coloque parte FRONTAL del documento en el cuadro';
      case DetectionStage.documentotrasero:
      return 'Coloque parte TRASERA del documento en el cuadro';
    }
  }

  DetectionStage advanceStage(DetectionStage currentStage,{String? process=''}) {
      switch (currentStage) {
        case DetectionStage.front :
          return DetectionStage.right;
          
        case DetectionStage.right:
          return DetectionStage.left;
          
        case DetectionStage.left:
          return DetectionStage.smile;
          
        case DetectionStage.smile:
          // Finaliza o reinicia
          return DetectionStage.exito;
          
        case DetectionStage.exito:
          // Finaliza o reinicia
          return DetectionStage.exito;

        case DetectionStage.documentofrontal:
          return DetectionStage.documentotrasero;

        case DetectionStage.documentotrasero:
          return DetectionStage.front;
          
      }
  }
  
  Future<File> saveTempFaceImage(
    Uint8List bytes,
    String name,
  ) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String path = '${tempDir.path}/$name.jpeg';

    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  /// Conversión precisa del flujo de imagen de la cámara a `InputImage`
  InputImage? convertCameraImageToInputImage(CameraImage image) {
    try {
      /*final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();*/
      
      final plane = image.planes[0];
      return InputImage.fromBytes(
        //bytes: bytes,
        bytes:plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.nv21, // Cambio clave: formato correcto
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      //print('Error en la conversión de imagen: $e');
      return null;
    }
  }

  Future<Uint8List?> cropFaceIsolate(Uint8List bytes ,double previewHeight) async {
    //final Uint8List bytes = data['bytes'];
    //final double previewHeight = data['previewHeight'];

  //  Decodificar la imagen usando el motor nativo de Flutter 
  final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(buffer);
  final ui.Codec codec = await descriptor.instantiateCodec();
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image fullImage = frameInfo.image;

  final int width = fullImage.width;
  final int height = fullImage.height;

  //  Cálculos de dimensiones 
  const double extraBottomMarginFactor = 0.40;
  final double frameWidth = width * 0.8;
  final double frameHeight = frameWidth * (1 + extraBottomMarginFactor);

  final double left = (width - frameWidth) / 2;
  final double top = (height - frameHeight) / 2 - (55 / previewHeight) * height;

  final double x = left.clamp(0, width - 1);
  final double y = top.clamp(0, height - 1);
  final double w = frameWidth.clamp(1, width - x);
  final double h = frameHeight.clamp(1, height - y);

  // RECORTAR Y REDIMENSIONAR usando el Canvas nativo
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Definimos el tamaño de salida (320x...)
  const double targetWidth = 320.0;
  final double targetHeight = (h * targetWidth) / w;

  // Dibujamos solo la parte recortada escalándola al destino
  canvas.drawImageRect(
    fullImage,
    ui.Rect.fromLTWH(x, y, w, h), // Fuente (Crop)
    ui.Rect.fromLTWH(0, 0, targetWidth, targetHeight), // Destino (Resize)
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(targetWidth.toInt(), targetHeight.toInt());
  
  // Convertir a ByteData (JPG/PNG)
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  // Limpieza de memoria
  fullImage.dispose();
  img.dispose();
  descriptor.dispose();
  buffer.dispose();

  return byteData?.buffer.asUint8List();
}

  
Uint8List? cropDocumentFrame(Map<String, dynamic> data) {
  final Uint8List imageBytes = data['imageBytes'];
  final double canvasWidth=data['canvasWidth'];
  final double canvasHeight=data['canvasHeight'];
  final decoded = img.decodeImage(imageBytes);
  if (decoded == null) return null;

  // 🔹 Parámetros del marco (igual que en tu CustomPainter)
  const double margin = 30;
  const double rectLeft = margin;
  final double rectTop = canvasHeight * 0.1;
  final double rectWidth = canvasWidth - 2 * margin;
  final double rectHeight = canvasHeight * 0.65;

  // 🔹 Escalar rectángulo al tamaño real de la imagen
  final double scaleX = decoded.width / canvasWidth;
  final double scaleY = decoded.height / canvasHeight;

  final int x = (rectLeft * scaleX).toInt();
  final int y = (rectTop * scaleY).toInt();
  final int w = (rectWidth * scaleX).toInt();
  final int h = (rectHeight * scaleY).toInt();

  // 🔹 Asegurarse que no salga de los límites
  final int cropX = x.clamp(0, decoded.width - 1);
  final int cropY = y.clamp(0, decoded.height - 1);
  final int cropW = min(w, decoded.width - cropX);
  final int cropH = min(h, decoded.height - cropY);

  // 🔹 Recortar
  final cropped = img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH);

  final resized = img.copyResize(cropped, width: 1200);
  // 🔹 Convertir a bytes (JPEG)
  return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
}


Future<void> logError(String error, String stack) async {
  try {
    await http.post(
      Uri.parse('https://app.ipsfa.gob.sv/appMovil/controlVivencia/error_log'),
      body: {
        'error': error,
        'stack': stack,
      },
    );
  } catch (e) {
    //showOverlaySnack('Hubo un error inesperado en el log_error', 'error');
  }
}

DateTime? _lastProcessed;
bool canProcessFrame() {
  final now = DateTime.now();
  if (_lastProcessed == null ||
      now.difference(_lastProcessed!).inMilliseconds > 300) {
    _lastProcessed = now;
    return true;
  }
  return false;
}
  /*Future<int> getTotalRAM() async {
    try {
      final meminfo = await rootBundle.loadString('/proc/meminfo');
      final line = meminfo.split('\n\n').firstWhere(
        (l) => l.startsWith('MemTotal'),
        orElse: () => '',
      );

      if (line.isEmpty) return 0;

      final parts = line.split(RegExp(r'\s+'));
      final kb = int.tryParse(parts[1]) ?? 0;
      return (kb / 1024).round(); // Convertir KB ➜ MB
    } catch (_) {
      return 0;
    }
  }

Size getRealResolution() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final physical = view.physicalSize;
  return Size(physical.width, physical.height);
}
  

  Future<DeviceTier> getDeviceTier() async {
    // CPU: número de arquitecturas soportadas
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final int cpuArchCount = androidInfo.supportedAbis.length;

    // RAM
    final int ramMB = await getTotalRAM();

    // Resolución usando physicalSize
    final Size resolution = getRealResolution();
    final double megapixels = (resolution.width * resolution.height) / 1_000_000;

    // ---- Clasificación ----
    if (ramMB < 2500 || cpuArchCount <= 2 || megapixels < 2.0) {
      return DeviceTier.low;
    }

    if (ramMB < 4000 || cpuArchCount <= 4) {
      return DeviceTier.mid;
    }

    if (ramMB < 6500 || cpuArchCount <= 6) {
      return DeviceTier.midHigh;
    }

    return DeviceTier.high;
  }*/
}
