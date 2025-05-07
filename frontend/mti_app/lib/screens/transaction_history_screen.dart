import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mti_app/models/transaction_model.dart';
import 'package:mti_app/services/api_service.dart';
import 'package:mti_app/screens/transaction_receipt_screen.dart';
import '../config/theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _error = '';
  int _currentPage = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _transactions.clear();
        _hasMore = true;
        _error = '';
      });
    }
    if (!_hasMore && !refresh) return;
    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
      } else {
        _loadingMore = true;
      }
    });
    debugPrint('[MTI_Transactions] Fetching page $_currentPage');
    try {
      final result = await ApiService.getWalletTransactions(
        walletType: 'cash_wallet',
        page: _currentPage,
        perPage: _perPage,
      );
      debugPrint('[MTI_Transactions] API response: ' + result.toString());
      if (result['status'] == 'success' &&
          result['data'] != null &&
          result['data']['data'] != null) {
        final List<dynamic> txs = result['data']['data'];
        final List<Transaction> fetched =
            txs.map((e) => Transaction.fromJson(e)).toList();
        setState(() {
          if (_currentPage == 1) _transactions.clear();
          _transactions.addAll(fetched);
          _hasMore = fetched.length >= _perPage;
          _currentPage++;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load transactions';
          _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint('[MTI_Transactions] Exception: $e');
      setState(() {
        _error = 'An error occurred while loading transactions';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              )
              : _transactions.isEmpty
              ? const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !_loadingMore &&
                      _hasMore) {
                    _fetchTransactions();
                    return true;
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: _transactions.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _transactions.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final tx = _transactions[index];

                    // Format date as HH:mm - dd/MM/yyyy
                    final formattedDate =
                        '${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')} - '
                        '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}';

                    // Compose sender/recipient display
                    String parties = '';
                    if (tx.isIncoming && tx.senderName != null) {
                      parties = 'From: ${tx.senderName}';
                    } else if (tx.isOutgoing && tx.recipientName != null) {
                      parties = 'To: ${tx.recipientName}';
                    }

                    // Compose wallet type
                    String wallet =
                        tx.walletType != null
                            ? tx.walletType!.replaceAll('_', ' ').toUpperCase()
                            : '';

                    // Modern card UI
                    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  child: Material(
    color: Colors.transparent,
    elevation: 0,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: tx.isIncoming
              ? Colors.green.withOpacity(0.22)
              : Colors.red.withOpacity(0.22),
          width: 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        onTap: () => Get.to(() => TransactionReceiptScreen(transaction: tx)),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor:
              tx.isIncoming ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
          child: Icon(
            tx.isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: tx.isIncoming ? Colors.green : Colors.red,
            size: 27,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                tx.type[0].toUpperCase() + tx.type.substring(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              (tx.isIncoming ? '+' : '-') + tx.amount.toStringAsFixed(2),
              style: TextStyle(
                color: tx.isIncoming ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (parties.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        tx.isIncoming ? Icons.person_rounded : Icons.person_outline_rounded,
                        color: Colors.blueGrey[200],
                        size: 15.5,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          parties,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13.2,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (wallet.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: Colors.amberAccent, size: 15.5),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Wallet: $wallet',
                          style: TextStyle(
                            color: Colors.amber[200],
                            fontSize: 13.2,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.grey[400], size: 14.5),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 24),
      ),
    ),
  ),
);
                  },
                ),
              ),
    );
  }
}
