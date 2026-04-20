class DisciplineZoneModel {
  final String? zone;
  final int? zoneCount;

  DisciplineZoneModel({required this.zone, required this.zoneCount});

  // Factory constructor to create an instance from a JSON map
  factory DisciplineZoneModel.fromJson(Map<String, dynamic> json) {
    return DisciplineZoneModel(
      zone: json['zone'],
      zoneCount: json['zonecount'],
    );
  }

  // Convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
      'zonecount': zoneCount,
    };
  }

  static List<DisciplineZoneModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DisciplineZoneModel.fromJson(json)).toList();
  }
}
