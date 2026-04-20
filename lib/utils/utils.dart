import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/main.dart';
import 'package:school_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

// utils/navigation_helper.dart

Future<void> navigateToScreen(BuildContext context, Widget screen,
    {bool replace = false}) async {
  if (replace) {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  } else {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

void showSnackBarOnScreen(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      textScaler: const TextScaler.linear(1.0),
      style: const TextStyle(
          color: ColorConstant.onPrimary, fontFamily: fontFamily),
    ),
    backgroundColor: Colors.black87,
  );
  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}

Size getSizeOfScreen(BuildContext context) {
  return MediaQuery.of(context).size;
}

double getWidthOfScreen(BuildContext context) {
  return getSizeOfScreen(context).width;
}

double getHeightOfScreen(BuildContext context) {
  return getSizeOfScreen(context).height;
}

String monthIntToString(int month) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  return months[month - 1];
}

String getMonthIntToStringShort(int month) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return months[month - 1];
}

String threeAlphaDayToFull(String day) {
  const days = {
    "Sun": "Sunday",
    "Mon": "Monday",
    "Tue": "Tuesday",
    "Wed": "Wednesday",
    "Thu": "Thursday",
    "Fri": "Friday",
    "Sat": "Saturday"
  };
  return days[day] ?? "Invalid day";
}

String getDateInDDMMMYYYY(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}-${getMonthIntToStringShort(date.month).toUpperCase()}-${date.year}";
}

String getDDMMYYYYInNum(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
}

DateTime formatAnyDateIntoDateTime(String inputDate) {
// First, try to normalize the input by converting month abbreviations to proper case
  String normalizedInput = inputDate;

  // Handle lowercase month abbreviations like "mar" -> "Mar"
  final monthAbbreviations = {
    'jan': 'Jan',
    'feb': 'Feb',
    'mar': 'Mar',
    'apr': 'Apr',
    'may': 'May',
    'jun': 'Jun',
    'jul': 'Jul',
    'aug': 'Aug',
    'sep': 'Sep',
    'oct': 'Oct',
    'nov': 'Nov',
    'dec': 'Dec',
    // Add uppercase month abbreviations for normalization
    'JAN': 'Jan',
    'FEB': 'Feb',
    'MAR': 'Mar',
    'APR': 'Apr',
    'MAY': 'May',
    'JUN': 'Jun',
    'JUL': 'Jul',
    'AUG': 'Aug',
    'SEP': 'Sep',
    'OCT': 'Oct',
    'NOV': 'Nov',
    'DEC': 'Dec',
  };

  for (var entry in monthAbbreviations.entries) {
    normalizedInput = normalizedInput.replaceAll(entry.key, entry.value);
  }

  List<String> possibleFormats = [
    "dd-MM-yyyy",
    "dd/MM/yyyy",
    "MM-dd-yyyy",
    "MM/dd/yyyy",
    "yyyy-MM-dd",
    "yyyy/MM/dd",
    "yyyy.MM.dd",
    "dd.MM.yyyy",
    "d-M-yyyy",
    "d/M/yyyy",
    "M-d-yyyy",
    "M/d/yyyy",
    "dd MMM yyyy",
    "d MMM yyyy",
    "dd MMMM yyyy",
    "d MMMM yyyy",
    "MMM dd, yyyy",
    "MMMM dd, yyyy",
    "yyyyMMdd",
    "ddMMyyyy",
    "d-MMM-yy",
    "d MMM yy",
    "MMM d, yyyy",
    "MMMM d, yyyy",
    // Add format for dd-MMM-yyyy (e.g., 27-JUN-2025 -> 27-Jun-2025)
    "dd-MMM-yyyy",

    // Date + Time (24hr format)
    "dd-MM-yyyy HH:mm",
    "dd/MM/yyyy HH:mm",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy/MM/dd HH:mm:ss",
    "yyyy.MM.dd HH:mm:ss",
    "dd.MM.yyyy HH:mm:ss",
    "yyyy-MM-dd HH:mm",
    "dd MMM yyyy HH:mm",
    "dd MMMM yyyy HH:mm",

    // Date + Time (12hr format with AM/PM)
    "dd-MM-yyyy hh:mm a",
    "dd/MM/yyyy hh:mm a",
    "yyyy-MM-dd hh:mm:ss a",
    "dd MMM yyyy hh:mm a",
    "dd MMMM yyyy hh:mm a",
    "MMM d, yyyy hh:mm a",
    "MMMM d, yyyy hh:mm a",
  ];

  for (String format in possibleFormats) {
    try {
      return DateFormat(format).parseStrict(normalizedInput);
    } catch (_) {
      // try next format
    }
  }

  throw Exception("Invalid Format");
}

String formatAnyDateToDDMMYY(String inputDate, {String? ourputFormat}) {
  // First, try to normalize the input by converting month abbreviations to proper case
  String normalizedInput = inputDate;

  // Handle lowercase month abbreviations like "mar" -> "Mar"
  final monthAbbreviations = {
    'jan': 'Jan',
    'feb': 'Feb',
    'mar': 'Mar',
    'apr': 'Apr',
    'may': 'May',
    'jun': 'Jun',
    'jul': 'Jul',
    'aug': 'Aug',
    'sep': 'Sep',
    'oct': 'Oct',
    'nov': 'Nov',
    'dec': 'Dec',
    // Add uppercase month abbreviations for normalization
    'JAN': 'Jan',
    'FEB': 'Feb',
    'MAR': 'Mar',
    'APR': 'Apr',
    'MAY': 'May',
    'JUN': 'Jun',
    'JUL': 'Jul',
    'AUG': 'Aug',
    'SEP': 'Sep',
    'OCT': 'Oct',
    'NOV': 'Nov',
    'DEC': 'Dec',
  };

  for (var entry in monthAbbreviations.entries) {
    normalizedInput = normalizedInput.replaceAll(entry.key, entry.value);
  }

  List<String> possibleFormats = [
    "dd-MM-yyyy",
    "dd/MM/yyyy",
    "MM-dd-yyyy",
    "MM/dd/yyyy",
    "yyyy-MM-dd",
    "yyyy/MM/dd",
    "yyyy.MM.dd",
    "dd.MM.yyyy",
    "d-M-yyyy",
    "d/M/yyyy",
    "M-d-yyyy",
    "M/d/yyyy",
    "dd MMM yyyy",
    "d MMM yyyy",
    "dd MMMM yyyy",
    "d MMMM yyyy",
    "MMM dd, yyyy",
    "MMMM dd, yyyy",
    "yyyyMMdd",
    "ddMMyyyy",
    "d-MMM-yy",
    "d MMM yy",
    "MMM d, yyyy",
    "MMMM d, yyyy",
    // Add format for dd-MMM-yyyy (e.g., 27-JUN-2025 -> 27-Jun-2025)
    "dd-MMM-yyyy",

    // Date + Time (24hr format)
    "dd-MM-yyyy HH:mm",
    "dd/MM/yyyy HH:mm",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy/MM/dd HH:mm:ss",
    "yyyy.MM.dd HH:mm:ss",
    "dd.MM.yyyy HH:mm:ss",
    "yyyy-MM-dd HH:mm",
    "dd MMM yyyy HH:mm",
    "dd MMMM yyyy HH:mm",

    // Date + Time (12hr format with AM/PM)
    "dd-MM-yyyy hh:mm a",
    "dd/MM/yyyy hh:mm a",
    "yyyy-MM-dd hh:mm:ss a",
    "dd MMM yyyy hh:mm a",
    "dd MMMM yyyy hh:mm a",
    "MMM d, yyyy hh:mm a",
    "MMMM d, yyyy hh:mm a",
  ];

  for (String format in possibleFormats) {
    try {
      DateTime date = DateFormat(format).parseStrict(normalizedInput);
      return DateFormat(ourputFormat ?? 'dd/MM/yy').format(date);
    } catch (_) {
      // try next format
    }
  }

  return "Invalid date format";
}

String intToWeekDay(int day) {
  const weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];
  return weekDays[day % 7];
}

String intToDayFull(int day) {
  const weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  return weekDays[day % 7];
}

const months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

String intToMonthFull(int month) {
  return months[month - 1];
}

const monthsMMM = [
  "APR",
  "MAY",
  "JUN",
  "JUL",
  "AUG",
  "SEP",
  "OCT",
  "NOV",
  "DEC",
  "JAN",
  "FEB",
  "MAR",
];

String intToMonthShort(int month) {
  return monthsMMM[month - 1];
}

String monthToInt(String month) {
  const months = {
    "JAN": "01",
    "FEB": "02",
    "MAR": "03",
    "APR": "04",
    "MAY": "05",
    "JUN": "06",
    "JUL": "07",
    "AUG": "08",
    "SEP": "09",
    "OCT": "10",
    "NOV": "11",
    "DEC": "12"
  };
  return months[month.toUpperCase()] ?? "";
}

void launchURLString(String url) async {
  if (url.isNotEmpty) {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

Future<void> sendEmail(
    BuildContext context, String email, String subject, String body) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: encodeQueryParameters({
      'subject': subject,
      'body': body,
    }),
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No email app found on this device.')),
    );
  }
}

Future<void> sendMessage(String phoneNumber) async {
  final Uri smsUri = Uri.parse("sms:$phoneNumber?body=Hey");

  if (await canLaunchUrl(smsUri)) {
    await launchUrl(smsUri);
  } else {
    throw 'Could not launch $smsUri';
  }
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneUri';
  }
}

void popScreen(BuildContext context) async {
  Navigator.of(context).pop();
}

Future<bool> shouldShowPopup() async {
  // if (AuthViewModel.instance.getLoggedInUser()?.userType == "Teacher") {
  //   return false;
  // }
  final user = AuthViewModel.instance.getLoggedInUser();
  final prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  DateTime todayAt5AM = DateTime(now.year, now.month, now.day, 5);

  String today = now.toString().split(' ')[0];
  String? lastShownDate =
      prefs.getString('${user?.username}_popup_last_shown_date');

  if (now.isAfter(todayAt5AM) &&
      (lastShownDate == null || lastShownDate != today)) {
    await prefs.setString('${user?.username}_popup_last_shown_date', today);
    return true;
  }
  return false;
}

String getOrdinalNumber(int number) {
  if (number >= 11 && number <= 13) {
    return '${number}th';
  }
  switch (number % 10) {
    case 1:
      return '${number}st';
    case 2:
      return '${number}nd';
    case 3:
      return '${number}rd';
    default:
      return '${number}th';
  }
}

String getFormattedTodayDate() {
  final now = DateTime.now();
  final dayOfWeek = intToWeekDay(now.weekday);
  final month = getMonthIntToStringShort(now.month);
  return '$dayOfWeek, ${now.day} $month';
}

/// Opens date picker and returns the selected date in YYYY-MM-DD format
Future<String?> openDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2100),
  );

  if (pickedDate != null) {
    // Format date as YYYY-MM-DD
    return "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
  }
  return null;
}

/// Shows a bottom sheet for selecting school branch and returns the affiliation code.
Future<String?> showBranchSelectionBottomSheet(BuildContext context) async {
  return await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select School Branch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Anand Vihar'),
              onTap: () =>
                  Navigator.pop(context, AfficialationCodeConstants.anandVihar),
            ),
            ListTile(
              title: const Text('Preet Vihar'),
              onTap: () =>
                  Navigator.pop(context, AfficialationCodeConstants.preetVihar),
            ),
          ],
        ),
      );
    },
  );
}
