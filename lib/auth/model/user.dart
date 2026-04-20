import 'dart:convert';

enum UserRole {
  admin,
  teacher,
  student,
}

class User {
  final String name;
  final String username;
  final String? email;
  final String? password;
  final String userType;
  final int authenticationType;
  String? accessToken;
  bool isSelected;
  bool isLogged;
  String? profileImageUrl;
  String? classCode;
  String? sectionCode;
  String? className;
  String? sectionName;
  String? affiliationCode;

  User({
    required this.name,
    required this.username,
    this.email,
    this.password,
    required this.userType,
    required this.authenticationType,
    this.accessToken,
    this.isSelected = false,
    this.isLogged = false,
    this.profileImageUrl,
    this.classCode,
    this.sectionCode,
    this.className,
    this.sectionName,
    this.affiliationCode,
  });

  // Convert a User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'usertype': userType,
      'authenticationtype': authenticationType,
      'accessToken': accessToken,
      'isSelected': isSelected,
      'isLogged': isLogged,
      'profileImageUrl': profileImageUrl,
      'classCode': classCode,
      'sectionCode': sectionCode,
      'className': className,
      'sectionName': sectionName,
      'affiliationCode': affiliationCode,
    };
  }

  // Convert a Map to a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'],
      password: map['password'],
      userType: map['usertype'] ?? '',
      authenticationType: map['authenticationtype'] ?? 0,
      accessToken: map['accessToken'],
      isSelected: map['isSelected'] ?? false,
      isLogged: map['isLogged'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      classCode: map['classCode'],
      sectionCode: map['sectionCode'],
      className: map['className'],
      sectionName: map['sectionName'],
      affiliationCode: map['affiliationCode'],
    );
  }

  // Convert a JSON string to a User object
  factory User.fromJson(dynamic json) => User.fromMap(json);

  // Convert a User object to a JSON string
  String toJson() => json.encode(toMap());
}
