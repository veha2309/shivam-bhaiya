import 'package:flutter/material.dart';
import 'package:school_app/attendance_screen/view/student_attendance_screen.dart';
import 'package:school_app/class_work/view/class_work_screen.dart';
import 'package:school_app/discipline/view/discipline_screen.dart';
import 'package:school_app/fee_payment/view/fee_payment_screen.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_subsection/View/home_subsection_screen.dart';
import 'package:school_app/homework_screen/view/homework_screen.dart';
import 'package:school_app/document/view/view_document_screen.dart';
import 'package:school_app/exam_marks/view/exam_marks_screen.dart';
import 'package:school_app/utils/components/generic_webview_screen.dart';
import 'package:school_app/utils/constants.dart';

enum Menu {
  attendance("12", "Attendance", IconConstants.schoolCalendar, position: -1),
  homework("1", "Homework", IconConstants.homework, position: -1),
  classWork("11", "Class Work", IconConstants.classWork, position: -1),
  curriculum("812", "Class Work", IconConstants.classWork, position: -1),
  syllabus("10103", "Class Work", IconConstants.classWork, position: -1),
  disciplinePassbook("14", "Discipline Passbook", IconConstants.disciplinePassbook, position: 7),
  studentDisciplinePassbook("808", "Discipline Passbook", IconConstants.disciplinePassbook, position: 5),
  resultAnalysis("16", "Result Analysis", IconConstants.resultAnalysis, position: 13),
  examMarks("805", "Exam Marks", IconConstants.examinationSchedule, position: 14),
  academicRating("5", "Academic Rating", IconConstants.resultAnalysis, position: 15),
  performance("22", "Performance", IconConstants.resultAnalysis, position: 16),
  rulesViolationRecord("15", "Rules Violation Record", IconConstants.rulesViolationRecord, position: 4),
  rulesViolationRecordStudent(
    "801",
    "Rules Violation Record",
    IconConstants.rulesViolationRecord,
    position: 3,
  ),
  rulesViolationStudent(
    "10122",
    "Rules Violation Record",
    IconConstants.rulesViolationRecord,
  ),
  feePayment("59", "Fee Payment", IconConstants.feeIcon, position: 99),
  feePaymentOther("9", "Fee Payment", IconConstants.feeIcon, position: 100),
  feePaymentStudent("804", "Fee Payment", IconConstants.feeIcon, position: 101),
  viewDocuments("64", "Documents", IconConstants.viewDocuments, position: 10),
  viewDocumentsStudent("810", "Documents", IconConstants.viewDocuments, position: 11),
  viewDocumentsOther("19", "Documents", IconConstants.viewDocuments, position: 12),
  noticeBoard("2", "Notice Board", IconConstants.noticeBoard, position: 13),
  circular("65", "Circulars", IconConstants.noticeBoard, position: 14);

  final String mobileMenuId;
  final String title;
  final String icon;
  final int position;
  final bool isWebView;

  const Menu(
    this.mobileMenuId, 
    this.title, 
    this.icon, {
    this.position = 9999, 
    this.isWebView = false,
  });
}

// Helper to find Menu by ID
Menu? fromMobileMenuId(String id) {
  try {
    return Menu.values.firstWhere((menu) => menu.mobileMenuId == id);
  } catch (_) {
    return null;
  }
}

// Get icon safely
String getMenuIcon(MenuDetail menuDetail) {
  final menu = fromMobileMenuId(menuDetail.mobileMenuId ?? "");
  return menu?.icon ?? IconConstants.hyperLink;
}

// Centralized Navigation Hub
Widget? navigateToMenuDestination(MenuDetail menuDetail, {String? title}) {
  final menu = fromMobileMenuId(menuDetail.mobileMenuId ?? "");
  final displayTitle = title ?? menuDetail.menuName;
  final url = menuDetail.url;

  if (menu != null) {
    return menu.buildScreen(displayTitle, url: url);
  } 
  
  // Fallback for undefined webview routes
  if (url != null && url.isNotEmpty) {
    return GenericWebViewScreen(title: displayTitle, url: url);
  }

  return null;
}

// Extension to handle screen building on demand (Lazy Loading)
extension MenuExtension on Menu {
  Widget? buildScreen(String? title, {String? url}) {
    switch (this) { // Switch on the enum itself, much safer than switching on Strings!
      
      case Menu.attendance:
        return StudentAttendanceScreen(title: title);
        
      case Menu.homework:
        return const HomeWorkScreen();
        
      case Menu.classWork:
      case Menu.curriculum:
      case Menu.syllabus:
        return ClassWorkScreen(title: title);
        
      case Menu.disciplinePassbook:
      case Menu.studentDisciplinePassbook:
      case Menu.rulesViolationRecord:
      case Menu.rulesViolationRecordStudent:
      case Menu.rulesViolationStudent:
        return DisciplineScreen(title: title);

      case Menu.resultAnalysis:
      case Menu.examMarks:
      case Menu.academicRating:
      case Menu.performance:
        return ExamMarksScreen(title: title);
        
      case Menu.feePayment:
      case Menu.feePaymentOther:
      case Menu.feePaymentStudent:
        return FeePaymentScreen(title: title, paymentUrl: url);
        
      case Menu.viewDocuments:
      case Menu.viewDocumentsStudent:
      case Menu.viewDocumentsOther:
      case Menu.noticeBoard:
      case Menu.circular:
        return ViewDocumentScreen(title: title);
        
      // ... [Map the rest of your cases here]
      
      default:
        if (url != null && url.isNotEmpty) {
          return GenericWebViewScreen(title: title, url: url);
        }
        return null;
    }
  }
}