class NewsData {
  List<MonthData>? months;

  NewsData({this.months});

  factory NewsData.fromJson(List<dynamic> json) {
    return NewsData(
      months: json.map((e) => MonthData.fromJson(e)).toList(),
    );
  }
}

// Model representing a month and its data
class MonthData {
  String? monthName;
  List<NewsItem>? news;
  List<List<DateItem>>? dates;
  bool? selected;

  MonthData({
    this.monthName,
    this.news,
    this.dates,
    this.selected,
  });

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      monthName: json["monthName"],
      news: (json["news"] as List<dynamic>?)
          ?.map((e) => NewsItem.fromJson(e))
          .toList(),
      dates: (json["Dates"] as List<dynamic>?)
          ?.map((dateList) => (dateList as List<dynamic>)
              .map((e) => DateItem.fromJson(e))
              .toList())
          .toList(),
      selected: json["selected"] == "true",
    );
  }

  Map<String, dynamic> toJson() => {
        "monthName": monthName,
        "news": news?.map((e) => e.toJson()).toList(),
        "Dates": dates
            ?.map((dateList) => dateList.map((e) => e.toJson()).toList())
            .toList(),
        "selected": selected.toString(),
      };
}

// Model representing a single news item
class NewsItem {
  String? fromDate;
  String? attachment;
  String? subject;
  String? reader;
  String? toDate;
  String? message;

  NewsItem({
    this.fromDate,
    this.attachment,
    this.subject,
    this.reader,
    this.toDate,
    this.message,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      fromDate: json["fromDate"],
      attachment: json["ATTACHMENT"],
      subject: json["subject"],
      reader: json["reader"],
      toDate: json["toDate"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "fromDate": fromDate,
        "ATTACHMENT": attachment,
        "subject": subject,
        "reader": reader,
        "toDate": toDate,
        "message": message,
      };
}

// Model representing a single date entry
class DateItem {
  String? date;

  DateItem({this.date});

  factory DateItem.fromJson(Map<String, dynamic> json) {
    return DateItem(date: json["Date"]);
  }

  Map<String, dynamic> toJson() => {
        "Date": date,
      };
}
