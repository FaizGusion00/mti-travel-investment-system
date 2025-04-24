import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String _selectedMethod = 'USDT';
  
  // Simulated account balance
  final double _accountBalance = 10000.0;
  
  final List<String> _withdrawalMethods = [
    'USDT',
    'Bitcoin',
    'Ethereum',
    'Bank Transfer',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processWithdrawal() async {
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
              "Withdrawal Processing",
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
                  "Your withdrawal of \$${_amountController.text} via $_selectedMethod is being processed. It will be sent to your account within 24 hours.",
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
            content: Text('Withdrawal failed: ${e.toString()}'),
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
          "Withdraw Funds",
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
                  // Withdraw illustration
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.red,
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
                      "Withdraw Funds",
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Account balance
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.goldColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Available Balance: \$${_accountBalance.toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
                      
                      if (amount > _accountBalance) {
                        return "Insufficient balance";
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
                  
                  // Withdrawal method
                  Text(
                    "Withdrawal Method",
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
                        items: _withdrawalMethods.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    _getWithdrawalIcon(value),
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
                  
                  const SizedBox(height: 24),
                  
                  // Wallet address / bank account
                  Text(
                    _selectedMethod == 'Bank Transfer' 
                        ? "Bank Account Number" 
                        : "Wallet Address",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                  
                  const SizedBox(height: 12),
                  
                  CustomTextField(
                    label: _selectedMethod == 'Bank Transfer' 
                        ? "Bank Account Number" 
                        : "Wallet Address",
                    hint: _selectedMethod == 'Bank Transfer' 
                        ? "Enter your bank account number" 
                        : "Enter your wallet address",
                    controller: _addressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _selectedMethod == 'Bank Transfer' 
                            ? "Bank account number is required" 
                            : "Wallet address is required";
                      }
                      return null;
                    },
                    prefix: Icon(
                      _selectedMethod == 'Bank Transfer' 
                          ? Icons.account_balance 
                          : Icons.wallet,
                      color: AppTheme.tertiaryTextColor,
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Withdraw button
                  CustomButton(
                    text: "Withdraw Now",
                    onPressed: _processWithdrawal,
                    isLoading: _isLoading,
                    width: double.infinity,
                    type: ButtonType.primary,
                  ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Withdrawals are processed within 24 hours. A 2% fee applies to all withdrawals.",
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getWithdrawalIcon(String method) {
    switch (method) {
      case 'USDT':
        return Icons.currency_bitcoin;
      case 'Bitcoin':
        return Icons.currency_bitcoin;
      case 'Ethereum':
        return Icons.currency_bitcoin;
      case 'Bank Transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}
