import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_reader/auth/auth_repository.dart';
import 'package:sms_reader/auth/model/login_model.dart';
import 'package:sms_reader/db/prefs.dart';

import '../controller/sms_controller.dart';
import '../routes/app_routes.dart';
import '../services/background_services.dart';

class AuthController extends GetxController{

  AuthController(this.authRepo);

  AuthRepo authRepo;

  String token = '';
  bool firstTimeLogin = false;

  var loginResponseModel = LoginModel();

  Future<void> getLoginResponse (BuildContext context,String phone,String pass) async{


    final eitherResponse =await authRepo.loginUser(phone, pass);
    eitherResponse.fold((left){
      log('error $left');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error')));

    }, (success) {

      loginResponseModel = success;
      updateToken(success.token.toString());

      setIsFirstTimeLogin(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success')));
      initializeService();
      Get.offAndToNamed(RouteName.home);
      log('Success $success');

    });

    update();
  }


  void updateToken(String mToken){
    Prefs.token.updateValue(mToken);
    token = mToken;
    update();
  }


  void setIsFirstTimeLogin(bool firstLogin){
    Prefs.firstTimeLogin.updateValue(firstLogin);
    firstTimeLogin = firstLogin;
    update();
  }

}