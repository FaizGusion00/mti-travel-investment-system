import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as developer;
import 'dart:convert';

import '../config/theme.dart';
// Removed unused import
import '../services/api_service.dart';
import '../utils/number_formatter.dart';
import '../core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Event bus for communicating between screens
class WalletEvents {
  static RxBool refreshWallets = true.obs;
  
  static void triggerWalletRefresh() {
    // Toggle the value to trigger reactions in other screens
    refreshWallets.toggle();
    developer.log('Wallet refresh event triggered', name: 'MTI_Events');
  }
}

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  // Tab controller
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLoadingTransactions = false; // For transaction history loading
  double _cashBalance = 0.0;
  List<Map<String, dynamic>> _recentRecipients = [];
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedUser;
  
  // Transaction history state
  List<Map<String, dynamic>> _transactions = [];
  bool _hasMoreTransactions = true;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletData();
    _loadRecentRecipients();
    _loadTransactionHistory();
    
    // Listen for tab changes to refresh data
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // If switching to transaction history tab
        if (_tabController.index == 1) {
          _loadTransactionHistory(refresh: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    try {
      setState(() => _isLoading = true);

      final response = await ApiService.getWalletBalances();
      if (response['status'] == 'success' && response['data'] != null) {
        final walletData = response['data'];
        final cashWallet =
            double.tryParse(walletData['cash_wallet'].toString()) ?? 0.0;

        setState(() {
          _cashBalance = cashWallet;
        });
      }
    } catch (e) {
      developer.log('Error loading wallet data: $e', name: 'MTI_Swap');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading wallet data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecentRecipients() async {
    try {
      // Load saved recent recipients from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final recipientsJson = prefs.getString('recent_recipients') ?? '[]';

      final List<dynamic> savedRecipients = json.decode(recipientsJson);

      if (savedRecipients.isNotEmpty) {
        setState(() {
          _recentRecipients = List<Map<String, dynamic>>.from(savedRecipients);
        });
        developer.log(
          'Loaded ${_recentRecipients.length} recent recipients',
          name: 'MTI_Swap',
        );
      } else {
        developer.log('No recent recipients found', name: 'MTI_Swap');
      }
    } catch (e) {
      developer.log('Error loading recent recipients: $e', name: 'MTI_Swap');
      // If there's an error, we'll just have an empty list
      setState(() {
        _recentRecipients = [];
      });
    }
  }

  Future<void> _saveToRecentRecipients(Map<String, dynamic> user) async {
    try {
      // Ensure we have all required fields for display
      if (!user.containsKey('full_name') && user.containsKey('name')) {
        user['full_name'] = user['name'];
      }

      if (!user.containsKey('email')) {
        return; // Skip if no email (required for identification)
      }

      // Get existing recent recipients
      final prefs = await SharedPreferences.getInstance();
      final recipientsJson = prefs.getString('recent_recipients') ?? '[]';

      List<Map<String, dynamic>> savedRecipients =
          List<Map<String, dynamic>>.from(json.decode(recipientsJson));

      // Check if user is already in recent recipients by email (unique identifier)
      bool userExists = false;
      for (int i = 0; i < savedRecipients.length; i++) {
        if (savedRecipients[i]['email'] == user['email']) {
          // Update existing user data with latest info
          savedRecipients[i] = user;
          userExists = true;
          break;
        }
      }

      if (!userExists) {
        // Add user to recent recipients
        savedRecipients.add(user);
      }

      // Limit to max 5 recent recipients (most recent first)
      if (savedRecipients.length > 5) {
        savedRecipients = savedRecipients.sublist(savedRecipients.length - 5);
      }

      // Save recent recipients to SharedPreferences
      await prefs.setString('recent_recipients', json.encode(savedRecipients));

      developer.log(
        'Saved ${savedRecipients.length} recipients to preferences',
        name: 'MTI_Swap',
      );
    } catch (e) {
      developer.log('Error saving recent recipients: $e', name: 'MTI_Swap');
    }
  }

  Future<void> _searchUser(String query) async {
    if (query.isEmpty) return;

    try {
      setState(() {
        _isSearching = true;
        _searchResults = [];
      });

      final response = await ApiService.findUsers(query);
      if (response['success'] && response['users'] != null) {
        final users = response['users'];
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(users);
        });

        if (_searchResults.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No users found matching your search'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to find users'),
          ),
        );
      }
    } catch (e) {
      developer.log('Error searching users: $e', name: 'MTI_Swap');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectUser(Map<String, dynamic> user) {
    setState(() {
      _selectedUser = user;
      _searchResults = [];
      _searchController.clear();
    });

    // Show a confirmation message with full name
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected recipient: ${user['full_name'] ?? ''}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _transferFunds() async {
    // Check if a recipient has been selected
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recipient first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final note = _noteController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (amount > _cashBalance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    // Show confirmation dialog with recipient info
    String recipientName =
        _selectedUser != null
            ? (_selectedUser!['full_name'] ?? 'Unknown')
            : 'the recipient';
    bool confirmed =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Transfer'),
                content: Text(
                  'You are about to transfer ${NumberFormatter.formatCurrency(amount)} to $recipientName.\n\n'
                  'Email is used as a unique identifier to ensure funds are sent to the correct account.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      setState(() => _isLoading = true);

      // Get the best identifier from the selected user
      String recipientIdentifier;
      String identifierType;

      // Prioritize email as it's the most reliable identifier
      if (_selectedUser!['email'] != null &&
          _selectedUser!['email'].toString().isNotEmpty) {
        recipientIdentifier = _selectedUser!['email'];
        identifierType = 'email';
      }
      // Fall back to phone number if available
      else if (_selectedUser!['phonenumber'] != null &&
          _selectedUser!['phonenumber'].toString().isNotEmpty) {
        recipientIdentifier = _selectedUser!['phonenumber'];
        identifierType = 'phone';
      }
      // Use ID as last resort
      else if (_selectedUser!['id'] != null) {
        recipientIdentifier = _selectedUser!['id'].toString();
        identifierType = 'id';
      }
      // If somehow we don't have any identifier, use whatever is available
      else {
        recipientIdentifier = _selectedUser!['full_name'] ?? 'Unknown';
        identifierType = 'auto';
      }

      // Save recipient details before the API call in case we need them after clearing the form
      final savedRecipient = {
        'full_name': _selectedUser!['full_name'] ?? '',
        'email': _selectedUser!['email'] ?? '',
        'profile_image': _selectedUser!['profile_image'],
      };
      
      final response = await ApiService.transferFunds(
        recipientIdentifier: recipientIdentifier,
        amount: amount,
        notes: note,
        identifierType: identifierType,
      );

      // Check for success in both formats that might come from API (status or success key)
      final isSuccess = response['success'] == true || response['status'] == 'success';
      
      if (isSuccess) {
        // Save the recipient to recent recipients (do this before clearing)
        await _saveToRecentRecipients(savedRecipient);
        
        // Show success modal/dialog first - so user gets immediate feedback
        // Extract recipient name from response or use the saved one
        final recipientFullName = response['data']?['recipient']?['full_name'] ?? 
                                  savedRecipient['full_name'] ?? 
                                  recipientName;

        // Clear form fields and selected user
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _selectedUser = null;
        });
        
        // Show the success dialog
        _showTransferSuccessDialog(amount, recipientFullName);
        
        // Refresh wallet data to get the new balance
        await _loadWalletData();
        
        // Notify other screens to refresh their wallet balances using our event system
        WalletEvents.triggerWalletRefresh();
                
        // Refresh recent recipients list
        _loadRecentRecipients();
        
        // Refresh transaction history
        _loadTransactionHistory(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Transfer failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      developer.log('Error transferring funds: $e', name: 'MTI_Swap');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error transferring funds: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Swap Funds',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.goldColor,
          indicatorWeight: 3,
          labelColor: AppTheme.goldColor,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Transfer'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Transfer Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBalanceCard(),
                            const SizedBox(height: 24),
                            _buildSearchBar(),
                            if (_searchResults.isNotEmpty) _buildSearchResults(),
                            const SizedBox(height: 24),
                            _buildRecipientSection(),
                            const SizedBox(height: 24),
                            _buildTransferForm(),
                            const SizedBox(height: 24),
                            _buildTransferButton(),
                          ],
                        ),
                      ),
                    ),
                    
                    // Transaction History Tab
                    _buildTransactionHistoryTab(),
                  ],
                ),
          if (_isSearching)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search User',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _searchController,
          labelText: 'Search by ID, Name, Email or Phone',
          hintText: 'Enter ID, name, email or phone number',
          prefixIcon: Icons.search,
          onSuffixPressed: () {
            if (_searchController.text.isNotEmpty) {
              _searchUser(_searchController.text.trim());
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        separatorBuilder:
            (context, index) => Divider(
              color: AppTheme.dividerColor.withOpacity(0.2),
              height: 1,
            ),
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final name = user['full_name'] ?? user['name'] ?? 'Unknown';
          final email = user['email'] ?? 'No email';
          final phone =
              user['phone_number'] ?? user['phonenumber'] ?? 'No phone';

          // Get profile image URL or null if not available
          final profileImage = user['profile_image'] ?? user['avatar_url'];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            // Add profile image as leading widget
            leading: CircleAvatar(
              backgroundColor: AppTheme.goldColor.withOpacity(0.2),
              radius: 24,
              backgroundImage:
                  profileImage != null && profileImage.toString().isNotEmpty
                      ? NetworkImage(
                        profileImage.toString().startsWith('http')
                            ? profileImage.toString()
                            : '${AppConstants.baseUrl}/storage/$profileImage',
                      )
                      : null,
              child:
                  profileImage == null || profileImage.toString().isEmpty
                      ? Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            title: Text(
              name,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppTheme.goldColor,
              ),
              onPressed: () => _selectUser(user),
            ),
            onTap: () => _selectUser(user),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard() {
    final formattedBalance =
        "\$${NumberFormatter.formatCurrency(_cashBalance)}";

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5DD3), Color(0xFF8677F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.goldColor.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5DD3).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cash Wallet Balance',
                    style: GoogleFonts.inter(
                      color: AppTheme.goldColor.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                formattedBalance,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: AppTheme.goldColor.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Available for transfer',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildRecipientSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT RECIPIENTS',
              style: GoogleFonts.inter(
                color: AppTheme.goldColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentRecipients.length,
                itemBuilder: (context, index) {
                  final recipient = _recentRecipients[index];
                  return _buildRecipientItem(
                    name: recipient['full_name'] ?? recipient['name'],
                    email: recipient['email'],
                    profileImage:
                        recipient['profile_image'] ?? recipient['avatar_url'],
                  );
                },
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 700.ms, delay: 100.ms)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildRecipientItem({
    required String name,
    required String email,
    String? profileImage,
  }) {
    return GestureDetector(
      onTap: () {
        // Set selected user with this recipient's information
        setState(() {
          _selectedUser = {
            'full_name': name,
            'email': email,
            'profile_image': profileImage,
          };
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 80,
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.goldColor.withOpacity(0.2),
              backgroundImage:
                  profileImage != null && profileImage.isNotEmpty
                      ? NetworkImage(
                        profileImage.startsWith('http')
                            ? profileImage
                            : '${AppConstants.baseUrl}/storage/$profileImage',
                      )
                      : null,
              child:
                  (profileImage == null || profileImage.isEmpty)
                      ? Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 8),
            Text(
              name.split(' ')[0],
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Display selected recipient information if available
            if (_selectedUser != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.goldColor.withOpacity(0.2),
                      backgroundImage:
                          _selectedUser!.containsKey('profile_image') &&
                                  _selectedUser!['profile_image'] != null &&
                                  _selectedUser!['profile_image']
                                      .toString()
                                      .isNotEmpty
                              ? NetworkImage(
                                _selectedUser!['profile_image']
                                        .toString()
                                        .startsWith('http')
                                    ? _selectedUser!['profile_image'].toString()
                                    : '${AppConstants.baseUrl}/storage/${_selectedUser!['profile_image']}',
                              )
                              : null,
                      child:
                          (!_selectedUser!.containsKey('profile_image') ||
                                  _selectedUser!['profile_image'] == null ||
                                  _selectedUser!['profile_image']
                                      .toString()
                                      .isEmpty)
                              ? Text(
                                (_selectedUser!['full_name'] ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.goldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedUser!['full_name'] ?? 'Unknown',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _selectedUser!['email'] ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.goldColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedUser = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please search and select a recipient first',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              labelText: 'Amount (USDT)',
              hintText: 'Enter amount to transfer',
              prefixIcon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > _cashBalance) {
                  return 'Insufficient balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _noteController,
              labelText: 'Note (Optional)',
              hintText: 'Add a note for this transfer',
              prefixIcon: Icons.note_alt_outlined,
              maxLines: 2,
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 800.ms, delay: 200.ms)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onSuffixPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(prefixIcon, color: AppTheme.goldColor, size: 20),
          suffixIcon:
              onSuffixPressed != null
                  ? IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppTheme.goldColor,
                      size: 20,
                    ),
                    onPressed: onSuffixPressed,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }
  
  Widget _buildTransferButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF34C759), Color(0xFF2A9F49)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34C759).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _transferFunds,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              'Transfer Funds',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 900.ms, delay: 300.ms)
    .slideY(
      begin: 0.10,
      end: 0,
      duration: 900.ms,
      curve: Curves.easeOutCubic,
    );
  }
  
  // Load transaction history
  Future<void> _loadTransactionHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _transactions = [];
        _hasMoreTransactions = true;
      });
    }
    
    if (!_hasMoreTransactions) return;
    
    try {
      setState(() => _isLoadingTransactions = true);
      
      final response = await ApiService.getWalletTransactions(
        walletType: 'cash_wallet',
        page: _currentPage,
        perPage: 10,
      );
      
      if (response['status'] == 'success' && response['data'] != null) {
        try {
          final transactionData = response['data'];
          
          // Check if transactionData has the expected structure
          if (transactionData == null || !(transactionData is Map)) {
            developer.log('Invalid transaction data structure: $transactionData', name: 'MTI_Swap');
            setState(() => _hasMoreTransactions = false);
            return;
          }
          
          // Safely extract the transactions list
          final transactions = transactionData['data'];
          if (transactions == null || !(transactions is List)) {
            developer.log('Invalid or missing transactions list: $transactions', name: 'MTI_Swap');
            setState(() => _hasMoreTransactions = false);
            return;
          }
          
          // Safely extract metadata
          final metadata = transactionData['meta'] is Map ? transactionData['meta'] : {};
          
          // Safely parse transactions
          final List<Map<String, dynamic>> parsedTransactions = [];
          for (var i = 0; i < transactions.length; i++) {
            try {
              if (transactions[i] is Map) {
                parsedTransactions.add(Map<String, dynamic>.from(transactions[i]));
              }
            } catch (e) {
              developer.log('Error parsing transaction at index $i: $e', name: 'MTI_Swap');
            }
          }
          
          setState(() {
            if (refresh) {
              _transactions = parsedTransactions;
            } else {
              _transactions.addAll(parsedTransactions);
            }
            
            // Update pagination information
            _currentPage = metadata['current_page'] ?? _currentPage;
            _totalPages = metadata['last_page'] ?? 1;
            _hasMoreTransactions = _currentPage < _totalPages;
          });
          
          developer.log('Successfully parsed ${parsedTransactions.length} transactions, page $_currentPage of $_totalPages', name: 'MTI_Swap');
        } catch (e) {
          developer.log('Error parsing transaction data: $e', name: 'MTI_Swap');
          setState(() => _hasMoreTransactions = false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Failed to load transaction history',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      developer.log('Error loading transaction history: $e', name: 'MTI_Swap');
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('Failed to load transaction history'),
      //   backgroundColor: Colors.red,
      // ));
    } finally {
      setState(() => _isLoadingTransactions = false);
    }
  }
  
  // Build transaction history tab
  Widget _buildTransactionHistoryTab() {
    // Show loading indicator if loading first page
    if (_isLoadingTransactions && _transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Show empty state if no transactions
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    // Show transaction list
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            // Guard against potential data inconsistencies
            itemCount: _transactions.length + (_hasMoreTransactions ? 1 : 0),
            itemBuilder: (context, index) {
              // Handle the load more indicator case
              if (index == _transactions.length && _hasMoreTransactions) {
                _loadTransactionHistory();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Guard against index out of bounds
              if (index >= _transactions.length) {
                developer.log('Index out of range: $index, length: ${_transactions.length}', name: 'MTI_Swap');
                return const SizedBox.shrink();
              }
                        
                        // Safely access transaction data with robust null checking
                        final transaction = _transactions[index];
                        
                        // Add debug log to identify problematic transactions
                        developer.log('Processing transaction at index $index: ${transaction.toString()}', name: 'MTI_Swap');
                        
                        // Safely determine if transaction is outgoing
                        final isOutgoing = transaction['direction']?.toString() == 'out';
                        
                        // Safely extract recipient/sender name with multiple fallbacks
                        String otherPartyName = 'Unknown';
                        try {
                          if (isOutgoing && transaction['recipient'] != null) {
                            if (transaction['recipient'] is Map) {
                              otherPartyName = transaction['recipient']['full_name']?.toString() ?? 
                                            transaction['recipient']['name']?.toString() ?? 
                                            transaction['recipient']['email']?.toString() ?? 'Unknown';
                            }
                          } else if (!isOutgoing && transaction['sender'] != null) {
                            if (transaction['sender'] is Map) {
                              otherPartyName = transaction['sender']['full_name']?.toString() ?? 
                                            transaction['sender']['name']?.toString() ?? 
                                            transaction['sender']['email']?.toString() ?? 'Unknown';
                            }
                          }
                        } catch (e) {
                          developer.log('Error extracting name from transaction: $e', name: 'MTI_Swap');
                        }
                        
                        // Safely parse amount
                        final amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
                        
                        // Safely parse date
                        final date = DateTime.tryParse(transaction['created_at']?.toString() ?? '') ?? DateTime.now();
                        
                        return _buildTransactionItem(
                          amount: amount,
                          otherPartyName: otherPartyName,
                          date: date,
                          isOutgoing: isOutgoing,
                          status: transaction['status'] ?? 'unknown',
                        );
                      },
                    ),
                  ),
                ],
              );
  }

  // Build individual transaction item
  // Show a success dialog after transfer completes
  void _showTransferSuccessDialog(double amount, String recipientName) {
    final formattedAmount = NumberFormatter.formatCurrency(amount);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppTheme.secondaryBackgroundColor,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
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
                const SizedBox(height: 12),
                Text(
                  'You have successfully transferred',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$$formattedAmount',
                  style: GoogleFonts.inter(
                    color: AppTheme.goldColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'to $recipientName',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.goldColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTransactionItem({
    required double amount,
    required String otherPartyName,
    required DateTime date,
    required bool isOutgoing,
    required String status,
  }) {
    final formattedAmount = NumberFormatter.formatCurrency(amount);
    final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    final isSuccess = status.toLowerCase() == 'success';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isOutgoing ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
            color: isOutgoing ? Colors.red : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                isOutgoing ? 'To $otherPartyName' : 'From $otherPartyName',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${isOutgoing ? '-' : '+'} \$$formattedAmount',
              style: GoogleFonts.inter(
                color: isOutgoing ? Colors.red : Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                formattedDate,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isSuccess ? 'Success' : 'Failed',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
