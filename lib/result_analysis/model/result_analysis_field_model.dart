class ResultAnalysisFieldModel {
  final String? jasperName;
  final String? multipleSelectDropdown;
  final String? jspName;
  final String? reportName;
  final String? parameterName;
  final String? moduleId;
  final String? parameterValue;
  final String? queryPart;
  final String? functionName;
  final String? type;
  final String? remarks;
  final String? fieldId;

  // Constructor
  ResultAnalysisFieldModel({
    this.jasperName,
    this.multipleSelectDropdown,
    this.jspName,
    this.reportName,
    this.parameterName,
    this.moduleId,
    this.parameterValue,
    this.queryPart,
    this.functionName,
    this.type,
    this.remarks,
    this.fieldId,
  });

  // Factory method to create an instance from JSON
  factory ResultAnalysisFieldModel.fromJson(Map<String, dynamic> json) {
    return ResultAnalysisFieldModel(
      jasperName: json['jasperName'],
      multipleSelectDropdown: json['multipleSelectDropdown'],
      jspName: json['jspName'],
      reportName: json['reportName'],
      parameterName: json['parameterName'],
      moduleId: json['moduleId'],
      parameterValue: json['parameterValue'],
      queryPart: json['queryPart'],
      functionName: json['functionName'],
      type: json['type'],
      remarks: json['remarks'],
      fieldId: json['fieldId'],
    );
  }

  // Method to convert the model back into JSON
  Map<String, dynamic> toJson() {
    return {
      'jasperName': jasperName,
      'multipleSelectDropdown': multipleSelectDropdown,
      'jspName': jspName,
      'reportName': reportName,
      'parameterName': parameterName,
      'moduleId': moduleId,
      'parameterValue': parameterValue,
      'queryPart': queryPart,
      'functionName': functionName,
      'type': type,
      'remarks': remarks,
      'fieldId': fieldId,
    };
  }
}
