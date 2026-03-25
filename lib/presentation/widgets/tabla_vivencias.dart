import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class TablaVivencias extends StatefulWidget {
  final String afiliacion;
  const TablaVivencias({super.key,required this.afiliacion});

  @override
  State<TablaVivencias> createState() => _TablaVivenciasState();
}

class _TablaVivenciasState extends State<TablaVivencias> {
  GeneralMethods general = GeneralMethods();

  Future<List<Map<String, dynamic>>> obtenerVivencias(BuildContext context, String afiliacion) async {
    return general.getRegistrosVivencias(context,afiliacion);
  }
 
  @override
  Widget build(BuildContext context) {
    
    User usuario = context.watch<UserProvider>().user!;
    final textScale = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Map<String, dynamic>>> (
        future: obtenerVivencias(context,widget.afiliacion),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final vivencias = snapshot.data!;
          return  SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable( 
                showBottomBorder: true,  
                headingRowColor: WidgetStateProperty.all(Provider.of<ThemeProvider>(context,listen: false).iconColor),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 20
                ),/*
                border: TableBorder(
                  top: const BorderSide(color: Colors.grey, width: 1),
                  bottom: const BorderSide(color: Colors.grey, width: 1),
                  left: const BorderSide(color: Colors.grey, width: 1),
                  right: const BorderSide(color: Colors.grey, width: 1),
                  horizontalInside: const BorderSide(color: Colors.grey, width: 1),
                  verticalInside: BorderSide.none,
                ),*/
                  columns: [
                    usuario.numBeneficiario!='null'?
                    const DataColumn(label: Text('Numero Beneficiario')
                              )
                    :
                    DataColumn(label: Text('Afiliacion',
                                            style: TextStyle(fontSize: 0.05 * textScale),
                                            )),
                    
                    DataColumn(label: Text('Fecha realizo Vivencia',
                                            style: TextStyle(fontSize: 0.05 * textScale),)
                              ),
                    DataColumn(label: Text('Fecha proxima Vivencia',
                                            style: TextStyle(fontSize: 0.05 * textScale),)
                              )
                              
                
                  ],
                  rows: vivencias.map((m) {
                    return DataRow(
                      cells: [
                        usuario.numBeneficiario=='null'?
                        DataCell(Text(m['afiliacion'],
                                            style: TextStyle(fontSize: 0.05 * textScale), ))
                                            : 
                                            DataCell(Text(m['num_beneficiario'] ?? '',
                                            style: TextStyle(fontSize: 0.05 * textScale),)),
                        DataCell(Text(m['fec_adicion'],
                                            style: TextStyle(fontSize: 0.05 * textScale), )),
                        DataCell(Text(m['fecha_vivencia'],
                                            style: TextStyle(fontSize: 0.05 * textScale), )),
                       
                      ],
                    );
                  }).toList(),
            ),
          );
        },
      );
  }
}
