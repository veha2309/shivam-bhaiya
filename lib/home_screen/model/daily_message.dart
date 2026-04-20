class DailyMessage {
  final String? messageDate;
  final String? message;

  DailyMessage({
    this.messageDate,
    this.message,
  });

  factory DailyMessage.fromJson(Map<String, dynamic> json) {
    return DailyMessage(
      messageDate: json['messageDate'] as String?,
      message: json['message'] as String?,
    );
  }
}
