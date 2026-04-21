class Section {
  final String sectionName;
  final String sectionCode;

  Section({
    required this.sectionName,
    required this.sectionCode,
  });

  // Factory method to create an instance from JSON
  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionName: json['sectionName'],
      sectionCode: json['sectionCode'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'sectionName': sectionName,
      'sectionCode': sectionCode,
    };
  }

  // Static method to parse a list of sections from JSON
  static List<Section> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Section.fromJson(json)).toList();
  }
}
