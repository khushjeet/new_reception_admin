class Billing {
  final int id;
  final String patientName;
  final String services;
  final String amount;

  Billing({
    required this.id,
    required this.patientName,
    required this.services,
    required this.amount,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      id: json['id'],
      patientName: json['patient_name'],
      services: json['services'],
      amount: json['amount'],
    );
  }
}
