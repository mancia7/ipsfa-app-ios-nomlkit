import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ipsfa/infrastucture/classes/general.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';
import 'package:ipsfa/presentation/providers/theme_provider.dart';
import 'package:ipsfa/presentation/providers/user_provider.dart';
import 'package:ipsfa/presentation/widgets/section_card.dart';
import 'package:ipsfa/presentation/widgets/snackbar_message.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class PrestamoScreen extends StatefulWidget {
  const PrestamoScreen({super.key});

  @override
  State<PrestamoScreen> createState() => _PrestamoScreenState();
}

class _PrestamoScreenState extends State<PrestamoScreen> {
  final _formKey = GlobalKey<FormState>();

  /// controllers
  //final nombreCtrl = TextEditingController();
  //final duiCtrl = TextEditingController();
  final TextEditingController montoCtrl = TextEditingController();
  final TextEditingController aniosAlta = TextEditingController();
  //final telefonoCtrl = TextEditingController();
  MaskTextInputFormatter duiFormater =MaskTextInputFormatter(mask: '########-#', filter: {"#": RegExp(r'[0-9]')});
  final TextEditingController ingresosCtrl = TextEditingController();

 final GeneralMethods general = GeneralMethods();
  String? tipoPoblacion;
  int? esAlta;
  String? tipoCredito;
  String? destinoPrestamo;
  String? anioSeleccionado;
  String? sexo;
  String? afiliacion;
  late Future<bool> estadoServicio;
  bool loading = false;

  /// dependencia destino → años
  /*final Map<String, List<String>> opcionesAnios = {
    "Vivienda": ["10", "15", "20", "25"],
    "Vehículo": ["3", "5", "7"],
    "Consumo": ["1", "2", "3"],
  };*/

  final List<String> tipoPoblacionList = [
     "Pensionado",
     "Personal de alta",
     "Otra poblacion"
     ];
  
  final List<String> tipoCreditoList = [
     "Personal",
     "Hipotecario",
     "Educativo",
     ];

  final List<String> tipoPrestamoList = [
     "Adquisicion",
     "Remodelacion",
     "Traslado de deuda hipotecaria",
     ];

  final List<String> sexoList = [
     "Masculino",
     "Femenino",
     ];

     @override
     initState()  {
       super.initState();
       User usuario = Provider.of<UserProvider>(context,listen: false).user!;
       afiliacion=usuario.afiliacion;
       if(usuario.estadoAfiliado=='01'){
         esAlta=1;
         tipoPoblacion='Personal de alta';
       }else{
         esAlta=0;
       }
      
      estadoServicio=  general.serviceCreditoMaintenance();
       
     }

  /// ---------- ENVIO A PHP ----------
  Future<void> enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await http.post(
        Uri.parse("https://ipsfa.gob.sv/servicios/1/insert_app.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
            "tipoPoblacion": tipoPoblacion, 
            "tipoCredito": tipoCredito,
            "destinoPrestamo": destinoPrestamo,
            "montoPrestamo": montoCtrl.text,
            "ingresosMensuales": ingresosCtrl.text,
            "tieneAlta": tipoPoblacion=='Personal de alta'?'Si':'No',
            "tiempoAlta": aniosAlta.text,
            "id_afiliado": afiliacion,
          })
      );

      final data = json.decode(response.body);

      if (data["status"] == "success") {
        showOverlaySnack(data["message"],'');
        Future.delayed(const Duration(seconds: 3), () {
            Navigator.pushNamedAndRemoveUntil(
              // ignore: use_build_context_synchronously
              context,
              '/paginaPrincipal',
              (Route<dynamic> route) => route.isFirst, // deja la ruta inicial (root)
            );
            //}
          });
      } else {
        showOverlaySnack(data["message"],'error');
      }
    }on http.ClientException {
        showOverlaySnack('Error de conexion. Favor revisar su conexion a internet','error');
        //general.showSnackBar(context, 'Error de conexion. Favor revisar su conexion a internet',color: 'error');
      } on TimeoutException {
        showOverlaySnack('La solicitud está tardando demasiado. Intenta de nuevo.','error');
        //general.showSnackBar(context, 'La solicitud está tardando demasiado. Intenta de nuevo.',color: 'error');
      } catch (e) {
        await general.logError('insert_app.php error catch:', e.toString()) ;
          showOverlaySnack('Hubo un error inesperado. Favor volver a intentar: $e','error');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitud de Préstamo")),

      body: FutureBuilder(
        future: estadoServicio,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Text("Error al validar el dispositivo");
          }

          final  inMaintenance = snapshot.data!;
          return inMaintenance ? 
          Center(
            child: Column(
              children: [
                SizedBox(height: 0.1 * textScale),
                Icon(Icons.build_circle, size: 0.2 * textScale, color: Colors.orange.shade400,),
                SizedBox(height: 0.03 * textScale),
                Text(
                  "Servicio en mantenimiento",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 0.07 * textScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 0.02 * textScale),
                Text(
                  "Disculpe las molestias, estamos trabajando para mejorar nuestros servicios.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 0.05 * textScale,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          )
          :
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
          
                /// ---------- DATOS CREDITO ----------
                SectionCard(
                  title: "Datos del crédito",
                  children: [
                    DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 0.07 * textScale,color: Colors.black),
                      isExpanded: true,
                      decoration:  InputDecoration(
                        labelText: "Tipo de poblacion",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                        icon: Icon(Icons.people_outline_outlined,size: textScale*0.08,),
                        iconColor: Provider.of<ThemeProvider>(context,listen: false).iconColor,
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      initialValue: tipoPoblacion,
                      
                      items:tipoPoblacionList.where((e) =>
                                esAlta != 1
                                    ? e != 'Personal de alta' // muestra todo
                                    : e == 'Personal de alta')
                            .map((e) {
          
                              return  DropdownMenuItem(value: e, child: Text(e));
          
                            }).toList(),
                      /*items: opcionesAnios.keys.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),*/
                      onChanged: (v) {
                        setState(() {
                          tipoPoblacion = v;
                          aniosAlta.text = "";
                        });
                      },
                      validator: (v) => v == null ? "Seleccione tipo de poblacion" : null,
                    ),
          
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 0.07 * textScale,color: Colors.black),
                      isExpanded: true,
                      decoration:  InputDecoration(
                        labelText: "Tipo de credito",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                        icon: Icon(Icons.credit_score_rounded,size: textScale*0.08,),
                        iconColor: Provider.of<ThemeProvider>(context,listen: false).iconColor,
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      initialValue: tipoCredito,
                      items:tipoCreditoList.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      /*items: opcionesAnios.keys.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),*/
                      onChanged: (v) {
                        setState(() {
                          tipoCredito = v;
                          destinoPrestamo=null;
                        });
                      },
                      validator: (v) => v == null ? "Seleccione tipo de credito" : null,
                    ),
          
                    const SizedBox(height: 16),
                    
                    if(tipoCredito=="Hipotecario")
                    DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 0.07 * textScale,color: Colors.black,overflow: TextOverflow.ellipsis,),
                      isExpanded: true,
                      decoration:  InputDecoration(
                        label:Text( "Destino del préstamo", style: TextStyle(fontSize: textScale*0.06),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,),
                        //labelText: "Destino del prestamo",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                        icon: Icon(Icons.compare_arrows_outlined,size: textScale*0.08,),
                        iconColor: Provider.of<ThemeProvider>(context,listen: false).iconColor,
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      initialValue: destinoPrestamo,
                    
                      items:tipoPrestamoList.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      /*items: opcionesAnios.keys.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),*/
                      onChanged: (v) {
                        setState(() {
                          destinoPrestamo = v;
                        });
                      },
                      validator: (v) => v == null ? "Seleccione tipo de credito" : null,
                    ),
                    if(tipoCredito=="Hipotecario")
                    const SizedBox(height: 16),
          
                    TextFormField( 
                      style: TextStyle(fontSize: 0.07 * textScale),
                      controller: montoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        icon: Icon(Icons.attach_money,size: textScale*0.08,color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                        focusColor: Theme.of(context).colorScheme.primary,
                        labelText: "Monto del préstamo",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                      ),
                      validator: (v) => v!.isEmpty ? "Ingrese monto" : null,
                    ),
          
                    
          
                    /*
                    //Widgets dependientes se comentario porque no son necesarios en este formulario, pero se dejan para referencia de como hacerlos en caso de ser necesarios en el futuro
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Destino préstamo",
                        prefixIcon: Icon(Icons.home_work),
                      ),
                      initialValue: destinoSeleccionado,
                      items: opcionesAnios.keys.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          destinoSeleccionado = v;
                          anioSeleccionado = null;
                        });
                      },
                      validator: (v) => v == null ? "Seleccione destino" : null,
                    ),
          
                    const SizedBox(height: 16),
          
                    /// DEPENDIENTE
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Años",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      initialValue: anioSeleccionado,
                      items: destinoSeleccionado == null
                          ? []
                          : opcionesAnios[destinoSeleccionado]!
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                      onChanged: destinoSeleccionado == null
                          ? null
                          : (v) => setState(() => anioSeleccionado = v),
                      validator: (v) => v == null ? "Seleccione años" : null,
                    ),*/
                  ],
                ),
          
                const SizedBox(height: 16),
          
                /// ---------- DATOS PERSONALES ----------
                SectionCard(
                  title: "Datos personales",
                  children: [
                    /*TextFormField(
                      controller: nombreCtrl,
                      style: TextStyle(fontSize: 0.07 * textScale),
                      decoration: InputDecoration(
                        labelText: "Nombre completo",
                        icon: Icon(Icons.badge,size: textScale*0.08,color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                        focusColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                      ),
                    ),
          
                    const SizedBox(height: 16),
          
                    TextFormField(
                      inputFormatters: [duiFormater],
                      keyboardType:  TextInputType.number,
                      style: TextStyle(fontSize: 0.07 * textScale),
                      controller: duiCtrl,
                      decoration:  InputDecoration(
                        labelText: "DUI",
                        icon: Icon(Icons.credit_card,size: textScale*0.08,color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                        focusColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                      ),
                    ),
          
                    const SizedBox(height: 16),
          
                    TextFormField( 
                      maxLength: 2,
                      style: TextStyle(fontSize: 0.07 * textScale),
                      controller: edadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_month_sharp,size: textScale*0.08,color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                        focusColor: Theme.of(context).colorScheme.primary,
                        labelText: "Edad",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
          
                      ),
                      validator: (v) => v!.isEmpty ? "Ingrese monto" : null,
                    ),
          
          
                    
                    DropdownButtonFormField<String>(
                      style: TextStyle(fontSize: 0.07 * textScale,color: Colors.black),
                      isExpanded: true,
                      decoration:  InputDecoration(
                        labelText: "Sexo",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                        icon: Icon(Icons.people_outline_outlined,size: textScale*0.08,),
                        iconColor: Provider.of<ThemeProvider>(context,listen: false).iconColor,
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      initialValue: sexo,
          
                      items:sexoList.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      /*items: opcionesAnios.keys.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),*/
                      onChanged: (v) {
                        setState(() {
                          sexo = v;
                        });
                      },
                      validator: (v) => v == null ? "Seleccione sexo" : null,
                    ),
          
                    const SizedBox(height: 16),
          */
                    TextFormField( 
                      style: TextStyle(fontSize: 0.07 * textScale),
                      controller: ingresosCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        icon: Icon(Icons.attach_money,size: textScale*0.08,color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                        focusColor: Theme.of(context).colorScheme.primary,
                        labelText: "Ingresos mensuales",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
                      ),
                      validator: (v) => v!.isEmpty ? "Ingrese monto" : null,
                    ),
          
          
                    if(tipoPoblacion=="Personal de alta")
                    const SizedBox(height: 16),
                    if(tipoPoblacion=="Personal de alta")
                    TextFormField( 
                      maxLength: 2,
                      style: TextStyle(fontSize: 0.07 * textScale),
                      controller: aniosAlta,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_month_sharp,size: textScale*0.08,color: Provider.of<ThemeProvider>(context,listen: false).iconColor,),
                        focusColor: Theme.of(context).colorScheme.primary,
                        labelText: "Años de alta",
                        labelStyle: TextStyle(fontSize: textScale*0.06),
          
                      ),
                      validator: (v) => v!.isEmpty ? "Ingrese años de alta" : null,
                    ),
                  ],
                ),
          
                
          
                const SizedBox(height: 30),
          
                ElevatedButton(
                  onPressed: loading ? null : enviarSolicitud,
                  style: ElevatedButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 30)
                  ),
                  child: loading
                      ? 
                        Padding(
                          padding: const EdgeInsetsGeometry.all(5),
                          child: SizedBox(
                            height: textScale * 0.122,
                            width: textScale * 0.122,
                            child: CircularProgressIndicator(
                              color:Provider.of<ThemeProvider>(context,listen:false).iconColor,
                          )),
                        )
                      :  Text("Enviar solicitud",style:  TextStyle(fontSize: textScale*0.1,color: Colors.white),),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
  /// widget reusable de secciones
}
