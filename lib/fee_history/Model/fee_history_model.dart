class FeeHistoryModel {
  final String? netPayable;
  final String? balance;
  final String? transactionNo;
  final String? monthName;
  final String? grossAmount;
  final String? paidAmount;
  final String? transactionTypename;
  final String? url;

  FeeHistoryModel({
    this.netPayable,
    this.balance,
    this.transactionNo,
    this.monthName,
    this.grossAmount,
    this.paidAmount,
    this.transactionTypename,
    this.url,
  });

  factory FeeHistoryModel.fromJson(Map<String, dynamic> json) {
    return FeeHistoryModel(
      netPayable: json['netPayable'],
      balance: json['balance'],
      transactionNo: json['transactionNo'],
      monthName: json['monthName'],
      grossAmount: json['grossAmount'],
      paidAmount: json['paidAmount'],
      transactionTypename: json['transactionTypename'],
      url: json['url'],
    );
  }

  static List<FeeHistoryModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FeeHistoryModel.fromJson(json)).toList();
  }
}
