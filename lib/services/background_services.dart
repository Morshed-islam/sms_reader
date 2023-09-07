import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import '../controller/sms_controller.dart';


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

    Timer.periodic(const Duration(seconds: 2), (timer) async{
     if(await serviceInstance.isForegroundService()){

       serviceInstance.setForegroundNotificationInfo(title: "sms", content: "sms reader");
       serviceInstance.setAutoStartOnBootMode(true);
     }


     smsController.getAllSms();
     print('listen service running');
     smsController.listenIncomingSms();
    });
    // Start listening to incoming SMS
    // smsController.listenIncomingSms();
  }

}

