class UserProfileModel {
  final String? userImage;
  final String? classCode;
  final String? sectionCode;
  final String? className;
  final String? sectionName;

  UserProfileModel({
    required this.userImage,
    required this.classCode,
    required this.sectionCode,
    required this.className,
    required this.sectionName,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userImage: json['userImage'] ?? '',
      classCode: json['classCode'] ?? '',
      sectionCode: json['sectionCode'] ?? '',
      className: json['className'] ?? '',
      sectionName: json['sectionName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userImage': userImage,
      'classCode': classCode,
      'sectionCode': sectionCode,
      'className': className,
      'sectionName': sectionName,
    };
  }
}
