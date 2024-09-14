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

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctor_id'] ?? 0, // Provide a default value if null
      clinicName: json['clinic_name'] ?? '',
      doctorsName: json['doctors_name'] ?? '',
      doctorSpecelization: json['doctor_specelization'] ?? '',
      doctorQualification: json['doctor_qualification'] ?? '',
      doctorPreviousExperience: json['doctor_previous_experience'] ?? '',
      doctorAddress: json['doctor_address'] ?? '',
      doctorPhone:
          json['doctor_phone'] ?? 0, // Provide a default value for integer
      consultaionTime: json['consultaion_time'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      clinicPhotos: json['clinic_photos'] ?? '',
    );
  }
}
