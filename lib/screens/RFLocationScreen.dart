import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/RFHotelListComponent.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFDataGenerator.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class RFLocationScreen extends StatefulWidget {
  @override
  _RFLocationScreenState createState() => _RFLocationScreenState();
}

class _RFLocationScreenState extends State<RFLocationScreen> {
  TextEditingController addressController = TextEditingController();

  List<RoomFinderModel> hotelListData = hotelList();
  List<RoomFinderModel> availableHotelListData = availableHotelList();

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0x00000000), width: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing Results', style: boldTextStyle()),
                Text('4 Results', style: secondaryTextStyle()),
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 16),
            HorizontalList(
              itemCount: availableHotelListData.length,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (_, index) {
                RoomFinderModel data = availableHotelListData[index];

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: selectedIndex == index ? gray.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: Text(
                    data.roomCategoryName.validate(),
                    style: boldTextStyle(
                        color: selectedIndex == index
                            ? appStore.isDarkModeOn
                                ? white
                                : black
                            : appStore.isDarkModeOn
                                ? white.withOpacity(0.4)
                                : gray.withOpacity(0.6)),
                  ),
                ).onTap(() {
                  selectedIndex = index;
                  setState(() {});
                });
              },
            ),
            ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: hotelListData.length,
              itemBuilder: (BuildContext context, int index) => RFHotelListComponent(hotelData: hotelListData[index]),
            ),
          ],
        ),
      ),
    );
  }
}
