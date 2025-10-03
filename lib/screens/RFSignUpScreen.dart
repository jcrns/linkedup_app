import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/screens/CompleteProfileScreen.dart';
import 'package:room_finder_flutter/screens/RFSignInScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import '../utils/RFString.dart';
import 'package:room_finder_flutter/services/UserService.dart';

class RFSignUpScreen extends StatefulWidget {
  @override
  _RFSignUpScreenState createState() => _RFSignUpScreenState();
}

class _RFSignUpScreenState extends State<RFSignUpScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode usernameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passWordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  final UserService _userService = UserService();
  bool isLoading = false;

  Future<void> _handleRegistration() async {
    if (confirmPasswordController.text != passwordController.text) {
      toast("Password does not match...");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await _userService.registerUser(
      fullNameController.text,
      usernameController.text,
      passwordController.text,
      confirmPasswordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result != null && result['success'] == true) {
      toast(result['message'] ?? "Account created successfully. Please log in.");
      RFSignInScreen(showDialog: true).launch(context);
    } else {
      toast(result?['error'] ?? "Registration failed");
    }
  }

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
      body: RFCommonAppComponent(
        title: RFAppName,
        subTitle: RFAppSubTitle,
        mainWidgetHeight: 250,
        subWidgetHeight: 190,
        cardWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create an Account', style: boldTextStyle(size: 18)),
            16.height,
            AppTextField(
              controller: fullNameController,
              focus: usernameFocusNode,
              nextFocus: emailFocusNode,
              textFieldType: TextFieldType.NAME,
              decoration: rfInputDecoration(
                lableText: "Username",
                showLableText: true,
                suffixIcon: Container(
                  padding: EdgeInsets.all(2),
                  decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: rf_rattingBgColor),
                  child: Icon(Icons.done, color: Colors.white, size: 14),
                ),
              ),
            ),
            16.height,
            AppTextField(
              controller: usernameController,
              focus: emailFocusNode,
              nextFocus: passWordFocusNode,
              textFieldType: TextFieldType.EMAIL,
              decoration: rfInputDecoration(
                lableText: "Email Address",
                showLableText: true,
                suffixIcon: Container(
                  padding: EdgeInsets.all(2),
                  decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: rf_rattingBgColor),
                  child: Icon(Icons.done, color: Colors.white, size: 14),
                ),
              ),
            ),
            16.height,
            AppTextField(
              controller: passwordController,
              focus: passWordFocusNode,
              nextFocus: confirmPasswordFocusNode,
              textFieldType: TextFieldType.PASSWORD,
              decoration: rfInputDecoration(
                lableText: 'Password',
                showLableText: true,
              ),
            ),
            16.height,
            AppTextField(
              controller: confirmPasswordController,
              focus: confirmPasswordFocusNode,
              textFieldType: TextFieldType.PASSWORD,
              decoration: rfInputDecoration(
                lableText: 'Confirm Password',
                showLableText: true,
              ),
            ),
            32.height,
            AppButton(
              color: rf_primaryColor,
              child: isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: white))
                : Text('Create Account', style: boldTextStyle(color: white)),
              width: context.width(),
              height: 45,
              elevation: 0,
              onTap: isLoading ? null : _handleRegistration,
            ),
          ],
        ),
        subWidget: rfCommonRichText(title: "Have an account? ", subTitle: "Sign In Here").paddingAll(8).onTap(
          () {
            finish(context);
          },
        ),
      ),
    );
  }
}