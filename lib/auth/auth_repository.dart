import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:sms_reader/auth/model/login_model.dart';
class AuthRepo{

  Future<Either<String,LoginModel>> loginUser(String phone,String pass) async {
    const String url = 'http://18.136.115.162/api/auth/login';

    final Map<String, String> body = {
      "phone": phone,
      "password": pass,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Login successful, handle the response here
      final responseData = jsonDecode(response.body);
      LoginModel lModel = LoginModel.fromJson(responseData);
      print(responseData);
      return Right(lModel);
    } else {
      // Login failed, handle the error here
      print("Login failed. Status code: ${response.statusCode}");
      return const Left('Server Error');

    }
  }

}