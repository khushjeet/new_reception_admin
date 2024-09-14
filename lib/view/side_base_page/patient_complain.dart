import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/doctor_controller.dart';
import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/model/doctor_login_models.dart';
import 'package:receptions_app/model/patient_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';

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
  Doctor? doctor; // Add a variable to hold the doctor's details
  final patientController = Get.put(PatientController());
  final _complainController = TextEditingController();
  bool _isLoading = false;

  final doctorController = Get.put(DoctorController());

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    fetchDoctorData(); // Fetch doctor details on initialization
  }

  Future<void> fetchPatientData() async {
    final url = Uri.parse(
        'http://192.168.73.30/reciptions/patient_detail_api/get_today_patient_data.php?doctor_id=${patientController.doctorId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        setState(() {
          patients = (jsonResponse['data'] as List)
              .map((data) => Patient.fromJson(data))
              .toList();
        });
      }
    }
  }

  Future<void> fetchDoctorData() async {
    final url = Uri.parse(
        'http://192.168.73.30/reciptions/doctor/get_doctor_detail_th_doctor_id.php?doctor_id=${patientController.doctorId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);

        // Log the raw response to understand its structure
        debugPrint('Response body: ${response.body}');

        if (jsonResponse == null) {
          Get.snackbar('Error', 'No data received from the server.');
          return;
        }

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final doctorData = jsonResponse['data'];

          if (doctorData is Map<String, dynamic>) {
            // If it's a Map, convert it to a Doctor object
            final doctorDetails = Doctor.fromJson(doctorData);
            setState(() {
              doctor = doctorDetails; // Set the single doctor object
            });
          } else {
            Get.snackbar('Error', 'Unexpected data format for doctor.');
          }
        } else {
          Get.snackbar('Error',
              jsonResponse['message'] ?? 'Failed to fetch doctor data.');
        }
      } catch (e) {
        // Handle case where parsing doctor data fails
        debugPrint('Error parsing doctor data: $e');
        Get.snackbar('Error', 'Failed to parse doctor data.');
      }
    } else {
      Get.snackbar(
          'Error', 'Failed to fetch doctor data: ${response.reasonPhrase}');
    }
  }

  Future<void> generatePdfInvoice(Patient patient) async {
    if (doctor == null) {
      Get.snackbar('Error', 'Doctor details are not available.');
      return;
    }

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
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Doctor's information
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
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            " ${doctor!.doctorsName}",
                            style: pw.TextStyle(
                              fontSize: 18,
                              font: fontRegular,
                            ),
                          ),
                          pw.Text(
                            " ${doctor!.doctorSpecelization}",
                            style: pw.TextStyle(font: fontRegular),
                          ),
                          pw.Text(
                            " ${doctor!.doctorQualification}",
                            style: pw.TextStyle(font: fontRegular),
                          ),
                          pw.Text(
                            " ${doctor!.doctorPreviousExperience}",
                            style: pw.TextStyle(font: fontRegular),
                          ),
                        ],
                      ),
                      pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(height: 10),
                            pw.Text(
                              "Address: ${doctor!.doctorAddress}",
                              style: pw.TextStyle(font: fontRegular),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              "Phone: ${doctor!.doctorPhone}",
                              style: pw.TextStyle(font: fontRegular),
                            ),
                          ])
                    ]),

                pw.Divider(thickness: 2.0),

                // Patient's information
                pw.Center(
                  child: pw.Text(
                    'Valid UpTo ${patient.validUpTo}',
                    style: pw.TextStyle(
                        font: fontRegular, fontBold: fontBold, fontSize: 15),
                  ),
                ),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            ' ID:  ${patient.id}',
                            style: pw.TextStyle(font: fontBold),
                          ),
                          pw.Text(
                            'Name: ${patient.name}',
                            style: pw.TextStyle(font: fontBold),
                          ),
                          pw.Text(
                            'Mobile: ${patient.contact}',
                            style: pw.TextStyle(font: fontRegular),
                          ),
                          pw.Text(
                            ' Age: ${patient.age}',
                            style: pw.TextStyle(font: fontRegular),
                          ),
                          pw.Text(
                            'Gendor: ${patient.gender}',
                            style: pw.TextStyle(font: fontRegular),
                          ),
                        ],
                      ),
                      pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              ' ${patient.address}',
                              style: pw.TextStyle(font: fontRegular),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Registration Time: ${patient.registrationTime}',
                              style: pw.TextStyle(font: fontRegular),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              ' ${patient.email ?? 'Not Available'}',
                              style: pw.TextStyle(font: fontRegular),
                            ),
                          ])
                    ]),

                pw.Divider(thickness: 2.0),

                pw.Center(
                  child: pw.Text("Test Data",
                      style: pw.TextStyle(fontSize: 15, fontBold: fontBold)),
                ),

                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Weight: ${patient.weight ?? 'Not Available'}',
                        style: pw.TextStyle(font: fontRegular),
                      ),
                      pw.Text(
                        'Bp: ${patient.bloodPressure ?? 'Not Available'}',
                        style: pw.TextStyle(font: fontRegular),
                      ),
                      pw.Text(
                        'Pulse: ${patient.pulse ?? 'Not Available'}',
                        style: pw.TextStyle(font: fontRegular),
                      ),
                    ]),

                pw.Divider(),

                pw.Center(
                  child: pw.Text("Complaints",
                      style: pw.TextStyle(fontSize: 15, fontBold: fontBold)),
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      ' ${patient.complainent ?? 'Not Available'}',
                      style: pw.TextStyle(font: fontRegular),
                    ),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.Footer(
                  leading: pw.Text(
                    'Next Visiting Date :${patient.nextVisitingDate ?? 'Not Available'}',
                    style: pw.TextStyle(font: fontRegular),
                  ),
                )
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

  Future<void> _showUpdateDialog(Patient patient) async {
    _complainController.text = patient.complainent ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Complaint for ${patient.name}'),
          content: TextField(
            controller: _complainController,
            decoration: const InputDecoration(hintText: 'Enter Complaint'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _updatePatientComplain(
                    patient.id, _complainController.text);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
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
  }

  Future<void> _updatePatientComplain(int ptId, String complain) async {
    final url = Uri.parse(
        'http://192.168.73.30/reciptions/patient_detail_api/update_patient_complain_th_pt_id.php');

    final Map<String, String> data = {
      'pt_id': ptId.toString(),
      'pt_complainent': complain,
    };

    setState(() {
      _isLoading = true; // Optional: show loading state
    });

    try {
      final response = await http.post(url, body: data);
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == true) {
        Get.snackbar('Success', jsonResponse['message']);
        await fetchPatientData(); // Refresh the data after a successful update
      } else {
        Get.snackbar('Error', jsonResponse['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false; // End loading state
      });
    }
  }

  Widget _rowData(String text, int flex, Function()? onTap) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Text(text),
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
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator()) // Show loader if loading
        : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(10.0),
                  child: const Text(
                    "Patient Complain Page",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36),
                  ),
                ),
                Row(
                  children: [
                    _rowHeader("Patient Id", 1),
                    _rowHeader("Patient Name", 1),
                    _rowHeader("Contact Number", 1),
                    _rowHeader("Update Complainent", 1),
                    _rowHeader("Complainent", 1),
                    _rowHeader("Generate PDF", 1),
                  ],
                ),
                for (var patient in patients)
                  Row(
                    children: [
                      _rowData(patient.id.toString(), 1, null),
                      _rowData(patient.name, 1, null),
                      _rowData(patient.contact, 1, null),
                      _rowData(
                        'Update Complain',
                        1,
                        () => _showUpdateDialog(patient),
                      ),
                      _rowData(patient.complainent ?? '', 1, null),
                      _rowData(
                        "Pdf",
                        1,
                        () => generatePdfInvoice(patient),
                      )
                    ],
                  ),
              ],
            ),
          );
  }
}
