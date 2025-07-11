class PaymentMethod {
  final String methodId;
  final String methodName;
  // final int accountNumber;

  PaymentMethod({
    required this.methodId,
    required this.methodName,
    // required this.accountNumber,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      methodId: map['method_id'] ?? '',
      methodName: map['method_name'] ?? '',
      // accountNumber: map['account_number'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'method_id': methodId,
      'method_name': methodName,
      // 'account_number': accountNumber,
    };
  }
}
