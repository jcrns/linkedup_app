import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/OrderCardComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/utils/SSWidgets.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: boldTextStyle()),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #${widget.order.id}', style: boldTextStyle(size: 18)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(widget.order.status)),
                          ),
                          child: Text(
                            widget.order.status,
                            style: boldTextStyle(
                              size: 12,
                              color: _getStatusColor(widget.order.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    12.height,
                    _buildDetailRow('Order Date', _formatDate(widget.order.createdAt)),
                    _buildDetailRow('Email', widget.order.userEmail ?? 'N/A'),
                    if (widget.order.stripeId != null)
                      _buildDetailRow('Transaction ID', widget.order.stripeId!),
                  ],
                ),
              ),
            ),
            16.height,

            // Delivery Progress
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Progress', style: boldTextStyle(size: 16)),
                    16.height,
                    _buildDeliveryTimeline(),
                  ],
                ),
              ),
            ),
            16.height,

            // Shipping Address
            if (widget.order.shippingAddress != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipping Address', style: boldTextStyle(size: 16)),
                      12.height,
                      _buildAddressInfo(widget.order.shippingAddress!),
                    ],
                  ),
                ),
              ),
            16.height,

            // Order Items
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Items', style: boldTextStyle(size: 16)),
                    12.height,
                    ...widget.order.items.map((item) => _buildOrderItem(item)).toList(),
                    16.height,
                    Divider(),
                    8.height,
                    _buildOrderTotals(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: secondaryTextStyle()),
          Text(value, style: primaryTextStyle()),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeline() {
    final steps = [
      _TimelineStep('Order Placed', 'We\'ve received your order', Icons.shopping_cart),
      _TimelineStep('Processing', 'We\'re preparing your items', Icons.inventory_2),
      _TimelineStep('Shipped', 'Your order is on the way', Icons.local_shipping),
      _TimelineStep('Delivered', 'Order delivered successfully', Icons.check_circle),
    ];

    final currentStatus = widget.order.status.toLowerCase();
    final currentIndex = steps.indexWhere((step) => 
        step.title.toLowerCase() == currentStatus);

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and icon
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon, size: 16, color: Colors.white),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            12.width,
            // Step content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: boldTextStyle(
                      color: isCompleted ? Colors.green : Colors.grey,
                    )),
                    4.height,
                    Text(step.description, style: secondaryTextStyle(size: 12)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAddressInfo(ShippingAddress address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.fullName, style: boldTextStyle()),
        if (address.email.isNotEmpty) Text(address.email, style: secondaryTextStyle()),
        Text(address.address1, style: secondaryTextStyle()),
        if (address.address2 != null && address.address2!.isNotEmpty)
          Text(address.address2!, style: secondaryTextStyle()),
        Text('${address.city}, ${address.state ?? ''} ${address.zipcode ?? ''}', 
            style: secondaryTextStyle()),
        Text(address.country, style: secondaryTextStyle()),
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImage != null && item.productImage!.isNotEmpty
                ? Image.network(
                    item.productImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.shopping_bag, color: Colors.grey);
                    },
                  )
                : Icon(Icons.shopping_bag, color: Colors.grey),
          ),
          12.width,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Product',
                  style: boldTextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: secondaryTextStyle(size: 12),
                    ),
                    Text(
                      '\$${item.cost.toStringAsFixed(2)}',
                      style: boldTextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotals() {
    return Column(
      children: [
        _buildTotalRow('Subtotal', _calculateSubtotal()),
        _buildTotalRow('Shipping', widget.order.shippingCost),
        _buildTotalRow('Tax', _calculateTax()),
        Divider(),
        _buildTotalRow('Total', widget.order.totalPaid, isTotal: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? boldTextStyle() : secondaryTextStyle()),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal 
                ? boldTextStyle(size: 16, color: Colors.green)
                : primaryTextStyle(),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return widget.order.items.fold(0.0, (sum, item) => sum + item.cost);
  }

  double _calculateTax() {
    return _calculateSubtotal() * widget.order.taxRate;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'shipped': return Colors.blue;
      case 'processing': return Colors.orange;
      case 'pending': return Colors.yellow[700]!;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TimelineStep {
  final String title;
  final String description;
  final IconData icon;

  _TimelineStep(this.title, this.description, this.icon);
}