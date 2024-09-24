class Doctor {
  int doctorId;
  String clinicName;
  String doctorsName;
  String doctorSpecelization;
  String doctorQualification;
  String doctorPreviousExperience;
  String doctorAddress;
  int doctorPhone;
  String consultaionTime;
  String username;
  String password;
  String clinicPhotos;

  Doctor({
    required this.doctorId,
    required this.clinicName,
    required this.doctorsName,
    required this.doctorSpecelization,
    required this.doctorQualification,
    required this.doctorPreviousExperience,
    required this.doctorAddress,
    required this.doctorPhone,
    required this.consultaionTime,
    required this.username,
    required this.password,
    required this.clinicPhotos,
  });

  // Factory method to create Doctor object from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: int.tryParse(json['doctor_id']?.toString() ?? '') ?? 0,
      clinicName: json['clinic_name'] ?? '',
      doctorsName: json['doctors_name'] ?? '',
      doctorSpecelization: json['doctor_specelization'] ?? '',
      doctorQualification: json['doctor_qualification'] ?? '',
      doctorPreviousExperience: json['doctor_previous_experience'] ?? '',
      doctorAddress: json['doctor_address'] ?? '',
      doctorPhone: int.tryParse(json['doctor_phone']?.toString() ?? '') ?? 0,
      consultaionTime: json['consultaion_time'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      clinicPhotos: json['clinic_photos'] ?? '',
    );
  }

  // Method to convert Doctor object to JSON
  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId.toString(), // Convert int to string for JSON
      'clinic_name': clinicName,
      'doctors_name': doctorsName,
      'doctor_specelization': doctorSpecelization,
      'doctor_qualification': doctorQualification,
      'doctor_previous_experience': doctorPreviousExperience,
      'doctor_address': doctorAddress,
      'doctor_phone': doctorPhone.toString(), // Convert int to string for JSON
      'consultaion_time': consultaionTime,
      'username': username,
      'password': password,
      'clinic_photos': clinicPhotos,
    };
  }
}
