import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:sms_reader/auth/auth_controller.dart';
import 'package:sms_reader/db/prefs.dart';

import '../controller/sms_controller.dart';

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
    // Get.find<SmsController>().initMobileNumberState();
    // initMobileNumberState();

    setState(() {
      initMobileNumberState();
    });
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
      if (_simCard.isNotEmpty) {
        if (_simCard.length == 1) {
          _mobileNumber = _simCard[0].number.toString();
          log("sim card list 1 inside: ${_simCard[0].number ?? "SIM 1"}");
        } else if (_simCard.length == 2) {
          log("sim card list 1: ${_simCard[0].number ?? "SIM 1"}");
          log("sim card list 2: ${_simCard[1].number ?? "SIM 2"}");
        }
      } else {}

      log("sim count: ${_simCard.length}");
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {

    if(_simCard.isEmpty){
      initMobileNumberState();
    }

    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title:  Text("SMS Reader",style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            ),

          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(85),
                        border: Border.all(color: Colors.black,width: 1)
                      ),
                      child: Lottie.asset('assets/images/sms.json', width: 200)),

                  const SizedBox(
                    height: 35,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 50,
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone number',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              labelStyle: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your phone';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 50,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              labelStyle: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue, // Background color
                            ),
                          onPressed: () async{


                            setState(() {
                              initMobileNumberState();
                            });

                            if (_formKey.currentState!.validate()) {
                              // Perform the submit action here (e.g., authentication).

                              // if(_simCard[0].number != _phoneController.text){
                              //    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sim num not matched!')));
                              //    return;
                              // }

                              if (_simCard.isNotEmpty) {
                                bool isExist = _simCard.any((searchNum) => searchNum.number == _phoneController.text);
                                if (isExist) {
                                  log('phone number exist');

                                  final phone = _phoneController.text;
                                  final password = _passwordController.text;
                                  controller.getLoginResponse(context, phone, password);

                                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone num exist')));
                                } else {
                                  log('phone number not exist');
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number does not exist')));
                                  return;
                                }
                              } else {

                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please Pressed Refresh button / Insert sim! Maybe You have no sim card')));
                                return;
                              }

                              // Clear the form fields
                              // _phoneController.clear();
                              // _passwordController.clear();
                            }
                          },
                          child:  Text('Login',style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () async{

                            setState(() {
                              initMobileNumberState();
                            });

                          },
                          child:  Text('Refresh',style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
