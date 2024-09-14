import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/model/billing_model.dart';

class BillingListView extends StatefulWidget {
  const BillingListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillingListViewState createState() => _BillingListViewState();
}

class _BillingListViewState extends State<BillingListView> {
  late Future<List<Billing>> billingData;
  List<Billing> allBillings = []; // All fetched data stored here
  List<Billing> filteredBillings = []; // Filtered data displayed here
  TextEditingController searchController = TextEditingController();

  final patientController = Get.put(PatientController());

  @override
  void initState() {
    super.initState();
    billingData = getBillingData();
    billingData.then(
      (data) {
        setState(
          () {
            allBillings = data; // Store the fetched data
            filteredBillings =
                data; // Initially, filtered list is the same as all data
          },
        );
      },
    );
  }

  Future<List<Billing>> getBillingData() async {
    try {
      var res = await http.post(
        Uri.parse("http://localhost/reciptions/get_billing.php"),
        body: {
          "id": patientController.doctorId.value,
        },
      );

      if (res.statusCode == 200) {
        var resOfBody = json.decode(res.body);

        // Check if the response contains the "message" key and handle "No Data"
        if (resOfBody is Map<String, dynamic> &&
            resOfBody.containsKey('message')) {
          if (resOfBody['message'] == 'No Data') {
            return []; // Return an empty list when no data is found
          } else {
            throw Exception('Unexpected JSON message: ${resOfBody['message']}');
          }
        }

        // Check if the response is a list
        if (resOfBody is List) {
          return resOfBody.map((json) => Billing.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected JSON format: ${res.body}');
        }
      } else {
        throw Exception('Failed to load billing data: ${res.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  void filterBillingData(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredBillings = allBillings.where((billing) {
        return billing.patientName.toLowerCase().contains(lowerQuery) ||
            billing.services.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by patient name or services...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                filterBillingData(query);
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Billing>>(
        future: billingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                    Text('No billing data found.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                double childAspectRatio = 2.0;

                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                  childAspectRatio = 3;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: filteredBillings.length,
                  itemBuilder: (context, index) {
                    final billing = filteredBillings[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(billing.patientName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Services: ${billing.services}'),
                            Text('Amount: ₹${billing.amount}'),
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
