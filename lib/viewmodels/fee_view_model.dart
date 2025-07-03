import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/academic_year_model.dart';
import '../models/payment_model.dart';
import 'due_fee_view_model.dart';
import 'paid_fee_view_model.dart';

class FeeViewModel extends ChangeNotifier {
  final DueFeeViewModel dueFeeVM;
  final PaidFeeViewModel paidFeeVM;

  List<AcademicYearModel> _data = [];
  List<String> _academicYears = [];
  String? _selectedYear;

  FeeViewModel({
    required this.dueFeeVM,
    required this.paidFeeVM,
  });

  List<String> get academicYears => _academicYears;
  String? get selectedYear => _selectedYear;

  Future<void> loadData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data.json');

      final assetJson = await rootBundle.loadString('assets/dataFile.json');
      await file.writeAsString(assetJson);

      final content = await file.readAsString();
      final decoded = json.decode(content) as List;

      _data = decoded.map((e) => AcademicYearModel.fromJson(e)).toList();
      _academicYears = _data.map((e) => e.label).toSet().toList();

      _selectedYear = _academicYears.isNotEmpty ? _academicYears.first : null;
      if (_selectedYear != null) filterByYear(_selectedYear!);
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  void filterByYear(String year) {
    _selectedYear = year;
    final selected = _data.firstWhere(
          (element) => element.label == year,
      orElse: () => AcademicYearModel(label: '', payments: []),
    );

    final due = selected.payments.where((p) => p.paidStatus == 'unPaid').toList();
    final paid = selected.payments.where((p) => p.paidStatus == 'Paid').toList();

    dueFeeVM.setDuePayments(due);
    paidFeeVM.setPaidPayments(paid);
    notifyListeners();
  }
  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("d MMM yyyy").format(parsed);
    } catch (_) {
      return "Invalid date";
    }
  }
  void updatePayment(PaymentModel original, PaymentModel updated) {
    final yearIndex = _data.indexWhere((y) => y.label == _selectedYear);
    if (yearIndex == -1) return;

    final paymentIndex = _data[yearIndex].payments.indexWhere(
          (p) =>
          p.feeType == original.feeType &&
          p.amount == original.amount &&
          p.paidStatus == original.paidStatus,
    );

    if (paymentIndex != -1) {
      _data[yearIndex].payments[paymentIndex] = updated;
      filterByYear(_selectedYear!); // Refresh view models
      notifyListeners(); // Trigger UI updates
    }
  }


  void handlePayment(PaymentModel paid) {
    paidFeeVM.addPayment(paid);
    saveData();
  }

  Future<void> saveData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/data.json');
      final jsonString = json.encode(_data.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }
}
