import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/RFCongratulatedDialog.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class RFEventDescriptionScreen extends StatefulWidget {
  final Event? eventData; // Updated to EventModel

  RFEventDescriptionScreen({this.eventData});

  @override
  _RFEventDescriptionScreenState createState() => _RFEventDescriptionScreenState();
}

class _RFEventDescriptionScreenState extends State<RFEventDescriptionScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppButton(
        color: rf_primaryColor,
        elevation: 0,
        child: Text('Book Now', style: boldTextStyle(color: white)),
        width: context.width(),
        onTap: () {
          showInDialog(context, barrierDismissible: true, builder: (context) {
            return RFCongratulatedDialog();
          });
        },
      ).paddingSymmetric(horizontal: 16, vertical: 24),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: white, size: 18),
                onPressed: () {
                  finish(context);
                },
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              backgroundColor: rf_primaryColor,
              pinned: true,
              elevation: 2,
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding: EdgeInsets.all(10),
                centerTitle: true,
                background: Stack(
                  children: [
                    // Replace with actual event image URL
                    rfCommonCachedNetworkImage(
                      widget.eventData!.image ?? '', // Replace with event image URL
                      fit: BoxFit.cover,
                      width: context.width(),
                      height: 350,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.eventData!.name, style: boldTextStyle(color: white, size: 18)), // Event Name
                          8.height,
                          Text("Location: ${widget.eventData!.location}", style: secondaryTextStyle(color: white)), // Location
                          8.height,
                          Row(
                            children: [
                              Text("${widget.eventData!.rating} ", style: boldTextStyle(color: white)), // Rating
                              Icon(Icons.star, color: Colors.amber, size: 18), // Star icon for rating
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Event Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Description", style: boldTextStyle(size: 16)),
                    8.height,
                    Text(widget.eventData!.description, style: secondaryTextStyle()), // Event Description
                    16.height,
                    Text("Address: ${widget.eventData!.address}", style: secondaryTextStyle()), // Event Address
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
