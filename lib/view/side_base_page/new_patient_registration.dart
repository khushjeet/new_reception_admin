import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:receptions_app/controller/insert_patient_controllert.dart'; // For date formatting

// ignore: must_be_immutable
class NewPatientRegistrationPage extends StatelessWidget {
  static const routeName = "/NewPatientRegistrationPage";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ptNameController = TextEditingController();
  final TextEditingController ptNextVisitingDateController =
      TextEditingController();
  final TextEditingController ptAddressController = TextEditingController();
  final TextEditingController ptAgeController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedGender;

  final patientController = Get.put(InsertPatientController());

  NewPatientRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('New Patient Registration'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextFormField(
                      controller: ptNameController,
                      label: 'Patient Name',
                      validatorMessage: 'Please enter patient name',
                    ),
                    _buildTextFormField(
                      controller: contactNumberController,
                      label: 'Contact Number',
                      validatorMessage: 'Please enter the contact Number',
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        label: Text(
                          "Patient Email(Optional)",
                        ),
                        hintText: "Enter The Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      controller: ptAddressController,
                      label: 'Patient Address',
                    ),
                    _buildTextFormField(
                      controller: ptAgeController,
                      label: 'Patient Age',
                      keyboardType: TextInputType.number,
                    ),
                    _buildGenderDropdown(),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Call the controller function to insert data
                            patientController
                                .insertPatient(
                              ptName: ptNameController.text,
                              ptNextVisitingDate:
                                  ptNextVisitingDateController.text,
                              ptAddress: ptAddressController.text,
                              ptAge: int.parse(ptAgeController.text),
                              ptGendor: selectedGender ?? '',
                              contactNumber: contactNumberController.text,
                              email: emailController.text, // Fixed to use text
                            )
                                .then((_) {
                              // Clear the form fields after successful registration

                              _clearFormFields();
                            });
                          }
                        },
                        child: const Text('Register Patient'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to clear form fields
  void _clearFormFields() {
    ptNameController.clear();
    ptNextVisitingDateController.clear();
    ptAddressController.clear();
    ptAgeController.clear();
    contactNumberController.clear();
    emailController.clear();
    selectedGender = null;

    // If using a StatefulWidget, you might need to call setState here to reflect changes in the UI
  }

  // Reusable widget for text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? validatorMessage,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validatorMessage != null
            ? (value) {
                if (value == null || value.isEmpty) {
                  return validatorMessage;
                }
                return null;
              }
            : null,
        keyboardType: keyboardType,
      ),
    );
  }

  // Gender Dropdown Widget
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        items: ['Male', 'Female', 'Other'].map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          selectedGender = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select gender';
          }
          return null;
        },
      ),
    );
  }
}
