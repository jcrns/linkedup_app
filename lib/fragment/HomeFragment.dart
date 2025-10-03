import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:room_finder_flutter/components/BusinessDetailComponent.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/screens/BusinessDescriptionScreen.dart';
import 'package:room_finder_flutter/screens/RFSearchResultsScreen.dart';
import 'package:room_finder_flutter/screens/ViewAllBusinessesListScreen.dart';
import 'package:room_finder_flutter/screens/BusinessApplicationScreen.dart';
import 'package:room_finder_flutter/services/BusinessService.dart';
import 'package:room_finder_flutter/services/UserService.dart';
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
  List<Business> businessListData = [];
  List<Business> recentBusinesses = [];
  Map<String, dynamic>? userProfile;
  Business? userBusinessData;
  
  TextEditingController _searchController = TextEditingController();
  int selectCategoryIndex = 0;
  bool isLoading = false;

  Future<void> fetchBusinessData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch user's business
      final userBusiness = await UserService.getMyBusiness();
      setState(() {
        userBusinessData = userBusiness != null ? Business.fromJson(userBusiness) : null;
      });

      // Fetch recent businesses (last 7 days)
      final recentData = await BusinessService.getRecentBusinesses(days: 7, limit: 6);
      setState(() {
        // FIX: Properly handle the response which might be List or Map
        if (recentData is List) {
          print("recentData is List");
          print(recentData);
          recentBusinesses = recentData.map((business) => Business.fromJson(business as Map<String, dynamic>)).toList();
        } else {
          recentBusinesses = [];
          print('Unexpected recent businesses format: $recentData');
        }
      });

      print('qwqsdfergfwef');

      // Fetch all businesses for the main list
      final allBusinessesData = await BusinessService.getAllBusinesses(
        page: 1,
        pageSize: 10,
        ordering: '-created_at',
      );
      print('lllsdfergfwef');
      
      // FIX: Handle paginated response properly
      if (allBusinessesData!.length > 0) {
        print('sdfergfwef');
        List<dynamic> allBusinesses = allBusinessesData;
        setState(() {
        // FIX: Properly handle the response which might be List or Map
          print("allBusinesses is List");
          print(allBusinesses);
          businessListData = allBusinesses.map((business) => Business.fromJson(business as Map<String, dynamic>)).toList();

        });
      } else if (allBusinessesData is List) {
        print("allBusinesses is List unable to parse");
        // setState(() {
        //   businessListData = allBusinesses.map((business) => Business.fromJson(business as Map<String, dynamic>)).toList();
        // });
      } else {
        // Handle unexpected format
        setState(() {
          businessListData = [];
        });
        print('Unexpected all businesses format: $allBusinessesData');
      }

    } catch (e) {
      toast("An error occurred: $e");
      print("Error fetching business data: $e");
    } finally {
      setState(() { isLoading = false; });
    }
  }

  void _performSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      RFSearchResultsScreen(searchQuery: query).launch(context);
    } else {
      toast("Please enter a search term");
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);
    await fetchBusinessData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            Text('Discover Local Businesses', style: boldTextStyle(size: 18)),
            16.height,
            AppTextField(
              controller: _searchController,
              textFieldType: TextFieldType.NAME,
              decoration: rfInputDecoration(
                hintText: "Search businesses, categories, locations...",
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
                    // Advanced search/filter screen
                    RFSearchResultsScreen().launch(context);
                  },
                ),
              ],
            ),
          ],
        ),
        subWidget: SingleChildScrollView(
          child: Column(
            children: [
              // Business Categories
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
                      });
                      // Navigate to category-specific businesses
                      RFSearchResultsScreen(
                        businessType: data.roomCategoryName.validate(),
                      ).launch(context);
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
                        style: boldTextStyle(
                          color: selectCategoryIndex == index ? rf_primaryColor : gray,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Recently Added Businesses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recently Added', style: boldTextStyle()),
                  TextButton(
                    onPressed: () {
                      RFViewAllBusinessesScreen().launch(context);
                    },
                    child: Text('View All', style: secondaryTextStyle(decoration: TextDecoration.underline)),
                  )
                ],
              ).paddingOnly(left: 16, right: 16, top: 24, bottom: 8),

              // Recent Businesses List
              if (recentBusinesses.isNotEmpty)
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recentBusinesses.length,
                  itemBuilder: (BuildContext context, int index) {
                    Business data = recentBusinesses[index];
                    return BusinessDetailComponent(businessListData: data);
                  },
                )
              else if (!isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No recent businesses found',
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Popular Businesses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Businesses', style: boldTextStyle()),
                  TextButton(
                    onPressed: () {
                      RFSearchResultsScreen(
                        ordering: '-rating',
                        title: 'Popular Businesses',
                      ).launch(context);
                    },
                    child: Text('See All', style: secondaryTextStyle(decoration: TextDecoration.underline)),
                  )
                ],
              ).paddingOnly(left: 16, right: 16, top: 24, bottom: 8),

              // Popular Businesses List (first 3 from main list)
              if (businessListData.isNotEmpty)
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: businessListData.take(3).length,
                  itemBuilder: (BuildContext context, int index) {
                    Business data = businessListData[index];
                    return BusinessDetailComponent(businessListData: data);
                  },
                )
              else if (!isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No businesses available',
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Business Owner Section
              if (userBusinessData != null) 
                // User has a business - show manage business button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Manage Your Business", style: boldTextStyle(size: 18)),
                      SizedBox(height: 8),
                      Text(
                        "View and manage your business listing, update information, and track performance",
                        style: secondaryTextStyle(),
                      ),
                      SizedBox(height: 16),
                      AppButton(
                        color: rf_primaryColor,
                        text: "Manage Business",
                        textStyle: boldTextStyle(color: white),
                        onTap: () {
                      BusinessDescriptionScreen(businessData: userBusinessData!).launch(context);
                    },
                      ),
                    ],
                  ),
                )
              else 
                // User doesn't have a business - show create business section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Own a business?", style: boldTextStyle(size: 18)),
                      SizedBox(height: 8),
                      Text(
                        "List your business on our platform to reach thousands of potential customers",
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
                    ],
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
                      Text('Loading businesses...', style: secondaryTextStyle()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}