import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/BusinessDescriptionScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class BusinessDetailComponent extends StatelessWidget {
  final Business? businessListData;
  final bool? showHeight;

  BusinessDetailComponent({this.businessListData, this.showHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: boxDecorationRoundedWithShadow(8, backgroundColor: context.cardColor),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rfCommonCachedNetworkImage(businessListData?.image.validate(), height: 100, width: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(businessListData!.name.validate(), style: boldTextStyle()),
                      8.height,
                      Row(
                        children: [
                          Text(businessListData!.rating.toString(), style: boldTextStyle(color: rf_primaryColor)).paddingOnly(right: 5),
                          Text(businessListData!.businessType.validate(), style: secondaryTextStyle()).paddingOnly(right: 5),
                          // Text(businessListData!.location.validate(), style: secondaryTextStyle()).paddingOnly(right: 5),
                        ],
                      ).fit(),
                    ],
                  ).expand(),
                  Row(
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: Color(0xFF1157FA)),
                        padding: EdgeInsets.all(4),
                      ),
                      6.width,
                      Text(businessListData!.address.validate(), style: secondaryTextStyle()),
                    ],
                  ),
                ],
              ).paddingOnly(left: 3),
              showHeight.validate() ? 8.height : 24.height,
              Row(
                children: [
                  Icon(Icons.location_on, color: rf_primaryColor, size: 16),
                  6.width,
                  Text(businessListData!.location.validate(), style: secondaryTextStyle()),
                ],
              ),
            ],
          ).expand()
        ],
      ),
    ).onTap(() {
      BusinessDescriptionScreen(businessData: businessListData!).launch(context);
    }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent);
  }
}
