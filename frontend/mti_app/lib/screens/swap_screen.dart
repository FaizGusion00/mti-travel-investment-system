import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as developer;
import '../config/theme.dart';
import '../services/api_service.dart';
import '../utils/number_formatter.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingWallets = true;
  
  // Wallet balances
  double _cashBalance = 0.0;
  double _travelBalance = 0.0;
  double _xlmBalance = 0.0;
  
  // Selected wallets
  String _sourceWallet = 'cash_wallet';
  String _destinationWallet = 'travel_wallet';
  
  // Wallet type to display name mapping
  final Map<String, String> _walletNames = {
    'cash_wallet': 'Cash Wallet',
    'travel_wallet': 'Travel Wallet',
    'xlm_wallet': 'XLM Wallet',
  };
  
  // Wallet icons
  final Map<String, IconData> _walletIcons = {
    'cash_wallet': Icons.attach_money,
    'travel_wallet': Icons.luggage,
    'xlm_wallet': Icons.star,
  };
  
  // Wallet colors
  final Map<String, Color> _walletColors = {
    'cash_wallet': Colors.green,
    'travel_wallet': Colors.blue,
    'xlm_wallet': Colors.purple,
  };
  
  @override
  void initState() {
    super.initState();
    _loadWalletBalances();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  // Load user's wallet balances
  Future<void> _loadWalletBalances() async {
    setState(() => _isLoadingWallets = true);
    
    try {
      final response = await ApiService.getWalletBalances();
      
      if (response['status'] == 'success' && response['data'] != null) {
        final walletData = response['data'];
        
        setState(() {
          _cashBalance = double.tryParse(walletData['cash_wallet']?.toString() ?? '0') ?? 0.0;
          _travelBalance = double.tryParse(walletData['travel_wallet']?.toString() ?? '0') ?? 0.0;
          _xlmBalance = double.tryParse(walletData['xlm_wallet']?.toString() ?? '0') ?? 0.0;
        });
        
        developer.log('Wallet balances loaded: Cash = $_cashBalance, Travel = $_travelBalance, XLM = $_xlmBalance', 
          name: 'SwapScreen');
      } else {
        developer.log('Failed to load wallet balances: ${response['message']}', name: 'SwapScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallet balances: ${response['message']}'))
        );
      }
    } catch (e) {
      developer.log('Error loading wallet balances: $e', name: 'SwapScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading wallet balances: $e'))
      );
    } finally {
      setState(() => _isLoadingWallets = false);
    }
  }
  
  // Get balance for a specific wallet
  double _getWalletBalance(String walletType) {
    switch (walletType) {
      case 'cash_wallet': return _cashBalance;
      case 'travel_wallet': return _travelBalance;
      case 'xlm_wallet': return _xlmBalance;
      default: return 0.0;
    }
  }
  
  // Swap source and destination wallets
  void _swapWallets() {
    setState(() {
      final temp = _sourceWallet;
      _sourceWallet = _destinationWallet;
      _destinationWallet = temp;
    });
  }
  
  // Execute the wallet transfer
  Future<void> _transferBetweenWallets() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final note = _noteController.text.trim();
    final sourceBalance = _getWalletBalance(_sourceWallet);
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'))
      );
      return;
    }
    
    if (amount > sourceBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance in ${_walletNames[_sourceWallet]}'))
      );
      return;
    }
    
    // Confirm the transfer
    final confirmed = await _showConfirmationDialog(amount);
    if (!confirmed) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await ApiService.transferBetweenWallets(
        sourceWallet: _sourceWallet,
        destinationWallet: _destinationWallet,
        amount: amount,
        notes: note.isNotEmpty ? note : null,
      );
      
      if (response['success']) {
        // Show success message
        _showSuccessDialog(amount);
        
        // Clear form
        _amountController.clear();
        _noteController.clear();
        
        // Reload wallet balances
        _loadWalletBalances();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Transfer failed'))
        );
      }
    } catch (e) {
      developer.log('Error transferring between wallets: $e', name: 'SwapScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error transferring between wallets: $e'))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Show confirmation dialog before executing transfer
  Future<bool> _showConfirmationDialog(double amount) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundColor,
        title: Text(
          'Confirm Transfer',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            children: [
              const TextSpan(text: 'You are about to transfer '),
              TextSpan(
                text: '\$${NumberFormatter.formatCurrency(amount)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: _walletColors[_sourceWallet],
                ),
              ),
              TextSpan(text: ' from '),
              TextSpan(
                text: '${_walletNames[_sourceWallet]}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: _walletColors[_sourceWallet],
                ),
              ),
              const TextSpan(text: ' to '),
              TextSpan(
                text: '${_walletNames[_destinationWallet]}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: _walletColors[_destinationWallet],
                ),
              ),
              const TextSpan(text: '.\n\nDo you want to proceed?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: GoogleFonts.inter(color: Colors.green),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // Show success dialog after successful transfer
  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Transfer Successful!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${NumberFormatter.formatCurrency(amount)}',
              style: GoogleFonts.inter(
                color: AppTheme.goldColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'has been transferred from',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _walletIcons[_sourceWallet] ?? Icons.wallet,
                  color: _walletColors[_sourceWallet],
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '${_walletNames[_sourceWallet]}',
                  style: GoogleFonts.inter(
                    color: _walletColors[_sourceWallet],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'to',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _walletIcons[_destinationWallet] ?? Icons.wallet,
                  color: _walletColors[_destinationWallet],
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '${_walletNames[_destinationWallet]}',
                  style: GoogleFonts.inter(
                    color: _walletColors[_destinationWallet],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(color: Colors.green),
            ),
          ),
        ],
      ),
    );
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
        title: Text(
          "Swap Funds",
          style: GoogleFonts.inter(
            color: AppTheme.goldColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingWallets 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.goldColor))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildWalletSelector(),
                  const SizedBox(height: 24),
                  _buildTransferForm(),
                  const SizedBox(height: 30),
                  _buildTransferButton(),
                ],
              ),
            ),
          ),
    );
  }
  
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.goldColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallet Swap',
                style: GoogleFonts.inter(
                  color: AppTheme.goldColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Transfer funds between your wallets instantly. This allows you to move money between your Cash, Travel, and XLM wallets without fees.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBalanceItem('Cash', _cashBalance, Colors.green),
              const SizedBox(width: 8),
              _buildBalanceItem('Travel', _travelBalance, Colors.blue),
              const SizedBox(width: 8),
              _buildBalanceItem('XLM', _xlmBalance, Colors.purple),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        );
  }
  
  Widget _buildBalanceItem(String name, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${NumberFormatter.formatCurrency(amount)}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWalletSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT WALLETS',
          style: GoogleFonts.inter(
            color: AppTheme.goldColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Source wallet dropdown
              DropdownButtonFormField<String>(
                value: _sourceWallet,
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: GoogleFonts.inter(color: Colors.white),
                dropdownColor: AppTheme.backgroundColor,
                items: _walletNames.keys
                    .map((wallet) => DropdownMenuItem(
                          value: wallet,
                          child: Row(
                            children: [
                              Icon(
                                _walletIcons[wallet] ?? Icons.wallet,
                                color: _walletColors[wallet],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _walletNames[wallet] ?? wallet,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(\$${NumberFormatter.formatCurrency(_getWalletBalance(wallet))})',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      if (value == _destinationWallet) {
                        // Swap the values to prevent same source and destination
                        _destinationWallet = _sourceWallet;
                      }
                      _sourceWallet = value;
                    });
                  }
                },
              ),
              
              // Swap direction button
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: IconButton(
                  onPressed: _swapWallets,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert,
                      color: AppTheme.goldColor,
                    ),
                  ),
                ),
              ),
              
              // Destination wallet dropdown
              DropdownButtonFormField<String>(
                value: _destinationWallet,
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: GoogleFonts.inter(color: Colors.white),
                dropdownColor: AppTheme.backgroundColor,
                items: _walletNames.keys
                    .map((wallet) => DropdownMenuItem(
                          value: wallet,
                          child: Row(
                            children: [
                              Icon(
                                _walletIcons[wallet] ?? Icons.wallet,
                                color: _walletColors[wallet],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _walletNames[wallet] ?? wallet,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(\$${NumberFormatter.formatCurrency(_getWalletBalance(wallet))})',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      if (value == _sourceWallet) {
                        // Swap the values to prevent same source and destination
                        _sourceWallet = _destinationWallet;
                      }
                      _destinationWallet = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        );
  }
  
  Widget _buildTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRANSFER DETAILS',
          style: GoogleFonts.inter(
            color: AppTheme.goldColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.attach_money, color: AppTheme.goldColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter amount to transfer',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > _getWalletBalance(_sourceWallet)) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Note field
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.note, color: AppTheme.goldColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Add a note for this transfer',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        );
  }
  
  Widget _buildTransferButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _transferBetweenWallets,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Swap Funds',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        );
  }
}
