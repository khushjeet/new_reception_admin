class Patient {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String address;
  final String doctor;
  final String appointmentDate;
  final String time;
  final String registrationTime;
  final String? email;
  final String? nextVisitingDate;
  final String? weight;
  final String? bloodPressure;
  final String? pulse;
  final String validUpTo;
  final String? complainent; // New field for complaints

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.address,
    required this.doctor,
    required this.appointmentDate,
    required this.time,
    required this.registrationTime,
    this.email,
    this.nextVisitingDate,
    this.weight,
    this.bloodPressure,
    this.pulse,
    required this.validUpTo,
    this.complainent,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['pt_id'],
      name: json['pt_name'],
      age: int.parse(json['pt_age']),
      gender: json['pt_gendor'],
      contact: json['pt_contact_number'],
      address: json['pt_address'],
      doctor: 'Doctor Name', // Placeholder
      appointmentDate: 'Appointment Date', // Placeholder
      time: 'Time', // Placeholder
      registrationTime: json['pt_registration'],
      email: json['pt_email'],
      nextVisitingDate: json['pt_next_visiting_date'],
      weight: json['pt_wt'],
      bloodPressure: json['pt_bp'],
      pulse: json['pt_pluse'],
      validUpTo: json['valid_up_to'],
      complainent: json['pt_complainent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pt_id': id,
      'pt_name': name,
      'pt_age': age.toString(),
      'pt_gendor': gender,
      'pt_contact_number': contact,
      'pt_address': address,
      'pt_registration': registrationTime,
      'pt_email': email,
      'pt_next_visiting_date': nextVisitingDate,
      'pt_wt': weight,
      'pt_bp': bloodPressure,
      'pt_pluse': pulse,
      'valid_up_to': validUpTo,
      'pt_complainent': complainent,
    };
  }
}
