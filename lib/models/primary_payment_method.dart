class PrimaryPaymentMethod {
  bool applePay;
  bool googlePay;
  bool card;
  String paymentMethodId;


  PrimaryPaymentMethod({
    required this.applePay,
    required this.googlePay,
    required this.card,
    this.paymentMethodId = '',
  });

  // Method to convert PaymentMethodSetting to JSON Map
  Map<String, dynamic> toJson() => {
        'applePay': applePay,
        'googlePay': googlePay,
        'cardPayment': card,
        'paymentMethodId': paymentMethodId,
      };

  // Method to create a PaymentMethodSetting from JSON Map
  factory PrimaryPaymentMethod.fromJson(Map<String, dynamic> json) => PrimaryPaymentMethod(
        applePay: json['applePay'],
        googlePay: json['googlePay'],
        card: json['cardPayment'],
        paymentMethodId: json['paymentMethodId'] ?? '',
      );
}