import 'package:flutter/material.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/academic_concerns/view/academic_concerns_screen.dart';
import 'package:school_app/awards_recognitions/view/awards_recognitions_screen.dart';
import 'package:school_app/circular/View/circular_screen.dart';
import 'package:school_app/curriculum_screen/view/curriculum_screen.dart';
import 'package:school_app/discipline/view/raise_discipline_search_screen.dart';
import 'package:school_app/discipline_passbook/view/discipline_passbook_screen.dart';
import 'package:school_app/document/view/upload_document_screen.dart';
import 'package:school_app/document/view/view_document_screen.dart';
import 'package:school_app/examination_schedule/view/examination_schedule_screen.dart';
import 'package:school_app/fee_history/View/fee_history_screen.dart';
import 'package:school_app/fee_ledger/View/fee_ledger_screen.dart';
import 'package:school_app/fee_payment/view/fee_payment_screen.dart';
import 'package:school_app/home_subsection/View/home_subsection_screen.dart';
import 'package:school_app/homework_screen/view/add_homework_screen.dart';
import 'package:school_app/homework_screen/view/homework_screen.dart';
import 'package:school_app/my_discipline_passbook/view/student_discipline_passbook_screen.dart';
import 'package:school_app/my_discipline_passbook/view/student_rule_violation_record_screen.dart';
import 'package:school_app/news_events/View/news_event_screen.dart';
import 'package:school_app/report_card/View/report_card_screen.dart';
import 'package:school_app/school_calendar/view/school_calendar_screen.dart';
import 'package:school_app/school_planner/view/school_planner_screen.dart';
import 'package:school_app/search_student_profile/View/search_student_profile_screen.dart';
import 'package:school_app/student_dossier/View/student_dossier_search_screen.dart';
import 'package:school_app/student_time_table/View/student_time_table_screen.dart';
import 'package:school_app/teacher_time_table/View/teacher_time_table_screen.dart';
import 'package:school_app/timetable_details/View/timetable_details_screen.dart';
import 'package:school_app/transport_tracker_screen/view/transport_tracker_screen.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/components/generic_webview_screen.dart';
import 'package:school_app/vquick/view/vquick_screen.dart';
import 'package:school_app/word_of_the_day/view/word_of_the_day_screen.dart';

enum Menu {
  attendance(
    "12",
    "Attendance",
    IconConstants.schoolCalendar,
    HomeSubsectionScreen(
      currentScreen: ScreenType.attandance,
    ),
    position: -1,
  ),
  disciplinePassbook(
    "14",
    "Discipline Passbook",
    IconConstants.disciplinePassbook,
    DisciplinePassbookScreen(
      title: "Discipline Passbook",
    ),
    position: 7,
  ),
  studentDisciplinePassbook(
    "808",
    "Discipline Passbook",
    IconConstants.disciplinePassbook,
    StudentDisciplinePassbookScreen(),
    position: 5,
  ),
  resultAnalysis(
    "16",
    "Result Analysis",
    IconConstants.resultAnalysis,
    HomeSubsectionScreen(
      currentScreen: ScreenType.resultAnalysis,
    ),
    position: 13,
  ),
  rulesViolationRecord(
    "15",
    "Rules Violation Record",
    IconConstants.rulesViolationRecord,
    HomeSubsectionScreen(
      currentScreen: ScreenType.ruleViolation,
    ),
    position: 4,
  ),
  studentDiscipline(
    "21",
    "Student Discipline",
    IconConstants.studentDiscipline,
    RaiseDisciplineSearchScreen(),
  ),
  studentDossier(
    "20",
    "Student Dossier",
    IconConstants.studentDossier,
    StudentDossierSearchScreen(),
    position: 11,
  ),
  studentsDetails("13", "Student's Details", IconConstants.studentDossier,
      SearchStudentProfileScreen(),
      position: 0),
  uploadDocuments(
    "19",
    "Upload Documents",
    IconConstants.uploadDocuments,
    UploadDocumentScreen(),
    position: 8,
  ),
  viewDocuments(
    "64",
    "View Documents",
    IconConstants.viewDocuments,
    ViewDocumentScreen(),
    position: 2,
  ),
  viewDocumentsTeacher(
    "810",
    "View Documents",
    IconConstants.viewDocuments,
    ViewDocumentScreen(),
    position: 9,
  ),
  uploadMarks(
    "17",
    "Upload Marks",
    IconConstants.uploadMarks,
    HomeSubsectionScreen(
      currentScreen: ScreenType.uploadMarks,
    ),
    position: 10,
  ),
  vQuick("18", "V Quick", IconConstants.vQuick, VQuickScreen(), position: 12),
  curriculum("6", "Curriculum", IconConstants.curricullam, CurriculumScreen()),
  examinationSchedule(
    "4",
    "Examination Schedule",
    IconConstants.examinationSchedule,
    ExaminationScheduleScreen(),
    position: 6,
  ),
  fee("9", "Fee", IconConstants.studentDossier, FeeHistoryScreen()),
  homework(
    "1",
    "Homework",
    IconConstants.homework,
    HomeWorkScreen(),
    position: -1,
  ),
  newsAndEvents(
      "24", "News and Events", IconConstants.schoolCalendar, NewsEventScreen()),
  noticeBoard(
    "2",
    "Notice Board",
    IconConstants.noticeBoard,
    CircularScreen(),
    position: 0,
  ),
  feePayment(
    "59",
    "Fee Payment",
    IconConstants.feeIcon,
    Placeholder(),
    position: 99,
  ),

  progressReportCard(
    "5",
    "Progress Report Card",
    IconConstants.progressReportCard,
    ReportCardScreen(),
    position: 7,
  ),
  reportCard("22", "Report Card", IconConstants.progressReportCard,
      ReportCardScreen()),
  schoolCalendar("3", "School Calendar", IconConstants.schoolCalendar,
      SchoolCalendarScreen()),
  schoolCalendarTeacher(
    "809",
    "School Calendar",
    IconConstants.schoolCalendar,
    SchoolPlannerScreen(),
    position: 3,
  ),
  schoolPlanner("11", "School Planner", IconConstants.schoolCalendar,
      SchoolPlannerScreen()),
  timeTable(
    "7",
    "Student Timetable",
    IconConstants.teachersTimetable,
    StudentTimeTableScreen(),
    position: 1,
  ),
  timeTableAlt(
    "23",
    "Student Timetable",
    IconConstants.teachersTimetable,
    StudentTimeTableScreen(),
    position: 1,
  ),
  transportTracker("8", "Transport Tracker", IconConstants.transportTracker,
      TransportTrackerScreen()),
  wordOfTheDay("10", "Word of the day", IconConstants.schoolCalendar,
      WordOfTheDayScreen()),
  teacherTimeTable(
      "51",
      "Teacher's Timetable",
      IconConstants.teachersTimetable,
      position: 1,
      LoggedInTeacherTimetableScreen()),
  timetableDetail("50", "Timetable Detail", IconConstants.timetableDetails,
      TimetableDetailsScreen()),
  rulesViolationRecordStudent(
    "801",
    "Rules Violation Record",
    IconConstants.rulesViolationRecord,
    StudentRuleViolationRecordScreen(),
    position: 3,
  ),
  academicNormsViolationRecord(
    "806",
    "Academic Norms Violation Record",
    IconConstants.academicNormsViolationRecord,
    HomeSubsectionScreen(currentScreen: ScreenType.academicNormViolation),
    position: 5,
  ),
  academicNormsViolationRecordStudent(
    "802",
    "Academic Norms Violation Record",
    IconConstants.academicNormsViolationRecord,
    AcademicConcernsScreen(),
    position: 4,
  ),
  acheivementProfile(
    "803",
    "Acheivement Profile",
    IconConstants.achievementProfile,
    AwardsRecognitionScreen(),
    position: 8,
  ),
  feeLedger(
      "804", "Fee Ledger", IconConstants.schoolCalendar, FeeLedgerScreen()),
  rulesViolationStudent(
      "10122",
      "Rules Violation Record",
      IconConstants.rulesViolationRecord,
      HomeSubsectionScreen(currentScreen: ScreenType.ruleViolation)),
  curriculam(
      "555", "Curriculam", IconConstants.curricullam, CurriculumScreen()),
  circular("65", "Circular", IconConstants.schoolCalendar, CircularScreen()),
  raiseDiscipline(
    "805",
    "Raise Discipline",
    IconConstants.raiseDiscipline,
    HomeSubsectionScreen(
      currentScreen: ScreenType.discipline,
    ),
    position: 6,
  ),
  academicRemark(
    "9999",
    "Academic Remark",
    IconConstants.academicRemarks,
    HomeSubsectionScreen(
      currentScreen: ScreenType.academicRemark,
    ),
  ),
  addHomeWork(
      "807", "Add Homework", IconConstants.homework, AddHomeWorkScreen(),
      position: 2),
  academicCards(
    "999999",
    "Academic Cards",
    IconConstants.academicCards,
    HomeSubsectionScreen(
      currentScreen: ScreenType.academicConcern,
    ),
  );

  final String mobileMenuId;
  final String title;
  final String icon;
  final Widget screen;
  final int position;
  final bool isWebView;

  const Menu(this.mobileMenuId, this.title, this.icon, this.screen,
      {this.position = 9999, this.isWebView = false});
}

Menu? fromMobileMenuId(String id) {
  try {
    return Menu.values.firstWhere(
      (menu) => menu.mobileMenuId == id, // Returns null if not found
    );
  } catch (_) {
    return null;
  }
}

/// Get icon for menu item, returns HyperLink icon for undefined menus
String getMenuIcon(MenuDetail menuDetail) {
  final menu = fromMobileMenuId(menuDetail.mobileMenuId ?? "");
  return menu?.icon ?? IconConstants.hyperLink;
}

/// Navigate to destination for any menu item, including undefined ones
Widget? navigateToMenuDestination(
  MenuDetail menuDetail, {
  String? title,
}) {
  final menu = fromMobileMenuId(menuDetail.mobileMenuId ?? "");

  if (menu != null) {
    return menu.navigateToDestination(
      title ?? menuDetail.menuName,
      params: {
        "url": menuDetail.url,
      },
    );
  } else {
    // Handle undefined menu items with generic webview
    final url = menuDetail.url;
    if (url != null && url.isNotEmpty) {
      return GenericWebViewScreen(
        title: title ?? menuDetail.menuName,
        url: url,
      );
    }
  }

  return null;
}

extension MenuExtension on Menu {
  Widget? navigateToDestination(String? title, {Map<String, dynamic>? params}) {
    switch (mobileMenuId) {
      case "12":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.attandance,
          title: title,
        );
      case "14":
        return DisciplinePassbookScreen(
          title: title,
        );
      case "808":
        return StudentDisciplinePassbookScreen(
          title: title,
        );
      case "16":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.resultAnalysis,
          title: title,
        );
      case "15":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.ruleViolation,
          title: title,
        );
      case "21":
        return RaiseDisciplineSearchScreen(
          title: title,
        );
      case "20":
        return StudentDossierSearchScreen(
          title: title,
        );
      case "13":
        return SearchStudentProfileScreen(
          title: title,
        );
      case "19":
        return UploadDocumentScreen(
          title: title,
        );
      case "64":
      case "810":
        return ViewDocumentScreen(
          title: title,
        );
      case "17":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.uploadMarks,
          title: title,
        );
      case "18":
        return VQuickScreen(
          title: title,
        );
      case "6":
      case "555":
        return CurriculumScreen(
          title: title,
        );
      case "4":
        return ExaminationScheduleScreen(
          title: title,
        );
      case "9":
        return FeeHistoryScreen(
          title: title,
        );
      case "1":
        return HomeWorkScreen(title: title);
      case "24":
        return NewsEventScreen(
          title: title,
        );
      case "2":
      case "65":
        return CircularScreen(
          title: title,
        );
      case "5":
      case "22":
        return ReportCardScreen(
          title: title,
        );
      case "3":
        return SchoolCalendarScreen(title: title);
      case "809":
      case "11":
        return SchoolPlannerScreen(title: title);
      case "7":
      case "23":
        return StudentTimeTableScreen(
          title: title,
        );
      case "8":
        return TransportTrackerScreen(title: title);
      case "10":
        return WordOfTheDayScreen(title: title);
      case "51":
        return LoggedInTeacherTimetableScreen(
          title: title,
        );
      case "50":
        return TimetableDetailsScreen(title: title);
      // Rule Violation For Student
      case "801":
        return StudentRuleViolationRecordScreen(title: title);
      case "806":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.academicNormViolation,
          title: title,
        );
      case "802":
        return AcademicConcernsScreen(
          title: title,
        );
      case "803":
        return AwardsRecognitionScreen(
          title: title,
        );
      case "804":
        return FeeLedgerScreen(
          title: title,
        );
      case "10122":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.ruleViolation,
          title: title,
        );
      case "805":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.discipline,
          title: title,
        );
      case "9999":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.academicRemark,
          title: title,
        );
      case "807":
        return AddHomeWorkScreen(title: title);
      case "999999":
        return HomeSubsectionScreen(
          currentScreen: ScreenType.academicConcern,
          title: title,
        );

      case "59":
        return FeePaymentScreen(title: title, url: params?["url"] ?? "");
      default:
        // Handle generic webview for undefined menu items
        final url = params?["url"] as String?;
        if (url != null && url.isNotEmpty) {
          return GenericWebViewScreen(title: title, url: url);
        }
        return null;
    }
  }
}
