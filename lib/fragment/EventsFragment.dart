import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:room_finder_flutter/components/EventListComponent.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';

class EventsFragment extends StatefulWidget {
  @override
  State<EventsFragment> createState() => _EventsFragmentState();
}

class _EventsFragmentState extends State<EventsFragment> {
  // final List<RoomFinderModel> settingData = settingList();
  List<Event> eventListData = []; // Initialize with empty list
  bool isLoading = false;

  Future<void> fetchEvents() async { // Renamed to fetchEvents
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('http://127.0.0.1:8000/api/events');
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
          eventListData = jsonResponse.map((event) => Event.fromJson(event)).toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recently Added Events', style: boldTextStyle()),
                // TextButton(
                //   onPressed: () {
                //     ViewAllEventsListScreen(eventListData: eventListData).launch(context); // Pass actual data
                //   },
                //   child: Text(
                //     'View All',
                //     style: secondaryTextStyle(
                //       decoration: TextDecoration.underline,
                //       textBaseline: TextBaseline.alphabetic,
                //     ),
                //   ),
                // ),
              ],
            ).paddingOnly(left: 16, right: 16, top: 106, bottom: 8),

            isLoading 
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: eventListData.take(3).length, // Show up to 3 items
                  itemBuilder: (context, index) {
                    Event data = eventListData[index];
                    return EventListComponent(eventData: data);
                  },
                ),
          ],
        ),
      ),
    );
  }
}