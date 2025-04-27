import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/routes.dart';

import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  int _selectedPeriod = 1; // 0: Day, 1: Week, 2: Month, 3: Year
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];
  bool _isBalanceVisible = true;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    // Use a longer duration to reduce frame rate and buffer usage
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat(reverse: false);
    
    // Add a small delay before starting animations to prevent initial buffer overload
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Smooth scrolling for Android
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBalanceCard(),
              _buildChartSection(),
              _buildLatestTransactions(),
              const SizedBox(height: 100), // Space for bottom nav bar
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Faiz Gusion",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.notification);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.settings);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackgroundColor,
                    border: Border.all(
                      color: AppTheme.goldColor.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        children: [
          // First animated shine effect - horizontal sweep
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppTheme.goldColor.withOpacity(0.1),
                        AppTheme.goldColor.withOpacity(0.3),
                        Colors.white.withOpacity(0.4),
                        AppTheme.goldColor.withOpacity(0.3),
                        AppTheme.goldColor.withOpacity(0.1),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.33, 0.4, 0.5, 0.6, 0.67, 0.7, 1.0],
                      transform: GradientRotation(
                        (2 * 3.14159 * _animationController.value) - (3.14159 / 4),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Second animated shine effect - diagonal sweep
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppTheme.goldColor.withOpacity(0.2),
                        AppTheme.goldColor.withOpacity(0.6),
                        Colors.white.withOpacity(0.5),
                        AppTheme.goldColor.withOpacity(0.6),
                        AppTheme.goldColor.withOpacity(0.2),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 0.73, 0.8, 0.85, 0.9, 0.93, 0.95, 1.0],
                      transform: GradientRotation(
                        3.14159 - (2 * 3.14159 * _animationController.value),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Edge glow effect with shadow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppTheme.goldColor.withOpacity(0.8),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          // Main card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0A0A),
                  Colors.black,
                  const Color(0xFF0A0A0A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.goldColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Balance",
                      style: GoogleFonts.montserrat(
                        color: AppTheme.goldColor.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                      child: Icon(
                        _isBalanceVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedCrossFade(
                  firstChild: Text(
                    "12,580.42 USDT",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  secondChild: Text(
                    "••••••••••",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  crossFadeState: _isBalanceVisible
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      color: Colors.greenAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    AnimatedCrossFade(
                      firstChild: Text(
                        "+1,245.80 USDT (10.8%)",
                        style: GoogleFonts.inter(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondChild: Text(
                        "••••••••••",
                        style: GoogleFonts.inter(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      crossFadeState: _isBalanceVisible
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.depositGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.successColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.deposit);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Deposit",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.withdrawGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.errorColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.withdraw);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.arrow_downward, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Withdraw",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
      begin: 0.1,
      end: 0,
      delay: 200.ms,
      duration: 500.ms,
      curve: Curves.easeOutQuad,
    );
  }

  Widget _buildChartSection() {
    // Different gradient colors for each time period
    final List<LinearGradient> chartGradients = [
      // Day - Green gradient
      const LinearGradient(
        colors: [Color(0xFF00C566), Color(0xFF00E676)],
      ),
      // Week - Purple gradient (primary)
      const LinearGradient(
        colors: [AppTheme.primaryColor, AppTheme.accentColor],
      ),
      // Month - Blue gradient
      const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF00B2FF)],
      ),
      // Year - Gold gradient
      AppTheme.goldGradient,
    ];
    
    // Different area gradient colors for each time period
    final List<LinearGradient> areaGradients = [
      // Day
      LinearGradient(
        colors: [
          const Color(0xFF00C566).withOpacity(0.3),
          const Color(0xFF00E676).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      // Week
      LinearGradient(
        colors: [
          AppTheme.primaryColor.withOpacity(0.3),
          AppTheme.accentColor.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      // Month
      LinearGradient(
        colors: [
          const Color(0xFF2196F3).withOpacity(0.3),
          const Color(0xFF00B2FF).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      // Year
      LinearGradient(
        colors: [
          AppTheme.goldColor.withOpacity(0.3),
          const Color(0xFFDAA520).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Portfolio Performance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "+10.8%",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _periods.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedPeriod == index;
                // Get the appropriate color for each period tab
                final Color periodColor = index == 0 
                    ? const Color(0xFF00C566) // Day - Green
                    : index == 1 
                        ? AppTheme.primaryColor // Week - Purple
                        : index == 2 
                            ? const Color(0xFF2196F3) // Month - Blue
                            : AppTheme.goldColor; // Year - Gold
                            
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? periodColor
                          : AppTheme.secondaryBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: periodColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        _periods[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.secondaryTextColor,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.dividerColor.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: AppTheme.tertiaryTextColor,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Mon', style: style);
                            break;
                          case 2:
                            text = const Text('Wed', style: style);
                            break;
                          case 4:
                            text = const Text('Fri', style: style);
                            break;
                          case 6:
                            text = const Text('Sun', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: AppTheme.tertiaryTextColor,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = '10k';
                            break;
                          case 2:
                            text = '12k';
                            break;
                          case 4:
                            text = '14k';
                            break;
                          default:
                            return Container();
                        }
                        return Text(text, style: style);
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 2.5),
                      FlSpot(2, 3.5),
                      FlSpot(3, 3.2),
                      FlSpot(4, 4),
                      FlSpot(5, 3.8),
                      FlSpot(6, 4.5),
                    ],
                    isCurved: true,
                    gradient: chartGradients[_selectedPeriod],
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: _selectedPeriod == 0 
                              ? const Color(0xFF00C566) // Day - Green
                              : _selectedPeriod == 1 
                                  ? AppTheme.primaryColor // Week - Purple
                                  : _selectedPeriod == 2 
                                      ? const Color(0xFF2196F3) // Month - Blue
                                      : AppTheme.goldColor, // Year - Gold
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: areaGradients[_selectedPeriod],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildLatestTransactions() {
    final List<Map<String, dynamic>> transactions = [
      {
        'icon': Icons.card_travel_outlined,
        'color': AppTheme.primaryColor,
        'title': 'Travel Package',
        'subtitle': 'Bali Vacation',
        'amount': '-1,200 USDT',
        'isPositive': false,
        'date': 'Apr 22, 2025',
      },
      {
        'icon': Icons.currency_bitcoin,
        'color': AppTheme.accentColor,
        'title': 'Staking Reward',
        'subtitle': 'XLM Staking',
        'amount': '+45.80 USDT',
        'isPositive': true,
        'date': 'Apr 20, 2025',
      },
      {
        'icon': Icons.people_outline,
        'color': AppTheme.tertiaryColor,
        'title': 'Referral Bonus',
        'subtitle': 'From: Jane Smith',
        'amount': '+200 USDT',
        'isPositive': true,
        'date': 'Apr 18, 2025',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Latest Transactions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: transaction['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        transaction['icon'],
                        color: transaction['color'],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction['subtitle'],
                            style: const TextStyle(
                              color: AppTheme.tertiaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction['amount'],
                          style: TextStyle(
                            color: transaction['isPositive']
                                ? Colors.green
                                : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction['date'],
                          style: const TextStyle(
                            color: AppTheme.tertiaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }
}
