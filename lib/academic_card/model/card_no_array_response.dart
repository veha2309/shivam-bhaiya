class CardNoArrayResponse {
  final List<int>? cardNoArray;
  final List<NormArrayItem>? normArray;
  final int? nextCardNo;

  CardNoArrayResponse({
    this.cardNoArray,
    this.normArray,
    this.nextCardNo,
  });

  factory CardNoArrayResponse.fromJson(Map<String, dynamic> json) {
    return CardNoArrayResponse(
      cardNoArray:
          (json['cardNoArray'] as List?)?.map((e) => e as int).toList(),
      normArray: (json['normArray'] as List?)
          ?.map((item) => NormArrayItem.fromJson(item))
          .toList(),
      nextCardNo: json['nextCardNo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNoArray': cardNoArray,
      'normArray': normArray?.map((item) => item.toJson()).toList(),
      'nextCardNo': nextCardNo,
    };
  }
}

class NormArrayItem {
  final String? categoryCode;
  final String? norm;

  NormArrayItem({
    this.categoryCode,
    this.norm,
  });

  factory NormArrayItem.fromJson(Map<String, dynamic> json) {
    return NormArrayItem(
      categoryCode: json['categoryCode']?.toString(),
      norm: json['norm']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryCode': categoryCode,
      'norm': norm,
    };
  }
}
