import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';

class TestPage extends StatefulWidget {
  static const String routeName = "/TestPage";

  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<PatientTest> patientTests = [];
  final patientController = Get.put(PatientController());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    final url = Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/get_today_patient_data.php?doctor_id=${patientController.doctorId}');
    final response = await http.get(url);

    if (!mounted) return; // Check if widget is still in the tree

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        setState(() {
          patientTests = (jsonResponse['data'] as List)
              .map((data) => PatientTest.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar("Error", "Today Not Registered any Patient Yet");
      }
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to connect to the server");
    }
  }

  Future<void> _showUpdateDialog(PatientTest patient, String field) async {
    TextEditingController controller = TextEditingController();
    controller.text = _getInitialValueForField(patient, field);
    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Update $field'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpdating)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildDialogContent(field, controller),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    isUpdating = true;
                  });

                  _updatePatientFieldLocally(patient, field, controller.text);
                  await _updatePatientField(patient, field, controller.text);

                  if (mounted) {
                    setState(() {
                      isUpdating = false;
                    });
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
        });
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
    if (!mounted) return; // Check if widget is still in the tree
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
    Map<String, String> body = {
      'pt_id': patient.ptId.toString(),
    };

    switch (field) {
      case 'Weight':
        body['pt_wt'] = value;
        break;
      case 'Pulse':
        body['pt_pluse'] = value;
        break;
      case 'BP':
        body['pt_bp'] = value;
        break;
      case 'Next Visiting Date':
        body['pt_next_visiting_date'] = value;
        break;
      default:
        Get.snackbar("Error", "Invalid field");
        return;
    }

    final response = await http.post(
      Uri.parse(
          'https://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/update_patient_test_data_id.php'),
      body: body,
    );

    if (!mounted) return; // Check if widget is still in the tree

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true) {
        Get.snackbar(
          "Success",
          "$field updated successfully in the backend",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Error", "Failed to update $field in the backend");
      }
    } else {
      Get.snackbar("Error", "Failed to connect to the server");
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
          child: Text(
            text,
            style: const TextStyle(color: Color.fromARGB(238, 247, 227, 4)),
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
      body: Stack(
        children: [
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && patientTests.isEmpty)
            const Center(
              child: Text(
                "Today No Data For Test",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          if (!isLoading && patientTests.isNotEmpty)
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10.0),
                    child: const Text(
                      "Patient Test Data",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 36),
                    ),
                  ),
                  Row(
                    children: [
                      _rowHeader("Patient Id", 1),
                      _rowHeader("Patient Name", 1),
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
                          () => _showUpdateDialog(
                              patientTest, 'Next Visiting Date'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Any cleanup tasks if needed, e.g., cancel timers, listeners, etc.
  }
}

class PatientTest {
  final String ptId;
  final String ptName;
  String ptWt;
  String ptPulse;
  String ptBp;
  String ptNextVisitingDate;

  PatientTest({
    required this.ptId,
    required this.ptName,
    required this.ptWt,
    required this.ptPulse,
    required this.ptBp,
    required this.ptNextVisitingDate,
  });

  factory PatientTest.fromJson(Map<String, dynamic> json) {
    return PatientTest(
      ptId: json['pt_id'].toString(),
      ptName: json['pt_name'] ?? 'N/A',
      ptWt: json['pt_wt']?.toString() ?? 'N/A',
      ptPulse: json['pt_pluse']?.toString() ?? 'N/A',
      ptBp: json['pt_bp']?.toString() ?? 'N/A',
      ptNextVisitingDate: json['pt_next_visiting_date'] ?? 'N/A',
    );
  }
}
