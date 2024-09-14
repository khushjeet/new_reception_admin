import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/model/patient_model.dart';

class PatientListView extends StatefulWidget {
  PatientListView({super.key});

  final patientController = Get.put(PatientController());

  @override
  // ignore: library_private_types_in_public_api
  _PatientListViewState createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> {
  late Future<List<Patient>> patientData;
  List<Patient> allPatients = [];
  List<Patient> filteredPatients = [];
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'name'; // Default filter
  final prController = Get.put(PatientController());

  @override
  void initState() {
    super.initState();
    patientData = getDataFromPatientRegistration();
    patientData.then((data) {
      setState(() {
        allPatients = data;
        filteredPatients = data;
      });
    });
  }

  Future<List<Patient>> getDataFromPatientRegistration() async {
    try {
      var res = await http.post(
        Uri.parse("http://192.168.73.30/reciptions/get_appoitment.php"),
        body: {
          'id': prController.doctorId.toString(),
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Connection timed out, please try again later.");
        },
      );

      if (res.statusCode == 200) {
        var resOfBody = json.decode(res.body);

        if (resOfBody is Map<String, dynamic> &&
            resOfBody.containsKey('message')) {
          // Handle the "No Data" message
          if (resOfBody['message'] == 'No Data') {
            return []; // Return an empty list if there's no data
          } else {
            throw Exception('Error: ${resOfBody['message']}');
          }
        } else if (resOfBody is List) {
          return resOfBody.map((json) => Patient.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected JSON format: ${res.body}');
        }
      } else {
        throw Exception('Failed to load patient data: ${res.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  void filterPatientData(String query) {
    final lowerQuery = query.toLowerCase();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (lowerQuery == searchController.text.toLowerCase()) {
        setState(() {
          filteredPatients = allPatients.where((patient) {
            switch (selectedFilter) {
              case 'name':
                return patient.name.toLowerCase().contains(lowerQuery);
              case 'contact':
                return patient.contact.toLowerCase().contains(lowerQuery);
              case 'address':
                return patient.address.toLowerCase().contains(lowerQuery);
              case 'appointment_date':
                return patient.appointmentDate
                    .toLowerCase()
                    .contains(lowerQuery);
              default:
                return false;
            }
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Filter by Name'),
                ),
                const PopupMenuItem<String>(
                  value: 'contact',
                  child: Text('Filter by Contact'),
                ),
                const PopupMenuItem<String>(
                  value: 'address',
                  child: Text('Filter by Address'),
                ),
                const PopupMenuItem<String>(
                  value: 'appointment_date',
                  child: Text('Filter by Appointment Date'),
                ),
              ];
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by $selectedFilter...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (query) {
                filterPatientData(query);
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Patient>>(
        future: patientData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Still there is no registration.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text('No patients found.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;

                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2, // Adjust as needed
                  ),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: const Color.fromRGBO(13, 165, 215, 0.956),
                      child: ListTile(
                        title: Text(
                            patient.name.isNotEmpty ? patient.name : 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Age: ${patient.age}'),
                            Text('Gender: ${patient.gender}'),
                            Text('Contact: ${patient.contact}'),
                            Text('Address: ${patient.address}'),
                            Text(
                                'Appointment Date: ${patient.appointmentDate}'),
                            Text('Appointment Time: ${patient.time}'),
                            Text(
                              'Registration Time: ${patient.registrationTime.isNotEmpty ? patient.registrationTime : 'Not Available'}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () {},
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
