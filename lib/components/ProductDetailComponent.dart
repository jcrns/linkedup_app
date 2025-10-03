import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class ProductDetailComponent extends StatelessWidget {
  final Product productListData;
  final VoidCallback? onTap;

  const ProductDetailComponent({
    Key? key, 
    required this.productListData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 100,
                height: 100,
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: productListData.image != null
                    ? Image.network(
                        '${productListData.image!}',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                          );
                        },
                      ).cornerRadiusWithClipRRectOnly(topLeft: 12, bottomLeft: 12)
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                      ),
              ),
              
              // Product Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productListData.name,
                        style: boldTextStyle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      if (productListData.business != null)
                        Text(
                          'by ${productListData.business!.name}',
                          style: secondaryTextStyle(size: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      8.height,
                      Text(
                        '\$${productListData.price.toStringAsFixed(2)}',
                        style: boldTextStyle(size: 16, color: rf_primaryColor),
                      ),
                      4.height,
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: productListData.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              productListData.stock > 0 ? 'In Stock' : 'Out of Stock',
                              style: boldTextStyle(
                                size: 10,
                                color: productListData.stock > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          8.width,
                          if (productListData.category != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                productListData.category!,
                                style: secondaryTextStyle(size: 10),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}