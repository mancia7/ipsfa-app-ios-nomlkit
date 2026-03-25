class Beneficiarios {
  final String numBeneficiario;

  Beneficiarios({ required this.numBeneficiario});

  factory Beneficiarios.fromJson(Map<String, dynamic> json) {
    return Beneficiarios(
      numBeneficiario: json['NUM_BENEFICIARIO'],
    );
  }
}