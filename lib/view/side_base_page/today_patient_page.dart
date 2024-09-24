import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/model/patient_model.dart';

class TodayPatientPage extends StatefulWidget {
  static String routeName = "/TodayPatientPage";
  const TodayPatientPage({super.key});

  @override
  State<TodayPatientPage> createState() => _TodayPatientPageState();
}

class _TodayPatientPageState extends State<TodayPatientPage> {
  late Future<List<Patient>> futurePatientData;
  List<Patient> allPatients = [];
  List<Patient> filteredPatients = [];
  String searchQuery = '';

  final patientController = Get.put(PatientController());

  @override
  void initState() {
    super.initState();
    futurePatientData = fetchPatientData(
        int.parse(patientController.doctorId.value)); // Pass the doctor_id here
  }

  Future<List<Patient>> fetchPatientData(int doctorId) async {
    final response = await http.get(Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/get_today_patient_data.php?doctor_id=$doctorId'));

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
            _rowCell(patient.doctor, 2),
            _rowCell(patient.appointmentDate, 2),
            _rowCell(patient.time, 2),
            _rowCell(patient.registrationTime, 2),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today All Patient Registration'),
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
                      _rowHeader("Doctor", 2),
                      _rowHeader("Appointment Date", 2),
                      _rowHeader("Time", 2),
                      _rowHeader("Registration Time", 2),
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
}
