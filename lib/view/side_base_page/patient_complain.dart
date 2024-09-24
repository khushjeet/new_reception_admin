import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/doctor_controller.dart';

import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/controller/suggestion_controller.dart';

import 'package:receptions_app/model/doctor_login_models.dart';
import 'package:receptions_app/model/patient_model.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PatientComplainPage extends StatefulWidget {
  static const String routeName = "/PatientComplainPage";

  PatientComplainPage({super.key});

  final patientController = Get.put(PatientController());

  @override
  // ignore: library_private_types_in_public_api
  _PatientComplainPageState createState() => _PatientComplainPageState();
}

class _PatientComplainPageState extends State<PatientComplainPage> {
  List<Patient> patients = [];
  Doctor? doctor;
  final _complainController = TextEditingController();
  final bool _isLoading = false;
  final doctorController = Get.put(DoctorController());

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    fetchDoctorData();
  }

  Future<void> fetchPatientData() async {
    final url = Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/get_today_patient_data.php?doctor_id=${widget.patientController.doctorId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        if (mounted) {
          setState(() {
            patients = (jsonResponse['data'] as List)
                .map((data) => Patient.fromJson(data))
                .toList();
          });
        }
      }
    }
  }

  Future<void> fetchDoctorData() async {
    final url = Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/doctor/get_doctor_detail_th_doctor_id.php?doctor_id=${widget.patientController.doctorId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final doctorData = jsonResponse['data'];
          if (doctorData is Map<String, dynamic>) {
            if (mounted) {
              setState(() {
                doctor = Doctor.fromJson(doctorData);
              });
            }
          }
        } else {
          Get.snackbar('Error',
              jsonResponse['message'] ?? 'Failed to fetch doctor data.');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to parse doctor data: $e');
      }
    } else {
      Get.snackbar(
          'Error', 'Failed to fetch doctor data: ${response.reasonPhrase}');
    }
  }

  Future<void> generatePdfInvoice(Patient patient) async {
    if (doctor == null) {
      Get.snackbar('Error', 'Doctor data is not available.');
      return;
    }

    final pdf = pw.Document();

    try {
      final fontRegularData =
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final fontBoldData =
          await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      final fontRegular = pw.Font.ttf(fontRegularData);
      final fontBold = pw.Font.ttf(fontBoldData);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(8),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // Clinic and Doctor Details
                pw.Center(
                  child: pw.Text(
                    doctor!.clinicName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: fontBold,
                    ),
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          children: [
                            pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(' ${doctor!.doctorsName}',
                                      style: pw.TextStyle(
                                          font: fontRegular, fontSize: 14)),
                                  pw.Text(' ${doctor!.doctorSpecelization}',
                                      style: pw.TextStyle(
                                          font: fontRegular, fontSize: 14)),
                                  pw.Text(' ${doctor!.doctorQualification}',
                                      style: pw.TextStyle(
                                          font: fontRegular, fontSize: 14)),
                                  pw.Text(
                                      ' ${doctor!.doctorPreviousExperience}',
                                      style: pw.TextStyle(
                                          font: fontRegular, fontSize: 14)),
                                ]),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text(' ${doctor!.doctorAddress}',
                                      style: pw.TextStyle(
                                          font: fontRegular, fontSize: 14)),
                                  pw.Text(' ${doctor!.doctorPhone}',
                                      style: pw.TextStyle(
                                          font: fontRegular, fontSize: 14)),
                                ],
                              ),
                            ),
                          ]),
                      pw.Divider(
                        thickness: 2,
                        borderStyle: pw.BorderStyle.solid,
                      ),
                      pw.Column(children: [
                        pw.Center(
                            child: pw.Text(
                          "Valid UpTo ${patient.validUpTo}",
                          style: const pw.TextStyle(
                            fontSize: 18,
                          ),
                        )),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                            children: [
                              pw.Column(children: [
                                pw.Text('ID: ${patient.id}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 14)),
                                pw.Text(' ${patient.name}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 14)),
                                pw.Text(' ${patient.contact}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 14)),
                                pw.Text(' ${patient.age}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 14)),
                                pw.Text(' ${patient.gender}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 14)),
                              ]),
                              pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text(' ${patient.address}',
                                        style: pw.TextStyle(
                                            font: fontRegular, fontSize: 14)),
                                    pw.Text(' ${patient.registrationTime}',
                                        style: pw.TextStyle(
                                            font: fontRegular, fontSize: 14)),
                                    pw.Text(' ${patient.email}',
                                        style: pw.TextStyle(
                                            font: fontRegular, fontSize: 14)),
                                  ])
                            ]),
                      ]),
                      pw.Divider(
                        thickness: 2,
                        borderStyle: pw.BorderStyle.solid,
                      ),
                      pw.Column(children: [
                        pw.Center(
                            child: pw.Text(
                          "Test Data",
                          style: const pw.TextStyle(
                            fontSize: 18,
                          ),
                        )),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                            children: [
                              pw.Text('Weight: ${patient.weight}',
                                  style: pw.TextStyle(
                                      font: fontRegular, fontSize: 14)),
                              pw.Text('BP: ${patient.bloodPressure}',
                                  style: pw.TextStyle(
                                      font: fontRegular, fontSize: 14)),
                              pw.Text('Pulse: ${patient.pulse}',
                                  style: pw.TextStyle(
                                      font: fontRegular, fontSize: 14)),
                            ]),
                      ]),
                      pw.Divider(
                        thickness: 2,
                      ),
                      pw.Row(children: [
                        pw.Center(
                            child: pw.Text(
                          "Complaints:",
                          style: const pw.TextStyle(
                            fontSize: 16,
                          ),
                        )),
                      ]),
                      pw.Text(' ${patient.complainent}',
                          style: pw.TextStyle(font: fontRegular, fontSize: 14)),
                      pw.Divider(
                        thickness: 2,
                      ),
                      pw.Text('Next Visiting Date: ${patient.nextVisitingDate}',
                          style: pw.TextStyle(font: fontRegular, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF to the temporary directory
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/patient_invoice_${patient.id}.pdf");
      await file.writeAsBytes(await pdf.save());
      await savePdfInfoToDatabase(
          int.parse(patient.id.toString()), file.path, patient.name);

      await OpenFile.open(file.path);
    } catch (e) {
      Get.snackbar('Error', 'Error generating PDF: $e');
    }
  }

  Future<void> savePdfInfoToDatabase(
      int patientId, String pdfPath, String ptName) async {
    final url = Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/doctor/pt_generated_pdf.php');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Attach fields
    request.fields['patient_id'] = patientId.toString();
    request.fields['patient_name'] = ptName;

    // Attach the PDF file
    var pdfFile = await http.MultipartFile.fromPath('pdf_file', pdfPath);

    // Add file to the request
    request.files.add(pdfFile);

    try {
      // Send the request
      var response = await request.send();

      // Convert the response to a usable format
      var responseData = await http.Response.fromStream(response);

      // Parse the response body
      final jsonResponse = json.decode(responseData.body);

      if (jsonResponse['status'] == true) {
        Get.snackbar('Success', 'PDF info saved successfully.');
      } else {
        Get.snackbar('Error', jsonResponse['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while saving PDF info: $e');
    }
  }

  Future<void> _showUpdateDialog(Patient patient) async {
    _complainController.text =
        patient.complainent ?? ''; // Load previous complaint into text field

    // Initialize the SuggestionsController
    final SuggestionsController suggestionsController =
        Get.put(SuggestionsController());

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Complaint for ${patient.name}'),
              content: SizedBox(
                width: double
                    .maxFinite, // Ensures dialog stretches to its max width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _complainController,
                      decoration:
                          const InputDecoration(hintText: 'Enter Complaint'),
                      onChanged: (value) {
                        suggestionsController.fetchSuggestions(value);
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height:
                          200, // Adjust the height based on your UI preference
                      child: Obx(() {
                        if (suggestionsController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (suggestionsController
                            .suggestions.isNotEmpty) {
                          return ListView.builder(
                            itemCount: suggestionsController.suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                    suggestionsController.suggestions[index]),
                                onTap: () {
                                  // Append the selected suggestion to the existing text
                                  setState(() {
                                    if (_complainController.text.isEmpty) {
                                      _complainController.text =
                                          suggestionsController
                                              .suggestions[index];
                                    } else {
                                      // ignore: prefer_interpolation_to_compose_strings
                                      _complainController.text += ', ' +
                                          suggestionsController
                                              .suggestions[index];
                                    }
                                    // Clear suggestions after selecting one
                                    suggestionsController.clearSuggestions();
                                  });
                                },
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final suggestions = await _updatePatientComplain(
                        patient.id, _complainController.text);

                    // Update the patient data with new suggestions
                    setState(() {
                      suggestionsController.suggestions.value = suggestions;
                    });

                    if (suggestions.isEmpty) {
                      // Re-fetch the updated patient data
                      await fetchPatientData();
                      Get.back(); // Close the dialog
                    }
                  },
                  child: const Text('Update'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>> _updatePatientComplain(int ptId, String complain) async {
    // Split the complaints by comma or semicolon
    final List<String> complaintsList =
        complain.split(RegExp(r'[;,]')).map((s) => s.trim()).toList();

    // Join the complaints into a single string, separated by commas or your preferred delimiter
    final String formattedComplaints = complaintsList.join(', ');

    final url = Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/update_patient_complain_th_pt_id.php');
    final Map<String, String> data = {
      'pt_id': ptId.toString(),
      'pt_complainent': formattedComplaints, // Send the formatted complaints
    };

    List<String> suggestions = []; // To store suggestions

    try {
      final response = await http.post(url, body: data);
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == true) {
        Get.snackbar('Success', jsonResponse['message']);
        suggestions = jsonResponse['suggestions'] != null
            ? List<String>.from(
                jsonResponse['suggestions']) // Get suggestions if they exist
            : [];
      } else {
        Get.snackbar('Error', jsonResponse['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }

    return suggestions; // Return suggestions
  }

  Widget _rowData(String text, int flex, Function()? onTap) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _rowHeader(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey), color: Colors.grey),
        child: Text(
          text,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: const Text(
                      "Patient Complain Page",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 36),
                    ),
                  ),
                  Row(
                    children: [
                      _rowHeader("Patient Id", 1),
                      _rowHeader("Patient Name", 1),
                      _rowHeader("Contact Number", 1),
                      _rowHeader("Update Complaint", 1),
                      _rowHeader("Complaint", 1),
                      _rowHeader("Generate PDF", 1),
                    ],
                  ),
                  for (var patient in patients)
                    Row(
                      children: [
                        Expanded(
                            child: _rowData(patient.id.toString(), 1, null)),
                        Expanded(child: _rowData(patient.name, 1, null)),
                        Expanded(child: _rowData(patient.contact, 1, null)),
                        Expanded(
                            child: _rowData('Update Complaint', 1,
                                () => _showUpdateDialog(patient))),
                        Expanded(
                            child:
                                _rowData(patient.complainent ?? '', 1, null)),
                        Expanded(
                            child: _rowData(
                                "PDF", 1, () => generatePdfInvoice(patient))),
                      ],
                    )
                ],
              ),
            ),
    );
  }
}
