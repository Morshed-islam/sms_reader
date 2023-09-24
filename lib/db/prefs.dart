

import 'package:sms_reader/db/shared_db.dart';

class Prefs{

  static IntPreference<int> get sharedPrefCalcIndex => const IntPreference('calc', 0);

  static BoolPreference get getSimNum => const BoolPreference('sim', false);

  static StringPreference<String?> get getSim1Value => const StringPreference<String?>('sim1', '');
  static StringPreference<String?> get getSim2Value => const StringPreference<String?>('sim2', '');

  static StringPreference<String?> get token => const StringPreference<String?>('token', '');
  static BoolPreference get firstTimeLogin => const BoolPreference('first_time_login', false);


  static List<StringPreference> get user => const[

    StringPreference('first_name', null),
    StringPreference('last_name', null),
    StringPreference('gender', null),
    StringPreference('contact', null),
    StringPreference('email', null),
    StringPreference('avatar', null),
  ];




}