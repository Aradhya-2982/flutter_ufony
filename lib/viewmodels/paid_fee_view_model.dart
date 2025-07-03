import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaidFeeViewModel extends ChangeNotifier {
  List<PaymentModel> _paidPayments = [];

  List<PaymentModel> get paidPayments => _paidPayments;

  void setPaidPayments(List<PaymentModel> list) {
    _paidPayments = list;
    notifyListeners();
  }

  void addPayment(PaymentModel model) {
    _paidPayments.add(model);
    notifyListeners();
  }
}
