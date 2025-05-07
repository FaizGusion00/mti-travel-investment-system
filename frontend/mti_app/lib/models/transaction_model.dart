import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final DateTime date;
  final String status;
  final String description;
  final String referenceCode;
  final String? senderName;
  final String? senderEmail;
  final String? recipientName;
  final String? recipientEmail;
  final String? walletType;
  final double? balanceBefore;
  final double? balanceAfter;
  final String? notes;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    required this.description,
    required this.referenceCode,
    this.senderName,
    this.senderEmail,
    this.recipientName,
    this.recipientEmail,
    this.walletType,
    this.balanceBefore,
    this.balanceAfter,
    this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] ?? json['transaction_id'] ?? '').toString(),
      type: (json['type'] ?? json['transaction_type'] ?? 
      (json['direction'] == 'out' ? 'sent' : json['direction'] == 'in' ? 'received' : 'unknown')).toString(),
      amount: (json['amount'] != null) 
          ? double.tryParse(json['amount'].toString()) ?? 0.0 
          : 0.0,
      currency: (json['currency'] ?? 'USDT').toString(),
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      status: (json['status'] ?? 'completed').toString(),
      description: (json['description'] ?? json['notes'] ?? '').toString(),
      referenceCode: (json['reference_code'] ?? json['transaction_id'] ?? '').toString(),
      senderName: json['sender_name']?.toString(),
      senderEmail: json['sender_email']?.toString(),
      recipientName: json['recipient_name']?.toString(),
      recipientEmail: json['recipient_email']?.toString(),
      walletType: json['wallet_type']?.toString(),
      balanceBefore: json['balance_before'] != null 
          ? double.tryParse(json['balance_before'].toString()) 
          : null,
      balanceAfter: json['balance_after'] != null 
          ? double.tryParse(json['balance_after'].toString()) 
          : null,
      notes: json['notes']?.toString(),
    );
  }

  String get formattedDate {
    return DateFormat('MMMM dd, yyyy • hh:mm a').format(date);
  }

  String get shortFormattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedAmount {
    final sign = type.toLowerCase() == 'deposit' || type.toLowerCase() == 'received' 
        ? '+' 
        : '-';
    return '$sign${amount.toStringAsFixed(2)} $currency';
  }

  String get amountColor {
    return type.toLowerCase() == 'deposit' || type.toLowerCase() == 'received'
        ? 'green'
        : 'red';
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return 'green';
      case 'pending':
        return 'yellow';
      case 'failed':
      case 'declined':
        return 'red';
      default:
        return 'white';
    }
  }

  bool get isIncoming {
    return type.toLowerCase() == 'deposit' || 
           type.toLowerCase() == 'received' || 
           type.toLowerCase() == 'commission';
  }

  bool get isOutgoing {
    return type.toLowerCase() == 'withdrawal' || 
           type.toLowerCase() == 'sent' || 
           type.toLowerCase() == 'fee';
  }
}
