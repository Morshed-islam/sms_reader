import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_reader/db/shared_db.dart';
import 'package:sms_reader/db/prefs.dart';

// import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/sms_controller.dart';
import '../routes/app_routes.dart';
import '../services/siminfo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SmsController _smsController = Get.find<SmsController>();
  // static const platform = MethodChannel("com.sms_reader/sim1");
  int _status = 0;
  List<DateTime> _events = [];

  ///getting sim num

  bool isReload = false;

  // String _simInfo = "";
  //
  // void _loadSimInfo() async {
  //   try {
  //     SimInfo simInfo2 = await SimInfoService.getSimInfo();
  //
  //     setState(() {
  //       _simInfo = simInfo2.simNumber;
  //       log('sim info: ${_simInfo}');
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _simInfo = "Error: $e";
  //     });
  //   }
  // }

  Future<void> _requestPhoneStatePermission() async {
    if (await Permission.phone.request().isGranted) {
      // Permission granted, proceed to load SIM info
      // _loadSimInfo();
      _smsController.getAllSms(isFromBackground: false);
    } else {
      // Permission denied
      print("Phone state permission denied");
    }
  }


  @override
  void initState() {
    super.initState();
    // _smsController.getAllSms();
    _requestPhoneStatePermission();
    // _loadSimInfo();


    ///todo -- will work on it
    // _smsController.getSim1Messages(platform);

    // _smsController.listenIncomingSms();

    ///getting sim num
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        _smsController.initMobileNumberState();
      } else {}
    });

    _smsController.initMobileNumberState();
  }

  ///getting sim num
  // Platform messages are asynchronous, so we initialize in an async method.


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sms Reader"),
        leading: InkWell(
            onTap: () {
              // _openSettings();

              // Prefs.getSimNum.updateValue(false);
              _showCustomDialog(context);
              log('pressed');
            },
            child: const Icon(Icons.sim_card)),
        actions: [
          InkWell(
            onTap: () {
              isReload = true;

              setState(() {
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    isReload = false;
                    _smsController.getAllSms(isFromBackground: false);
                  });
                });
                // _smsController.listenIncomingSms();
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.refresh_sharp),
            ),
          ),

           InkWell(
               onTap: (){
                 _showLogoutDialog(context);
               },
               child: const Padding(
                 padding: EdgeInsets.only(right: 8.0),
                 child: Icon(Icons.logout),
               ))
        ],
      ),
      body: Obx(() {
        log("First Time login: ${Prefs.firstTimeLogin.value}");
        log("token :${Prefs.token.value}");
        log("number :${_smsController.mobileNumber.value}");

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isReload
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _smsController.smsList.length,
                      itemBuilder: (context, index) {
                        // log('pref ${Prefs.getSimNum.value}');
                        return Column(
                          children : [
                            ListTile(
                              title: Text('From: ${_smsController.smsList[index].address}',style: const TextStyle(fontWeight: FontWeight.w600),),
                              subtitle: Text('Message: ${_smsController.smsList[index].body} '
                                  // '\nTime: ${_smsController.smsList[index].date}'
                              ),
                              // trailing: Text(_simInfo.substring(0,5)),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Divider(height: 1,color: Colors.grey,),
                            )
                          ],
                        );
                      },
                    ),
                  ),
          ],
        );
      }),
    );
  }

  _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Prefs.getSimNum.value == false
            ? Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 16,
                child: SizedBox(
                  height: 300.0,
                  width: 360.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add SIM number'),
                        const SizedBox(height: 20),
                        TextFormField(
                          enabled: false,
                          onChanged: (value) => _smsController.setSim1(value),
                          decoration: InputDecoration(
                            labelText: _smsController.mobileNumber.value ?? "",
                            // labelText: 'SIM 1',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          enabled: false,
                          onChanged: (value) => _smsController.setSim2(value),
                          decoration: const InputDecoration(
                            labelText: 'SIM 2',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Align(
                        //   alignment: Alignment.bottomRight,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       log('Field 1: ${_smsController.sim1.value}');
                        //       log('Field 2: ${_smsController.sim2.value}');
                        //
                        //       if (_smsController.sim1.value == '' && _smsController.sim2.value == '') {
                        //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please input value')));
                        //
                        //         return;
                        //       }
                        //
                        //       Prefs.getSim1Value.updateValue(_smsController.sim1.value);
                        //       Prefs.getSim2Value.updateValue(_smsController.sim2.value);
                        //
                        //       Prefs.getSimNum.updateValue(true);
                        //       Navigator.pop(context);
                        //     },
                        //     child: const Text('Add'),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              )
            : Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SizedBox(
                  height: 100,
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SIM 1 : ${_smsController.sim1.value}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "SIM 2 : ${_smsController.sim2.value}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

/*
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
// Configure BackgroundFetch.
    var status = await BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 1,
      forceAlarmManager: false,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
    ), _onBackgroundFetch, _onBackgroundFetchTimeout);
    print("[BackgroundFetch] configure success: $status");
// Schedule backgroundfetch for the 1st time it will execute with 1000ms delay.
// where device must be powered (and delay will be throttled by the OS).
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.dltlabs.task",
        delay: 100,
        periodic: false,
        stopOnTerminate: false,
        enableHeadless: true
    ));
  }


  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }


  void _onBackgroundFetch(String taskId) async {
    if(taskId == "your_task_id") {
      print("[BackgroundFetch] Event received");
  //TODO: perform your task like : call the API’s, call the DB and local notification.
    }
  }*/

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Do you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                // Perform logout actions here
                // For example, you can navigate to the login screen
                Prefs.logOut();
                Navigator.of(context).pop(); // Dismiss the dialog
                Get.offAndToNamed(RouteName.login);
              },
            ),
          ],
        );
      },
    );
  }


}
