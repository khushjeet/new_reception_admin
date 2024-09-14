import 'package:flutter/material.dart';

class PatientBillingPage extends StatelessWidget {
  static const String routeName = "/PatientBillingPage";
  const PatientBillingPage({super.key});

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
              "Patient Billing Page",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 36),
            ),
          ),
          Row(
            children: [
              _rowHeader("Name", 1),
              _rowHeader("BANK NAME", 1),
              _rowHeader("Bank ACCOUNT", 1),
              _rowHeader("EMAIL", 1),
              _rowHeader("PHONE", 1),
            ],
          ),
        ],
      ),
    );
  }
}
