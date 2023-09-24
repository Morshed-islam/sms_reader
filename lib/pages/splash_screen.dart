import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sms_reader/controller/sms_controller.dart';
import 'package:sms_reader/db/prefs.dart';
import 'package:sms_reader/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;

  Future<void> init() async {
    timer = Timer(const Duration(seconds: 3), () {
      log("token :${Prefs.token.value}");
      if(Prefs.token.value!.isNotEmpty){
        Get.offAndToNamed(RouteName.home);
      }else{
        Get.offAndToNamed(RouteName.login);
      }
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(child: Lottie.asset('assets/images/sms.json',width: 250)),
    );
  }
}
