class UploadDocumentPreSignResponse {
  final String? bucketName;
  final String? fileName;
  final String? presignUrl;

  UploadDocumentPreSignResponse({
    this.bucketName,
    this.fileName,
    this.presignUrl,
  });

  factory UploadDocumentPreSignResponse.fromJson(Map<String, dynamic> json) {
    return UploadDocumentPreSignResponse(
      bucketName: json['bucketName'] as String?,
      fileName: json['fileName'] as String?,
      presignUrl: json['presignUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bucketName': bucketName,
      'fileName': fileName,
      'presignUrl': presignUrl,
    };
  }
}
