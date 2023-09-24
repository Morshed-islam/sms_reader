import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_repository.dart';
import '../controller/sms_controller.dart';

Future<void> diInit() async {

  Get.lazyPut(() => SmsController(),fenix: true);
  Get.lazyPut(() => AuthRepo(),fenix: true);
  Get.lazyPut(() => AuthController(Get.find()),fenix: true);
}