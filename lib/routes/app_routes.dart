import 'package:get/get.dart';
import 'package:sms_reader/auth/login_screen.dart';
import 'package:sms_reader/pages/homepage.dart';

import '../pages/splash_screen.dart';

part 'route_name.dart';
class AppRoutes {

  static const initial = RouteName.splash;

  final appRouter = [
    GetPage(
      name: RouteName.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: RouteName.home,
      page: () =>  HomePage(),) ,
    GetPage(
      name: RouteName.login,
      page: () =>  LoginScreen(),)

  ];
}