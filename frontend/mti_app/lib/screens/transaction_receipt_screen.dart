import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mti_app/config/theme.dart';
import 'package:mti_app/models/transaction_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

class TransactionReceiptScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Transaction Receipt",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _isProcessing ? null : _shareReceipt,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              RepaintBoundary(
                key: _receiptKey,
                child: _buildReceiptCard(screenWidth),
              ),
              const SizedBox(height: 20),
              _buildDownloadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(double screenWidth) {
    return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppTheme.goldColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Gold border gradient at the top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldColor.withOpacity(0.7),
                          AppTheme.goldColor,
                          AppTheme.goldColor.withOpacity(0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with logo and transaction ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MTI",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Text(
                                "Meta Travel International",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.qr_code,
                                size: 40,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Transaction Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getTransactionTypeText(),
                          style: TextStyle(
                            color: _getTypeColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Amount Display
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "${widget.transaction.isIncoming ? '+' : '-'}${widget.transaction.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _getTypeColor(),
                              ),
                            ),
                            Text(
                              widget.transaction.currency,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Transaction Status
                      _buildInfoRow(
                        "Status",
                        widget.transaction.status.toUpperCase(),
                        valueColor: _getStatusColor(),
                      ),

                      // Date & Time
                      _buildInfoRow(
                        "Date & Time",
                        DateFormat(
                          'MMMM dd, yyyy • hh:mm a',
                        ).format(widget.transaction.date),
                      ),

                      // Transaction ID / Reference Code
                      _buildInfoRow(
                        "Transaction ID",
                        widget.transaction.referenceCode,
                      ),

                      // Wallet Type
                      if (widget.transaction.walletType != null)
                        _buildInfoRow(
                          "Wallet",
                          _getWalletTypeFormatted(
                            widget.transaction.walletType!,
                          ),
                        ),

                      // Description
                      if (widget.transaction.description.isNotEmpty)
                        _buildInfoRow(
                          "Description",
                          widget.transaction.description,
                        ),

                      // Sender/Recipient Information
                      if (widget.transaction.type.toLowerCase() == 'sent' ||
                          widget.transaction.type.toLowerCase() == 'transfer')
                        _buildInfoRow(
                          "Recipient",
                          widget.transaction.recipientName ??
                              widget.transaction.recipientEmail ??
                              "N/A",
                        ),

                      if (widget.transaction.type.toLowerCase() == 'received')
                        _buildInfoRow(
                          "Sender",
                          widget.transaction.senderName ??
                              widget.transaction.senderEmail ??
                              "N/A",
                        ),

                      // Balance Before/After
                      if (widget.transaction.balanceBefore != null)
                        _buildInfoRow(
                          "Balance Before",
                          "${widget.transaction.balanceBefore!.toStringAsFixed(2)} ${widget.transaction.currency}",
                        ),

                      if (widget.transaction.balanceAfter != null)
                        _buildInfoRow(
                          "Balance After",
                          "${widget.transaction.balanceAfter!.toStringAsFixed(2)} ${widget.transaction.currency}",
                        ),

                      // Notes
                      if (widget.transaction.notes != null &&
                          widget.transaction.notes!.isNotEmpty)
                        _buildInfoRow("Notes", widget.transaction.notes!),

                      // Timestamp and footer
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Thank you for using MTI",
                          style: TextStyle(
                            color: AppTheme.goldColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "This is an electronic receipt",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Verification: ${widget.transaction.referenceCode.substring(0, min(8, widget.transaction.referenceCode.length))}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 500))
        .slideY(
          begin: 20,
          end: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _captureAndSaveReceipt,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon:
            _isProcessing
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                  ),
                )
                : const Icon(Icons.download_rounded),
        label: Text(
          _isProcessing ? "Processing..." : "Download Receipt",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _captureAndSaveReceipt() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      // Capture the receipt as an image
      final imageBytes = await _captureReceipt();
      if (imageBytes == null) {
        throw Exception('Failed to capture receipt');
      }

      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'MTI_Receipt_${widget.transaction.referenceCode.substring(0, min(8, widget.transaction.referenceCode.length))}_${DateFormat('yyyyMMdd').format(widget.transaction.date)}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Copy to downloads folder if on Android
      String saveLocation = file.path;
      if (Platform.isAndroid) {
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            final downloadFile = File('${downloadsDir.path}/$fileName');
            await file.copy(downloadFile.path);
            saveLocation = downloadFile.path;
          }
        } catch (e) {
          // If fails, just use the temp file
          developer.log(
            'Could not save to downloads: $e',
            name: 'MTI_ReceiptCapture',
          );
        }
      }

      // Success notification
      Get.snackbar(
        'Success',
        'Receipt saved to: $saveLocation',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      developer.log(
        'Error capturing receipt: $e',
        name: 'MTI_ReceiptCapture',
        error: e,
      );

      // Error notification
      Get.snackbar(
        'Error',
        'Failed to save receipt: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _shareReceipt() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      // Capture the receipt as an image
      final imageBytes = await _captureReceipt();
      if (imageBytes == null) {
        throw Exception('Failed to capture receipt');
      }

      // Save to a temporary file for sharing
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'MTI_Receipt_${widget.transaction.referenceCode.substring(0, min(8, widget.transaction.referenceCode.length))}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'MTI Transaction Receipt',
        subject: 'Transaction Receipt from MTI App',
      );
    } catch (e) {
      developer.log(
        'Error sharing receipt: $e',
        name: 'MTI_ReceiptShare',
        error: e,
      );

      Get.snackbar(
        'Error',
        'Failed to share receipt: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<Uint8List?> _captureReceipt() async {
    try {
      // Find the render object
      final RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Capture the image with high quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      developer.log(
        'Error capturing receipt: $e',
        name: 'MTI_ReceiptCapture',
        error: e,
      );
      return null;
    }
  }

  // Helper methods
  Color _getTypeColor() {
    return widget.transaction.isIncoming ? Colors.green : Colors.red;
  }

  Color _getStatusColor() {
    switch (widget.transaction.status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'failed':
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTransactionTypeText() {
    switch (widget.transaction.type.toLowerCase()) {
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'transfer':
      case 'sent':
        return 'Transfer';
      case 'received':
        return 'Received';
      case 'commission':
        return 'Commission';
      case 'fee':
        return 'Fee';
      default:
        return widget.transaction.type;
    }
  }

  String _getWalletTypeFormatted(String walletType) {
    final formattedType = walletType.replaceAll('_', ' ');
    return formattedType
        .split(' ')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}

int min(int a, int b) => a < b ? a : b;
