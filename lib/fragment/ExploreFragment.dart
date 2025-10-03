// In ExploreFragment.dart, update the usage of ProductDetailComponent
// screens/ExploreFragment.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/ProductDetailComponent.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/components/RFLocationComponent.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/screens/ProductDescriptionScreen.dart';
import 'package:room_finder_flutter/screens/ProductSearchResultsScreen.dart';
import 'package:room_finder_flutter/screens/ViewAllProductsScreen.dart';
import 'package:room_finder_flutter/services/ProductService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFDataGenerator.dart';
import 'package:room_finder_flutter/utils/RFString.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class ExploreFragment extends StatefulWidget {
  @override
  _ExploreFragmentState createState() => _ExploreFragmentState();
}

class _ExploreFragmentState extends State<ExploreFragment> {
  List<RoomFinderModel> categoryData = categoryList();
  List<Product> recentProducts = [];
  List<Product> bestSellingProducts = [];
  List<Product> featuredProducts = [];
  
  TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  int selectedCategoryIndex = 0;

  Future<void> fetchProductData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch recent products
      final recentData = await ProductService.getRecentProducts(limit: 6);
      print("recentData: $recentData");
      setState(() {
        if (recentData is List) {
          print("recentData is List with length: ${recentData.length}");
          recentProducts = recentData.map((product) => Product.fromJson(product as Map<String, dynamic>)).toList();
        } else {
          print("recentData is not a List");
          recentProducts = [];
        }
      });

      // Fetch best selling products
      final bestSellingData = await ProductService.getBestSellingProducts(limit: 6);
      print("bestSellingData: $bestSellingData");
      setState(() {
        if (bestSellingData is List) {
          bestSellingProducts = bestSellingData.map((product) => Product.fromJson(product as Map<String, dynamic>)).toList();
        } else {
          bestSellingProducts = [];
        }
      });

      // Fetch featured products
      final featuredData = await ProductService.getFeaturedProducts(limit: 4);
      print("featuredData: $featuredData");
      setState(() {
        if (featuredData is List) {
          featuredProducts = featuredData.map((product) => Product.fromJson(product as Map<String, dynamic>)).toList();
        } else if (featuredData is Map && featuredData.containsKey('results')) {
          featuredProducts = (featuredData['results'] as List).map((product) => Product.fromJson(product as Map<String, dynamic>)).toList();
        } else {
          featuredProducts = [];
        }
      });

    } catch (e) {
      toast("An error occurred: $e");
      print("Error fetching product data: $e");
    } finally {
      setState(() { isLoading = false; });
    }
  }

  void _performSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ProductSearchResultsScreen(searchQuery: query).launch(context);
    } else {
      toast("Please enter a search term");
    }
  }

  void _onCategoryTap(int index, String category) {
    setState(() {
      selectedCategoryIndex = index;
    });
    ProductSearchResultsScreen(
      category: category,
      title: '$category Products',
    ).launch(context);
  }

  void _onProductTap(Product product) {
    toast('View product: ${product.name}');
    // TODO: Navigate to product detail screen when created
    ProductDescriptionScreen(product: product).launch(context);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);
    await fetchProductData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RFCommonAppComponent(
        title: RFAppName,
        mainWidgetHeight: 200,
        subWidgetHeight: 130,
        cardWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Discover Amazing Products', style: boldTextStyle(size: 18)),
            16.height,
            AppTextField(
              controller: _searchController,
              textFieldType: TextFieldType.NAME,
              decoration: rfInputDecoration(
                hintText: "Search products, brands, categories...",
                showPreFixIcon: true,
                showLableText: false,
                prefixIcon: Icon(Icons.search, color: rf_primaryColor, size: 18),
              ),
              onFieldSubmitted: (value) => _performSearch(),
            ),
            16.height,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    color: rf_primaryColor,
                    elevation: 0.0,
                    child: Text('Search', style: boldTextStyle(color: white)),
                    onTap: _performSearch,
                  ),
                ),
                8.width,
                AppButton(
                  color: context.cardColor,
                  elevation: 0.0,
                  child: Icon(Icons.tune, color: rf_primaryColor),
                  onTap: () {
                    ProductSearchResultsScreen().launch(context);
                  },
                ),
              ],
            ),
          ],
        ),
        subWidget: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured Products Carousel
              if (featuredProducts.isNotEmpty) ...[
                Text('Featured Products', style: boldTextStyle(size: 18))
                    .paddingOnly(left: 16, right: 16, top: 16, bottom: 8),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: featuredProducts.length,
                    itemBuilder: (context, index) {
                      Product product = featuredProducts[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onProductTap(product),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 140,
                            margin: EdgeInsets.only(right: 12),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: product.image != null
                                      ? Image.network(
                                          '${product.image!}',
                                          height: 100,
                                          width: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 100,
                                              width: 140,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                                            );
                                          },
                                        )
                                      : Container(
                                          height: 100,
                                          width: 140,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                                        ),
                                ),
                                8.height,
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: primaryTextStyle(size: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      4.height,
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: boldTextStyle(size: 14, color: rf_primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                16.height,
              ],

              // Product Categories
              Text('Product Categories', style: boldTextStyle())
                  .paddingOnly(left: 16, right: 16, top: 16, bottom: 8),
              HorizontalList(
                padding: EdgeInsets.only(right: 16, left: 16),
                itemCount: categoryData.length,
                itemBuilder: (BuildContext context, int index) {
                  RoomFinderModel data = categoryData[index];
                  return GestureDetector(
                    onTap: () => _onCategoryTap(index, data.roomCategoryName.validate()),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: appStore.isDarkModeOn
                            ? scaffoldDarkColor
                            : selectedCategoryIndex == index
                                ? rf_selectedCategoryBgColor
                                : rf_categoryBgColor,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        data.roomCategoryName.validate(),
                        style: boldTextStyle(
                          color: selectedCategoryIndex == index ? rf_primaryColor : gray,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Best Selling Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Best Selling', style: boldTextStyle()),
                  TextButton(
                    onPressed: () {
                      ViewAllProductsScreen(
                        title: 'Best Selling Products',
                        ordering: '-stock',
                      ).launch(context);
                    },
                    child: Text('View All', style: secondaryTextStyle(decoration: TextDecoration.underline)),
                  )
                ],
              ).paddingOnly(left: 16, right: 16, top: 24, bottom: 8),

              if (bestSellingProducts.isNotEmpty)
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: bestSellingProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    Product data = bestSellingProducts[index];
                    return ProductDetailComponent(
                      productListData: data,
                      onTap: () => _onProductTap(data),
                    );
                  },
                )
              else if (!isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No best selling products found',
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Recently Added Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recently Added', style: boldTextStyle()),
                  TextButton(
                    onPressed: () {
                      ViewAllProductsScreen().launch(context);
                    },
                    child: Text('View All', style: secondaryTextStyle(decoration: TextDecoration.underline)),
                  )
                ],
              ).paddingOnly(left: 16, right: 16, top: 24, bottom: 8),

              if (recentProducts.isNotEmpty)
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recentProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    Product data = recentProducts[index];
                    return ProductDetailComponent(
                      productListData: data,
                      onTap: () => _onProductTap(data),
                    );
                  },
                )
              else if (!isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No recent products found',
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Loading indicator
              if (isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      8.width,
                      Text('Loading products...', style: secondaryTextStyle()),
                    ],
                  ),
                ),

              16.height,
            ],
          ),
        ),
      ),
    );
  }
}