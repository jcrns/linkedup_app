import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/FavoritesService.dart';
import 'package:room_finder_flutter/services/UserService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class ProductDescriptionScreen extends StatefulWidget {
  final Product product;

  const ProductDescriptionScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDescriptionScreenState createState() => _ProductDescriptionScreenState();
}

class _ProductDescriptionScreenState extends State<ProductDescriptionScreen> {
  bool isFavorite = false;
  bool isOwner = false;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    _checkIfFavorited();
    _checkOwnership();
  }

  // In ProductDescriptionScreen.dart
  Future<void> _checkOwnership() async {
    try {
      // Get current user's business
      final myBusiness = await UserService.getMyBusiness();
      if (myBusiness != null) {
        final myBusinessObj = Business.fromJson(myBusiness);
        setState(() {
          // Check if the product's business ID matches the user's business ID
          isOwner = myBusinessObj.id == widget.product.business?.id;
        });
      } else {
        setState(() {
          isOwner = false;
        });
      }
    } catch (e) {
      print('Error checking ownership: $e');
      setState(() {
        isOwner = false;
      });
    }
  }

  Future<void> _checkIfFavorited() async {
    final favorited = await FavoritesService.isProductFavorited(widget.product.id!);
    setState(() {
      isFavorite = favorited;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await FavoritesService.removeProduct(widget.product.id!);
      toast('Removed from favorites');
    } else {
      await FavoritesService.addProduct(widget.product.toJson());
      toast('Added to favorites');
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _editProduct() {
    toast('Edit product functionality coming soon');
    // Navigate to product edit screen
    // ProductEditScreen(product: widget.product).launch(context);
  }

  void _manageInventory() {
    toast('Inventory management coming soon');
    // Navigate to inventory management
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      body: CustomScrollView(
        slivers: [
          // Header with image
          SliverAppBar(
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () {
                  finish(context);
                },
              ),
            ),
            actions: [
              if (isOwner) // Edit button for owner
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: white),
                    onPressed: _editProduct,
                  ),
                ),
              Container(
                margin: EdgeInsets.all(8),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            backgroundColor: rf_primaryColor,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.image != null
                  ? Image.network(
                      '${widget.product.image!}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
                    ),
            ),
          ),

          // Product details
          SliverToBoxAdapter(
            child: Container(
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product header
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.product.name,
                                          style: boldTextStyle(size: 24),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isOwner)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: boxDecorationWithRoundedCorners(
                                            backgroundColor: Colors.green.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Your Product',
                                            style: boldTextStyle(color: white, size: 10),
                                          ),
                                        ),
                                    ],
                                  ),
                                  8.height,
                                  Text(
                                    '\$${widget.product.price.toStringAsFixed(2)}',
                                    style: boldTextStyle(size: 28, color: rf_primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        16.height,
                        
                        // Owner Actions Section
                        if (isOwner) 
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text('Product Management', style: boldTextStyle(size: 16, color: Colors.blue)),
                                12.height,
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: 'Edit Product',
                                        textColor: Colors.blue,
                                        color: Colors.blue.withOpacity(0.1),
                                        onTap: _editProduct,
                                      ),
                                    ),
                                    12.width,
                                    Expanded(
                                      child: AppButton(
                                        text: 'Manage Stock',
                                        textColor: Colors.green,
                                        color: Colors.green.withOpacity(0.1),
                                        onTap: _manageInventory,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        16.height,

                        // Business info
                        if (widget.product.business != null) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                12.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sold by ${widget.product.business!.name}',
                                        style: boldTextStyle(size: 14),
                                      ),
                                      4.height,
                                      Text(
                                        widget.product.business!.location ?? 'Unknown location',
                                        style: secondaryTextStyle(size: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ).onTap(() {
                            // Navigate to business page
                            toast('View ${widget.product.business!.name}');
                          }),
                          16.height,
                        ],
                      ],
                    ),
                  ),

                  // Divider
                  Container(height: 8, color: context.cardColor),

                  // Product details sections
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        if (widget.product.description != null && widget.product.description!.isNotEmpty) ...[
                          Text('Product Description', style: boldTextStyle(size: 18)),
                          12.height,
                          Text(
                            widget.product.description!,
                            style: primaryTextStyle(),
                            textAlign: TextAlign.justify,
                          ),
                          24.height,
                        ],

                        // Product information
                        Text('Product Information', style: boldTextStyle(size: 18)),
                        12.height,
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('Category', widget.product.category ?? 'Not specified'),
                              _buildInfoRow('Stock', '${widget.product.stock} available'),
                              _buildInfoRow('Business', widget.product.business?.name ?? 'Unknown'),
                              _buildInfoRow('Added', _formatDate(widget.product.created_at)),
                            ],
                          ),
                        ),
                        24.height,

                        // Contact & Actions
                        if (!isOwner) ...[
                          Text('Contact Business', style: boldTextStyle(size: 18)),
                          12.height,
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Message',
                                  textColor: rf_primaryColor,
                                  color: context.cardColor,
                                  onTap: () {
                                    toast('Message feature coming soon');
                                  },
                                ),
                              ),
                              12.width,
                              Expanded(
                                child: AppButton(
                                  text: 'Call',
                                  textColor: white,
                                  color: rf_primaryColor,
                                  onTap: () {
                                    toast('Call feature coming soon');
                                  },
                                ),
                              ),
                            ],
                          ),
                          24.height,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          border: Border.all(color: context.dividerColor),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (!isOwner) // Only show cart for non-owners
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined, color: rf_primaryColor),
                    onPressed: () {
                      toast('Add to cart feature coming soon');
                    },
                  ),
                ),
              if (!isOwner) 12.width,
              Expanded(
                child: AppButton(
                  text: isOwner ? 'Manage Product' : 'Buy Now',
                  textColor: white,
                  color: rf_primaryColor,
                  onTap: () {
                    if (isOwner) {
                      _editProduct();
                    } else {
                      toast('Purchase feature coming soon');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: secondaryTextStyle()),
          Text(value, style: boldTextStyle()),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}