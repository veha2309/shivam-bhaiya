class ResultAnalysisDropDownModel {
  final String? label;
  final String? value;

  // Constructor
  ResultAnalysisDropDownModel({
    this.label,
    this.value,
  });

  // Factory method to create an instance from JSON
  factory ResultAnalysisDropDownModel.fromJson(Map<String, dynamic> json) {
    return ResultAnalysisDropDownModel(
      label: json['label'] as String?,
      value: json['value'] as String?,
    );
  }

  // Convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }

  // Convert a JSON list to a list of objects
  static List<ResultAnalysisDropDownModel> fromJsonList(
      List<dynamic> jsonList) {
    return jsonList
        .map((json) => ResultAnalysisDropDownModel.fromJson(json))
        .toList();
  }

  // Convert a list of objects to a JSON list
  static List<Map<String, dynamic>> toJsonList(
      List<ResultAnalysisDropDownModel> list) {
    return list.map((item) => item.toJson()).toList();
  }
}
