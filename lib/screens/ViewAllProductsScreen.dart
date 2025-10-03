// screens/ViewAllProductsScreen.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/ProductDetailComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/ProductService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';

class ViewAllProductsScreen extends StatefulWidget {
  final String? title;
  final String? ordering;
  final String? category;

  const ViewAllProductsScreen({
    Key? key,
    this.title,
    this.ordering,
    this.category,
  }) : super(key: key);

  @override
  _ViewAllProductsScreenState createState() => _ViewAllProductsScreenState();
}

class _ViewAllProductsScreenState extends State<ViewAllProductsScreen> {
  List<Product> _allProducts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange &&
        _hasMore &&
        !_isLoading) {
      _loadProducts(loadMore: true);
    }
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _allProducts.clear();
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await ProductService.getAllProducts(
        page: _currentPage,
        pageSize: _pageSize,
        ordering: widget.ordering ?? '-created_at',
        category: widget.category,
      );

      List<dynamic> productsData = [];
      
      if (response is Map && response.containsKey('results')) {
        productsData = response['results'] as List<dynamic>;
        _hasMore = response['next'] != null;
      } else if (response is List) {
        productsData = response;
        _hasMore = false;
      } else {
        productsData = [];
        _hasMore = false;
        print('Unexpected response format: $response');
      }

      setState(() {
        _allProducts.addAll(productsData.map((product) => Product.fromJson(product as Map<String, dynamic>)).toList());
        _currentPage++;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      toast('Failed to load products: $e');
      print('Error loading products: $e');
    }
  }

  Future<void> _refresh() async {
    await _loadProducts();
  }

  String _getScreenTitle() {
    return widget.title ?? 'All Products';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: rf_primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Header with count
            Container(
              padding: EdgeInsets.all(16),
              color: context.cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getScreenTitle(),
                    style: boldTextStyle(size: 18),
                  ),
                  Text(
                    '${_allProducts.length} products',
                    style: secondaryTextStyle(),
                  ),
                ],
              ),
            ),

            // Product List
            Expanded(
              child: _allProducts.isEmpty && _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _allProducts.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
                            16.height,
                            Text(
                              'No products available',
                              style: boldTextStyle(size: 18),
                            ),
                            8.height,
                            Text(
                              'Check back later for new product listings',
                              style: secondaryTextStyle(),
                              textAlign: TextAlign.center,
                            ),
                            16.height,
                            AppButton(
                              text: 'Refresh',
                              onTap: _refresh,
                            ),
                          ],
                        ).paddingAll(16)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _allProducts.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _allProducts.length) {
                              return _hasMore
                                  ? Container(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          'No more products to load',
                                          style: secondaryTextStyle(),
                                        ),
                                      ),
                                    );
                            }

                            final product = _allProducts[index];
                            return ProductDetailComponent(productListData: product);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}