class CompleteTeacherTimetable {
  final List<TotalData>? total;
  final List<TimeTable>? timeTable;

  CompleteTeacherTimetable({this.total, this.timeTable});

  factory CompleteTeacherTimetable.fromJson(dynamic json) =>
      CompleteTeacherTimetable.fromMap(json);

  factory CompleteTeacherTimetable.fromMap(Map<String, dynamic> json) =>
      CompleteTeacherTimetable(
        total:
            (json["total"] as List?)?.map((x) => TotalData.fromMap(x)).toList(),
        timeTable: (json["timeTable"] as List?)
            ?.map((x) => TimeTable.fromMap(x))
            .toList(),
      );

  Map<String, dynamic>? toMap() => {
        "total": total?.map((x) => x.toMap()).toList(),
        "timeTable": timeTable?.map((x) => x.toMap()).toList(),
      };
}

class TotalData {
  final int? monday;
  final int? tuesday;
  final int? wednesday;
  final int? thursday;
  final int? friday;
  final int? saturday;
  final int? total;

  TotalData({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.total,
  });

  factory TotalData.fromMap(Map<String, dynamic> json) => TotalData(
        monday: int.tryParse(json["monday"] ?? "0"),
        tuesday: int.tryParse(json["tuesday"] ?? "0"),
        wednesday: int.tryParse(json["wednesday"] ?? "0"),
        thursday: int.tryParse(json["thrusday"] ?? "0"),
        friday: int.tryParse(json["friday"] ?? "0"),
        saturday: int.tryParse(json['saturday'] ?? "0"),
        total: int.tryParse(json["Total"] ?? "0"),
      );

  Map<String, dynamic>? toMap() => {
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thrusday": thursday,
        "friday": friday,
        "Total": total,
      };
}

class TimeTable {
  final String? teacherName;
  final String? teacherCode;
  final int? monday;
  final int? tuesday;
  final int? wednesday;
  final int? thursday;
  final int? friday;
  final int? saturday;
  final int? total;

  TimeTable({
    this.teacherName,
    this.teacherCode,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.total,
  });

  factory TimeTable.fromMap(Map<String, dynamic> json) => TimeTable(
        teacherName: json["teacherName"],
        teacherCode: json["teacherCode"],
        monday: int.tryParse(json["monday"] ?? "0"),
        tuesday: int.tryParse(json["tuesday"] ?? "0"),
        wednesday: int.tryParse(json["wednesday"] ?? "0"),
        thursday: int.tryParse(json["thrusday"] ?? "0"),
        friday: int.tryParse(json["friday"] ?? "0"),
        saturday: int.tryParse(json['saturday'] ?? "0"),
        total: int.tryParse(json["total"] ?? "0"),
      );

  Map<String, dynamic>? toMap() => {
        "teacherName": teacherName,
        "teacherCode": teacherCode,
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thrusday": thursday,
        "friday": friday,
        "total": total,
      };
}
