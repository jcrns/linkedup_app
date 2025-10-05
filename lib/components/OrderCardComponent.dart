import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/OrderDetailScreen.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.yellow[700]!;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'processing':
        return Icons.hourglass_empty;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {
          OrderDetailScreen(order: order).launch(context);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: boldTextStyle(size: 16),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          size: 14,
                          color: _getStatusColor(order.status),
                        ),
                        4.width,
                        Text(
                          order.status,
                          style: primaryTextStyle(
                            size: 12,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              12.height,
              
              // Order Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  8.width,
                  Text(
                    'Placed on ${_formatDate(order.createdAt)}',
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ),
              8.height,
              
              // Items Summary
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                  8.width,
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ),
              8.height,
              
              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Paid:',
                    style: primaryTextStyle(),
                  ),
                  Text(
                    '\$${order.totalPaid.toStringAsFixed(2)}',
                    style: boldTextStyle(size: 16, color: Colors.green),
                  ),
                ],
              ),
              8.height,
              
              // Progress Bar for Order Status
              _buildProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Pending', 'Processing', 'Shipped', 'Delivered'];
    final currentIndex = steps.indexWhere((step) => 
        step.toLowerCase() == order.status.toLowerCase());
    
    return Column(
      children: [
        8.height,
        LinearProgressIndicator(
          value: currentIndex >= 0 ? (currentIndex + 1) / steps.length : 0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(order.status)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        4.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((step) {
            final isCompleted = steps.indexOf(step) <= currentIndex;
            final isCurrent = steps.indexOf(step) == currentIndex;
            
            return Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? _getStatusColor(order.status) : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(
                      color: _getStatusColor(order.status),
                      width: 2,
                    ) : null,
                  ),
                ),
                4.height,
                Text(
                  step,
                  style: secondaryTextStyle(
                    size: 8,
                    color: isCompleted ? _getStatusColor(order.status) : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.month}/${date.day}/${date.year}';
  }
}