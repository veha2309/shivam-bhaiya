class NoticeBoardModel {
  final String? id;
  final String? subject;
  final String? message;
  final String? date;
  final String? attachmentUrl;
  final String? category;

  NoticeBoardModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.date,
    this.attachmentUrl,
    this.category,
  });

  factory NoticeBoardModel.fromJson(Map<String, dynamic> json) {
    return NoticeBoardModel(
      id: json['id'] as String?,
      subject: json['subject'] as String?,
      message: json['message'] as String?,
      date: json['date'] as String?,
      attachmentUrl: json['attachment'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': subject,
      'description': message,
      'date': date,
      'attachmentUrl': attachmentUrl,
      'category': category,
    };
  }
}
