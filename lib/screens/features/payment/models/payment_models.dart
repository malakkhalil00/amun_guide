// Models for Payment Feature

class PaymentModel {
  final int id;
  final String payableType; // 'tour_booking' or 'tour'
  final int payableId;
  final double amount;
  final String paymentMethod; // 'bank_transfer', 'credit_card', etc.
  final String? transactionId;
  final String? receiptImage; // Image URL
  final String status; // 'pending', 'approved', 'failed'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;

  PaymentModel({
    required this.id,
    required this.payableType,
    required this.payableId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.receiptImage,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      payableType: json['payable_type'] ?? '',
      payableId: json['payable_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'],
      receiptImage: json['receipt_image'],
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      userId: json['user_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'payable_type': payableType,
        'payable_id': payableId,
        'amount': amount,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'receipt_image': receiptImage,
        'status': status,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'user_id': userId,
      };
}

class PaymentRequestModel {
  final String payableType;
  final int payableId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String? receiptImage;
  final String? notes;

  PaymentRequestModel({
    required this.payableType,
    required this.payableId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.receiptImage,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'payable_type': payableType,
        'payable_id': payableId,
        'amount': amount,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'receipt_image': receiptImage,
        'notes': notes,
      };
}

class PaymentReceiptModel {
  final int id;
  final int paymentId;
  final String receiptUrl;
  final DateTime uploadedAt;

  PaymentReceiptModel({
    required this.id,
    required this.paymentId,
    required this.receiptUrl,
    required this.uploadedAt,
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) {
    return PaymentReceiptModel(
      id: json['id'] ?? 0,
      paymentId: json['payment_id'] ?? 0,
      receiptUrl: json['receipt_url'] ?? '',
      uploadedAt:
          DateTime.tryParse(json['uploaded_at'] ?? '') ?? DateTime.now(),
    );
  }
}
