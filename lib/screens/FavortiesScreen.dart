// screens/FavoritesScreen.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/BusinessDetailComponent.dart';
import 'package:room_finder_flutter/components/ProductDetailComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/FavoritesService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Business> _favoriteBusinesses = [];
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoriteBusinessesData = await FavoritesService.getFavoriteBusinesses();
      final favoriteProductsData = await FavoritesService.getFavoriteProducts();

      setState(() {
        _favoriteBusinesses = favoriteBusinessesData
            .map((businessJson) => Business.fromJson(businessJson))
            .toList();
        
        _favoriteProducts = favoriteProductsData
            .map((productJson) => Product.fromJson(productJson))
            .toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      toast('Error loading favorites: $e');
    }
  }

  Future<void> _removeBusinessFromFavorites(Business business) async {
    await FavoritesService.removeBusiness(business.id!);
    await _loadFavorites();
    toast('Business removed from favorites');
  }

  Future<void> _removeProductFromFavorites(Product product) async {
    await FavoritesService.removeProduct(product.id!);
    await _loadFavorites();
    toast('Product removed from favorites');
  }

  void _clearAllFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Favorites'),
        content: Text('Are you sure you want to remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => finish(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FavoritesService.clearAllFavorites();
              await _loadFavorites();
              finish(context);
              toast('All favorites cleared');
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites', style: boldTextStyle(color: white)),
        backgroundColor: rf_primaryColor,
        actions: [
          if (_favoriteBusinesses.isNotEmpty || _favoriteProducts.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: _clearAllFavorites,
              tooltip: 'Clear all favorites',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: white,
          labelColor: white,
          unselectedLabelColor: white.withOpacity(0.7),
          tabs: [
            Tab(
              text: 'Businesses (${_favoriteBusinesses.length})',
            ),
            Tab(
              text: 'Products (${_favoriteProducts.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Businesses Tab
                _favoriteBusinesses.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.business_center,
                        title: 'No Favorite Businesses',
                        subtitle: 'Businesses you favorite will appear here',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _favoriteBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _favoriteBusinesses[index];
                            return Dismissible(
                              key: Key('business_${business.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.delete, color: white),
                              ),
                              onDismissed: (direction) => _removeBusinessFromFavorites(business),
                              child: BusinessDetailComponent(businessListData: business),
                            );
                          },
                        ),
                      ),

                // Products Tab
                _favoriteProducts.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.shopping_bag,
                        title: 'No Favorite Products',
                        subtitle: 'Products you favorite will appear here',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _favoriteProducts.length,
                          itemBuilder: (context, index) {
                            final product = _favoriteProducts[index];
                            return Dismissible(
                              key: Key('product_${product.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.delete, color: white),
                              ),
                              onDismissed: (direction) => _removeProductFromFavorites(product),
                              child: ProductDetailComponent(productListData: product),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          20.height,
          Text(title, style: boldTextStyle(size: 20)),
          8.height,
          Text(
            subtitle,
            style: secondaryTextStyle(),
            textAlign: TextAlign.center,
          ),
          20.height,
          AppButton(
            text: 'Explore Businesses',
            onTap: () {
              // Navigate to explore or home
              finish(context);
            },
          ).visible(_tabController.index == 0),
          AppButton(
            text: 'Browse Products',
            onTap: () {
              // Navigate to products
              finish(context);
            },
          ).visible(_tabController.index == 1),
        ],
      ).paddingAll(32),
    );
  }
}