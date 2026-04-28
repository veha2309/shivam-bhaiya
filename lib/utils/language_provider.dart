import 'package:flutter/material.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';

enum Language { english, hindi }

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  LanguageProvider._internal() {
    _loadLanguage();
  }

  Language _currentLanguage = Language.english;

  Language get currentLanguage => _currentLanguage;

  void _loadLanguage() {
    final lang = LocalStorage.getLanguage();
    if (lang != null) {
      _currentLanguage = lang == 'en' ? Language.english : Language.hindi;
    }
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == Language.english ? Language.hindi : Language.english;
    LocalStorage.saveLanguage(_currentLanguage == Language.english ? 'en' : 'hi');
    notifyListeners();
  }

  void setLanguage(Language language) {
    _currentLanguage = language;
    LocalStorage.saveLanguage(_currentLanguage == Language.english ? 'en' : 'hi');
    notifyListeners();
  }

  List<Map<String, dynamic>> get supportedLanguages => [
        {'name': 'English', 'code': 'en', 'value': Language.english},
        {'name': 'हिंदी (Hindi)', 'code': 'hi', 'value': Language.hindi},
      ];

  String translate(String key) {
    final Map<String, String> currentMap = _currentLanguage == Language.english ? _en : _hi;
    return currentMap[key] ?? currentMap[key.toLowerCase()] ?? key;
  }

  static const Map<String, String> _en = {
    // Auth / Login
    'welcome_back': 'Welcome Back',
    'login_subtitle': 'Sign in to your account',
    'username_hint': 'Username',
    'password_hint': 'Password',
    'forgot_password': 'Forgot Password?',
    'login_button': 'LOG IN',
    'login_issue': 'Problem logging in?',
    'enter_username': 'Please enter username',
    'enter_password': 'Please enter password',
    'something_wrong': 'Something went wrong, please try again',
    'auth_failed': 'Authentication failed',
    'login_failed': 'Login failed',
    'school_address': 'D-Block, Anand Vihar | F-Block, Preet Vihar',
    'select_language': 'Select Language',
    'language': 'Language',
    
    // Header / Greetings
    'good_morning': 'Good Morning',
    'hello': 'Hello',
    'good_evening': 'Good Evening',
    'student': 'Student',
    
    // Home
    'thought_of_the_day': 'Thought of the Day',
    'all_services': 'All Services',
    
    // Drawer
    'home': 'Home',
    'user_list': 'User List',
    'add_user': 'Add User',
    'settings': 'Settings',
    'profile': 'Profile',
    'school_website': 'School Website',
    'refresh': 'Refresh',
    'help': 'Help',
    'connect_with_us': 'Connect with us',

    // Menu Items
    'attendance': 'Attendance',
    'homework': 'Homework',
    'circular': 'Circular',
    'notice board': 'Notice Board',
    'report card': 'Report Card',
    'fee history': 'Fee History',
    'fee ledger': 'Fee Ledger',
    'school calendar': 'School Calendar',
    'timetable': 'Timetable',
    'student timetable': 'Student Timetable',
    'teacher timetable': 'Teacher Timetable',
    'result analysis': 'Result Analysis',
    'discipline passbook': 'Discipline Passbook',
    'upload documents': 'Upload Documents',
    'view documents': 'View Documents',
    'v quick': 'V Quick',
    'word of the day': 'Word of the day',
    'transport tracker': 'Transport Tracker',
    'school planner': 'School Planner',
    
    // Bottom Sheets / Common
    'select class': 'Select Class',
    'select section': 'Select Section',
    'select document type': 'Select Document Type',
    'select option': 'Select Option',
    'select report template': 'Select Report Template',
    'select month': 'Select Month',
    'select subject': 'Select Subject',
    'contact support': 'Contact Support',
    'call office': 'Call Office',
    'email support': 'Email Support',
    'visit website': 'Visit Website',
    'logout': 'Logout',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'search': 'Search',
    'student name': 'Student Name',
    'student admission no': 'Student Admission No',
    'examination schedule': 'Examination Schedule',
    'student dossier search': 'Student Dossier Search',
    'website': 'Website',
    'mark_attendance': 'Mark Attendance',
    'exam_schedules': 'Exam Schedules',
    'present': 'Present',
    'absent': 'Absent',
    'leave': 'Leave',
    'late': 'Late',
  };

  static const Map<String, String> _hi = {
    // Auth / Login
    'welcome_back': 'स्वागत है',
    'login_subtitle': 'अपने खाते में प्रवेश करें',
    'username_hint': 'उपयोगकर्ता नाम',
    'password_hint': 'पासवर्ड',
    'forgot_password': 'पासवर्ड भूल गए?',
    'login_button': 'लॉगिन करें',
    'login_issue': 'लॉगिन में समस्या?',
    'enter_username': 'कृपया उपयोगकर्ता नाम दर्ज करें',
    'enter_password': 'कृपया पासवर्ड दर्ज करें',
    'something_wrong': 'कुछ गलत हुआ, कृपया पुनः प्रयास करें',
    'auth_failed': 'प्रमाणीकरण विफल',
    'login_failed': 'लॉगिन विफल',
    'school_address': 'D-Block, आनन्द विहार | F-Block, प्रीत विहार',
    'select_language': 'भाषा चुनें',
    'language': 'भाषा (Language)',
    
    // Header / Greetings
    'good_morning': 'शुभ प्रभात',
    'hello': 'नमस्ते',
    'good_evening': 'शुभ संध्या',
    'student': 'विद्यार्थी',
    
    // Home
    'thought_of_the_day': 'आज का विचार',
    'all_services': 'सभी सेवाएं',
    
    // Drawer
    'home': 'होम',
    'user_list': 'उपयोगकर्ता सूची',
    'add_user': 'उपयोगकर्ता जोड़ें',
    'settings': 'सेटिंग्स',
    'profile': 'प्रोफाइल',
    'school_website': 'स्कूल वेबसाइट',
    'refresh': 'रिफ्रेश',
    'help': 'सहायता',
    'connect_with_us': 'हमसे जुड़ें',

    // Menu Items
    'attendance': 'उपस्थिति',
    'homework': 'होमवर्क',
    'circular': 'परिपत्र',
    'notice board': 'सूचना पट्ट',
    'report card': 'प्रगति पत्र',
    'fee history': 'शुल्क इतिहास',
    'fee ledger': 'शुल्क लेजर',
    'school calendar': 'स्कूल कैलेंडर',
    'timetable': 'समय सारणी',
    'student timetable': 'छात्र समय सारणी',
    'teacher timetable': 'शिक्षक समय सारणी',
    'result analysis': 'परिणाम विश्लेषण',
    'discipline passbook': 'अनुशासन पासबुक',
    'upload documents': 'दस्तावेज़ अपलोड करें',
    'view documents': 'दस्तावेज़ देखें',
    'v quick': 'वी क्विक',
    'word of the day': 'आज का शब्द',
    'transport tracker': 'परिवहन ट्रैकर',
    'school planner': 'स्कूल प्लानर',

    // Bottom Sheets / Common
    'select class': 'कक्षा चुनें',
    'select section': 'अनुभाग चुनें',
    'select document type': 'दस्तावेज़ प्रकार चुनें',
    'select option': 'विकल्प चुनें',
    'select report template': 'रिपोर्ट टेम्पलेट चुनें',
    'select month': 'महीना चुनें',
    'select subject': 'विषय चुनें',
    'contact support': 'सहायता से संपर्क करें',
    'call office': 'कार्यालय को कॉल करें',
    'email support': 'ईमेल सहायता',
    'visit website': 'वेबसाइट पर जाएं',
    'logout': 'लॉगआउट',
    'cancel': 'रद्द करें',
    'confirm': 'पुष्टि करें',
    'search': 'खोजें',
    'student name': 'छात्र का नाम',
    'student admission no': 'छात्र प्रवेश संख्या',
    'examination schedule': 'परीक्षा कार्यक्रम',
    'student dossier search': 'छात्र डोजियर खोज',
    'website': 'वेबसाइट',
    'mark_attendance': 'उपस्थिति दर्ज करें',
    'exam_schedules': 'परीक्षा कार्यक्रम',
    'present': 'उपस्थित',
    'absent': 'अनुपस्थित',
    'leave': 'छुट्टी',
    'late': 'देरी से',
  };
}
