import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_reader/auth/auth_controller.dart';
import 'package:sms_reader/auth/auth_repository.dart';
import 'package:sms_reader/db/shared_db.dart';
import 'package:sms_reader/helper/get_di.dart';
import 'package:sms_reader/pages/homepage.dart';
import 'package:sms_reader/routes/app_routes.dart';
import 'package:sms_reader/services/background_services.dart';

import 'auth/login_screen.dart';
import 'controller/sms_controller.dart';
import 'db/prefs.dart';
// import 'package:sms_reader/services/background_services.dart';


// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
// @pragma('vm:entry-point')
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   BackgroundFetch.finish(taskId);
// }

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();

  await Permission.notification.isDenied.then((value){
    if(value){
      Permission.notification.request();
    }
  });
  Get.put(SmsController());

  await diInit();
  // await initializeService();
  // if(Prefs.token.value!.isNotEmpty){
  //   log("init service");
  //
  // }
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMS READER',
      getPages: AppRoutes().appRouter,
      initialRoute: RouteName.splash,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
