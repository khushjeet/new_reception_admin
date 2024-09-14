// ignore_for_file: unused_local_variable

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';

class InsertPatientController extends GetxController {
  // Function to insert data into the database using HTTP POST request

  final patientController = Get.put(PatientController());

  Future<void> insertPatient({
    required String ptName,
    required String ptNextVisitingDate,
    required String ptAddress,
    required int ptAge,
    required String ptGendor,
    required String contactNumber,
    required String email,
  }) async {
    try {
      var url = Uri.parse(
          'http://192.168.73.30/reciptions/patient_detail_api/insert_pasentient_registration.php');

      // Ensure all values in the body are strings
      var response = await http.post(url, body: {
        'pt_name': ptName,
        'pt_next_visiting_date': ptNextVisitingDate,
        'pt_address': ptAddress,
        'pt_age': ptAge.toString(), // Convert ptAge to string
        'pt_gendor': ptGendor,
        'doctor_id': patientController.doctorId
            .toString(), // Ensure doctorId is a string
        'pt_contact_number': contactNumber,
        'pt_email': email,
      });

      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        // Handle the response if necessary
        Get.snackbar('Success', 'Patient registered successfully!');
      } else {
        Get.snackbar('Error', 'Failed to register patient');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
