import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/model/doctor_login_models.dart';

class DoctorController extends GetxController {
  // Observable to hold doctor's data
  var doctor = Doctor(
    doctorId: 0,
    clinicName: '',
    doctorsName: '',
    doctorSpecelization: '',
    doctorQualification: '',
    doctorPreviousExperience: '',
    doctorAddress: '',
    doctorPhone: 0,
    consultaionTime: '',
    username: '',
    password: '',
    clinicPhotos: '',
  ).obs;

  var isLoading = false.obs;

  Future<Doctor?> loginAndGetDoctorDetails(
      String username, String password) async {
    final url = Uri.parse(
        'http://192.168.73.30/reciptions/doctor/get_doctor_detail_th_username.php');

    try {
      isLoading.value = true; // Set loading to true

      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final doctorData = jsonResponse['data'];
          final doctorDetails = Doctor.fromJson(doctorData);

          // Update the observable with the new data
          doctor.value = doctorDetails;

          return doctorDetails;
        } else {
          Get.snackbar("Error", jsonResponse['message'] ?? 'Login failed');
          return null;
        }
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return null;
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }
}
