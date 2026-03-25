import 'package:flutter/material.dart';

class BulletList extends StatelessWidget {
  final List<String> items = [
    'Buscar un lugar bien iluminado.',
    'No usar anteojos,gorras,audifonos ni el cabello sobre el rostro para que pueda verse bien el rostro.',
    'Coloque el celular a la altura de su rostro. Tendra un recuadro que le indicara la posicion',
    'Al presionar TOMAR FOTOGRAFIA inciara una cuenta regresiva, luego comenzara la deteccion del rostro.',
    'Favor colocar su rostro en el recuadro para que sea analizado correctamente.',
    'Por cada perfil escaneado, la aplicacion le guiara para el siguiente lado.',
    'Para escanear correctamente el lado IZQUIERDO y DERECHO, girar lento la cabeza al terminar la cuenta regresiva.',
    'Por cada lado , favor no moverse hasta escuchar la voz de confirmacion.',
  ];
  final List<String> imageNumbers = [
    'lib/assets/number_1.png',
    'lib/assets/number_2.png',
    'lib/assets/number_3.png',
    'lib/assets/number_4.png',
    'lib/assets/number_5.png',
    'lib/assets/number_6.png',
    'lib/assets/number_7.png',
    'lib/assets/number_8.png',
  ];

  BulletList({super.key});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //const Icon(Icons.check_circle, color: Colors.green),
                    Image.asset(
                      imageNumbers[items.indexOf(item)],
                      width: 70,
                      height: 90,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            'Paso ${items.indexOf(item)+1}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 0.06 * textScale),
                          ),
                          Text(
                            item,
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 0.05 * textScale),
                          ),
                        ])),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
