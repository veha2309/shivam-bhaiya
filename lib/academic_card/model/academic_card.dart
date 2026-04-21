class AcademicCard {
  final String? displayOrder;
  final String? categoryCode;
  final String? categoryName;
  bool isSelected;

  AcademicCard({
    this.displayOrder,
    this.categoryCode,
    this.categoryName,
    this.isSelected = false,
  });

  factory AcademicCard.fromJson(Map<String, dynamic> json) {
    return AcademicCard(
      displayOrder: json['displayOrder']?.toString(),
      categoryCode: json['categoryCode']?.toString(),
      categoryName: json['categoryName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayOrder': displayOrder,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
    };
  }

  AcademicCard copy() {
    return AcademicCard(
      displayOrder: displayOrder,
      categoryCode: categoryCode,
      categoryName: categoryName,
      isSelected: isSelected,
    );
  }
}
