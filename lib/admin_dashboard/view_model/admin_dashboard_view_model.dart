import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // staff specific data points
  String get adminName => AuthViewModel.instance.getLoggedInUser()?.name ?? "System Admin";
  String get adminRole => AuthViewModel.instance.getLoggedInUser()?.userType ?? "Staff";
  String get avatarUrl => AuthViewModel.instance.getLoggedInUser()?.profileImageUrl ?? "https://i.pravatar.cc/150?u=admin";
  
  String get todayCollection => "₹ 1,45,000";
  String get pendingApprovals => "12";
  
  List<String> get criticalAlerts => [
    '3 Staff members on leave today.',
    'Fee defaulters list generated.',
    'Board meeting at 2:00 PM.'
  ];

  Future<void> loadAdminData() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API fetch
    await Future.delayed(const Duration(milliseconds: 800));
    
    _isLoading = false;
    notifyListeners();
  }
}