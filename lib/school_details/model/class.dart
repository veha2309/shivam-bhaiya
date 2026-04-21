class ClassModel {
  final String classCode;
  final String className;

  ClassModel({required this.classCode, required this.className});

  // Factory constructor to create a ClassModel from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      classCode: json['classCode'],
      className: json['className'],
    );
  }

  // Convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'classCode': classCode,
      'className': className,
    };
  }
}
