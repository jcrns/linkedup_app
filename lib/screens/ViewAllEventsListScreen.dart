import 'package:flutter/material.dart';
import 'package:room_finder_flutter/components/EventListComponent.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import 'package:room_finder_flutter/models/Models.dart';

class ViewAllEventsListScreen extends StatelessWidget {
  final List<Event> eventListData; // Correct declaration

  // Constructor to initialize eventListData
  ViewAllEventsListScreen({required this.eventListData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBarWidget(
        context,
        title: "Recently Added Events",
        appBarHeight: 80,
        showLeadingIcon: false,
        roundCornerShape: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 24),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: eventListData.length, // Use actual event list length
        itemBuilder: (BuildContext context, int index) {
          Event data = eventListData[index]; // Use Event instead of RoomFinderModel
          return EventListComponent(eventData: data); // Ensure EventListComponent accepts Event
        },
      ),
    );
  }
}
