class AcademicConcernCategoryModel {
  final int? categoryCode;
  final String? categoryName;
  final List<AcademicConcernSubCategoryModel>? subCategoryDetail;

  AcademicConcernCategoryModel({
    this.categoryCode,
    this.categoryName,
    this.subCategoryDetail,
  });

  factory AcademicConcernCategoryModel.fromJson(Map<String, dynamic> json) {
    return AcademicConcernCategoryModel(
      categoryCode: json['CategoryCode'],
      categoryName: json['CategoryName'],
      subCategoryDetail: json['SubCategoryDetail'] != null
          ? List<AcademicConcernSubCategoryModel>.from(
              json['SubCategoryDetail'].map(
                  (item) => AcademicConcernSubCategoryModel.fromJson(item)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CategoryCode': categoryCode,
      'CategoryName': categoryName,
      'SubCategoryDetail': subCategoryDetail?.map((e) => e.toJson()).toList(),
    };
  }

  AcademicConcernCategoryModel copy() {
    return AcademicConcernCategoryModel(
      categoryName: categoryName,
      subCategoryDetail: subCategoryDetail
          ?.map((subcat) => AcademicConcernSubCategoryModel(
                subCategoryCode: subcat.subCategoryCode,
                subCategoryName: subcat.subCategoryName,
                isSelected: subcat.isSelected,
              ))
          .toList(),
    );
  }
}

class AcademicConcernSubCategoryModel {
  final String? subCategoryCode;
  final String? subCategoryName;
  bool isSelected;

  AcademicConcernSubCategoryModel({
    this.subCategoryCode,
    this.subCategoryName,
    this.isSelected = false,
  });

  factory AcademicConcernSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return AcademicConcernSubCategoryModel(
      subCategoryCode: json['subCategoryCode'],
      subCategoryName: json['subCategoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategoryCode': subCategoryCode,
      'subCategoryName': subCategoryName,
    };
  }
}
