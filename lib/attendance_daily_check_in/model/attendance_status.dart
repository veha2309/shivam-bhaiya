// class AttendanceStatus {
//   final String? statusCode;
//   final String? attendanceValue;
//   final String? status;

//   AttendanceStatus({
//     this.statusCode,
//     this.attendanceValue,
//     this.status,
//   });

//   // Factory constructor to create an instance from JSON
//   factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
//     return AttendanceStatus(
//       statusCode: json['statuscode'] as String?,
//       attendanceValue: json['attendancevalue'] as String?,
//       status: json['status'] as String?,
//     );
//   }

//   // Convert an instance to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'statuscode': statusCode,
//       'attendancevalue': attendanceValue,
//       'status': status,
//     };
//   }

//   // Convert a list of JSON objects to a list of AttendanceStatus instances
//   static List<AttendanceStatus> listFromJson(List<dynamic> jsonList) {
//     return jsonList.map((json) => AttendanceStatus.fromJson(json)).toList();
//   }

//   // Convert a list of AttendanceStatus instances to a list of JSON objects
//   static List<Map<String, dynamic>> listToJson(List<AttendanceStatus> list) {
//     return list.map((item) => item.toJson()).toList();
//   }
// }
