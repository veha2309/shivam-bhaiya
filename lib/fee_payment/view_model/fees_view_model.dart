import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/fee_history/Model/fee_history_model.dart';
import 'package:school_app/network_manager/network_manager.dart';

class FeeMonth {
  final String month;
  final double amount;
  final bool isPaid;
  final String? paidDate;
  bool isSelected;

  FeeMonth({
    required this.month,
    required this.amount,
    required this.isPaid,
    this.paidDate,
    this.isSelected = false,
  });
}

class FeeReceipt {
  final String year;
  final double totalPaid;
  FeeReceipt({required this.year, required this.totalPaid});
}

class FeesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _totalFees = 0;
  double _paidAmount = 0;
  double get totalFees => _totalFees;
  double get paidAmount => _paidAmount;
  double get pendingAmount => _totalFees - _paidAmount;

  List<FeeMonth> _months = [];
  List<FeeMonth> get months => _months;
  List<FeeMonth> get selectedMonths => _months.where((m) => m.isSelected).toList();
  double get totalPayable => selectedMonths.fold(0, (sum, m) => sum + m.amount);
  List<FeeMonth> get previousPayments => _months.where((m) => m.isPaid).toList().reversed.toList();

  List<FeeReceipt> get previousYearReceipts => [
    FeeReceipt(year: '2023-24', totalPaid: 56000),
    FeeReceipt(year: '2022-23', totalPaid: 54000),
    FeeReceipt(year: '2021-22', totalPaid: 52000),
  ];

  FeesViewModel() {
    loadFees();
  }

  void toggleMonthSelection(int index) {
    if (_months[index].isPaid) return;
    _months[index].isSelected = !_months[index].isSelected;
    notifyListeners();
  }

  void clearSelection() {
    for (var m in _months) {
      m.isSelected = false;
    }
    notifyListeners();
  }

  Future<void> loadFees() async {
    _isLoading = true;
    notifyListeners();

    final studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
    final response = await NetworkManager.instance.makeRequest(
      Endpoints.getStudentFeeHistory(studentId),
      (json) async => FeeHistoryModel.fromJsonList(json),
      method: HttpMethod.get,
    );

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      final apiMonths = response.data!.map((f) {
        return FeeMonth(
          month: f.monthName ?? "N/A",
          amount: double.tryParse(f.netPayable ?? "0") ?? 0,
          isPaid: (double.tryParse(f.paidAmount ?? "0") ?? 0) > 0,
          paidDate: (double.tryParse(f.paidAmount ?? "0") ?? 0) > 0 ? "Paid" : null,
        );
      }).toList();

      // Ensure all 12 months are present for the user
      final allMonths = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
      _months = [];
      
      for (var monthName in allMonths) {
        final existing = apiMonths.firstWhere((m) => m.month.toLowerCase().contains(monthName.toLowerCase()), orElse: () => FeeMonth(month: monthName, amount: 4500, isPaid: false));
        _months.add(existing);
      }
      
      _paidAmount = response.data!.fold(0, (sum, f) => sum + (double.tryParse(f.paidAmount ?? "0") ?? 0));
      _totalFees = _months.fold(0, (sum, m) => sum + m.amount);
    } else {
      // Fallback Dummy Data
      _totalFees = 56000;
      _paidAmount = 28000;
      _months = [
        FeeMonth(month: 'Apr', amount: 4000, isPaid: true, paidDate: '06 Apr 2024'),
        FeeMonth(month: 'May', amount: 4000, isPaid: true, paidDate: '06 May 2024'),
        FeeMonth(month: 'Jun', amount: 4000, isPaid: true, paidDate: '05 Jun 2024'),
        FeeMonth(month: 'Jul', amount: 4000, isPaid: true, paidDate: '05 Jul 2024'),
        FeeMonth(month: 'Aug', amount: 4000, isPaid: false),
        FeeMonth(month: 'Sep', amount: 4000, isPaid: false),
        FeeMonth(month: 'Oct', amount: 4000, isPaid: false),
        FeeMonth(month: 'Nov', amount: 4000, isPaid: false),
        FeeMonth(month: 'Dec', amount: 4000, isPaid: false),
        FeeMonth(month: 'Jan', amount: 4000, isPaid: false),
        FeeMonth(month: 'Feb', amount: 4000, isPaid: false),
        FeeMonth(month: 'Mar', amount: 4000, isPaid: false),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }
}
