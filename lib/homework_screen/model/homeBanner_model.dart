class HomebannerModel {
  final String? attachment;
  final String? subject;
  final String? message;

  HomebannerModel({
    this.attachment,
    this.subject,
    this.message,
  });

  static List<HomebannerModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => HomebannerModel.fromJson(json)).toList();
  }

  factory HomebannerModel.fromJson(Map<String, dynamic> json) {
    return HomebannerModel(
      attachment: json['attachment'],
      subject: json['subject'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachment': attachment,
      'subject': subject,
      'message': message,
    };
  }
}
