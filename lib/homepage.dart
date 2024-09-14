import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:receptions_app/view/side_base_page/Today_patient_page.dart';

import 'package:receptions_app/view/side_base_page/new_patient_registration.dart';
import 'package:receptions_app/view/side_base_page/old_patient.dart';
import 'package:receptions_app/view/side_base_page/patient_complain.dart';
import 'package:receptions_app/view/side_base_page/test_page.dart';

import 'package:receptions_app/view/side_base_page/patient_billing.dart';
import 'package:receptions_app/view/side_base_page/upconing_patient_regis_page.dart';

class HomePage extends StatefulWidget {
  final String cName;
  final String doctorId;

  // ignore: prefer_const_constructors_in_immutables
  HomePage({required this.cName, required this.doctorId, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _selectedItem = NewPatientRegistrationPage();

  screenSlector(item) {
    if (item.route == NewPatientRegistrationPage.routeName) {
      setState(() {
        _selectedItem = NewPatientRegistrationPage();
      });
      return;
    } else if (item.route == TestPage.routeName) {
      setState(() {
        _selectedItem = const TestPage();
      });
      return;
    } else if (item.route == PatientComplainPage.routeName) {
      setState(() {
        _selectedItem = PatientComplainPage();
      });
      return;
    } else if (item.route == PatientBillingPage.routeName) {
      setState(() {
        _selectedItem = const PatientBillingPage();
      });
      return;
    } else if (item.route == TodayPatientPage.routeName) {
      setState(() {
        _selectedItem = const TodayPatientPage();
      });
      return;
    } else if (item.route == OldPatientPage.routeName) {
      setState(() {
        _selectedItem = const OldPatientPage();
      });
      return;
    } else if (item.route == NewPatientRegistrationPage.routeName) {
      setState(() {
        _selectedItem = NewPatientRegistrationPage();
      });
      return;
    } else if (item.route == PatientBillingPage.routeName) {
      setState(() {
        _selectedItem = PatientComplainPage();
      });
      return;
    } else if (item.route == UpconingPatientRegisPage.routeName) {
      setState(() {
        _selectedItem = const UpconingPatientRegisPage();
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.yellow.shade900,
      appBar: AppBar(
        title: const Text("Reception Management System"),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: "New Patient Registration",
            icon: Icons.person_add,
            route: '/NewPatientRegistrationPage',
          ),
          AdminMenuItem(
            title: "Test Page",
            icon: Icons.book_outlined,
            route: '/TestPage',
          ),
          AdminMenuItem(
            title: "Patient Complainent Page",
            icon: Icons.report_problem,
            route: '/PatientComplainPage',
          ),
          AdminMenuItem(
            title: "Today AppointMent",
            icon: Icons.today,
            route: '/TodayPatientPage',
          ),
          AdminMenuItem(
            title: 'OldPatientPage',
            icon: Icons.history,
            route: '/OldPatientPage',
          ),
          AdminMenuItem(
            title: "Upcomming Appoitment",
            icon: Icons.calendar_today,
            route: '/UpconingPatientRegisPage',
          ),
        ],
        selectedRoute: '',
        onSelected: (item) {
          screenSlector(item);
        },
        header: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: Center(
            child: Text(
              widget.cName, // Correct way to access the variable
              style: const TextStyle(
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'Footer',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _selectedItem,
    );
  }
}
