class EventResponse {
  List<MonthEvent>? months;

  EventResponse({this.months});

  factory EventResponse.fromMap(List<dynamic> json) => EventResponse(
        months: json.map((x) => MonthEvent.fromMap(x)).toList(),
      );

  List<dynamic>? toMap() => months?.map((x) => x.toMap()).toList();
}

class MonthEvent {
  String? monthName;
  List<EventDetail>? eventDetails;
  List<List<DateDetail>>? dates;
  bool? selected;

  MonthEvent({
    this.monthName,
    this.eventDetails,
    this.dates,
    this.selected,
  });

  factory MonthEvent.fromMap(Map<String, dynamic> json) => MonthEvent(
        monthName: json["monthName"],
        eventDetails: json["eventDetails"] != null
            ? List<EventDetail>.from(
                json["eventDetails"].map((x) => EventDetail.fromMap(x)))
            : null,
        dates: json["Dates"] != null
            ? List<List<DateDetail>>.from(json["Dates"].map((x) =>
                List<DateDetail>.from(x.map((y) => DateDetail.fromMap(y)))))
            : null,
        selected: json["selected"] == "true",
      );

  Map<String, dynamic> toMap() => {
        "monthName": monthName,
        "eventDetails": eventDetails != null
            ? List<dynamic>.from(eventDetails!.map((x) => x.toMap()))
            : null,
        "Dates": dates != null
            ? List<dynamic>.from(
                dates!.map((x) => List<dynamic>.from(x.map((y) => y.toMap()))))
            : null,
        "selected": selected.toString(),
      };
}

class EventDetail {
  String? fromDate;
  String? toDate;
  String? eventName;
  String? description;
  String? eventFor;

  EventDetail({
    this.fromDate,
    this.toDate,
    this.eventName,
    this.description,
    this.eventFor,
  });

  factory EventDetail.fromMap(Map<String, dynamic> json) => EventDetail(
        fromDate: json["fromDate"],
        toDate: json["toDate"],
        eventName: json["eventName"],
        description: json["description"],
        eventFor: json["eventFor"],
      );

  Map<String, dynamic> toMap() => {
        "fromDate": fromDate,
        "toDate": toDate,
        "eventName": eventName,
        "description": description,
        "eventFor": eventFor,
      };
}

class DateDetail {
  String? date;

  DateDetail({this.date});

  factory DateDetail.fromMap(Map<String, dynamic> json) => DateDetail(
        date: json["Date"],
      );

  Map<String, dynamic> toMap() => {
        "Date": date,
      };
}
