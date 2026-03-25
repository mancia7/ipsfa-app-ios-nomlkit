// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:ipsfa/infrastucture/classes/detect_gama.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/main.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/cuenta_regresiva.dart';
//import 'package:ipsfa/presentation/widgets/beneficiaros_dialog.dart';
import 'package:ipsfa/presentation/widgets/face_overlay.dart';
import 'package:ipsfa/presentation/widgets/recuadro_documento.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:ipsfa/screens/control_vivencia.dart';
import 'package:ipsfa/screens/login.dart';
//import 'package:ipsfa/screens/pagina_principal.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ValidarVivencia extends StatefulWidget {
  const ValidarVivencia({super.key});
  @override
  State<ValidarVivencia> createState() => _ValidarVivenciaState();
}


class _ValidarVivenciaState extends State<ValidarVivencia>
    with WidgetsBindingObserver {
  late List<CameraDescription> _cameras = [];
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  final faceDetector = FaceDetector(
      options:  FaceDetectorOptions(
                  performanceMode: FaceDetectorMode.accurate, // Prioriza precisión
                  enableClassification: true, // Permite identificar rasgos
                  enableLandmarks: true, // Identifica puntos clave
                  minFaceSize: 0.2, // Mejora la detección de rostros pequeños
                ));
  int _currentCameraIndex = 0;
  //bool _allPositionsDetected = false; // Bandera para activar el botón de envío
  final ValueNotifier<Color> _frameColor = ValueNotifier(Colors.transparent); // Color inicial del marco
  
  final ValueNotifier<bool> _isDetecting = ValueNotifier(false);// Control para activar detección
  //bool _beginDetecting = false;
  // Checklist para indicar posiciones detectadas
  final ValueNotifier<bool> _frontalDetected = ValueNotifier(false);
  final ValueNotifier<bool> _smileDetected = ValueNotifier(false);
  //bool _rightDetected = false;
  //bool _leftDetected = false;
  final ValueNotifier<bool> _isSendingData = ValueNotifier(false);

  final ValueNotifier<bool> _showCounter =ValueNotifier(false);

  bool _cameraReady = false;

  GeneralMethods general = GeneralMethods();

  //String? _tipoUsuario = '';

  double _previewWidth = 0;
  double _previewHeight = 0;
  final ValueNotifier<DetectionStage> _currentStage = ValueNotifier(DetectionStage.documentofrontal);
  
  //String _rostro = '';
  //String _documento='';
  String _tiporostro = '';
  final ValueNotifier<bool> _returnapi = ValueNotifier(false);
  final ValueNotifier<bool> _frontalTaked=ValueNotifier(false);
  final ValueNotifier _backTaked = ValueNotifier(false);
  /*final Map<String, String> _capturas = {
    'id_afiliado': '',
    'frontal': '',
    'izquierdo': '',
    'derecho': '',
    'sonrisa': '',
    //'tipoUsuario': '',
    'numBeneficiario': ''
  };*/

  //VARIABLES PARA SENSIBILIDAD DE ROSTROS Y DISPOSITIVO
  late DeviceLevel deviceLevel;
  //late double _minY;
  //late double _maxY;
  late double _smileProbability;
  late double _frontSensitive;
  //bool _validated = false;
  //Variable para manejar la voz
  final FlutterTts flutterTts = FlutterTts();

  String _idafiliado = '';
  String _password = '';
  String _numBeneficiario = '';
  final ValueNotifier<bool> _insideFrame=ValueNotifier( false);
  final ValueNotifier<bool> _changeFront=ValueNotifier(false);

  final ValueNotifier<int> _contador = ValueNotifier(0);
  bool _isDisposed = false;
  void validarLogin(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);
    //print(auth);
    if (!auth.isLoggedIn) {
      Future.microtask(() {
        general.redirigir(context, const Login());
      });
    }
  }

  @override
  void initState() {
    //final context = navigatorKey.currentState?.overlay?.context;
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDevice();
    //if (context == null) return;
    //validarLogin(context);
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    faceDetector.close();
    super.dispose();
  }

  Future<void> initDevice() async {
    deviceLevel = await DeviceClassifier.getDeviceLevel();
    configureSensitivity();
    await requestPermissions();
  }

    void configureSensitivity() {
      

    //_minY = 35;
    //_maxY = 8;
    _frontSensitive = 10;
    _smileProbability = 0.45;
  /*switch (deviceLevel) {
    case DeviceLevel.medium:
      //_minY = 40;
      //_maxY = 15;
      _frontSensitive = 12;
      _smileProbability = 0.65;
      break;
    case DeviceLevel.mediumHigh:
      //_minY = 35;
      //_maxY = 12;
      _frontSensitive = 10;
      _smileProbability = 0.55;
      break;
    case DeviceLevel.high:
      //_minY = 25;
      //_maxY = 10;
      _frontSensitive = 8;
      _smileProbability = 0.45;
      break;
    case DeviceLevel.ultraHigh:
      //_minY = 20;
      //_maxY = 8;
      _frontSensitive = 6;
      _smileProbability = 0.35;
      break;
    default:
      // gama baja no se usa
      //_minY = -999;
      //_maxY = 999;
      break;
  }*/
}
  Future<void> speak(String text) async {
    await flutterTts.setLanguage("es-ES"); // Español
    await flutterTts.setPitch(1.0); // Tono normal
    await flutterTts.speak(text);
  }

  Future<void> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      if (_isDisposed) return;
      _initializeCamera(_currentCameraIndex);
      //print('✅ Permisos concedidos después de solicitar');
    }
    if (cameraStatus.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        if (_isDisposed) return;
        _initializeCamera(_currentCameraIndex);
      } else {
        await openAppSettings();
      }
    } else if (cameraStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  // Inicializa la cámara actual
  void _initializeCamera(int index) async {
    if (_isDisposed) return;
    _cameras = await availableCameras();
    if (!mounted) return;
    
    _controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    if (!mounted) return;
    _cameraReady = true;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      // App en segundo plano => liberar la cámara
      //No necesito hacer dispose, flutter ya lo maneja y solo necesito inicializar la camara abajo en el resumed
      //_controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (await Permission.camera.isGranted) {
        if (_isDisposed) return;
        _initializeCamera(_currentCameraIndex); // o el método que uses para reiniciar la cámara
      } else {
        // Avisa al usuario o muestra un diálogo
        await openAppSettings();
      }
    }
  }

  /*void _toggleCamera() async {
    if (_controller.value.isStreamingImages) {
      _startDetection();
      await _controller.stopImageStream();
      await _controller.dispose();
      await _initializeControllerFuture;
    }

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    _initializeCamera();
  }*/
  Future<void> switchCamera() async {
    if (!mounted) return;
    _controller.dispose();
  final cameras = await availableCameras();
  final newCamera = _contador.value==2
      ? cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front)
      : cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);

  _controller = CameraController(newCamera, ResolutionPreset.high);
  await _controller.initialize();
  _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
}


  void _startDetection() async {
    if (!_cameraReady) return;

    await _initializeControllerFuture;
    if (!mounted) return;
    //setState(() {
      _isDetecting.value = true;
      _frameColor.value = Colors.orange;
      //_beginDetecting = true;
    //});

    _controller.startImageStream(_processCameraImage);
   //setState(() {
   //  
   //});
  }

  /*Rect expandRect(Rect rect, double percent) {
  final double dw = rect.width * percent;
  final double dh = rect.height * percent;

  return Rect.fromLTRB(
    rect.left - dw,
    rect.top - dh,
    rect.right + dw,
    rect.bottom + dh,
  );
}*/

  void _processCameraImage(CameraImage image) async {
    if (!general.canProcessFrame()) return;
    if (!_controller.value.isStreamingImages) return;
    if (!_isDetecting.value) return;
    _showCounter.value = false;
    try {
     
      final inputImage = general.convertCameraImageToInputImage(image);
      
      if (inputImage == null) {
        
        return;
      }
      final faces = await faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        //setState(() => _frameColor.value = Colors.redAccent);
        return;
      }
      final double previewWidth = _previewWidth;
      final double previewHeight = _previewHeight;

      // 🔹 Tamaño del recuadro (igual a tu FractionallySizedBox + AspectRatio)
      final double frameWidth = previewWidth * 0.8;
      final double frameHeight = frameWidth; // aspectRatio = 1
      final double frameLeft = (previewWidth - frameWidth) / 2;
      final double frameTop = (previewHeight - frameHeight) / 2;

      // 🔹 Escala de la cámara al preview
      final double imageW = image.height.toDouble(); // rota si es frontal
      final double imageH = image.width.toDouble();
      final double scaleX = previewWidth / imageW;
      final double scaleY = previewHeight / imageH;

      //bool faceInside = false;

      for (var face in faces) {
        //final rect = face.boundingBox;
        
        double left = face.boundingBox.left * scaleX;
        double right = face.boundingBox.right * scaleX;
        double top = face.boundingBox.top * scaleY;
        double bottom = face.boundingBox.bottom * scaleY;

        left = _previewWidth - right;
        right = _previewWidth - face.boundingBox.left * scaleX;

        final Rect faceRect = Rect.fromLTRB(left, top, right, bottom);

        final Rect frameRect = Rect.fromLTWH(
          frameLeft,
          frameTop,
          frameWidth,
          frameHeight,
        );
        //final Rect expandedRect = expandRect(frameRect, 0.15);
        _insideFrame.value =
          frameRect.contains(faceRect.topLeft)&&
          frameRect.contains(faceRect.bottomRight);
        
        if (!_insideFrame.value) {
           //setState(() {
           // });
          _frameColor.value = Colors.red;
          continue;
        }else{
          //setState(() {
          //});
          _frameColor.value = Colors.orange;
        }


        if (left > frameLeft &&
        right < frameLeft + frameWidth &&
        top > frameTop &&
        bottom < frameTop + frameHeight) {
          final eulerAngleY = face.headEulerAngleY ?? 0;

          if (!_frontalDetected.value && eulerAngleY.abs() < _frontSensitive && _isDetecting.value) {
            
                await _controller.stopImageStream();
              
            XFile file = await _controller.takePicture();
            Uint8List bytes = await file.readAsBytes();
            //_rostro = base64Encode(bytes);
            //final croppedFace = general.cropFace(bytes, face, image,_controller.value.previewSize!);
            Uint8List? croppedFace;
            try {
              //print("Iniciando recorte..."); // D
              croppedFace = await general.cropFaceIsolate(
                bytes,
                _previewHeight,
              );

              if (croppedFace == null) {
                //print("Error: El recorte devolvió null");
              } else {
                //print("Recorte exitoso: ${croppedFace.length} bytes");
                // Aquí ya puedes usar tu imagen
              }
            } catch (e) {
              throw("Error detectado: $e");
            }
            if (croppedFace != null) {
              //final String base64Face = base64Encode(croppedFace);
              //_rostro = base64Face;
            }
            _tiporostro = 'fontral';
            await _sendDataToApi(croppedFace!);
            _tiporostro = '';
            _isDetecting.value = false;
            if (!_returnapi.value) {
            await Future.delayed(const Duration(milliseconds: 1));
              _startDetection();
              return;
            }
            showOverlaySnack('Perfil FRONTRAL detectado correctamente.','');
            _frontalDetected.value = true;
            _currentStage.value=general.advanceStage(DetectionStage.left);
            await speak("Perfil frontal detectado");
            if (!mounted) return;
            await Future.delayed(const Duration(milliseconds: 1800));
            _showCounter.value = true;
            _returnapi.value = false;
            //setState(() {
            //});
            //return;
          }/*
          else if (!_rightDetected && eulerAngleY < -8 && _frontalDetected.value) {
          //general.showSnackBar(context,'Perfil DERECHO detectado.');
            _rightDetected = true;
          
    
          await _controller.stopImageStream();
              
          showOverlaySnack('Perfil IZQUIERDO detectado correctamente.','');
          setState(() {
            _frameColor.value = Theme.of(context).colorScheme.primary;
            _isDetecting.value = false;
          });
          _currentStage.value=general.advanceStage(_currentStage.value);
          await speak("Perfil IZQUIERDO detectado.");
          if (!_returnapi.value) {
              _startDetection();
              return;
          }
        } else if (!_leftDetected &&
            eulerAngleY > 8 &&
            _frontalDetected.value &&
            _rightDetected) {
            _leftDetected = true;
    
            await _controller.stopImageStream();
              
          showOverlaySnack('Perfil DERECHO detectado correctamente.','');
          setState(() {
            _frameColor.value = Theme.of(context).colorScheme.primary;
            _isDetecting.value = false;
          });
          await speak("Perfil DERECHO detectado.");
          _currentStage.value=general.advanceStage(_currentStage.value);
          if (!_returnapi.value) {
              _startDetection();
              return;
          }
        }*/ else if (!_smileDetected.value &&
                  (face.smilingProbability ?? 0.0) > _smileProbability &&
                  _frontalDetected.value //&&
              //_rightDetected &&
              //_leftDetected
              ) {
            
              await _controller.stopImageStream();
              
            XFile file = await _controller.takePicture();
            Uint8List bytes = await file.readAsBytes();
            //_rostro = base64Encode(bytes);
            //final croppedFace = general.cropFace(bytes, face, image,_controller.value.previewSize!);
            Uint8List? croppedFace;
            try {
              //print("Iniciando recorte..."); // D
              croppedFace = await general.cropFaceIsolate(
                bytes,
                _previewHeight,
              );

              if (croppedFace == null) {
                //print("Error: El recorte devolvió null");
              } else {
                //print("Recorte exitoso: ${croppedFace.length} bytes");
                // Aquí ya puedes usar tu imagen
              }
            } catch (e) {
              throw("Error detectado: $e");
            }
            if (croppedFace != null) {
              //final String base64Face = base64Encode(croppedFace);
              //_rostro = base64Face;
            }
            _smileDetected.value = true;
            _frameColor.value = Theme.of(context).colorScheme.primary;
            showOverlaySnack('SONRISA detectada correctamente.','');
            await _sendDataToApi(croppedFace!);
            await speak("Sonrisa detectada, detección completa");
            if (!mounted) return;
            //general.showSnackBar(context, 'SONRISA detectada correctamente.');
            
            _isDetecting.value = false;
            
            //setState(() {
            //});
          }
        }
      }
    } catch (e) {
      //print('Error al procesar la imagen: $e');
    }
  }

 Future<void> _guardarFotoDoc() async {
  _isSendingData.value = true;
  if (!mounted) return;

  final image = await _controller.takePicture();
  Uint8List bytes = await image.readAsBytes();

  double canvasWidth = 1080;
  double canvasHeight = 1920;

  final croppedBytes = await compute(
    general.cropDocumentFrame,
    {
      'imageBytes': bytes,
      'canvasWidth': canvasWidth,
      'canvasHeight': canvasHeight,
    },
  );

  if (croppedBytes == null) {
    _isSendingData.value = false;
    showOverlaySnack('No se pudo procesar la imagen', 'error');
    return;
  }

  const url =
      'https://app.ipsfa.gob.sv/appMovil/controlVivencia/guardarFotoDoc';

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'documento', // nombre del campo en PHP
        croppedBytes,
        filename: 'documento.jpg',
      ),
    );

    request.fields['tipoDoc'] = _contador.value.toString();
    request.fields['id_afiliado'] = _idafiliado.toString();
    request.fields['password'] = _password.toString();
    request.fields['numBeneficiario'] = _numBeneficiario.toString();

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 20));

    final response = await http.Response.fromStream(streamedResponse);

    final respuesta = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('STATUS: $respuesta');
    debugPrint('RAW RESPONSE: ${response.body.substring(0, min(2000, response.body.length))}');
    if (respuesta['Success'] == '1') {
      _isSendingData.value = false;

      if (_contador.value == 0) {
        _frontalTaked.value = true;
      } else {
        _backTaked.value = true;
      }

      _contador.value++;
      if (!mounted) return;

      _currentStage.value = general.advanceStage(_currentStage.value);

      showOverlaySnack('Foto guardada CORRECTAMENTE', '');
      await speak('Foto guardada CORRECTAMENTE');

      if (_contador.value == 2) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

        if (!mounted) return;
        if (_isDisposed) return;

        _initializeCamera(_currentCameraIndex);
        _changeFront.value = true;
        _contador.value++;

        setState(() {});
        _showCounter.value = true;
      }
    } else {
      if (mounted) {
        showOverlaySnack(respuesta['error'], 'error');
      }
    }
  } on http.ClientException {
    showOverlaySnack('Error de conexión', 'error');
  } on TimeoutException {
    showOverlaySnack(
        'La solicitud está tardando demasiado. Intenta de nuevo.', 'error');
  } catch (e) {
    await general.logError('Guardar foto doc error catch:', e.toString());
    showOverlaySnack('Error catch: $e', 'error');
  }

  if (!mounted) return;
}

  Future<void> _sendDataToApi(Uint8List croppedFace) async {
    if (!mounted) return;
    //setState(() =>)
     _isSendingData.value = true;
    const url =
        'https://app.ipsfa.gob.sv/appMovil/controlVivencia/validarRostro'; // URL API
    try {
      
      var request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );
    
    request.files.add(
      http.MultipartFile.fromBytes(
        'rostro', // nombre del campo en PHP
        croppedFace,
        filename: 'rostro.jpg',
      ),
    );

    request.fields['tipoRostro'] = _tiporostro;
    request.fields['id_afiliado'] = _idafiliado.toString();
    request.fields['password'] = _password.toString();
    request.fields['numBeneficiario'] = _numBeneficiario.toString();

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 20));

    final response = await http.Response.fromStream(streamedResponse);
    final respuesta = jsonDecode(response.body) as Map<String, dynamic>;

    debugPrint('STATUS: $respuesta');
    debugPrint('RAW RESPONSE: ${response.body.substring(0, min(2000, response.body.length))}');

      if (respuesta['Success'] == '1') {
        //await speak("Vivencia completada. Gracias");
          showOverlaySnack('CONTROL VIVENCIA COMPLETADO','');
        //general.showSnackBar(context, 'CONTROL VIVENCIA COMPLETADO');
        Provider.of<UserProvider>(context, listen: false)
            .updDisponibilidad("N");
        Provider.of<UserProvider>(context, listen: false).updVivencia("S");
        _returnapi.value = true;
        Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => const ControlVivencia()),
            (Route<dynamic> route) => false,
          );
          /*general.redirigir(
              context,
              const PaginaPrincipal(
                loginHuella: false,
              ));*/
        });
      } else if (respuesta['Success'] == '2') {
        _returnapi.value = true;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted){
          showOverlaySnack(respuesta['error'],'error');
            //general.showSnackBar(context, respuesta['error'], color: 'error');
          }
          _returnapi.value = false;
        });
      }
    } on http.ClientException {
          showOverlaySnack('Error de conexion','error');
      //general.showSnackBar(context, 'Error de conexion', color: 'error');
      //return {'status': false,'message':'Error de conexion. Favor revisar su conexion a internet'};
    } on TimeoutException {
          showOverlaySnack('La solicitud está tardando demasiado. Intenta de nuevo.','error');
      //general.showSnackBar(context, 'La solicitud está tardando demasiado. Intenta de nuevo.',color: 'error');
      //return {'status': false,'message':'La solicitud está tardando demasiado. Intenta de nuevo.'};
      //throw Exception('La solicitud está tardando demasiado. Intenta de nuevo.');
    } catch (e) {
      //print(e);
      //await general.logError('ValidarVivencia.php error catch:', e.toString()) ;
          showOverlaySnack('Error: $e','error');
          //print(e) ;
      //general.showSnackBar(context, 'Error: $e', color: 'error');
    }
    if (!mounted) return;
    //setState(() => )
    _isSendingData.value = false;
    /*} else {
      general.showSnackBar(context, 'Favor seleccionnar una opcion',
          color: 'Error');
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    _idafiliado = context.watch<UserProvider>().user!.afiliacion;
    _password = context.watch<UserProvider>().user!.password;
    _numBeneficiario = context.watch<UserProvider>().user!.numBeneficiario;

    //_capturas["id_afiliado"] = idAfiliado;
    //_capturas["numBeneficiario"] = numBeneficiario;
    //final auth = Provider.of<AuthController>(context, listen: false);

    return PopScope(
      //canPop: false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Validacion de vivencia',
              style: TextStyle(fontSize: 0.07 * textScale),
            ),
            //automaticallyImplyLeading: false,
          ),
          body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final size = MediaQuery.of(context).size;
                //final cameraRatio = _controller.value.previewSize!.height /_controller.value.previewSize!.width;

                return LayoutBuilder(
                    builder: (context, constraints) {
                    _previewWidth = constraints.maxWidth;
                    _previewHeight = constraints.maxHeight;
                    return Stack(
                      children: [
                        OverflowBox(
                          maxHeight: size.height,
                          maxWidth: textScale * 1.5,
                          child:  CameraPreview(_controller),
                          
                        ),
                        
                         ValueListenableBuilder(
                            valueListenable:  _showCounter,
                            builder: (_, value, __) {
                              return  value?
                                      CountdownScreen(
                                        contador: 3,
                                        onFinish:(){
                                          if(!mounted)return;
                                           _contador.value =0;
                                          _startDetection();
                                        }
                                      ):const Text('');
                            }
                          ),
                    
                    
                        ValueListenableBuilder(
                          valueListenable: _backTaked,
                          builder: (context, value, child) {
                            if(!value){
                              return Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: DocumentFramePainter(),
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          }
                        ),
                        ValueListenableBuilder(
                          valueListenable: _currentStage,
                          builder: (context, value, child) {
                              return ValueListenableBuilder(
                                valueListenable: _changeFront,
                                builder: (context, value, child) {
                                  if(value){
                                    return FaceOverlay(assetPath: general.getGuideImagePath(_currentStage.value));
                                  }
                                  return const Text('');
                                }
                              );
                          }
                        ),  
                        
                    
                          ValueListenableBuilder(
                            valueListenable: _isSendingData,
                            builder: (context, value, child) {
                              if (value){
                                return OverflowBox(
                                  maxHeight: size.height,
                                  maxWidth: textScale * 1.5,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    height: textScale * 0.5,
                                    width: textScale * 0.5,
                                    child: CircularProgressIndicator(
                                      color:
                                          Provider.of<ThemeProvider>(context).iconColor,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            }
                          ),
                    
                          ValueListenableBuilder(
                            valueListenable: _currentStage,
                            builder: (context, value, child) {
                              return ValueListenableBuilder(
                                valueListenable:  _isDetecting,
                                    builder: (context, value, child) {
                                  if (value) {
                                    return Positioned(
                                      bottom: !value?textScale*0.3:textScale*0.2,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          color: Colors.black54,
                                          child: Text(
                                            general.getInstructionText(_currentStage.value),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 0.065 * textScale,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                }
                              );
                            }
                          ),

                          
                          ValueListenableBuilder(
                            valueListenable: _isDetecting,
                            builder: (context, value, child) {
                              if (value){
                                return Positioned(
                                  bottom: textScale*0.45,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: ValueListenableBuilder(
                                      valueListenable: _insideFrame,
                                      builder: (context, value, child) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          color: !value?Colors.red:Theme.of(context).colorScheme.primary,
                                          child: Text(
                                            value?'Esta DENTRO del recuadro':'Esta FUERA del recuadro',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            }
                          ),
                    
                        
                          ValueListenableBuilder(
                            valueListenable: _isDetecting,
                            builder: (context, value, child) {
                              if (value){
                                return ValueListenableBuilder(
                                  valueListenable: _frameColor,
                                  builder: (context, value, child) {
                                    return Positioned.fill(
                                      bottom: 55,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.8,
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: value,
                                                  width: 3.0,
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                );
                              }
                              return const Text('');
                            }
                          ),
                    
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            
                            ValueListenableBuilder(
                              valueListenable: _frontalTaked,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color:
                                          value ? Colors.green : Colors.red),
                                  title: Text('DUI Frontal',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            ),
                            ValueListenableBuilder(
                              valueListenable: _backTaked,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color:
                                          value ? Colors.green : Colors.red),
                                  title: Text('DUI Trasero',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            ),
                            
                            ValueListenableBuilder(
                              valueListenable: _frontalDetected,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color:
                                          value ? Colors.green : Colors.red),
                                  title: Text('Parte Frontal',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            ),/*
                            ListTile(
                                  leading: Icon(
                                      size: 0.11 * textScale,
                                      _rightDetected ? Icons.check : Icons.close,
                                      color: _rightDetected ? Colors.green : Colors.red),
                                  title: Text('Perfil Izquierdo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                ),
                                ListTile(
                                  leading: Icon(
                                      size: 0.11 * textScale,
                                      _leftDetected ? Icons.check : Icons.close,
                                      color: _leftDetected ? Colors.green : Colors.red),
                                  title: Text('Perfil Derecho',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                ),*/
                            ValueListenableBuilder(
                              valueListenable: _smileDetected,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color:
                                          value ? Colors.green : Colors.red),
                                  title: Text('Sonrisa',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            ),
                          ],
                        ),
                    
                        //Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Container()),
                            
                            const SizedBox(
                              height: 10,
                            ),
                            
                            ValueListenableBuilder(
                              valueListenable: _backTaked,
                              builder: (context, value, child) {
                                if(!value){
                                  return FloatingActionButton(
                                    heroTag: "Tomar foto",
                                    onPressed: () async {
                                      try {
                                        if(!_isSendingData.value){
                                          _guardarFotoDoc();
                                        }else{
                                          null;
                                        }
                                        
                                      } catch (e) {
                                        debugPrint("Error al tomar foto: $e");
                                      }
                                    },
                                    child: const Icon(Icons.camera_alt),
                                  );
                                }
                                return const Text('');
                              }
                            ),
                            
                      
                            const SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                        //]),
                      ],
                    );
                  },
                );
              } else {
                return Center(
                    child: CircularProgressIndicator(
                  color: Provider.of<ThemeProvider>(context).iconColor,
                ));
              }
            },
          )),
    );
  }
}
