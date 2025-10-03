import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/fragment/ProfileFragment.dart';
import 'package:room_finder_flutter/fragment/EventsFragment.dart';
import 'package:room_finder_flutter/fragment/HomeFragment.dart';
import 'package:room_finder_flutter/fragment/ExploreFragment.dart';
import 'package:room_finder_flutter/fragment/SocialFragment.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFImages.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  var _pages = [
    HomeFragment(),
    ExploreFragment(),
    EventsFragment(), // fixed typo here (EventsFragmentnt → EventsFragment)
    // SocialFragment(),
    ProfileFragment(),
  ];

  Widget _bottomTab() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedLabelStyle: boldTextStyle(size: 14),
      selectedFontSize: 14,
      unselectedFontSize: 14,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 22),
          label: 'Home',
          activeIcon: Icon(Icons.home_outlined, color: rf_primaryColor, size: 22),
        ),
        BottomNavigationBarItem(
          icon: rf_search.iconImage(),
          label: 'Explore',
          activeIcon: rf_search.iconImage(iconColor: rf_primaryColor, size: 22),
        ),
        BottomNavigationBarItem(
          icon: rf_setting.iconImage(size: 22),
          label: 'Events',
          activeIcon: rf_setting.iconImage(iconColor: rf_primaryColor),
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.people_alt_outlined, size: 22),
        //   label: 'Forum',
        //   activeIcon: Icon(Icons.people_alt, color: rf_primaryColor, size: 22),
        // ),
        BottomNavigationBarItem(
          icon: rf_person.iconImage(),
          label: 'Account',
          activeIcon: rf_person.iconImage(iconColor: rf_primaryColor, size: 22),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // disables back-swipe & back button
      child: Scaffold(
        bottomNavigationBar: _bottomTab(),
        body: Center(child: _pages.elementAt(_selectedIndex)),
      ),
    );
  }
}
