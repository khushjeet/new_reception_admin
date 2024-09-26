import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/model/patient_model.dart';
import 'package:url_launcher/url_launcher.dart';

class OldPatientPage extends StatefulWidget {
  static const String routeName = "/OldPatientPage";

  const OldPatientPage({super.key});

  @override
  State<OldPatientPage> createState() => _OldPatientPageState();
}

class _OldPatientPageState extends State<OldPatientPage> {
  late Future<List<Patient>> futurePatientData;
  List<Patient> allPatients = [];
  List<Patient> filteredPatients = [];
  String searchQuery = '';

  final patientController = Get.put(PatientController());

  @override
  void initState() {
    super.initState();
    futurePatientData = fetchPatientData(int.parse(
        patientController.doctorId.value)); // Fetch patient data by doctor ID
  }

  Future<List<Patient>> fetchPatientData(int doctorId) async {
    final response = await http.get(Uri.parse(
        'https://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/get_all_patient_data_th_dc_id.php?doctor_id=$doctorId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      List<Patient> patients =
          data.map((json) => Patient.fromJson(json)).toList();
      setState(() {
        allPatients = patients;
        filteredPatients = patients;
      });
      return patients;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _filterPatients(String query) {
    setState(() {
      searchQuery = query;
      filteredPatients = allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query.toLowerCase()) ||
            patient.id.toString().contains(query);
      }).toList();
    });
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

  Widget _rowCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey), color: Colors.white),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildPatientList(List<Patient> patients) {
    return Column(
      children: patients.map((patient) {
        return Row(
          children: [
            _rowCell(patient.id.toString(), 1),
            _rowCell(patient.name, 2),
            _rowCell(patient.age.toString(), 1),
            _rowCell(patient.address, 2),
            _rowCell(patient.contact, 2),
            _rowCell(patient.email ?? 'N/A', 2),
            _rowCell(patient.nextVisitingDate ?? 'N/A', 2),
            _rowCell(patient.weight ?? 'N/A', 2),
            _rowCell(patient.bloodPressure ?? 'N/A', 2),
            _rowCell(patient.pulse ?? 'N/A', 2),
            _rowCell(patient.complainent ?? 'N/A', 2),
            _rowCell(patient.registrationTime, 2),
            _rowCell(patient.validUpTo, 2),
            IconButton(
              onPressed: () async {
                int? count =
                    await _showCountDialog(context); // Ask user for count
                if (count != null) {
                  String? pdfUrl = await fetchPdfPath(
                      patient.id.toString(), patient.name, count);
                  if (pdfUrl != null) {
                    openPdf(pdfUrl); // Open the PDF URL if found
                  }
                }
              },
              icon: const Icon(Icons.print_rounded),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('All Old Registered Data'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                onChanged: _filterPatients,
                decoration: InputDecoration(
                  hintText: 'Search by name or ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Patient>>(
        future: futurePatientData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      _rowHeader("Patient Id", 1),
                      _rowHeader("Patient Name", 2),
                      _rowHeader("Age", 1),
                      _rowHeader("Address", 2),
                      _rowHeader("Contact", 2),
                      _rowHeader("Email", 2),
                      _rowHeader("Next Visit Date", 2),
                      _rowHeader("Weight", 2),
                      _rowHeader("Blood Pressure", 2),
                      _rowHeader("Pulse", 2),
                      _rowHeader("Complainent", 2),
                      _rowHeader("Registration Time", 2),
                      _rowHeader("Valid Up to", 2),
                      const Icon(Icons.print_sharp)
                    ],
                  ),
                  _buildPatientList(filteredPatients),
                ],
              ),
            );
          }
        },
      ),
    );
  }

// The existing fetchPdfPath function
  Future<String?> fetchPdfPath(
      String patientId, String patientName, int count) async {
    // Replace spaces with underscores and convert the name to lowercase
    patientName = patientName.toLowerCase().replaceAll(' ', '_');

    final String url =
        'https://test.ankusamlogistics.com/doc_reception_api/doctor/get_patient_genrated_pdf.php?patient_id=$patientId&patient_name=$patientName&count=$count';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('pdf_url')) {
          final pdfPath = jsonResponse['pdf_url'];
          final fullUrl = '$pdfPath';
          return fullUrl;
        } else {
          Get.snackbar('Error', jsonResponse['error'] ?? 'Unknown error');
          return null;
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch PDF: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      return null;
    }
  }

// The existing openPdf function
  void openPdf(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url); // Open the PDF in a browser or a PDF viewer
    } else {
      Get.snackbar('Error', 'Could not open the PDF');
    }
  }

// Function to show a dialog and get count input from the user
  Future<int?> _showCountDialog(BuildContext context) async {
    TextEditingController countController = TextEditingController();
    int? count;

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Count'),
          content: TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter the count"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                count = int.tryParse(countController.text);
                if (count != null) {
                  Navigator.of(context).pop(count);
                } else {
                  Get.snackbar('Invalid Input', 'Please enter a valid number.');
                }
              },
              child: const Text('Submit'),
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
}
