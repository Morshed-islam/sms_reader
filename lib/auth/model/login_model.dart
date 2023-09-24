import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel({
    this.login,
    this.message,
    this.user,
    this.token,
  });

  LoginModel.fromJson(dynamic json) {
    login = json['login'];
    message = json['message'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = json['token'];
  }

  bool? login;
  String? message;
  User? user;
  String? token;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['login'] = login;
    map['message'] = message;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    map['token'] = token;
    return map;
  }
}

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.active,
    this.phone,
    this.userType,
    this.joiningDate,
    this.name,
    this.gender,
    this.id,
  });

  User.fromJson(dynamic json) {
    active = json['active'];
    phone = json['phone'];
    userType = json['userType'];
    joiningDate = json['joiningDate'];
    name = json['name'];
    gender = json['gender'];
    id = json['id'];
  }

  bool? active;
  String? phone;
  String? userType;
  String? joiningDate;
  String? name;
  String? gender;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['phone'] = phone;
    map['userType'] = userType;
    map['joiningDate'] = joiningDate;
    map['name'] = name;
    map['gender'] = gender;
    map['id'] = id;
    return map;
  }
}
