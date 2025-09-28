// CoinPage.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/services/UserService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';

class CoinPage extends StatefulWidget {
  @override
  _CoinPageState createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  Map<String, int>? coinBalances;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoinData();
  }

  Future<void> _fetchCoinData() async {
    setState(() => isLoading = true);
    try {
      final coins = await UserService.getCoinBalances();
      setState(() {
        coinBalances = coins;
        isLoading = false;
      });
    } catch (e) {
      toast('Failed to load coin data');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Coins', style: boldTextStyle(color: Colors.white)),
        backgroundColor: rf_primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCoinCard('Spend Coins', coinBalances?['spend_coins'] ?? 0, rf_primaryColor,
                      'For booking rooms and services'),
                  16.height,
                  _buildCoinCard('Give Coins', coinBalances?['give_coins'] ?? 0, Colors.green,
                      'For gifting to other users'),
                  16.height,
                  _buildCoinCard('Invest Coins', coinBalances?['invest_coins'] ?? 0, Colors.blueAccent,
                      'For long-term investments'),
                  30.height,
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Add Funds',
                          color: rf_primaryColor,
                          textColor: Colors.white,
                          onTap: () => toast('Add funds feature coming soon'),
                        ),
                      ),
                      16.width,
                      Expanded(
                        child: AppButton(
                          text: 'Withdraw',
                          color: Colors.grey[300]!,
                          textColor: Colors.black,
                          onTap: () => toast('Withdraw feature coming soon'),
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationRoundedWithShadow(8, backgroundColor: context.cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vouchers', style: boldTextStyle(size: 18)),
                        16.height,
                        Text('Your voucher section will appear here', style: secondaryTextStyle()),
                        20.height,
                        AppButton(
                          text: 'Redeem Voucher',
                          color: rf_primaryColor,
                          textColor: Colors.white,
                          onTap: () => toast('Voucher redemption coming soon'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCoinCard(String title, int amount, Color color, String description) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationRoundedWithShadow(8, backgroundColor: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: boldTextStyle(size: 18)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$amount', style: boldTextStyle(color: color)),
              ),
            ],
          ),
          8.height,
          Text(description, style: secondaryTextStyle()),
          12.height,
          LinearProgressIndicator(
            value: (amount / 1000).clamp(0.0, 1.0),
            backgroundColor: context.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}