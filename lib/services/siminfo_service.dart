// sim_info.dart

import 'package:flutter/services.dart';

class SimInfo {
  final String simNumber;

  SimInfo(this.simNumber);
}

// class SimInfoService {
//   static const platform = MethodChannel('com.sms_reader/sim_info');
//
//   static Future<SimInfo> getSimInfo() async {
//     try {
//       final Map<dynamic, dynamic> result =
//       await platform.invokeMethod('getSimInfo');
//       return SimInfo(result['simNumber']);
//     } on PlatformException catch (e) {
//       throw Exception("Failed to get SIM info: ${e.message}");
//     }
//   }
// }
