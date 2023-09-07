import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telephony/telephony.dart';

class SmsController extends GetxController {
  final Rx<Telephony> telephony = Telephony.instance.obs;
  final Rx<Telephony> sim1Telephony = Telephony.instance.obs;
  RxList<SmsMessage> smsList = <SmsMessage>[].obs;
  RxList<SmsMessage> sim1SmsList = <SmsMessage>[].obs;

   final platform = const MethodChannel('com.sms_reader/sim_info');




  @override
  void onInit() {
    super.onInit();
    getSim1Messages();
  }

  bool isListening = false;

  RxString sim1 = ''.obs;
  RxString sim2 = ''.obs;


  Future<void> getAllSms() async {
    smsList.value = await telephony.value.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC), // Sorting by date in descending order
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.BODY),
      ],
    );

    // Check if the smsList is not empty
    if (smsList.isNotEmpty) {
      // Get the most recent message (it should now be the first in the list)
      SmsMessage mostRecentMessage = smsList.first;

      // Print the most recent message details
      print("Most recent message from: ${mostRecentMessage.address}");
      print("Message body: ${mostRecentMessage.body}");
      print("Received date: ${DateTime.fromMillisecondsSinceEpoch(mostRecentMessage.date?.toInt() ?? 1693807493000)}");

    } else {
      print("No messages available");
    }

    print("Total messages: ${smsList.length}");
  }


  Future<void> getSim1Messages() async {
    try {
      sim1SmsList.value = await sim1Telephony.value.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
          OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
          OrderBy(SmsColumn.BODY),
        ],
      );


      if (sim1SmsList.isNotEmpty) {
        // Get the most recent message (it should now be the first in the list)
        // SmsMessage mostRecentMessage = smsList.first;
        final List<SmsMessage> filteredMessages = await filterSim1Messages(sim1SmsList.value);
        sim1SmsList.value = filteredMessages;

        SmsMessage mostRecentMessage = sim1SmsList.first;
        // Print the most recent message details
        print("SIM1 message from: ${mostRecentMessage.address}");
        print("SIM1 Message body: ${mostRecentMessage.body}");

      } else {
        print("SIM 1 No messages available");
      }



    } catch (e) {
      print("Error in getting messages: $e");
    }
  }

  Future<List<SmsMessage>> filterSim1Messages(List<SmsMessage> messages) async {
    try {
      final List<int> sim1MessageIds = await platform.invokeMethod("getSim1MessageIds");
      return messages.where((message) => sim1MessageIds.contains(message.id)).toList();
    } catch (e) {
      print("Error in filtering messages: $e");
      return [];
    }
  }



  Future<void> listenIncomingSms() async {
    // Check if already listening
    if (isListening) {
      print("Already listening for incoming SMS");
      return;
    }

    // Set the flag to true so we don't start another listener
    isListening = true;

    telephony.value.listenIncomingSms(
      onNewMessage: (SmsMessage smsMessage) {
        print("Received SMS: ${smsMessage.body}");
        print("Received SMS: ${smsMessage.address}");
        print("Received date: ${DateTime.fromMillisecondsSinceEpoch(smsMessage.date?.toInt() ?? 1693807493000)}");

        // Update the list of SMS messages and refresh the UI
        smsList.insert(0, smsMessage);

      },

      listenInBackground: false,
    );

    print("Started listening to incoming SMS");
  }

  // Future<void> listenIncomingSms() async{
  //   telephony.value.listenIncomingSms(
  //     onNewMessage: (SmsMessage smsMessage) {
  //       print("Received SMS: ${smsMessage.body}");
  //       print("Received SMS: ${smsMessage.address}");
  //       // Handle the received SMS message here
  //       // smsList.insert(0,smsMessage);
  //         smsList.value.insert(0,smsMessage);
  //         log('inside listen');
  //     },
  //     listenInBackground: false,
  //
  //   );
  //   print("get listen:");
  //
  // }


void setSim1(String sim){
    sim1.value = sim;
}


  void setSim2(String sim){
    sim2.value = sim;
  }


}
