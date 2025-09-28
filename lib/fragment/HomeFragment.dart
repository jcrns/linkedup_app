import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:room_finder_flutter/components/BusinessListComponent.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/screens/RFRecentupdateViewAllScreen.dart';
import 'package:room_finder_flutter/screens/RFSearchDetailScreen.dart';
import 'package:room_finder_flutter/screens/RFViewAllHotelListScreen.dart';
import 'package:room_finder_flutter/screens/ViewAllCategoryScreen.dart';
import 'package:room_finder_flutter/screens/BusinessApplicationScreen.dart';
// import 'package:room_finder_flutter/screens/RFViewAllHotelListScreen.dart';
// import 'package:room_finder_flutter/screens/ViewAllEventsListScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFDataGenerator.dart';
import 'package:room_finder_flutter/utils/RFString.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  List<RoomFinderModel> categoryData = categoryList();
  List<RoomFinderModel> hotelListData = hotelList();
  List<RoomFinderModel> locationListData = locationList();
  List<Business> businessListData = []; // Initialize with empty list
  //List<RoomFinderModel> recentUpdateData = recentUpdateList();
  List<Product> productListData = productList();

  int selectCategoryIndex = 0;
  bool isLoading = false;
  bool locationWidth = true;

  Future<void> fetchEvents() async { // Renamed to fetchEvents
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('http://127.0.0.1:8000/api/businesses');
    String token = getStringAsync('auth_token', defaultValue: '');

    // if (token.isEmpty) {
    //   toast("Token not found. Please login again.");
    //   setState(() { isLoading = false; });
    //   return;
    // }

    try {
      var response = await http.get(
        url,
        headers: { 
            // 'Authorization': 'Token $token', 
            'Content-Type': 'application/json',
            'X-Client-Version': '1.0.0',
            'X-Client-Platform': 'flutter-ios',

         },
        
      );

      if (response.statusCode == 200) {
        print(response.body);
        List jsonResponse = jsonDecode(response.body);
        setState(() {
          businessListData = jsonResponse.map((business) => Business.fromJson(business)).toList();
        });
      } else {
        toast("Failed to load events: ${response.statusCode}");
      }
    } catch (e) {
      toast("An error occurred: $e");
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);
    await fetchEvents(); // Fetch events on initialization
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
            Text('Buy, Spend, Give Anywhere', style: boldTextStyle(size: 18)),
            16.height,
            AppTextField(
              textFieldType: TextFieldType.EMAIL,
              decoration: rfInputDecoration(
                hintText: "Find Events, Products, Businesses near you",
                showPreFixIcon: true,
                showLableText: false,
                prefixIcon: Icon(Icons.location_on, color: rf_primaryColor, size: 18),
              ),
            ),
            16.height,
            AppButton(
              color: rf_primaryColor,
              elevation: 0.0,
              child: Text('Search Now', style: boldTextStyle(color: white)),
              width: context.width(),
              onTap: () {
                RFSearchDetailScreen().launch(context);
              },
            ),
            TextButton(
              onPressed: () {
                //
              },
              child: Align(
                alignment: Alignment.center,
                child: Text('Advance Search', style: primaryTextStyle(), textAlign: TextAlign.center),
              ),
            )
          ],
        ),
        subWidget: Column(
          children: [
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: Text('Best Selling Products', style: boldTextStyle()),
            // ).paddingOnly(left: 16, right: 16, top: 16, bottom: 16),
            // SizedBox(
            //   height: 150,
            //   child: ListView.separated(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: productListData.length,
            //     separatorBuilder: (context, index) => 16.width,
            //     itemBuilder: (context, index) {
            //       Product product = productListData[index];
            //       return Container(
            //         width: 120,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(8),
            //           color: context.cardColor,
            //         ),
            //         child: Column(
            //           children: [
            //             ClipRRect(
            //               borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            //               child: Image.asset(product.img, height: 80, width: 120, fit: BoxFit.cover),
            //             ),
            //             8.height,
            //             Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 4.0),
            //               child: Text(product.title, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
            //             ),
            //             4.height,
            //             Text('\$${product.price}', style: secondaryTextStyle()),
            //           ],
            //         ),
            //       ).onTap(() {
            //         RFSearchDetailScreen().launch(context);
            //       });
            //     },
            //   ),
            // ).paddingAll(16),
            Align(
                alignment: Alignment.topLeft,
                child: Text('Business Categories', style: boldTextStyle()),
            ).paddingOnly(left: 16, right: 16, top: 16, bottom: 16),
            HorizontalList(
              padding: EdgeInsets.only(right: 16, left: 16),
              wrapAlignment: WrapAlignment.spaceEvenly,
              itemCount: categoryData.length,
              itemBuilder: (BuildContext context, int index) {
                RoomFinderModel data = categoryData[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectCategoryIndex = index;
                      
                      print("Selected Category: ${data.roomCategoryName}"); // Debugging output
                      //Loop

                      // Create and link Viewall like class file for each room category header. ALso Pass category name for use in viewAllCategory Class 
                      ViewAllCategoryListScreen(categoryName: '', productListData: [],);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: appStore.isDarkModeOn
                          ? scaffoldDarkColor
                          : selectCategoryIndex == index
                              ? rf_selectedCategoryBgColor
                              : rf_categoryBgColor,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      data.roomCategoryName.validate(),
                      style: boldTextStyle(color: selectCategoryIndex == index ? rf_primaryColor : gray),
                    ),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recently Added Business', style: boldTextStyle()),
                TextButton(
                  onPressed: () {
                    RFViewAllHotelListScreen().launch(context);
                  },
                  child: Text('View All', style: secondaryTextStyle(decoration: TextDecoration.underline, textBaseline: TextBaseline.alphabetic)),
                )
              ],
            ).paddingOnly(left: 16, right: 16, top: 16, bottom: 8),
            ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: businessListData.take(3).length,
              itemBuilder: (BuildContext context, int index) {
                Business data = businessListData[index];
                return BusinessListComponent(businessListData: data);
              },
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Best Selling', style: boldTextStyle()),
            //     TextButton(
            //       onPressed: () {
            //         //update
            //         RFLocationViewAllScreen(locationWidth: true).launch(context);
            //       },
            //       child: Text('View All', style: secondaryTextStyle(decoration: TextDecoration.underline)),
            //     )
            //   ],
            // ).paddingOnly(left: 16, right: 16, bottom: 8),
            // Wrap(
            //   spacing: 16,
            //   runSpacing: 16,
            //   children: List.generate(locationListData.length, (index) {
            //     return RFLocationComponent(locationData: locationListData[index]);
            //   }),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Non-Profits', style: boldTextStyle()),
                TextButton(
                  onPressed: () {

                    //update
                    RFRecentUpdateViewAllScreen().launch(context);
                  },
                  child: Text('See All', style: secondaryTextStyle(decoration: TextDecoration.underline)),
                )
              ],
            ).paddingOnly(left: 16, right: 16, top: 16, bottom: 8),
            ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: businessListData.take(3).length,
              itemBuilder: (BuildContext context, int index) {
                Business data = businessListData[index];
                return BusinessListComponent(businessListData: data);
              },
            ),
            // Inside the subWidget Column of HomeFragment (after the last ListView)
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Own a business?", style: boldTextStyle(size: 18)),
                  SizedBox(height: 8),
                  Text(
                    "List your business or products on our platform to reach thousands of potential customers",
                    style: secondaryTextStyle(),
                  ),
                  SizedBox(height: 16),
                  AppButton(
                    color: rf_primaryColor,
                    text: "Create Business Listing",
                    textStyle: boldTextStyle(color: white),
                    onTap: () {
                      BusinessApplicationScreen().launch(context);
                    },
                  ),
                  SizedBox(height: 8),
                  AppButton(
                    color: context.cardColor,
                    text: "List a Product",
                    textColor: rf_primaryColor,
                    textStyle: boldTextStyle(color: rf_primaryColor),
                    onTap: () {
                      // Product listing screen would go here
                      toast('Product listing feature coming soon');
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
