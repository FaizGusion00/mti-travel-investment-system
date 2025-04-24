import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String _selectedMethod = 'USDT';
  
  final List<String> _paymentMethods = [
    'USDT',
    'Bitcoin',
    'Ethereum',
    'Bank Transfer',
    'Credit Card',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processDeposit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // Show success dialog
        Get.dialog(
          AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Deposit Processing",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your deposit of \$${_amountController.text} via $_selectedMethod is being processed. It will be credited to your account shortly.",
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to previous screen
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deposit failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Deposit Funds",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deposit illustration
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.goldColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.goldColor,
                        size: 60,
                      ),
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Center(
                    child: Text(
                      "Deposit Funds",
                      style: GoogleFonts.montserrat(
                        color: AppTheme.goldColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: AppTheme.goldColor.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Center(
                    child: Text(
                      "Add funds to your account to start investing",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Amount field
                  Text(
                    "Amount",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  
                  const SizedBox(height: 12),
                  
                  CustomTextField(
                    label: "Amount",
                    hint: "Enter amount",
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Amount is required";
                      }
                      
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return "Please enter a valid amount";
                      }
                      
                      if (amount <= 0) {
                        return "Amount must be greater than 0";
                      }
                      
                      return null;
                    },
                    prefix: const Icon(
                      Icons.attach_money,
                      color: AppTheme.tertiaryTextColor,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Payment method
                  Text(
                    "Payment Method",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMethod,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMethod = newValue!;
                          });
                        },
                        items: _paymentMethods.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    _getPaymentIcon(value),
                                    color: AppTheme.tertiaryTextColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    value,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        dropdownColor: AppTheme.cardColor,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.tertiaryTextColor,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Deposit button
                  CustomButton(
                    text: "Deposit Now",
                    onPressed: _processDeposit,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.goldColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Deposits are typically processed within 1-2 business days. USDT deposits are instant.",
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'USDT':
        return Icons.currency_bitcoin;
      case 'Bitcoin':
        return Icons.currency_bitcoin;
      case 'Ethereum':
        return Icons.currency_bitcoin;
      case 'Bank Transfer':
        return Icons.account_balance;
      case 'Credit Card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
}
