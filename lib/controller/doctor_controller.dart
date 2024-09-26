import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/model/doctor_login_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorController extends GetxController {
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
        'http://test.ankusamlogistics.com/doc_reception_api/doctor/get_doctor_detail_th_username.php');

    try {
      isLoading.value = true;

      final response = await http.post(url, body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final doctorData = jsonResponse['data'];
          final doctorDetails = Doctor.fromJson(doctorData);

          doctor.value = doctorDetails;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('doctor', json.encode(doctorDetails.toJson()));

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
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('doctor');

    doctor.value = Doctor(
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
    );

    Get.offAllNamed('/login'); // Navigate to the login page
  }
}
