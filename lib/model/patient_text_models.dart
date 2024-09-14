class PatientTest {
  final String ptName;
  final String ptContactNumber;
  final int ptId;
  String ptWt;
  String ptPulse;
  String ptBp;
  String ptNextVisitingDate;

  PatientTest({
    required this.ptName,
    required this.ptContactNumber,
    required this.ptId,
    this.ptWt = '',
    this.ptPulse = '',
    this.ptBp = '',
    this.ptNextVisitingDate = '',
  });

  factory PatientTest.fromJson(Map<String, dynamic> json) {
    return PatientTest(
      ptName: json['pt_name'],
      ptContactNumber: json['pt_contact_number'],
      ptId: json['pt_id'],
      ptWt: json['pt_wt'] ?? '',
      ptPulse: json['pt_pulse'] ?? '',
      ptBp: json['pt_bp'] ?? '',
      ptNextVisitingDate: json['pt_next_visiting_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pt_name': ptName,
      'pt_contact_number': ptContactNumber,
      'pt_id': ptId,
      'pt_wt': ptWt,
      'pt_pulse': ptPulse,
      'pt_bp': ptBp,
      'pt_next_visiting_date': ptNextVisitingDate,
    };
  }
}
