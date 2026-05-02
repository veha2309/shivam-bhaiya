import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:school_app/auth/model/user.dart';

class LocalStorage {
  static late Box _box;

  // Initialize Hive
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _box = await Hive.openBox('local_storage');
  }

  static Future<void> addUser(User user) async {
    List<User> users = getAllUsers();
    bool userExists = false;
    for (int i = 0; i < users.length; i++) {
      if (users[i].username.trim() == user.username.trim()) {
        users[i] = user;
        userExists = true;
        break;
      }
    }
    if (!userExists) {
      users.add(user);
    }
    await _box.put('users', users.map((user) => user.toJson()).toList());
  }

  static List<User> getAllUsers() {
    List<String> users =
        _box.get('users', defaultValue: [])?.cast<String>() ?? [];
    return users.map((user) => User.fromJson(jsonDecode(user))).toList();
  }

  static bool hasMultipleUsers() {
    List<User> users = getAllUsers();
    return users.length > 1;
  }

  static Future<void> deleteUser(String username) async {
    List<User> users = getAllUsers();
    users.removeWhere((user) => user.username == username);
    if (users.isNotEmpty) {
      users[0].isLogged = true;
    }
    await _box.put('users', users.map((user) => user.toJson()).toList());
  }

  static Future<void> updateUserStatus(User newUser) async {
    List<User> users = getAllUsers();
    bool userUpdated = false;
    for (int i = 0; i < users.length; i++) {
      if (users[i].username.trim() == newUser.username.trim()) {
        users[i] = newUser;
        userUpdated = true;
      } else {
        users[i].isLogged = false;
      }
    }
    if (!userUpdated) {
      users.add(newUser);
    }
    await _box.put('users', users.map((user) => user.toJson()).toList());
    clearNotificationShownStatus();
  }

  static User? getLoggedInUser() {
    try {
      List<User> userList = getAllUsers();

      int index = userList.indexWhere((user) => user.isLogged);

      if (index == -1) {
        return null;
      } else {
        return userList[index];
      }
    } catch (_) {
      return null;
    }
  }

  // Add new methods for notification tracking
  static Future<void> setNotificationShownForToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _box.put('last_notification_shown_date', today);
  }

  static bool wasNotificationShownToday() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastShownDate = _box.get('last_notification_shown_date');
    return lastShownDate == today;
  }

  static Future<void> clearNotificationShownStatus() async {
    await _box.delete('last_notification_shown_date');
  }

  static Future<void> deleteUserWithExpiredToken() async {
    List<User> users = getAllUsers();
    users.removeWhere(
        (user) => user.accessToken == null || user.accessToken!.isEmpty);
    await _box.put('users', users.map((user) => user.toJson()).toList());
  }

  static Future<void> checkIfMultipleUserLoggedIn() async {
    List<User> users = getAllUsers();
    int countOfLoggedInUser = 0;
    for (User user in users) {
      if (user.isLogged) {
        countOfLoggedInUser += 1;
      }
    }

    if (countOfLoggedInUser > 1) {
      users = users.map((user) {
        user.isLogged = false;
        return user;
      }).toList();
      users.first.isLogged = true;

      await _box.put('users', users.map((user) => user.toJson()).toList());
    }
  }

  static String? getLanguage() {
    return _box.get('language');
  }

  static Future<void> saveLanguage(String lang) async {
    await _box.put('language', lang);
  }

  static Future<void> logoutCurrentUser() async {
    List<User> users = getAllUsers();
    for (var user in users) {
      user.isLogged = false;
    }
    await _box.put('users', users.map((user) => user.toJson()).toList());
    await clearNotificationShownStatus();
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
