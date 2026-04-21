class DisciplineTransactionModel {
  final String? reason;
  final String? entryDate;
  final String? actionTaken;
  final String? balance;
  final String? penaltyCard;
  final String? zone;
  final String? name;
  final String? debit;
  final String? credit;
  final String? transactionClass;

  DisciplineTransactionModel({
    this.reason,
    this.entryDate,
    this.actionTaken,
    this.balance,
    this.penaltyCard,
    this.zone,
    this.name,
    this.debit,
    this.credit,
    this.transactionClass,
  });

  // Factory method to create an instance from a JSON map
  factory DisciplineTransactionModel.fromJson(Map<String, dynamic> json) {
    return DisciplineTransactionModel(
      reason: json['reason'],
      entryDate: json['entrydate'],
      actionTaken: json['actiontaken'],
      balance: json['balance'],
      penaltyCard: json['penaltycard'],
      zone: json['zone'],
      name: json['name'],
      debit: json['debit'],
      credit: json['credit'],
      transactionClass: json['class'],
    );
  }

  // Convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'entrydate': entryDate,
      'actiontaken': actionTaken,
      'balance': balance,
      'penaltycard': penaltyCard,
      'zone': zone,
      'name': name,
      'debit': debit,
      'credit': credit,
      'class': transactionClass,
    };
  }
}
