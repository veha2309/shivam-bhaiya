class CircularModel {
  final String? fileName;
  final DateTime? noticeFromDate;
  final String? attachments;
  final String? isPinned;
  final String? reader;
  final String? isRead;
  final String? noticeType;
  final String? message;
  final String? creationDate;
  final String? noticeId;
  final DateTime? noticeToDate;
  final String? createdBy;
  final String? remarks;

  CircularModel({
    this.fileName,
    this.noticeFromDate,
    this.attachments,
    this.isPinned,
    this.reader,
    this.isRead,
    this.noticeType,
    this.message,
    this.creationDate,
    this.noticeId,
    this.noticeToDate,
    this.createdBy,
    this.remarks,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) {
    return CircularModel(
      fileName: json['fileName'],
      noticeFromDate: json['noticeFromDate'] != null
          ? _parseDate(json['noticeFromDate'])
          : null,
      attachments: json['attachments'],
      isPinned: json['isPinned'],
      reader: json['reader'],
      isRead: json['isRead'],
      noticeType: json['noticeType'],
      message: json['message'],
      creationDate: json['creationDate'],
      noticeId: json['noticeId'],
      noticeToDate: json['noticeToDate'] != null
          ? _parseDate(json['noticeToDate'])
          : null,
      createdBy: json['createdBy'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'noticeFromDate':
          noticeFromDate != null ? _formatDate(noticeFromDate!) : null,
      'attachments': attachments,
      'isPinned': isPinned,
      'reader': reader,
      'isRead': isRead,
      'noticeType': noticeType,
      'message': message,
      'creationDate': creationDate,
      'noticeId': noticeId,
      'noticeToDate': noticeToDate != null ? _formatDate(noticeToDate!) : null,
      'createdBy': createdBy,
      'remarks': remarks,
    };
  }

  static DateTime _parseDate(String dateStr) {
    return DateTime.parse(dateStr.split('-').reversed.join());
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}
