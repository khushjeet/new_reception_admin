import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receptions_app/controller/doctor_controller.dart';
import 'package:receptions_app/controller/patientcontroller.dart';
import 'package:receptions_app/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  final PatientController patientController = Get.put(PatientController());
  final DoctorController doctorController = Get.put(DoctorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blueAccent,
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextFormField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      labelText: "Username",
                      labelStyle: const TextStyle(color: Colors.white),
                      hintStyle: const TextStyle(color: Colors.white),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Username";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: "Enter Password",
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white),
                      hintStyle: const TextStyle(color: Colors.white),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Password";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Obx(() {
                  return Center(
                    child: doctorController.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState != null &&
                                  formKey.currentState!.validate()) {
                                // Start loading
                                doctorController.isLoading.value = true;

                                // Attempt login
                                final doctor = await doctorController
                                    .loginAndGetDoctorDetails(
                                  usernameController.text,
                                  passwordController.text,
                                );

                                // Stop loading
                                doctorController.isLoading.value = false;

                                if (doctor != null) {
                                  // Update patient controller with doctor's details
                                  patientController.doctorName.value =
                                      doctor.doctorsName;
                                  patientController.doctorId.value =
                                      doctor.doctorId.toString();

                                  // Navigate to the HomePage
                                  Get.to(() => HomePage(
                                        doctorId: doctor.doctorId.toString(),
                                        cName: doctor.clinicName,
                                      ));
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Invalid credentials or server error",
                                  );
                                }
                              }
                            },
                            child: const Text("Login"),
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
