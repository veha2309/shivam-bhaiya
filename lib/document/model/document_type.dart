class DocumentType {
  final String? docTypeName;
  final String? docTypeCode;

  DocumentType({
    required this.docTypeName,
    required this.docTypeCode,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      docTypeName: json['doc_type_name'] as String,
      docTypeCode: json['doc_type_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doc_type_name': docTypeName,
      'doc_type_code': docTypeCode,
    };
  }

  static List<DocumentType> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DocumentType.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(
      List<DocumentType> documentTypes) {
    return documentTypes.map((type) => type.toJson()).toList();
  }
}
