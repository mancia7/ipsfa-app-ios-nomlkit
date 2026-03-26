// ignore_for_file: use_build_context_synchronously

import 'dart:async';
//import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:ipsfa/infrastucture/classes/detect_gama.dart';
//import 'package:http/http.dart' as http;
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/cuenta_regresiva.dart';
//import 'package:ipsfa/presentation/widgets/beneficiaros_dialog.dart';
import 'package:ipsfa/presentation/widgets/face_overlay.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
//import 'package:ipsfa/screens/control_vivencia.dart';
import 'package:ipsfa/screens/login.dart';
import 'package:ipsfa/screens/verificar_fotos.dart';
import 'package:ipsfa/shared/auth/shared_login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GetBiometricos extends StatefulWidget {
  final Map<String, dynamic>? capturas;
  final int? positionCapture;
  const GetBiometricos({super.key, this.capturas,this.positionCapture});
  @override
  State<GetBiometricos> createState() => _GetBiometricosState();
}

enum FaceStage { frontal, izquierdo, derecho, sonrisa }
class _GetBiometricosState extends State<GetBiometricos> with WidgetsBindingObserver {

  late List<CameraDescription> _cameras = [];
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: false,
      enableContours: false,
      enableClassification: true, // sonrisa
      minFaceSize: 0.15,
    ),
  );

  //bool _allPositionsDetected = false; // Bandera para activar el botón de envío
  Color _frameColor = Colors.transparent; // Color inicial del marco
  final ValueNotifier<bool> _isDetecting = ValueNotifier(false); // Control para activar detección
  //bool _beginDetecting = false;
  // Checklist para indicar posiciones detectadas
  final ValueNotifier<bool> _frontalDetected = ValueNotifier(false);
  final ValueNotifier<bool> _leftDetected  =ValueNotifier(false);
  final ValueNotifier<bool> _rightDetected =ValueNotifier(false);
  final ValueNotifier<bool> _smileDetected =ValueNotifier(false);
  final ValueNotifier<bool> _cameraReady =ValueNotifier(false);
  
  final ValueNotifier<bool> _showCounter =ValueNotifier(false);

  bool _isDisposed=false;

  double _previewWidth = 0;
  double _previewHeight = 0;
  GeneralMethods general = GeneralMethods();
  bool _isEnrollmentActive = true;
  bool _isProcessing=false;
  //String? _tipoUsuario = '';

  final ValueNotifier<DetectionStage> _currentStage = ValueNotifier(DetectionStage.front);

  final Map<String,DetectionStage> _positionStage={
    'frontal':DetectionStage.front,
    'izquierdo':DetectionStage.right,
    'derecho':DetectionStage.left,
    'sonrisa':DetectionStage.smile
  };
  final Map<String, dynamic> _capturas = {
    'id_afiliado': '',
    'faces': <String, Uint8List>{},
    //'tipoUsuario': '',
    'numBeneficiario': '',
    'password': ''
  };
  

  //VARIABLES PARA SENSIBILIDAD DE ROSTROS Y DISPOSITIVO
  late DeviceLevel deviceLevel;
  late double _minY;
  late double _maxY;
  late double _smileProbability;
  late double _frontSensitive;

 // bool _saved = false;
  //Variable para manejar la voz
  final FlutterTts flutterTts = FlutterTts();

  //bool _serviceEnabled = false;
  final ValueNotifier<bool> _insideFrame=ValueNotifier(false);
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
    super.initState();
    initDevice();
    WidgetsBinding.instance.addObserver(this);
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
    setState((){});
  } 
  
  void validateResetCapture(String tipo){
    //print('tipo get bio: $tipo');
    _currentStage.value=_positionStage[tipo]!;
    //print('_currentStage.value: ${_currentStage.value}');
    //print('_positionStage[tipo]: ${_positionStage[tipo]}');
      _isDetecting.value = false;
    if(tipo=='frontal'){
      _frontalDetected.value = false;
    }else if(tipo=='izquierdo'){
      _rightDetected.value = false;
    }else if(tipo=='derecho'){
      _leftDetected.value = false;
    }else {
      _smileDetected.value = false;
    }
      
      //setState((){});
      _showCounter.value = true;
  }

  void configureSensitivity() {

   /* _minY = 35;
    _maxY = 8;
    _frontSensitive = 10;
    _smileProbability = 0.45;*/
    
  switch (deviceLevel) {
    case DeviceLevel.medium:
      _minY = 35;
      _maxY = 8;
      _frontSensitive = 8;
      _smileProbability = 0.75;
      break;
    case DeviceLevel.mediumHigh:
      _minY = 35;
      _maxY = 8;
      _frontSensitive = 8;
      _smileProbability = 0.75;
      break;
    case DeviceLevel.high:
      _minY = 40;
      _maxY = 10;
      _frontSensitive = 8;
      _smileProbability = 0.75;
      break;
    case DeviceLevel.ultraHigh:
      _minY = 50;
      _maxY = 11;
      _frontSensitive = 9;
      _smileProbability = 0.75;
      break;
    default:
      // gama baja no se usa
      _minY = -999;
      _maxY = 999;
      break;
  }
}

  /*Future<Position?> getUserLocation() async {
    LocationPermission permission;

    // Verifica si el GPS está habilitado
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      
      showOverlaySnack('Favor activar servicio de ubicacion del dispositivo','error');
      //general.showSnackBar(context, 'Favor activar servicio de ubicacion del dispositivo',color: 'error');
      return null;
    }

    // Verifica el permiso
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Obtener ubicación actual
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }*/

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("es-ES"); // Español
    await flutterTts.setPitch(1.0); // Tono normal
    await flutterTts.speak(text);
  }

Future<void> requestPermissions() async {
  final status = await Permission.camera.request();

  if (_isDisposed) return;

  if (status.isGranted) {
    _initializeCamera();
  } else if (status.isDenied) {
    // Usuario negó, puedes mostrar mensaje si quieres
    //print("Permiso de cámara denegado");
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
  }
}

  // Inicializa la cámara actual
  void _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[1],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    _cameraReady.value = true;
      setState(() {});
    //await Future.delayed(const Duration(milliseconds: 1000));
    _showCounter.value = true;
    //if (mounted) {
    //}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
     if (!_isEnrollmentActive) return;
    if (state == AppLifecycleState.inactive) {
      // App en segundo plano => liberar la cámara
      //No necesito hacer dispose, flutter ya lo maneja y solo necesito inicializar la camara abajo en el resumed
      //_controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (await Permission.camera.isGranted && _isEnrollmentActive) {
          _initializeCamera(); // o el método que uses para reiniciar la cámara
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
  void _resetCaptureProcess(){
    (_capturas['faces'] as Map<String, Uint8List>).clear();
    _isDetecting.value = false;
    _frontalDetected.value = false;
    _leftDetected.value = false;
    _rightDetected.value = false;
    _smileDetected.value = false;
    _currentStage.value = DetectionStage.front;
    setState((){});
    _showCounter.value = true;
  }

  void _startDetection() async {
    if (!mounted) return;
    if (!_cameraReady.value) return;

    await _initializeControllerFuture;

    //setState(() {
      _isDetecting.value = true;
      _frameColor = Colors.orange;
    //});
    await _controller.startImageStream(_processCameraImage);
  }

  Future<bool> getFaceDetection(Face stableFace, CameraImage image,String perfil) async {
    bool result = false;
    //final sw = Stopwatch()..start();
  try {
    // === tu mismo código tal cual ===
    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
    }
    final XFile file = await _controller.takePicture();
    //print("takePicture: ${sw.elapsedMilliseconds} ms");
    /*if(deviceLevel==DeviceLevel.high || deviceLevel==DeviceLevel.ultraHigh){
      await Future.delayed(const Duration(milliseconds: 50));  
    }else{
      await Future.delayed(const Duration(milliseconds: 300)); 
    }*/
    
    result = true;
    // Tomar foto
    if (!_controller.value.isInitialized)   return false;

    // Leer bytes
    Uint8List bytes = await file.readAsBytes();
    //print("readAsBytes: ${sw.elapsedMilliseconds} ms");

    // Recortar rostro (igual que lo tenías)
    /*final croppedFace = general.cropFace(
      bytes,
      stableFace,
      image,
      _controller.value.previewSize!
    );
    //print("Tamaño original: ${bytes.lengthInBytes} bytes");
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 70,
    );*/

    //if (compressed != null) {
    //  print("Tamaño comprimido: ${compressed.lengthInBytes} bytes");
    //}
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
    //);
    //print("cropped: ${sw.elapsedMilliseconds} ms");

    // Guardar frontal si existe
    //if (croppedFace != null) {
      //final String base64Face = base64Encode(croppedFace); 
      //general.saveTempFaceImage(croppedFace, perfil);
      final perfilSpeak = perfil == 'frontal'
        ? 'Perfil frontal detectado'
        : perfil == 'izquierdo'
            ? 'Perfil izquierdo detectado'
            : perfil == 'derecho'
                ? 'Perfil derecho detectado'
                : 'sonrisa detectada detección completa';
                
      //Guardar en memoria los rostros
       _capturas['faces'][perfil] = croppedFace;
      /*if(perfil=='frontal'){
        _capturas['faces']['frontal'] = croppedFace; 
      }else if(perfil=='izquierdo'){
        _capturas['faces']['izquierdo'] = croppedFace;
      }else if(perfil=='derecho'){
        _capturas['faces']['derecho'] = croppedFace;
      }else{
        _capturas['faces']['sonrisa'] = croppedFace;
      }*/
      // Mensaje visual   
      showOverlaySnack(perfilSpeak.toUpperCase(), '');
      // Hablar
      await speak(perfilSpeak);
    //}

    
    //setState(() {});

  } catch (e) {
    //print("Error tomando captura: $e");
    result = false;
  } finally {
      if(_capturas['faces']['sonrisa'].toString()=='null'){
      // Avanzar etapa con tu función
      _currentStage.value = general.advanceStage(_currentStage.value);
        //await Future.delayed(const Duration(milliseconds: 850));
         /*if (mounted){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CountdownScreen(
              contador: 3,
              onFinish: () async {
                Navigator.pop(context);   // cerrar modal
                await Future.delayed(const Duration(milliseconds: 500));
                _startDetection();
              },
            ),
          );
         }*/_showCounter.value = true;
      }else{
        // Enviar datos a la API
        //await _sendDataToApi(_capturas);
        //await Future.delayed(const Duration(milliseconds: 250));
        _isEnrollmentActive=false;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FaceReviewScreen(loginData: _capturas),
          ),
        );

        if (result == "retry") {
          _resetCaptureProcess();
        }else{
          validateResetCapture(result);
        }

      }
  }
  
   return result;
}


  void _processCameraImage(CameraImage image) async {
    if (!general.canProcessFrame()) return;
    if (!_controller.value.isStreamingImages) return;
    if (!mounted) return;
    if (_isProcessing) return;
    _showCounter.value = false;
    _isProcessing = true;
    try {
      final inputImage = general.convertCameraImageToInputImage(image);

      if (inputImage == null) {
        //print('Error: No se pudo convertir la imagen.');
        return;
      }
      
      final faces = await faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        //setState(() => _frameColor = Colors.red Accent);
        return;
      }
      final double previewWidth = _previewWidth;
      final double previewHeight = _previewHeight;

      //  Tamaño del recuadro (igual a tu FractionallySizedBox + AspectRatio)
      final double frameWidth = previewWidth * 1;
      final double frameHeight = frameWidth; // aspectRatio = 1
      final double frameLeft = (previewWidth - frameWidth) / 2;
      final double frameTop = (previewHeight - frameHeight) / 2;

      //  Escala de la cámara al preview
      final double imageW = image.height.toDouble(); // rota si es frontal
      final double imageH = image.width.toDouble();
      final double scaleX = previewWidth / imageW;
      final double scaleY = previewHeight / imageH;

      final Rect frameRect = Rect.fromLTWH(
        frameLeft,
        frameTop,
        frameWidth,
        frameHeight,
      );
      for (var face in faces) {
        final eulerAngleY = face.headEulerAngleY ?? 0;


        double left = face.boundingBox.left * scaleX;
        double right = face.boundingBox.right * scaleX;
        double top = face.boundingBox.top * scaleY;
        double bottom = face.boundingBox.bottom * scaleY;

        left = _previewWidth - right;
        right = _previewWidth - (face.boundingBox.left * scaleX);

        final Rect faceRect = Rect.fromLTRB(left, top, right, bottom);

        _insideFrame.value =
          frameRect.contains(faceRect.topLeft)&&
          frameRect.contains(faceRect.bottomRight);

        if (!_insideFrame.value) {
          
        //setState(() {
        //});
          _frameColor = Colors.red;
          continue;
        }else{
          
        //setState(() {
        //});
          _frameColor = Colors.orange;
        }
        //setState(() {
        //});
        if (left > frameLeft &&
        right < frameLeft + frameWidth &&
        top > frameTop &&
        bottom < frameTop + frameHeight) {

          if (!_frontalDetected.value && eulerAngleY.abs() < _frontSensitive && _isDetecting.value ) {
            
            _isDetecting.value = false;
            _frontalDetected.value = true;
            getFaceDetection(face, image,'frontal');

          } else if (!_rightDetected.value && (eulerAngleY <= -_maxY && eulerAngleY >= -_minY) && _frontalDetected.value && _isDetecting.value) {

            _rightDetected.value = true; 
            _frameColor = Theme.of(context).colorScheme.primary;
            _isDetecting.value = false;
            getFaceDetection(face, image,'izquierdo');

          } else if (!_leftDetected.value &&
              (eulerAngleY >= _maxY && eulerAngleY <= _minY) &&
              _frontalDetected.value &&
              _rightDetected.value && _isDetecting.value) {
                
            _leftDetected.value=true;
            _isDetecting.value = false;
            getFaceDetection(face, image,'derecho');
            
          } else if (!_smileDetected.value &&
              (face.smilingProbability ?? 0.0) >= _smileProbability &&
              _frontalDetected.value &&
              _rightDetected.value &&
              _leftDetected.value && _isDetecting.value) {

            _smileDetected.value = true;
              _frameColor = Theme.of(context).colorScheme.primary;
              _isDetecting.value = false;
            getFaceDetection(face, image,'sonrisa');
            //await Future.delayed(const Duration(milliseconds: 800));
            //_startDetection();
          }
        }
      }
    } catch (e) {
      //print('Error al procesar la imagen: $e');
    }finally{
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    final idAfiliado = context.watch<UserProvider>().user!.afiliacion;
    final numBeneficiario = context.watch<UserProvider>().user!.numBeneficiario;
    final contra = context.watch<UserProvider>().user!.password;

    _capturas["id_afiliado"] = idAfiliado;
    _capturas["numBeneficiario"] = numBeneficiario;
    _capturas["password"] = contra;
    //final auth = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
            title: Text(
          'Registrar biometricos',
          style: TextStyle(fontSize: 0.07 * textScale),
        )),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              //final size = MediaQuery.of(context).size;
              final size = MediaQuery.of(context).size;

              return LayoutBuilder(
                builder: (context, constraints) {

                    _previewWidth = constraints.maxWidth;
                    _previewHeight = constraints.maxHeight;
                  return Stack(
                      children: [
                        /*OverflowBox(
                          maxHeight: size.height,
                          maxWidth: textScale * 1.5,
                          child: */OverflowBox(
                          maxHeight: size.height,
                          maxWidth: textScale * 1.5,
                          child:  CameraPreview(_controller),
                          
                        ),
                        
                        ValueListenableBuilder(
                          valueListenable: _showCounter,
                          builder: (context, value, child) {
                            return value?
                            CountdownScreen(
                                contador: 3,
                                onFinish:() async {
                                  //await Future.delayed(const Duration(milliseconds: 200));
                                  _startDetection();
                                }
                              ):const Text('');  
                          }
                        ),
                          
                          ValueListenableBuilder(
                            valueListenable: _currentStage,
                            builder: (context, value, child) {
                              return ValueListenableBuilder(
                                valueListenable:  _cameraReady,
                                builder: (context, value, child) {
                                  return value?FaceOverlay(assetPath: general.getGuideImagePath(_currentStage.value)):const Text('');  
                                }
                              );
                            }
                          ),
                    
                        /*if (_isSendingData)
                          OverflowBox(
                            maxHeight: size.height,
                            maxWidth: textScale * 1.5,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              height: textScale * 0.5,
                              width: textScale * 0.5,
                              child: CircularProgressIndicator(
                                color: Provider.of<ThemeProvider>(context).iconColor,
                              ),
                            ),
                          ),*/
                          ValueListenableBuilder(
                            valueListenable: _isDetecting,
                            builder: (context, value, child){
                              return value?ValueListenableBuilder(
                              valueListenable: _currentStage,
                              builder: (context, value, child) {
                              return ValueListenableBuilder(
                                  valueListenable: _cameraReady,
                                  builder: (context, value, child) {
                                    return value? Positioned(
                                      bottom: textScale*0.2,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          color: Colors.black54,
                                          child: Text(
                                            general.getInstructionText(_currentStage.value),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ):const Text('');
                                  }
                                );
                              }
                            ):const Text('');
                            }
                          ),
                          

                          ValueListenableBuilder(
                            valueListenable: _isDetecting,
                            builder: (context, value, child) {
                              return value?
                              ValueListenableBuilder(
                                valueListenable: _insideFrame,
                                builder: (context, value, child) {
                                  return Positioned(
                                    bottom: textScale*0.45,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
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
                                      ),
                                    ),
                                  );
                                }
                              ):const Text('');
                            }
                          ),
                        // Marco que se ajusta al tamaño de la cámara
                          ValueListenableBuilder(
                            valueListenable: _isDetecting,
                            builder: (context, value, child) {
                              return value? 
                              Positioned.fill(
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
                                            color: _frameColor,
                                            width: 3.0,
                                          ),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ):const Text('');
                            }
                          ),
                    
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                            ),
                            ValueListenableBuilder(
                              valueListenable: _rightDetected,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color: value ? Colors.green : Colors.red),
                                  title: Text('Perfil Izquierdo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            ),
                            ValueListenableBuilder(
                              valueListenable: _leftDetected,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color: value ? Colors.green : Colors.red),
                                  title: Text('Perfil Derecho',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 0.07 * textScale,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            ),
                            ValueListenableBuilder(
                              valueListenable: _smileDetected,
                              builder: (context, value, child) {
                                return ListTile(
                                  leading: Icon(
                                      size: 0.14 * textScale,
                                      value ? Icons.check : Icons.close,
                                      color: value ? Colors.green : Colors.red),
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
                    
                        /*Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Container()),
                            Text(
                              'Seleccione',
                              style: TextStyle(
                                  fontSize: 0.08 * textScale,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                              textAlign: TextAlign.center,
                            ),*/
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: textScale * 0.4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(50),
                                    /*border: Border.all(
                                            color:  Colors.blue,
                                            width: 2,
                                          ),*/
                                  ),
                                  child: Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.8,
                                        child: Radio<String>(
                                          value: 'Afiliado',
                                          groupValue: _tipoUsuario,
                                          onChanged: (_smileDetected.value ||
                                                  _frontalDetected.value ||
                                                  _rightDetected.value ||
                                                  _leftDetected.value)
                                              ? null
                                              : (String? value) {
                                                  setState(() {
                                                    _tipoUsuario = value;
                                                    _capturas['tipoUsuario'] =
                                                        _tipoUsuario!;
                                                    _capturas['numBeneficiario'] = '';
                                                  });
                                                  context
                                                      .read<UserProvider>()
                                                      .clearnumBeneficiario();
                                                },
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Afiliado',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).colorScheme.primary,
                                            fontSize: 0.08 * textScale,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Container(
                                    width: textScale * 0.55,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      borderRadius: BorderRadius.circular(50),
                                      /*border: Border.all(
                                          color:  Colors.blue,
                                          width: 2,
                                        ),*/
                                    ),
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.8,
                                          child: Radio<String>(
                                            value: 'Beneficiario',
                                            groupValue: numBeneficiario == null
                                                ? null
                                                : 'Beneficiario',
                                            onChanged: (_smileDetected.value ||
                                                    _frontalDetected.value ||
                                                    _rightDetected.value ||
                                                    _leftDetected.value)
                                                ? null
                                                : (String? value) async {
                                                    mostrarDialogoBeneficiarios(
                                                        context, idAfiliado);
                                                    _tipoUsuario = null;
                                                  },
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Beneficiario',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 0.08 * textScale,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),*/
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 30,
                                ),*/
                            /*ElevatedButton(
                                  onPressed: _beginDetecting 
                                      ? null
                                      : _toggleCamera,
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(
                                          0, 50), // Tamaño mínimo (ancho y alto)
                                      maximumSize:
                                          Size(textScale, 50), // Tamaño máximo
                                      padding: const EdgeInsets.all(10)),
                                  child: Icon(
                                    Icons.cameraswitch_sharp,
                                    size: 0.08 * textScale,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),*/
                            /*ElevatedButton(
                              onPressed: _beginDetecting
                                  ? null
                                  : () {
                                      //print('Tipo usuario: $_tipoUsuario');
                                      //print('Beneficiario: $numBeneficiario');
                                      if ((_tipoUsuario == null ||
                                                  _tipoUsuario == '') &&
                                              ((numBeneficiario == null ||
                                                      numBeneficiario == '') &&
                                                  (_tipoUsuario == null ||
                                                      _tipoUsuario == ''))) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Debe seleccionar una opcion'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          } else {
                                      _cameraReady.value ? _startDetection() : null;
                                      //}
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                    100, 50), // Tamaño mínimo (ancho y alto)
                                maximumSize: Size(textScale,
                                    textScale), // Tamaño máximo// Tamaño máximo
                              ),
                              child: SizedBox(
                                width: textScale * 0.6,
                                child: Text(
                                  'Iniciar Detección',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 0.085 * textScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),*/
                            //],
                            //),
                            const SizedBox(
                              height: 15,
                            ),
                            /* SE COMENTAREA PARA QUE EL USUARIO AL FINALIZAR EL ESCANEO AUTOMATICAMENTE LE REDIRIGA A LA PANTALLA PRINCIPAL
                            ElevatedButton(
                              onPressed:
                                  _allPositionsDetected && !_isSendingData && !_saved
                                      ? () async => auth.isLoggedIn
                                          ? _sendDataToApi(_capturas)
                                          : validarLogin(context)
                                      : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(
                                    100, 50), // Tamaño mínimo (ancho y alto)
                                maximumSize:
                                    Size(textScale, textScale), // Tamaño máximo
                              ),
                              child: SizedBox(
                                width: textScale * 0.6,
                                child: Text('Guardar Datos',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 0.09 * textScale,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis)),
                              ),
                            ),
                            
                            const SizedBox(
                              height: 75,
                            ),
                          ],
                        ),*/
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
        ));
      }
    }
