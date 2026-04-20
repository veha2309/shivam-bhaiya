import 'dart:convert';

class StudentFeedbackModel {
  final String? jsonData;
  final String? ptmName;
  final String? sessionName;
  final String? studentName;
  final String? className;
  final List<ObservationItem>? observations;

  StudentFeedbackModel({
    this.jsonData,
    this.ptmName,
    this.sessionName,
    this.studentName,
    this.className,
    this.observations,
  });

  factory StudentFeedbackModel.fromJson(Map<String, dynamic> json) {
    List<ObservationItem> observations = [];

    if (json['jsonData'] != null) {
      try {
        final List<dynamic> observationData = json['jsonData'] is String
            ? List<dynamic>.from(jsonDecode(json['jsonData']))
            : json['jsonData'];

        observations = observationData
            .map((item) => ObservationItem.fromJson(item))
            .toList();
      } catch (e) {
        // Error parsing observations
      }
    }

    return StudentFeedbackModel(
      jsonData: json['jsonData'],
      ptmName: json['ptmName'],
      sessionName: json['sessionName'],
      studentName: json['studentName'],
      className: json['className'],
      observations: observations,
    );
  }
}

class ObservationItem {
  final String? observationName;
  final List<ObservationData>? observationData;

  ObservationItem({
    this.observationName,
    this.observationData,
  });

  factory ObservationItem.fromJson(Map<String, dynamic> json) {
    List<ObservationData> data = [];

    if (json['OBSERVATIONDATA'] != null) {
      data = (json['OBSERVATIONDATA'] as List)
          .map((item) => ObservationData.fromJson(item))
          .toList();
    }

    return ObservationItem(
      observationName: json['OBSERVATIONNAME'],
      observationData: data,
    );
  }
}

class ObservationData {
  final String? observationValue;
  final String? subject;

  ObservationData({
    this.observationValue,
    this.subject,
  });

  factory ObservationData.fromJson(Map<String, dynamic> json) {
    return ObservationData(
      observationValue: json['OBSERVATIONVALUE'],
      subject: json['SUBJECT'],
    );
  }
}

// Helper function to decode JSON data
List<StudentFeedbackModel> parseStudentFeedback(List<dynamic> jsonList) {
  return jsonList.map((json) => StudentFeedbackModel.fromJson(json)).toList();
}
