import 'dart:convert';

class ReportCardModel {
  final String? sessionName;
  final String? className;
  final String? term;
  final String? classTeacher;
  final String? url;

  ReportCardModel({
    required this.sessionName,
    required this.className,
    required this.term,
    required this.classTeacher,
    required this.url,
  });

  // Factory method to create an instance from a JSON object
  factory ReportCardModel.fromJson(Map<String, dynamic> json) {
    return ReportCardModel(
      sessionName: json['sessionName'],
      className: json['className'],
      term: json['term'],
      classTeacher: json['classTeacher'],
      url: json['url'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionName': sessionName,
      'className': className,
      'term': term,
      'classTeacher': classTeacher,
      'url': url,
    };
  }

  // Factory method to parse a list of JSON objects
  static List<ReportCardModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => ReportCardModel.fromJson(item)).toList();
  }

  // Method to convert a list of reports to JSON string
  static String toJsonList(List<ReportCardModel> reports) {
    final List<Map<String, dynamic>> jsonList =
        reports.map((report) => report.toJson()).toList();
    return json.encode(jsonList);
  }
}
