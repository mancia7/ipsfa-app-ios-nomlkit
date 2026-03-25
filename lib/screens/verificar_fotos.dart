// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';
class FaceReviewScreen extends StatefulWidget {
  final Map<String, dynamic> loginData;
  const FaceReviewScreen({super.key, required this.loginData});

  @override
  State<FaceReviewScreen> createState() => _FaceReviewScreenState();
}

class _FaceReviewScreenState extends State<FaceReviewScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> currentIndex = ValueNotifier(0);
  final ValueNotifier<bool>  _isSendingData =  ValueNotifier(false);
  final ValueNotifier<int> counter = ValueNotifier(0);
  final GeneralMethods general = GeneralMethods();
  List<String> _indices = [];
  @override
  void initState() {
    super.initState();
    _indices=widget.loginData['faces'].keys.toList();
  }
  Future<void> _sendDataToApi() async {
    if (!mounted) return;
      _isSendingData.value = true;
    await general.sendDataToApi(context,widget.loginData);
      _isSendingData.value = false;
      /*} else {
        general.showSnackBar(context, 'Favor seleccionnar una opcion',
            color: 'Error');
      }*/
    //}
  }

  void repetirCaptura(String tipo) {
    final faces = widget.loginData['faces'] as Map<String, Uint8List>;
    
    faces.remove(tipo); // elimina foto
    print('tipo ver foto: $tipo');   
    Navigator.pop(context, tipo); 
  }

  @override
  Widget build(BuildContext context) {
    final total =_indices.length;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Navigator.pop(context, "retry");
          }
        },
      child: Scaffold(
        appBar: AppBar(
              title: Text(
                'Validar fotografias',
                style: TextStyle(fontSize: 0.07 * screenWidth),
              ),
            ),
        body: LayoutBuilder(
              builder: (context, constraints) {
                    final previewWidth = constraints.maxWidth;
                    final previewHeight = constraints.maxHeight;
              return Column(
                    children: [
                        
                      ValueListenableBuilder(
                        valueListenable: currentIndex,
                        builder: (_, value, __) {
                          return Text(
                            style: TextStyle(
                                            fontSize: 0.080 * screenWidth, // 🔹 Tamaño del texto
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        textAlign: TextAlign.justify,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                            "${_indices[currentIndex.value].toUpperCase()} "
                            );
                        },
                      ),
                        
                        
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _indices.length,
                          onPageChanged: (i) => currentIndex.value = i,
                          itemBuilder: (context, index) {
                            final String perfil = _indices[index];
                            final Uint8List imageBytes =
                                widget.loginData['faces'][perfil];

                            return Stack(
                              children: [
                                Center(
                                  child: Image.memory(
                                    imageBytes,
                                    width: previewWidth,
                                    height: previewHeight,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth*1.2,
                                  height: screenWidth*.15,
                                  left: screenWidth*.09,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        
                                        repetirCaptura(_indices[currentIndex.value]);
                                      },
                                      child: Text(
                                        'Volver a Capturar',
                                        style: TextStyle(
                                            color: Provider.of<ThemeProvider>(context).iconColor,
                                            fontSize: 0.09 * screenWidth),
                                      ),
                                    ),
                                ),
                              ]
                            );
                          },
                        ),
                      ),
                        
                      const SizedBox(height: 10),
                        
                      ValueListenableBuilder(
                        valueListenable: currentIndex,
                        builder: (_, value, __) {
                          return Text(
                            style: TextStyle(
                                            fontSize: 0.080 * screenWidth, // 🔹 Tamaño del texto
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        textAlign: TextAlign.justify,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                            "Foto ${value + 1} de $total"
                            );
                        },
                      ),
                        
                      const SizedBox(height: 20),
                        
                      // Botón, solo se reconstruye él
                      ValueListenableBuilder<int>(
                        valueListenable: currentIndex,
                        builder: (_, value, __) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _isSendingData,
                            builder: (_, isSending, __) {
                              return SizedBox(
                                width: screenWidth * 0.8,
                                height: screenWidth * 0.18,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: value==3 
                                  ? () async {
                                      await _sendDataToApi();
                                    }
                                  : null,
                              child:  _isSendingData.value ?
                                                  Padding(
                                                    padding: const EdgeInsetsGeometry.all(5),
                                                    child: SizedBox(
                                                      height: screenWidth * 0.1,
                                                      width: screenWidth * 0.1,
                                                      child: CircularProgressIndicator(
                                                        color:Provider.of<ThemeProvider>(context,listen:false).iconColor,
                                                    )),
                                                  )
                                                  :
                                            Text(
                                            style: TextStyle(
                                                    fontSize: 0.1 * screenWidth, // 🔹 Tamaño del texto
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                overflow: TextOverflow.ellipsis,
                                          "Enviar fotos"
                                          ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
            ),
        ),
    );
  }
}
