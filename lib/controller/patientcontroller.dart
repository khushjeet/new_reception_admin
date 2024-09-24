import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:receptions_app/model/doctor_login_models.dart';

import 'package:receptions_app/model/patient_model.dart';
import 'package:logger/logger.dart'; // Add the logger package to your pubspec.yaml
import 'package:http/http.dart' as http;

import 'package:open_file/open_file.dart';

class PatientController extends GetxController {
  var patientName = ''.obs;
  var age = ''.obs;
  var gender = ''.obs;
  var contact = ''.obs;
  var address = ''.obs;
  var appointmentDate = ''.obs;
  var doctorName = ''.obs;
  var time = ''.obs;
  var email = ''.obs;
  var clnicName = ''.obs;
  var doctorId = ''.obs;
  // Logger instance
  final Logger logger = Logger();

  // Function to send data to the REST API for patient registration
  Future<void> registerPatient() async {
    if (patientName.isEmpty ||
        age.isEmpty ||
        gender.isEmpty ||
        contact.isEmpty ||
        time.isEmpty ||
        address.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    const url =
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/patient_registration.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'name': patientName.value,
          'age': age.value,
          'gender': gender.value,
          'contact': contact.value,
          'address': address.value,
          'doctor': doctorName.value,
          'appointment_date': appointmentDate.value,
          'time': time.value,
          'email': email.value,
          'doctor_id': doctorId.value
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          Get.snackbar('Success', 'Patient registered successfully',
              backgroundColor: Colors.green);
          clearPatientForm();
        } else {
          Get.snackbar('Error', 'Failed to register patient');
        }
      } else {
        Get.snackbar('Error', 'Failed to register patient');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to register patient: $e');
    }
  }

  // Function to clear patient form fields
  void clearPatientForm() {
    patientName.value = '';
    age.value = '';
    gender.value = '';
    contact.value = '';
    address.value = '';
    appointmentDate.value = '';
    time.value = '';
    email.value = '';
  }

  Future<void> generatePdfInvoice(Patient patient, Doctor doctor) async {
    final pdf = pw.Document();

    try {
      // Load the custom fonts
      final fontRegularData =
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final fontBoldData =
          await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

      final fontRegular = pw.Font.ttf(fontRegularData);
      final fontBold = pw.Font.ttf(fontBoldData);

      // Add a page with the patient and doctor details
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Doctor's information
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      doctor.clinicName,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        font: fontBold,
                      ),
                    ),
                    pw.Text(
                      "Doctor: ${doctor.doctorsName}",
                      style: pw.TextStyle(
                        fontSize: 18,
                        font: fontRegular,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Specialization: ${doctor.doctorSpecelization}",
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  "Qualification: ${doctor.doctorQualification}",
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  "Experience: ${doctor.doctorPreviousExperience}",
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  "Address: ${doctor.doctorAddress}",
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  "Phone: ${doctor.doctorPhone}",
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Divider(thickness: 2.0),
                pw.SizedBox(height: 20),

                // Patient's information
                pw.Text(
                  'Patient Name: ${patient.name}',
                  style: pw.TextStyle(font: fontBold),
                ),
                pw.Text(
                  'Contact: ${patient.contact}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Age: ${patient.age}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Gender: ${patient.gender}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Address: ${patient.address}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Doctor: ${patient.doctor}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Appointment Date: ${patient.appointmentDate}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Appointment Time: ${patient.time}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Registration Time: ${patient.registrationTime}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Email: ${patient.email ?? 'Not Available'}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Next Visiting Date: ${patient.nextVisitingDate ?? 'Not Available'}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Weight: ${patient.weight ?? 'Not Available'}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Blood Pressure: ${patient.bloodPressure ?? 'Not Available'}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Pulse: ${patient.pulse ?? 'Not Available'}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Valid Up To: ${patient.validUpTo}',
                  style: pw.TextStyle(font: fontRegular),
                ),
                pw.Text(
                  'Complaint: ${patient.complainent ?? 'Not Available'}',
                  style: pw.TextStyle(font: fontRegular),
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF to a file
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/patient_invoice_${patient.id}.pdf");
      await file.writeAsBytes(await pdf.save());

      debugPrint('PDF generated and saved to: ${file.path}');

      // Open the PDF file
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      // Handle the error appropriately in your UI
    }
  }
}
