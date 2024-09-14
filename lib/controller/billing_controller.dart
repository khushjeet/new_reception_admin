import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:receptions_app/controller/patientcontroller.dart';

class BillingController extends GetxController {
  // Observables for storing form data
  final PatientController patientController = Get.put(PatientController());
  var patientName = ''.obs;
  var services = ''.obs;
  var amount = ''.obs;

  // Function to submit billing data to the PHP backend
  Future<void> submitBilling() async {
    const url = 'http://192.168.73.30/reciptions/insert_billing.php';

    final data = {
      'patient_name': patientName.value,
      'services': services.value,
      'amount': amount.value,
      'doctor_id': patientController.doctorId.value
    };

    // Sending POST request to the server
    final response = await http.post(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        // If successful, reset fields and show success message
        generateInvoice();
        Get.snackbar(
          'Success',
          'Billing data submitted successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Show error if submission failed
        Get.snackbar(
          'Error',
          'Failed to submit billing data.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // Show error if network request failed
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Reset fields after successful submission
  void generateInvoice() {
    patientName.value = '';
    services.value = '';
    amount.value = '';
  }
}
