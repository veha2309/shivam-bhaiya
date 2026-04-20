import 'dart:convert';

import 'package:flutter/material.dart';

class DisciplineData {
  final String? remedial;
  final String? remarks;
  final List<SuperCategory>? superCategories;
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController remedialController = TextEditingController();

  DisciplineData(
      {required this.superCategories,
      required this.remarks,
      required this.remedial});

  factory DisciplineData.fromJson(Map<String, dynamic> jsonMap) {
    final List<dynamic>? data = json.decode(jsonMap['disciplineData']) ?? [];

    var disciplineData = DisciplineData(
      remarks: jsonMap['remarks'],
      remedial: jsonMap['remedial'],
      superCategories:
          data?.map((item) => SuperCategory.fromJson(item)).toList(),
    );
    disciplineData.remarksController.text = jsonMap['remarks'] ?? "";
    disciplineData.remedialController.text = jsonMap['remedial'] ?? "";
    return disciplineData;
  }

  // Add copy method
  DisciplineData copy() {
    var newData = DisciplineData(
      remarks: remarks,
      remedial: remedial,
      superCategories: superCategories
          ?.map((superCategory) => SuperCategory(
                superCategoryCode: superCategory.superCategoryCode,
                superCategory: superCategory.superCategory,
                categories: superCategory.categories
                    ?.map((category) => Category(
                          categoryCode: category.categoryCode,
                          category: category.category,
                          marks: category.marks,
                          status: category.status,
                          isSelected: category.isSelected,
                        ))
                    .toList(),
              ))
          .toList(),
    );

    newData.remarksController.text = remarksController.text;
    newData.remedialController.text = remedialController.text;

    return newData;
  }
}

class SuperCategory {
  final String? superCategoryCode;
  final String? superCategory;
  final List<Category>? categories;

  SuperCategory({
    required this.superCategoryCode,
    required this.superCategory,
    required this.categories,
  });

  factory SuperCategory.fromJson(Map<String, dynamic> json) {
    return SuperCategory(
      superCategoryCode: json['SUPERCATEGORYCODE'],
      superCategory: json['SUPERCATEGORY'],
      categories: (json['DATA'] as List?)
          ?.map((item) => Category.fromJson(item))
          .toList(),
    );
  }
}

class Category {
  final String? categoryCode;
  final String? category;
  final int? marks;
  final String? status;
  bool isSelected;

  Category({
    required this.categoryCode,
    required this.category,
    required this.marks,
    required this.status,
    this.isSelected = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    int mark = 0;
    try {
      mark = int.parse(json['MARKS'] ?? 0);
    } catch (_) {}
    return Category(
      categoryCode: json['CATEGORYCODE'],
      category: json['CATEGORY'],
      marks: mark,
      status: json['STATUS'],
      isSelected: (json['STATUS'] ?? "").toUpperCase() == "MARKED",
    );
  }
}
