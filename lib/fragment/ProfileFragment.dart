// ProfileFragment.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/RoomFinderModel.dart';
import 'package:room_finder_flutter/screens/CoinPage.dart';
import 'package:room_finder_flutter/screens/EditProfileScreen.dart';
import 'package:room_finder_flutter/screens/RFSignInScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFDataGenerator.dart';
import 'package:room_finder_flutter/utils/RFImages.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
// New import
import '../services/UserService.dart'; // New import
// New import

class ProfileFragment extends StatefulWidget {
  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final List<RoomFinderModel> settingData = settingList();
  static const String _baseUrl = 'http://127.0.0.1:5000';
  Map<String, dynamic>? userProfile;
  Map<String, int>? coinBalances;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
    _fetchUserData();
  }

  void init() async {
    setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    
    try {
      final profile = await UserService.getUserProfile();
      final coins = await UserService.getCoinBalances();

      setState(() {
        userProfile = profile;
        coinBalances = coins;
        isLoading = false;
      });
      print("userProfile!['image']");
      print(userProfile);
      print(userProfile!['image']);
      print(_baseUrl + userProfile!['image']);
    } catch (e) {
      print("Error fetching user data: $e");
      toast('Failed to load profile data');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RFCommonAppComponent(
        title: "Account",
        mainWidgetHeight: 200,
        subWidgetHeight: 100,
        accountCircleWidget: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(top: 150),
                width: 100,
                height: 100,
                decoration: boxDecorationWithRoundedCorners(
                  boxShape: BoxShape.circle,
                  border: Border.all(color: white, width: 4),
                ),
                child: userProfile?['image'] != null
                ? ClipOval(
                    child: rfCommonCachedNetworkImage(
                      _baseUrl + userProfile!['image'],
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                : null, // No fallback
              ),
              Positioned(
                bottom: 8,
                right: -4,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.all(6),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: context.cardColor,
                    boxShape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(spreadRadius: 0.4, blurRadius: 3, color: gray.withOpacity(0.1), offset: Offset(1, 6)),
                    ],
                  ),
                  child: Icon(Icons.add, color: appStore.isDarkModeOn ? white : rf_primaryColor, size: 16),
                ),
              ),
            ],
          ),
        ),
        subWidget: isLoading 
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                16.height,
                Text(userProfile?['username'] ?? 'User Name', style: boldTextStyle(size: 18)),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${coinBalances?['total_vouchers'] ?? 0} Vouchers', style: secondaryTextStyle()),
                    8.width,
                    Container(height: 10, width: 1, color: appStore.isDarkModeOn ? white : gray.withOpacity(0.4)),
                    8.width,
                    GestureDetector(
                      onTap: () => CoinPage().launch(context),
                      child: Text('${coinBalances?['total_coins'] ?? 0} Coins', 
                          style: secondaryTextStyle(color: rf_primaryColor)),
                    ),
                  ],
                ),
                16.height,
                GestureDetector(
                  onTap: () => EditProfileScreen(profileData: userProfile).launch(context)
                      .then((_) => _fetchUserData()),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : rf_selectedCategoryBgColor,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        rf_person.iconImage(iconColor: rf_primaryColor).paddingOnly(top: 4),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Edit Profile", style: boldTextStyle(color: rf_primaryColor)),
                            8.height,
                            Text(
                              "Edit all the basic profile information associated with your profile",
                              style: secondaryTextStyle(color: gray),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ).expand(),
                      ],
                    ),
                  ),
                ),
                SettingItemWidget(
                  title: "Dark Mode",
                  leading: Icon(Icons.dark_mode_outlined, size: 18, color: rf_primaryColor),
                  titleTextStyle: primaryTextStyle(),
                  trailing: Switch(
                    value: appStore.isDarkModeOn,
                    activeTrackColor: rf_primaryColor,
                    onChanged: (bool value) {
                      appStore.toggleDarkMode(value: value);
                      setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);
                      setState(() {});
                    },
                  ),
                  padding: EdgeInsets.only(left: 40, right: 16, top: 8),
                  onTap: () {},
                ),
                ListView.builder(
                  padding: EdgeInsets.only(left: 22),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: settingData.length,
                  itemBuilder: (BuildContext context, int index) {
                    RoomFinderModel data = settingData[index];
                    return Container(
                      margin: EdgeInsets.only(right: 24),
                      child: SettingItemWidget(
                        title: data.roomCategoryName.validate(),
                        leading: data.img.validate().iconImage(iconColor: rf_primaryColor, size: 18),
                        titleTextStyle: primaryTextStyle(),
                        onTap: () {
                          if (index == 4) {
                            showConfirmDialogCustom(
                              context,
                              cancelable: false,
                              title: "Are you sure you want to logout?",
                              dialogType: DialogType.CONFIRMATION,
                              onCancel: (v) => finish(context),
                              onAccept: (v) async{
                                // RFSignInScreen().launch(v).then((value) => finish(context));
                                // Navigator.pop(context);
                                
                                final userService = UserService();
                                await userService.resetAuthToken();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => RFSignInScreen()),
                                  (route) => false,
                                );
                              },
                            );
                          } else if (index == 3) {
                            // New coin page navigation
                            CoinPage().launch(context);
                          } else {
                            data.newScreenWidget.validate().launch(context);
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
      ),
    );
  }
}