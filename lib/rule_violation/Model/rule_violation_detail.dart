class RuleViolationDetail {
  final int? cardCount;
  final String? cardCategoryName;

  RuleViolationDetail({this.cardCount, this.cardCategoryName});

  // Factory method to create an instance from JSON
  factory RuleViolationDetail.fromJson(Map<String, dynamic> json) {
    return RuleViolationDetail(
      cardCount: json['cardCount'] as int?,
      cardCategoryName: json['cardCategoryName'] as String?,
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cardCount': cardCount,
      'cardCategoryName': cardCategoryName,
    };
  }

  static List<RuleViolationDetail> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => RuleViolationDetail.fromJson(json)).toList();
  }
}
