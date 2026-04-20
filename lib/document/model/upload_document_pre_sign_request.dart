class UploadDocumentPreSignRequest {
  final String? affiliationcode;
  final String? studentid;
  final String? studentids;
  final String? classcode;
  final String? sectioncode;
  final String? documenttype;
  final String? subjectcode;
  final String? assignmenttype;
  final String? remark;

  UploadDocumentPreSignRequest({
    this.affiliationcode,
    this.studentid,
    this.studentids,
    this.classcode,
    this.sectioncode,
    this.documenttype,
    this.subjectcode,
    this.assignmenttype,
    this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'affiliationcode': affiliationcode,
      'studentid': studentid,
      'studentids': studentids,
      'classcode': classcode,
      'sectioncode': sectioncode,
      'documenttype': documenttype,
      'subjectcode': subjectcode,
      'assignmenttype': assignmenttype,
      'remark': remark,
    };
  }
}
