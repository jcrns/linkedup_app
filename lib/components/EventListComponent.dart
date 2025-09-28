import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/EventDescriptionScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class EventListComponent extends StatelessWidget {
  final Event? eventData;
  final bool? showHeight;

  EventListComponent({this.eventData, this.showHeight});

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
          rfCommonCachedNetworkImage(eventData?.image, height: 100, width: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
          16.width,
          // Wrap the Column in Expanded to prevent overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Remove .expand() here, use Flexible for text
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eventData!.name.validate(), style: boldTextStyle(), overflow: TextOverflow.ellipsis),
                          8.height,
                          Row(
                            children: [
                              Flexible(
                                child: Text(eventData!.location.validate(), style: boldTextStyle(color: rf_primaryColor), overflow: TextOverflow.ellipsis),
                              ),
                              8.width,
                              Text(eventData!.rating.toString(), style: secondaryTextStyle()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    8.width,
                    // Wrap address in Flexible to avoid overflow
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: Color(0xFF1157FA)),
                            padding: EdgeInsets.all(4),
                          ),
                          6.width,
                          Flexible(
                            child: Text(eventData!.address.validate(), style: secondaryTextStyle(), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingOnly(left: 3),
                showHeight.validate() ? 8.height : 24.height,
                Row(
                  children: [
                    Icon(Icons.location_on, color: rf_primaryColor, size: 16),
                    6.width,
                    // Wrap description in Flexible to allow wrapping
                    Flexible(
                      child: Text(eventData!.description.validate(), style: secondaryTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
      RFEventDescriptionScreen(eventData: eventData).launch(context);
    }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent);
  }
}
