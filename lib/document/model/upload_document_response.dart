class UploadDocumentResponse {
  final String? data;

  UploadDocumentResponse({
    this.data,
  });

  factory UploadDocumentResponse.fromJson(Map<String, dynamic> json) {
    return UploadDocumentResponse(
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}
