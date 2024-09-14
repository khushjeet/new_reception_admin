import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receptions_app/controller/billing_controller.dart';

class BillingScreen extends StatelessWidget {
  BillingScreen({super.key});

  // Controller instance to manage billing data
  final billingController = Get.put(BillingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Billing Form
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.40,
                width: MediaQuery.of(context).size.width * 0.40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(182, 182, 182, 182),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    const Center(
                      child: Text(
                        "Billing Information",
                        style: TextStyle(color: Colors.black, fontSize: 28),
                      ),
                    ),
                    // TextField for entering Patient Name
                    _buildTextField("Patient Name", (value) {
                      billingController.patientName.value = value;
                    }),
                    // TextField for entering Services
                    _buildTextField("Services", (value) {
                      billingController.services.value = value;
                    }),
                    // TextField for entering Amount
                    _buildTextField("Amount", (value) {
                      billingController.amount.value = value;
                    }),
                    // Button to trigger billing submission
                    ElevatedButton(
                      onPressed: () {
                        billingController.submitBilling();
                      },
                      child: const Text('Submit Billing'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable TextField widget
  Widget _buildTextField(String label, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 38,
        right: 38,
        top: 5,
        bottom: 15,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          label: Text(
            label,
            style: const TextStyle(color: Colors.black),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
