class User {
  final String dui;
  final String afiliacion;
  final String username;
  final String password;
  final String email;
  final String numBeneficiario;
  final String validoVivencia;
  final String validoConstancias;
  String disponibleFotos;
  String disponibleDoc;
  String realizoVivencia;
  String aprobadoFotos;
  String esReafiliado;
  String estadoAfiliado;
  String creditoService;
  String carneService;


  User({
      required this.dui,
      required this.afiliacion,
      required this.username,
      required this.password,
      required this.email,
      required this.numBeneficiario,
      required this.validoVivencia,
      required this.validoConstancias,
      required this.disponibleFotos,
      required this.disponibleDoc,
      required this.realizoVivencia,
      required this.aprobadoFotos,
      required this.esReafiliado,
      required this.estadoAfiliado,
      required this.creditoService,
      required this.carneService
      });
}
