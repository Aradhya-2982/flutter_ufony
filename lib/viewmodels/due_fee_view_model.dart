import 'package:flutter/material.dart';
import 'package:my_first_app/viewmodels/fee_view_model.dart';
import '../models/payment_model.dart';

class DueFeeViewModel extends ChangeNotifier {
  List<PaymentModel> _duePayments = [];
  Set<int> _selectedIndexes = {};

  List<PaymentModel> get duePayments => _duePayments;
  Set<int> get selectedIndexes => _selectedIndexes;

  void setDuePayments(List<PaymentModel> list) {
    _duePayments = list;
    _selectedIndexes.clear();
    notifyListeners();
  }

  void toggleSelection(int index) {
    _selectedIndexes.contains(index) ? _selectedIndexes.remove(index) : _selectedIndexes.add(index);
    notifyListeners();
  }

  int get totalSelectedAmount => _selectedIndexes
      .map((i) => _duePayments[i].amount)
      .fold(0, (a, b) => a + b);

  String get selectedTitleText => '${_selectedIndexes.length} Selected\n_selectedIndexes.map((i) => _duePayments[i].title).join(", ")}';

  void markAsPaid(int index, void Function(PaymentModel paid) onPaid, FeeViewModel feeVM) {
    final oldItem = _duePayments[index];
    final updatedItem= oldItem.copyWith(
        paidStatus: 'Paid',
        paidOnDate: DateTime.now().toIso8601String(),
    );
    feeVM.updatePayment(oldItem, updatedItem);

    onPaid(updatedItem);

    _duePayments.removeAt(index);
    _selectedIndexes = _selectedIndexes
        .where((i) => i != index)
        .map((i) => i > index ? i - 1 : i)
        .toSet();

    notifyListeners();
  }
}
