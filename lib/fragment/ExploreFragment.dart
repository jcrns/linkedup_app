import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/components/RFLocationComponent.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/screens/RFSearchDetailScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFDataGenerator.dart';
import 'package:room_finder_flutter/utils/RFString.dart';

class ExploreFragment extends StatefulWidget {
  @override
  _ExploreFragmentState createState() => _ExploreFragmentState();
}

class _ExploreFragmentState extends State<ExploreFragment> {
  List<RoomFinderModel> locationListData = locationList();
  List<Product> productListData = productList();
  List<Opportunity> opportunityListData = opportunityList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RFCommonAppComponent(
        title: RFAppName,
        mainWidgetHeight: 230,
        subWidgetHeight: 280, // Adjusted height for content
        subTitle: "Explore",
        cardWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products', style: boldTextStyle()),
            16.height,
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: productListData.length,
                separatorBuilder: (context, index) => 16.width,
                itemBuilder: (context, index) {
                  Product product = productListData[index];
                  return Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: context.cardColor,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.asset(product.img, height: 80, width: 120, fit: BoxFit.cover),
                        ),
                        8.height,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(product.title, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        4.height,
                        Text('\$${product.price}', style: secondaryTextStyle()),
                      ],
                    ),
                  ).onTap(() {
                    RFSearchDetailScreen().launch(context);
                  });
                },
              ),
            ),
          ],
        ),
        subWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Opportunities section (moved below Forum)
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Job Opportunities', style: boldTextStyle()),
                ),
                // 8.height,
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: opportunityListData.length,
                  itemBuilder: (context, index) {
                    Opportunity opportunity = opportunityListData[index];
                    return Container(
                      decoration: boxDecorationRoundedWithShadow(8),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opportunity.title, style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                          4.height,
                          Text(opportunity.company, style: secondaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                          8.height,
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14),
                              4.width,
                              Expanded(child: Text(opportunity.location, style: secondaryTextStyle(size: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(opportunity.type, style: secondaryTextStyle(color: rf_primaryColor)),
                              Text(opportunity.salary, style: boldTextStyle(size: 12)),
                            ],
                          ),
                          Spacer(),
                          Text(opportunity.postedDate, style: secondaryTextStyle(size: 10)),
                        ],
                      ),
                    ).onTap(() {
                      // Handle opportunity tap
                      RFSearchDetailScreen().launch(context);
                    });
                  },
                ),
                24.height, // Space between sections

                // Forum section
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Newsletter', style: boldTextStyle()),
                ),
                16.height,
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    locationListData.length,
                    (index) {
                      return RFLocationComponent(locationData: locationListData[index]);
                    },
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}