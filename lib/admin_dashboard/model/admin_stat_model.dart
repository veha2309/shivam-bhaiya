class AdminStatModel {
  final String title;
  final String value;
  final String iconPath;
  final String routeName;

  AdminStatModel({
    required this.title,
    required this.value,
    required this.iconPath,
    required this.routeName,
  });

  factory AdminStatModel.fromJson(Map<String, dynamic> json) {
    return AdminStatModel(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      iconPath: json['iconPath'] ?? '',
      routeName: json['routeName'] ?? '',
    );
  }
}