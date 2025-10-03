// screens/ProductSearchResultsScreen.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/ProductDetailComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/ProductService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class ProductSearchResultsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? ordering;
  final String? title;

  const ProductSearchResultsScreen({
    Key? key,
    this.searchQuery,
    this.category,
    this.ordering,
    this.title,
  }) : super(key: key);

  @override
  _ProductSearchResultsScreenState createState() => _ProductSearchResultsScreenState();
}

class _ProductSearchResultsScreenState extends State<ProductSearchResultsScreen> {
  List<Product> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery ?? '';
    _searchController.text = _currentQuery;
    _performSearch();
  }

  Future<void> _performSearch({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _searchResults.clear();
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final dynamic results = await ProductService.searchProducts(
        query: _currentQuery,
        category: widget.category,
        ordering: widget.ordering ?? '-created_at',
        page: _currentPage,
        pageSize: 10,
      );

      List<dynamic> productsData = [];

      if (results is Map && results.containsKey('results')) {
        productsData = results['results'] as List<dynamic>;
        _hasMore = results['next'] != null;
      } else if (results is List) {
        productsData = results;
        _hasMore = false;
      } else {
        print('Unexpected search results format: $results');
        _hasMore = false;
      }
      
      final List<Product> newProducts = productsData
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList()
          .cast<Product>();

      setState(() {
        if (loadMore) {
          _searchResults.addAll(newProducts);
        } else {
          _searchResults = newProducts;
        }
        _currentPage++;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      toast('Search failed: $e');
    }
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _currentQuery = value.trim();
    });
    _performSearch();
  }

  String _getScreenTitle() {
    if (widget.title != null) return widget.title!;
    if (widget.category != null) return '${widget.category} Products';
    if (_currentQuery.isNotEmpty) return 'Search: $_currentQuery';
    return 'Browse Products';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle(), style: boldTextStyle(color: Colors.white)),
        backgroundColor: rf_primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: context.cardColor,
            child: AppTextField(
              controller: _searchController,
              textFieldType: TextFieldType.NAME,
              decoration: rfInputDecoration(
                hintText: "Search products...",
                showPreFixIcon: true,
                showLableText: false,
                prefixIcon: Icon(Icons.search, color: rf_primaryColor),
              ),
              onFieldSubmitted: _onSearchSubmitted,
            ),
          ),

          // Results Count
          if (!_isLoading && _searchResults.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: context.width(),
              color: context.cardColor,
              child: Text(
                'Found ${_searchResults.length} products',
                style: secondaryTextStyle(),
              ),
            ),

          // Results List
          Expanded(
            child: _isLoading && _searchResults.isEmpty
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          16.height,
                          Text(
                            'No products found',
                            style: boldTextStyle(size: 18),
                          ),
                          8.height,
                          Text(
                            _currentQuery.isEmpty
                                ? 'Try searching with different terms'
                                : 'No results for "$_currentQuery"',
                            style: secondaryTextStyle(),
                            textAlign: TextAlign.center,
                          ),
                          16.height,
                          AppButton(
                            text: 'Browse All Products',
                            onTap: () {
                              _searchController.clear();
                              _onSearchSubmitted('');
                            },
                          ),
                        ],
                      ).paddingAll(16)
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _searchResults.length && _hasMore) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final product = _searchResults[index];
                          return ProductDetailComponent(productListData: product);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}