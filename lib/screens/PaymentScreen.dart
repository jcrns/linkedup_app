import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/OrderSuccessScreen.dart';
import 'package:room_finder_flutter/services/CheckoutService.dart';
import 'package:room_finder_flutter/services/CartService.dart';
import 'package:room_finder_flutter/utils/SSWidgets.dart';

class PaymentScreen extends StatefulWidget {
  final Cart cart;
  final ShippingAddress shippingAddress;

  const PaymentScreen({
    Key? key,
    required this.cart,
    required this.shippingAddress,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentIndex = 0;
  List<PaymentMethod> _paymentMethods = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    setState(() {
      _paymentMethods = CheckoutService.getPaymentMethods();
    });
  }

  // In PaymentScreen.dart - update _placeOrder method

  Future<void> _placeOrder() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      int shippingAddressId;
      
      print('Placing order with shipping address: ${widget.shippingAddress.toJson()}');
      // Check if we're using an existing saved address
      if (widget.shippingAddress.id != null) {
        // Use the existing address ID
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        print('Found user ID in prefs: $userId');

        shippingAddressId = userId != null ? int.parse(userId) : -1;
        print('Using existing shipping address ID: $shippingAddressId');
      } else {
        // Create new shipping address with deduplication
        final savedAddress = await CheckoutService.createShippingAddress(widget.shippingAddress);
        shippingAddressId = savedAddress.id!;
        print('Created new shipping address ID: $shippingAddressId');
      }
      print("Here");
      
      // Then create the order
      final order = await CheckoutService.createOrder(
        shippingAddressId: shippingAddressId,
        cart: widget.cart,
        shippingCost: 0.0, // Free shipping for now
        taxRate: 0.08, // 8% tax
      );

      // Clear the cart
      await CartService.clearCart();

      // Navigate to success screenF
      OrderSuccessScreen(order: order).launch(context);
      
    } catch (e) {
      toast('Error placing order: $e');
      print('Order error: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.cart.subtotal;
    final tax = subtotal * 0.08;
    final shipping = 0.0;
    final total = subtotal + tax + shipping;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Checkout", style: boldTextStyle()),
        leading: InkWell(
          onTap: () {
            finish(context);
          },
          child: Icon(Icons.arrow_back_ios, color: context.iconColor, size: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  _buildProgressIndicator(),
                  32.height,
                  
                  Text("Payment Method", style: boldTextStyle(size: 18)),
                  16.height,
                  
                  // Payment methods
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      return _buildPaymentMethod(method, index);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Order summary
          _buildOrderSummary(subtotal, tax, shipping, total),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart, color: Color(0xff808080), size: 24),
        ...List.generate(3, (index) => _buildProgressDot(true)),
        Icon(Icons.location_on, color: Color(0xff808080), size: 24),
        ...List.generate(3, (index) => _buildProgressDot(true)),
        Icon(Icons.credit_card, color: Colors.blue, size: 24),
        ...List.generate(3, (index) => _buildProgressDot(false)),
        Icon(Icons.verified, color: Color(0xff808080), size: 24),
      ],
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Color(0x1f000000),
        shape: BoxShape.circle,
        border: Border.all(color: isActive ? Colors.blue : Color(0x4d9e9e9e), width: 1),
      ),
    );
  }

  Widget _buildPaymentMethod(PaymentMethod method, int index) {
    final isSelected = _selectedPaymentIndex == index;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentIcon(method.type),
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        title: Text(method.name, style: boldTextStyle()),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Colors.blue)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: () {
          setState(() {
            _selectedPaymentIndex = index;
          });
        },
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.payment;
      case 'bank':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  Widget _buildOrderSummary(double subtotal, double tax, double shipping, double total) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Subtotal', style: secondaryTextStyle())),
              Text('\$${subtotal.toStringAsFixed(2)}', style: boldTextStyle()),
            ],
          ),
          8.height,
          Row(
            children: [
              Expanded(child: Text('Tax (8%)', style: secondaryTextStyle())),
              Text('\$${tax.toStringAsFixed(2)}', style: boldTextStyle()),
            ],
          ),
          8.height,
          Row(
            children: [
              Expanded(child: Text('Shipping', style: secondaryTextStyle())),
              Text('\$${shipping.toStringAsFixed(2)}', style: boldTextStyle()),
            ],
          ),
          12.height,
          Divider(color: Colors.grey),
          12.height,
          Row(
            children: [
              Expanded(child: Text('Total Payment', style: boldTextStyle(size: 16))),
              Text('\$${total.toStringAsFixed(2)}', style: boldTextStyle(size: 18, color: Colors.green)),
            ],
          ),
          16.height,
          sSAppButton(
            context: context,
            title: _isProcessing ? 'Processing...' : 'Place Order',
            onPressed: _isProcessing ? null : _placeOrder,
          ),
        ],
      ),
    );
  }
}