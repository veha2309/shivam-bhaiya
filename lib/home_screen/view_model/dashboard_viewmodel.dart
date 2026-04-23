import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isDashboard = false;
  DateTime _selectedDate = DateTime.now();
  bool _hasLocationPermission = false;
  bool _checkingLocationPermission = true;

  DashboardViewModel() {
    _initLocationPermissionCheck();
  }

  bool get isDashboard => _isDashboard;
  DateTime get selectedDate => _selectedDate;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get checkingLocationPermission => _checkingLocationPermission;

  void toggleView(bool value) {
    _isDashboard = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> _initLocationPermissionCheck() async {
    final status = await Permission.locationWhenInUse.status;
    _hasLocationPermission = status.isGranted;
    _checkingLocationPermission = false;
    notifyListeners();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    status = await Permission.locationWhenInUse.request();
    _hasLocationPermission = status.isGranted;
    notifyListeners();
  }
}
