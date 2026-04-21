class VQuickModel {
  final int? displayOrder;
  final String? title;
  final String? url;

  VQuickModel({
    this.displayOrder,
    this.title,
    this.url,
  });

  // Factory method to create an instance from a JSON map
  factory VQuickModel.fromJson(Map<String, dynamic> json) {
    return VQuickModel(
      displayOrder: int.parse(json['displayOrder'] ?? 0),
      title: json['title'],
      url: json['url'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'displayOrder': displayOrder,
      'title': title,
      'url': url,
    };
  }

  // Factory method to create a list of DocumentLink from JSON list
  static List<VQuickModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => VQuickModel.fromJson(json)).toList();
  }

  // Method to convert a list of DocumentLink to a JSON list
  static List<Map<String, dynamic>> toJsonList(List<VQuickModel> links) {
    return links.map((link) => link.toJson()).toList();
  }
}
