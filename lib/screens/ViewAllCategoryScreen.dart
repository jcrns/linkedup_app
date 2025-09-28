import 'package:flutter/material.dart';
import 'package:room_finder_flutter/components/CategoryProductListComponent.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import 'package:room_finder_flutter/models/Models.dart';

class ViewAllCategoryListScreen extends StatelessWidget {
  // Make API Call by category
  final List<Product> productListData;
  final String categoryName; // Added field for category name

  ViewAllCategoryListScreen({
    required this.categoryName, required this.productListData, // Required for the constructor
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBarWidget(
        context,
        title: "$categoryName", // Use the passed categoryName here
        appBarHeight: 80,
        showLeadingIcon: false,
        roundCornerShape: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 24),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 20, // Consider using businessListData.length if it's dynamic
        itemBuilder: (BuildContext context, int index) {
          Product data = productListData[index % productListData.length];
          return CategoryProductListComponent(productData: data);
        },
      ),
    );
  }
}

