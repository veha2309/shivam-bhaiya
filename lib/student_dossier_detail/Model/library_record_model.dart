class LibraryRecordModel {
  final String? subjectName;
  final String? issuedDate;
  final String? fine;
  final String? sessionName;
  final String? bookType;
  String? rating;
  final String? expectedReturnDate;
  final String? bookName;
  final String? returnedDate;

  LibraryRecordModel({
    this.subjectName,
    this.issuedDate,
    this.fine,
    this.sessionName,
    this.bookType,
    this.rating,
    this.expectedReturnDate,
    this.bookName,
    this.returnedDate,
  });

  // Factory method to create a LibraryBook from JSON
  factory LibraryRecordModel.fromJson(Map<String, dynamic> json) {
    return LibraryRecordModel(
      subjectName: json['subjectname'],
      issuedDate: json['issuedDate'],
      fine: json['fine'],
      sessionName: json['sessionName'],
      bookType: json['booktype'],
      rating: json['rating'],
      expectedReturnDate: json['expectedReturndate'],
      bookName: json['bookName'],
      returnedDate: json['returnedDate'],
    );
  }

  // Method to convert LibraryBook to JSON
  Map<String, dynamic> toJson() {
    return {
      'subjectname': subjectName,
      'issuedDate': issuedDate,
      'fine': fine,
      'sessionName': sessionName,
      'booktype': bookType,
      'rating': rating,
      'expectedReturndate': expectedReturnDate,
      'bookName': bookName,
      'returnedDate': returnedDate,
    };
  }
}
