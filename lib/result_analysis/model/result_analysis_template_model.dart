class ResultAnalysisTemplateModel {
  final String? jasperName;
  final String? reportGroup;
  final String? reportName;
  final String? showHide;

  // Constructor
  ResultAnalysisTemplateModel({
    this.jasperName,
    this.reportGroup,
    this.reportName,
    this.showHide,
  });

  // Factory method to create an instance from JSON
  factory ResultAnalysisTemplateModel.fromJson(Map<String, dynamic> json) {
    return ResultAnalysisTemplateModel(
      jasperName: json['jasperName'] as String?,
      reportGroup: json['reportGroup'] as String?,
      reportName: json['reportName'] as String?,
      showHide: json['showHide'] as String?,
    );
  }

  // Method to convert the model back into JSON
  Map<String, dynamic> toJson() {
    return {
      'jasperName': jasperName,
      'reportGroup': reportGroup,
      'reportName': reportName,
      'showHide': showHide,
    };
  }
}
