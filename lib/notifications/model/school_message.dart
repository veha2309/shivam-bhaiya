class NotificationModel {
  final String? attachmentPath;
  final String? messageText;
  final String? messageDate;
  final String? messageId;
  final String? messageHead;
  final String? seqId;
  String? status;

  NotificationModel({
    this.attachmentPath,
    this.messageText,
    this.messageDate,
    this.messageId,
    this.messageHead,
    this.seqId,
    this.status,
  });

  // Convert JSON to Model Object
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      attachmentPath: json["attachment_path"],
      messageText: json["message_text"],
      messageDate: json["message_date"],
      messageId: json["message_id"],
      messageHead: json["message_head"],
      seqId: json["seq_id"],
      status: json["status"],
    );
  }

  // Convert Model Object to JSON
  Map<String, dynamic> toJson() {
    return {
      "attachment_path": attachmentPath,
      "message_text": messageText,
      "message_date": messageDate,
      "messageid": messageId,
      "message_head": messageHead,
      "seq_id": seqId,
      "status": status,
    };
  }

  // Convert JSON List to Model List
  static List<NotificationModel> fromJsonList(dynamic json) {
    return json
        .map<NotificationModel>((e) => NotificationModel.fromJson(e))
        .toList();
  }
}
