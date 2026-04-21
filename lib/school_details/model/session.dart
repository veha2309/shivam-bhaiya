final class Session {
  final String sessionName;
  final String sessionCode;

  Session({
    required this.sessionName,
    required this.sessionCode,
  });

  // Factory method to create an instance from JSON
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionName: Session.formatSession(json['sessionname']),
      sessionCode: json['sessioncode'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionname': sessionName,
      'sessioncode': sessionCode,
    };
  }

  static String formatSession(String session) {
    List<String> parts = session.split('-');
    if (parts.length == 2) {
      String first = parts[0];
      String second = parts[1].substring(2);
      return '$first-$second';
    }
    return session;
  }
}
