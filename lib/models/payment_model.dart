
class PaymentModel {
  final String feeType;
  final int amount;
  final String paidStatus;
  final String? paidOnDate;
  final String? nextPaymentDate;

  PaymentModel({
    required this.feeType,
    required this.amount,
    required this.paidStatus,
    this.paidOnDate,
    this.nextPaymentDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      feeType: json['feeType'] ?? '',
      amount: json['amount'] ?? 0,
      paidStatus: json['paidStatus'] ?? 'unPaid',
      paidOnDate: json['paidOnDate'],
      nextPaymentDate: json['nextPaymentDate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'feeType': feeType,
    'amount': amount,
    'paidStatus': paidStatus,
    'paidOnDate': paidOnDate,
    'nextPaymentDate': nextPaymentDate,
  };

  PaymentModel copyWith({
    String? feeType,
    int? amount,
    String? paidStatus,
    String? paidOnDate,
    String? nextPaymentDate,
  }) {
    return PaymentModel(
      feeType: feeType ?? this.feeType,
      amount: amount ?? this.amount,
      paidStatus: paidStatus ?? this.paidStatus,
      paidOnDate: paidOnDate ?? this.paidOnDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
    );
  }
}
