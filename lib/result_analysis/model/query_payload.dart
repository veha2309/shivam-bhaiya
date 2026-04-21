import 'dart:convert';

class QueryPayload {
  final String? fieldIds;
  final String? queryPart;
  final Map<String, String>? parameters;

  QueryPayload({
    this.fieldIds,
    this.queryPart,
    this.parameters,
  });

  // Convert to JSON String
  String toJsonString() {
    final Map<String, dynamic> data = toJson();
    return jsonEncode(data);
  }

  // Convert to Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'fieldIds': fieldIds,
      'queryPart': queryPart,
      if (parameters != null)
        ...parameters!, // Merging parameters dynamically if not null
    };
  }
}
