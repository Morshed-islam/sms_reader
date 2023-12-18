import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:sms_reader/auth/auth_controller.dart';
import 'package:sms_reader/db/prefs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

   String _mobileNumber = '';
   List<SimCard> _simCard = <SimCard>[];


  @override
  void initState() {
    initMobileNumberState();

    super.initState();
  }


  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _mobileNumber = (await MobileNumber.mobileNumber)!;
      _simCard = (await MobileNumber.getSimCards)!;

      log("sim card list 1 outside: ${_simCard[0].number ?? "SIM 1"}");
      _mobileNumber = _simCard[0].number.toString();
      if(_simCard.isNotEmpty){
        if(_simCard.length == 1){
          _mobileNumber = _simCard[0].number.toString();
          log("sim card list 1 inside: ${_simCard[0].number ?? "SIM 1"}");

        }else if(_simCard.length == 2){
          log("sim card list 1: ${_simCard[0].number ?? "SIM 1"}");
          log("sim card list 2: ${_simCard[1].number ?? "SIM 2"}");

        }

      }else{

      }

      log("sim count: ${_simCard.length}");

    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

     if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sms Reader'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {

                    if (_formKey.currentState!.validate()) {
                      // Perform the submit action here (e.g., authentication).

                      // if(_simCard[0].number != _phoneController.text){
                      //    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sim num not matched!')));
                      //    return;
                      // }

                      final phone = _phoneController.text;
                      final password = _passwordController.text;
                      controller.getLoginResponse(context,phone, password);
                      // Implement your logic here.


                      // Clear the form fields
                      // _phoneController.clear();
                      // _passwordController.clear();
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    },);
  }
}
