import 'package:flutter/material.dart';
import 'package:room_finder_flutter/components/BusinessListComponent.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import 'package:room_finder_flutter/models/Models.dart';

class ViewAllBusinessesListScreen extends StatelessWidget {
  final List<Business> businessListData;

  // Constructor to initialize eventListData
  ViewAllBusinessesListScreen({required this.businessListData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBarWidget(context, title: "Recently Added Events", appBarHeight: 80, showLeadingIcon: false, roundCornerShape: true),
      body: ListView.builder(
        padding: EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 24),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          Business data = businessListData[index % businessListData.length];
          return BusinessListComponent(businessListData: data);
        },
      ),
    );
  }
}
