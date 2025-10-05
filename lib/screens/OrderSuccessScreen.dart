import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/fragment/HomeFragment.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/HomeScreen.dart';
import 'package:room_finder_flutter/utils/SSWidgets.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;

  const OrderSuccessScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Order Confirmation", style: boldTextStyle()),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Progress indicator (all steps completed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.grey, size: 24),
                ...List.generate(3, (index) => _buildProgressDot(true)),
                Icon(Icons.location_on, color: Colors.grey, size: 24),
                ...List.generate(3, (index) => _buildProgressDot(true)),
                Icon(Icons.credit_card, color: Colors.grey, size: 24),
                ...List.generate(3, (index) => _buildProgressDot(true)),
                Icon(Icons.verified, color: Colors.green, size: 24),
              ],
            ),
            32.height,
            
            // Success content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  24.height,
                  Text("Order Successful!", style: boldTextStyle(size: 24)),
                  16.height,
                  Text(
                    "Thank you for your purchase! Your order has been confirmed.",
                    style: secondaryTextStyle(size: 16),
                    textAlign: TextAlign.center,
                  ),
                  24.height,
                  
                  // Order details
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text("Order Details", style: boldTextStyle(size: 16)),
                        12.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Order ID:", style: secondaryTextStyle()),
                            Text("#${order.id}", style: boldTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Amount:", style: secondaryTextStyle()),
                            Text("\$${order.totalPaid.toStringAsFixed(2)}", style: boldTextStyle(color: Colors.green)),
                          ],
                        ),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status:", style: secondaryTextStyle()),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status,
                                style: boldTextStyle(size: 12, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Text(
                    "You will receive an email confirmation shortly. Your items will be shipped within 2-3 business days.",
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Continue shopping button
            sSAppButton(
              context: context,
              title: 'Continue Shopping',
              onPressed: () {
                HomeScreen().launch(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}