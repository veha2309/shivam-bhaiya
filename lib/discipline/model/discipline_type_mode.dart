class DisciplineTypeModel {
  final String? categoryCode;
  final String? categoryName;
  final List<SubCategoryDetail>? subCategoryDetail;

  DisciplineTypeModel({
    required this.categoryCode,
    required this.categoryName,
    required this.subCategoryDetail,
  });

  // Factory constructor to create an instance from JSON
  factory DisciplineTypeModel.fromJson(Map<String, dynamic> json) {
    return DisciplineTypeModel(
      categoryCode: json['CategoryCode'],
      categoryName: json['CategoryName'],
      subCategoryDetail: (json['SubCategoryDetail'] as List?)
          ?.map((item) => SubCategoryDetail.fromJson(item))
          .toList(),
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'CategoryCode': categoryCode,
      'CategoryName': categoryName,
      'SubCategoryDetail':
          subCategoryDetail?.map((item) => item.toJson()).toList(),
    };
  }
}

class SubCategoryDetail {
  final String subCategoryCode;
  final String subCategoryName;
  bool isSelected;

  SubCategoryDetail({
    required this.subCategoryCode,
    required this.subCategoryName,
    this.isSelected = false,
  });

  // Factory constructor to create an instance from JSON
  factory SubCategoryDetail.fromJson(Map<String, dynamic> json) {
    return SubCategoryDetail(
      subCategoryCode: json['subCategoryCode'],
      subCategoryName: json['subCategoryName'],
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'subCategoryCode': subCategoryCode,
      'subCategoryName': subCategoryName,
    };
  }
}
