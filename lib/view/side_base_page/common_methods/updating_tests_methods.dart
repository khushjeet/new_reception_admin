import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:receptions_app/model/patient_text_models.dart' as patient_model;

class UpdatingTestsMethods {
  Future<void> showUpdateDialog(BuildContext context,
      patient_model.PatientTest patient, String field) async {
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

                  _updatePatientFieldLocally(
                      context, patient, field, controller.text);
                  await _updatePatientField(patient, field, controller.text);

                  if (context.mounted) {
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

  String _getInitialValueForField(
      patient_model.PatientTest patient, String field) {
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
                    var context;
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

  void _updatePatientFieldLocally(BuildContext context,
      patient_model.PatientTest patient, String field, String value) {
    if (!context.mounted) return;
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
  }

  Future<void> _updatePatientField(
      patient_model.PatientTest patient, String field, String value) async {
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
    }

    final url = Uri.parse(
        'http://test.ankusamlogistics.com/doc_reception_api/patient_detail_api/update_patient_field.php');
    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == false) {
        Get.snackbar("Error", "Failed to update patient $field");
      }
    } else {
      Get.snackbar("Error", "Failed to connect to the server");
    }
  }
}
