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
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/get_today_patient_data.php?doctor_id=${patientController.doctorId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        if (mounted) {
          setState(() {
            patientTests = (jsonResponse['data'] as List)
                .map((data) => PatientTest.fromJson(data))
                .toList();
          });
        }
      }
    } else {
      // Handle errors appropriately
      Get.snackbar("Error", "Failed to fetch patient data");
    }
  }

  Future<void> _showUpdateDialog(PatientTest patient, String field) async {
    TextEditingController controller = TextEditingController();
    controller.text = _getInitialValueForField(patient, field);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update $field'),
          content: _buildDialogContent(field, controller),
          actions: [
            TextButton(
              onPressed: () async {
                _updatePatientFieldLocally(patient, field, controller.text);
                await _updatePatientField(patient, field, controller.text);
                if (mounted) {
                  Get.back();
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
  }

  String _getInitialValueForField(PatientTest patient, String field) {
    switch (field) {
      case 'Weight':
        return patient.ptWt;
      case 'Pulse':
        return patient.ptPulse;
      case 'BP':
        return patient.ptBp;
      case 'Next Visiting Date':
        return patient.ptNextVisitingDate;
      default:
        return '';
    }
  }

  Widget _buildDialogContent(String field, TextEditingController controller) {
    if (field == 'Next Visiting Date') {
      return Row(
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
                    if (selectedDate != null) {
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
      );
    } else {
      return TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Enter new $field'),
      );
    }
  }

  void _updatePatientFieldLocally(
      PatientTest patient, String field, String value) {
    setState(() {
      switch (field) {
        case 'Weight':
          patient.ptWt = value;
          break;
        case 'Pulse':
          patient.ptPulse = value;
          break;
        case 'BP':
          patient.ptBp = value;
          break;
        case 'Next Visiting Date':
          patient.ptNextVisitingDate = value;
          break;
      }
    });
  }

  Future<void> _updatePatientField(
      PatientTest patient, String field, String value) async {
    // Your logic to update the patient field in the backend
    // For example:
    final response = await http.post(
      Uri.parse(
          'https://test.ankusamlogistics.com/doc_reception_api/doctor/pt_generated_pdf.php'),
      body: {
        'pt_id': patient.ptId.toString(),
        field.toLowerCase(): value,
      },
    );

    // Handle the response as needed
    if (response.statusCode == 200) {
      // Successfully updated
    } else {
      // Handle errors appropriately
      Get.snackbar("Error", "Failed to update patient data");
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
          child: Text(text,
              style: const TextStyle(color: Color.fromARGB(238, 247, 227, 4))),
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
      body: SingleChildScrollView(
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
      ptPulse: json['pt_pulse'] ?? '',
      ptBp: json['pt_bp'] ?? '',
      ptNextVisitingDate: json['pt_next_visiting_date'] ?? '',
    );
  }
}
