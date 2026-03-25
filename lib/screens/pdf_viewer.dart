// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}
class _PdfViewerPageState extends State<PdfViewerPage> {
  Uint8List? pdfBytes;
  bool loading = true;
final PdfViewerController _pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(
        Uri.parse(widget.pdfUrl),
        headers: const {'Accept': 'application/pdf'},
      );
      if (mounted) {
          pdfBytes = response.bodyBytes;
      }
      if(pdfBytes!.length<200){
        showOverlaySnack('No posee constancia de ${widget.pdfUrl.contains('cotizaciones') ? 'COTIZACIONES' : widget.pdfUrl.contains('timeMesesApi') ? 'ULTIMOS 6 MESES' : widget.pdfUrl.contains('timeService') ? 'TIEMPO DE SERVICIO' : widget.pdfUrl.contains('rentaApi') ? 'RENTA' :widget.pdfUrl.contains('pensionApi')? 'PENSION' : widget.pdfUrl.contains('prestamoApi')?'PRESTAMO':'CARNE'}','error');
          loading = true;
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
      }else{
          loading = false;
      }
      setState(() {
        
      });
    } catch (e) {
      loading = false;
    }
  }

  Future<void> guardarEnDescargas() async {
    final bytes = await _pdfController.saveDocument();

    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tipoConstancia=widget.pdfUrl.contains('cotizaciones') ? 'Cotizaciones' : widget.pdfUrl.contains('timeMesesApi') ? 'Ultimos 6 Meses' : widget.pdfUrl.contains('timeService') ? 'Tiempo de Servicio' : widget.pdfUrl.contains('rentaApi') ? 'Renta' :widget.pdfUrl.contains('pensionApi')? 'pension' : widget.pdfUrl.contains('prestamoApi') ?'Prestamo':widget.pdfUrl.contains('anioApi')?'1 año':'Carne digital';
    final file = File(
      '${directory!.path}/${tipoConstancia}_$timestamp.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
      showOverlaySnack('PDF guardado en descargas: ${'$tipoConstancia"_"$timestamp.pdf'}','');
  }


  @override
  void dispose() {
    // NO cerrar documento manualmente
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfUrl.contains('cotizaciones') ? 'Cotizaciones' : widget.pdfUrl.contains('timeMesesApi') ? 'Ultimos 6 Meses' : widget.pdfUrl.contains('timeService') ? 'Tiempo de Servicio' : widget.pdfUrl.contains('rentaApi') ? 'Renta' :widget.pdfUrl.contains('pensionApi')? 'pension' : widget.pdfUrl.contains('prestamoApi') ?'Prestamo':widget.pdfUrl.contains('anioApi')?'1 año':'Carne digital'),
        actions: [
    IconButton(
      icon: const Icon(Icons.download,size: 40,),
      onPressed: !loading?guardarEnDescargas:null,
    ),
  ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SfPdfViewer.memory(
              pdfBytes!,
              enableDoubleTapZooming: true,
              key: ValueKey(pdfBytes!.length),
              controller: _pdfController,
            ),
    );
  }
}

