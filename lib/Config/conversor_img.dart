import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class Conversor{

  Uint8List convertYUV420ToImage(CameraImage image) {
  try {
    final int width = image.width;
    final int height = image.height;

    // Extraer planos YUV
    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final Uint8List yBuffer = yPlane.bytes;
    final Uint8List uBuffer = uPlane.bytes;
    final Uint8List vBuffer = vPlane.bytes;

    // Crear imagen vacía para llenarla con datos
    final img.Image rgbImage = img.Image(width: image.width,  height: image.height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;

        // Coordenadas UV ajustadas según el formato YUV420
        final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        final int yValue = yBuffer[yIndex];
        final int uValue = uBuffer[uvIndex];
        final int vValue = vBuffer[uvIndex];

        // Convertir YUV a RGB
        final int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).clamp(0, 255).toInt();
        final int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        rgbImage.setPixel(x, y, img.ColorInt8.rgb(r, g, b));
      }
    }

    // Convertir a formato JPEG
    return Uint8List.fromList(img.encodeJpg(rgbImage));
  } catch (e) {
    //print('Error al convertir imagen: $e');
    return Uint8List(0); // Devolver una lista vacía si falla
  }
}
}