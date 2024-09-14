import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';

class TestPage extends StatefulWidget {
  static const String routeName = "/TestPage";

  const TestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<PatientTest> patientTests = [];
  final patientController = Get.put(PatientController());

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    final url = Uri.parse(
        'http://192.168.73.30/reciptions/patient_detail_api/get_today_patient_data.php?doctor_id=${patientController.doctorId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        setState(() {
          patientTests = (jsonResponse['data'] as List)
              .map((data) => PatientTest.fromJson(data))
              .toList();
        });
      }
    }
  }

  Future<void> _updatePatientField(
      PatientTest patient, String field, String newValue) async {
    final url = Uri.parse(
        'http://192.168.73.30/reciptions/patient_detail_api/update_patient_test_data_id.php');

    final Map<String, String> data = {
      'pt_id': patient.ptId.toString(),
    };

    switch (field) {
      case 'Weight':
        data['pt_wt'] = newValue;
        break;
      case 'Pulse':
        data['pt_pluse'] = newValue;
        break;
      case 'BP':
        data['pt_bp'] = newValue;
        break;
      case 'Next Visiting Date':
        data['pt_next_visiting_date'] = newValue;
        break;
      default:
        throw Exception('Invalid field');
    }

    try {
      final response = await http.post(
        url,
        body: data,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['status'] == true) {
          Get.snackbar('Success', jsonResponse['message']);
        } else {
          Get.snackbar('Error', jsonResponse['message']);
        }
      } else {
        Get.snackbar('Error', 'Failed to connect to the server.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> _showUpdateDialog(PatientTest patient, String field) async {
    TextEditingController controller = TextEditingController();

    if (field == 'Next Visiting Date') {
      // Initialize the controller text with the current value if it's a date field
      controller.text = patient.ptNextVisitingDate;
    } else {
      // Initialize the controller text with the existing value for non-date fields
      switch (field) {
        case 'Weight':
          controller.text = patient.ptWt;
          break;
        case 'Pulse':
          controller.text = patient.ptPulse;
          break;
        case 'BP':
          controller.text = patient.ptBp;
          break;
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update $field'),
          content: field == 'Next Visiting Date'
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Select date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (selectedDate != null &&
                                  selectedDate != DateTime.now()) {
                                final formattedDate =
                                    "${selectedDate.toLocal()}".split(' ')[0];
                                controller.text = formattedDate;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Enter new $field'),
                ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  switch (field) {
                    case 'Weight':
                      patient.ptWt = controller.text;
                      break;
                    case 'Pulse':
                      patient.ptPulse = controller.text;
                      break;
                    case 'BP':
                      patient.ptBp = controller.text;
                      break;
                    case 'Next Visiting Date':
                      patient.ptNextVisitingDate = controller.text;
                      break;
                  }
                });

                await _updatePatientField(patient, field, controller.text);

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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10.0),
            child: const Text(
              "Patient Test Data",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36),
            ),
          ),
          Row(
            children: [
              _rowHeader("Patient Id", 1),
              _rowHeader("Patient Name", 1),
              _rowHeader("Contact Number", 1),
              _rowHeader("Weight", 1),
              _rowHeader("Pulse", 1),
              _rowHeader("BP", 1),
              _rowHeader("Next Visiting Date", 1),
            ],
          ),
          for (var patientTest in patientTests)
            Row(
              children: [
                _rowData(patientTest.ptId.toString(), 1, null),
                _rowData(patientTest.ptName, 1, null),
                _rowData(patientTest.ptContactNumber, 1, null),
                _rowData(
                  patientTest.ptWt,
                  1,
                  () => _showUpdateDialog(patientTest, 'Weight'),
                ),
                _rowData(
                  patientTest.ptPulse,
                  1,
                  () => _showUpdateDialog(patientTest, 'Pulse'),
                ),
                _rowData(
                  patientTest.ptBp,
                  1,
                  () => _showUpdateDialog(patientTest, 'BP'),
                ),
                _rowData(
                  patientTest.ptNextVisitingDate,
                  1,
                  () => _showUpdateDialog(patientTest, 'Next Visiting Date'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class PatientTest {
  final int ptId;
  final String ptName;
  final String ptContactNumber;
  String ptWt;
  String ptPulse;
  String ptBp;
  String ptNextVisitingDate;

  PatientTest({
    required this.ptId,
    required this.ptName,
    required this.ptContactNumber,
    this.ptWt = '',
    this.ptPulse = '',
    this.ptBp = '',
    this.ptNextVisitingDate = '',
  });

  factory PatientTest.fromJson(Map<String, dynamic> json) {
    return PatientTest(
      ptId: json['pt_id'],
      ptName: json['pt_name'],
      ptContactNumber: json['pt_contact_number'],
      ptWt: json['pt_wt'] ?? '',
      ptPulse: json['pt_pluse'] ?? '',
      ptBp: json['pt_bp'] ?? '',
      ptNextVisitingDate: json['pt_next_visiting_date'] ?? '',
    );
  }
}
