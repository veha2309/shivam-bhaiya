class Document {
  final String? uploadedBy;
  final String? creationDate;
  final String? attachment;
  final String? classCode;
  final String? sectionCode;
  final String? createdById;
  final String? id;
  final String? sessionCode;
  final String? remarks;
  final String? uploadDate;
  final String? documentType;

  Document({
    this.uploadedBy,
    this.creationDate,
    this.attachment,
    this.classCode,
    this.sectionCode,
    this.createdById,
    this.id,
    this.sessionCode,
    this.remarks,
    this.uploadDate,
    this.documentType,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      uploadedBy: json['uploaded_by'] ?? '',
      creationDate: json['creationdate'] ?? '',
      attachment: json['attachment'] ?? '',
      classCode: json['classcode'] ?? '',
      sectionCode: json['sectioncode'] ?? '',
      createdById: json['createdby_id'] ?? '',
      id: json['id'] ?? '',
      sessionCode: json['sessioncode'] ?? '',
      remarks: json['remarks'] ?? '',
      uploadDate: json['upload_date'] ?? '',
      documentType: json['document_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uploaded_by": uploadedBy,
      "creationdate": creationDate,
      "attachment": attachment,
      "classcode": classCode,
      "sectioncode": sectionCode,
      "createdby_id": createdById,
      "id": id,
      "sessioncode": sessionCode,
      "remarks": remarks,
      "upload_date": uploadDate,
      "document_type": documentType,
    };
  }
}
