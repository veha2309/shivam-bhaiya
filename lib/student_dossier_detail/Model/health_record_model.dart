class HealthRecordModel {
  final String? medicalType;
  final String? sessionName;
  final String? studentName;
  final String? diagnosis;
  final String? diagnoseBy;
  final String? visitDate;
  final String? referral;

  HealthRecordModel({
    this.medicalType,
    this.sessionName,
    this.studentName,
    this.diagnosis,
    this.diagnoseBy,
    this.visitDate,
    this.referral,
  });

  // Factory method to create a MedicalVisit from JSON
  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      medicalType: json['medicalType'],
      sessionName: json['sessionName'],
      studentName: json['studentName'],
      diagnosis: json['diagnosis'],
      diagnoseBy: json['diagnoseBy'],
      visitDate: json['visitDate'],
      referral: json['refferal'],
    );
  }

  // Method to convert MedicalVisit to JSON
  Map<String, dynamic> toJson() {
    return {
      'medicalType': medicalType,
      'sessionName': sessionName,
      'studentName': studentName,
      'diagnosis': diagnosis,
      'diagnoseBy': diagnoseBy,
      'visitDate': visitDate,
      'refferal': referral,
    };
  }
}
