class AcademicConcernResponse {
  final String? status;

  AcademicConcernResponse({
    required this.status,
  });

  factory AcademicConcernResponse.fromJson(Map<String, dynamic> json) {
    return AcademicConcernResponse(
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
