class AttendanceParam {
  final String? attendanceValue;
  final String? displayOrder;
  final String? defaultValue;
  final String? paramName;
  final String? paramValue;
  final String? paramId;

  // Constructor
  AttendanceParam({
    this.attendanceValue,
    this.displayOrder,
    this.defaultValue,
    this.paramName,
    this.paramValue,
    this.paramId,
  });

  // Factory method to create an instance from JSON
  factory AttendanceParam.fromJson(Map<String, dynamic> json) {
    return AttendanceParam(
      attendanceValue: json['attendancevalue'],
      displayOrder: json['display_order'],
      defaultValue: json['defaultvalue'],
      paramName: json['paramname'],
      paramValue: json['paramvalue'],
      paramId: json['paramid'],
    );
  }

  // Method to convert the model back into JSON
  Map<String, dynamic>? toJson() {
    return {
      'attendancevalue': attendanceValue,
      'display_order': displayOrder,
      'defaultvalue': defaultValue,
      'paramname': paramName,
      'paramvalue': paramValue,
      'paramid': paramId,
    };
  }
}
