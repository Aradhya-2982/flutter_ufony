import 'payment_model.dart';

class AcademicYearModel {
  final String label;
  final List<PaymentModel> payments;

  AcademicYearModel({
    required this.label,
    required this.payments,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    final paymentsJson = json['payments'] as List<dynamic>? ?? [];
    return AcademicYearModel(
      label: json['academicYear']['label'] ?? '',
      payments: paymentsJson.map((e) => PaymentModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'academicYear': {'label': label},
    'payments': payments.map((e) => e.toJson()).toList(),
  };

  AcademicYearModel copyWith({
    String? label,
    List<PaymentModel>? payments,
  }) {
    return AcademicYearModel(
      label: label ?? this.label,
      payments: payments ?? this.payments,
    );
  }
}
