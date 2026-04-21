import 'dart:convert';

class WordOfTheDayModel {
  final String? messageDate;
  final String? message;

  WordOfTheDayModel({
    this.messageDate,
    this.message,
  });

  // Factory constructor to create an instance from JSON
  factory WordOfTheDayModel.fromJson(Map<String, dynamic> json) {
    return WordOfTheDayModel(
      messageDate: json['messageDate'] as String?,
      message: json['message'] as String?,
    );
  }

  // Convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'messageDate': messageDate,
      'message': message,
    };
  }

  // Convert a list of JSON maps to a list of MessageModel objects
  static List<WordOfTheDayModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WordOfTheDayModel.fromJson(json)).toList();
  }

  // Convert a list of MessageModel objects to JSON
  static String toJsonList(List<WordOfTheDayModel> messages) {
    return jsonEncode(messages.map((message) => message.toJson()).toList());
  }
}
