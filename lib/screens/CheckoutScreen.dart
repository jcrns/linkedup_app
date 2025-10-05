import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/BillingAddressScreen.dart';
import 'package:room_finder_flutter/services/CartService.dart';
import 'package:room_finder_flutter/services/CheckoutService.dart';
import 'package:room_finder_flutter/utils/SSWidgets.dart';
import 'package:room_finder_flutter/components/OrderCardComponent.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback onGoExplore;

  CheckoutScreen({
    Key? key,
    required this.onGoExplore,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Cart _cart = Cart();
  bool _isLoading = true;
  List<Order> _orders = [];
  int _currentTab = 0; // 0 for Cart, 1 for Orders

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cart = await CartService.getCart();
      final orders = await CheckoutService.getOrders();
      
      setState(() {
        _cart = cart;
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(int productId, int newQuantity) async {
    await CartService.updateQuantity(productId, newQuantity);
    await _loadCart();
  }

  Future<void> _removeItem(int productId) async {
    await CartService.removeFromCart(productId);
    await _loadCart();
  }

  Future<void> _loadCart() async {
    final cart = await CartService.getCart();
    setState(() {
      _cart = cart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            _currentTab == 0 ? "Shopping Cart" : "My Orders",
            style: boldTextStyle(),
          ),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTab = index;
              });
            },
            tabs: [
              Tab(
                icon: Badge(
                  label: Text(_cart.totalItems.toString()),
                  isLabelVisible: _cart.totalItems > 0,
                  child: Icon(Icons.shopping_cart),
                ),
                text: 'Cart',
              ),
              Tab(
                icon: Badge(
                  label: Text(_orders.length.toString()),
                  isLabelVisible: _orders.isNotEmpty,
                  child: Icon(Icons.list_alt),
                ),
                text: 'Orders',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Cart Tab
                  _buildCartTab(),
                  
                  // Orders Tab
                  _buildOrdersTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildCartTab() {
    return _cart.items.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                16.height,
                Text("Your cart is empty", style: boldTextStyle(size: 18)),
                8.height,
                Text("Add some products to get started", style: secondaryTextStyle()),
                24.height,
                AppButton(
                  text: 'Continue Shopping',
                  onTap: widget.onGoExplore,
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _cart.items.length,
                  itemBuilder: (_, index) {
                    final item = _cart.items[index];
                    return _buildCartItem(item);
                  },
                ),
              ),
              _buildBottomSheet(),
            ],
          );
  }

  Widget _buildOrdersTab() {
    return _orders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 80, color: Colors.grey),
                16.height,
                Text("No orders yet", style: boldTextStyle(size: 18)),
                8.height,
                Text("Your orders will appear here", style: secondaryTextStyle()),
                24.height,
                AppButton(
                  text: 'Start Shopping',
                  onTap: widget.onGoExplore,
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: _orders[index]);
              },
            ),
          );
  }

  // Keep your existing _buildCartItem, _buildQuantityControls, and _buildBottomSheet methods
  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.product.image != null
                  ? Image.network(
                      item.product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.shopping_bag, color: Colors.grey);
                      },
                    )
                  : Icon(Icons.shopping_bag, color: Colors.grey),
            ),
          ),
          12.width,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: boldTextStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                if (item.product.description != null && item.product.description!.isNotEmpty)
                  Text(
                    item.product.description!,
                    style: secondaryTextStyle(size: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: boldTextStyle(size: 16, color: Colors.green),
                    ),
                    _buildQuantityControls(item),
                  ],
                ),
                8.height,
                Text(
                  'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                  style: boldTextStyle(size: 14),
                ),
              ],
            ),
          ),
          // Remove Button
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeItem(item.product.id!),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 16),
            onPressed: () {
              if (item.quantity > 1) {
                _updateQuantity(item.product.id!, item.quantity - 1);
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, maxWidth: 32),
          ),
          Text(item.quantity.toString(), style: boldTextStyle()),
          IconButton(
            icon: Icon(Icons.add, size: 16),
            onPressed: () {
              _updateQuantity(item.product.id!, item.quantity + 1);
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, maxWidth: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: secondaryTextStyle()),
              Text('\$${_cart.subtotal.toStringAsFixed(2)}', style: boldTextStyle()),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: secondaryTextStyle()),
              Text('\$0.00', style: boldTextStyle()),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax', style: secondaryTextStyle()),
              Text('\$${(_cart.subtotal * 0.08).toStringAsFixed(2)}', style: boldTextStyle()),
            ],
          ),
          12.height,
          Divider(color: Colors.grey),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: boldTextStyle(size: 18)),
              Text(
                '\$${(_cart.subtotal * 1.08).toStringAsFixed(2)}',
                style: boldTextStyle(size: 18, color: Colors.green),
              ),
            ],
          ),
          16.height,
          sSAppButton(
            context: context,
            onPressed: () {
              BillingAddressScreen(cart: _cart).launch(context);
            },
            title: 'Proceed to Checkout',
          ),
        ],
      ),
    );
  }
}