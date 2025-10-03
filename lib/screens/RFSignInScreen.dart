import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/components/RFConformationDialog.dart';
import 'package:room_finder_flutter/screens/HomeScreen.dart';
import 'package:room_finder_flutter/screens/RFResetPasswordScreen.dart';
import 'package:room_finder_flutter/screens/RFSignUpScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFString.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import 'package:room_finder_flutter/services/UserService.dart';

class RFSignInScreen extends StatefulWidget {
  bool showDialog;

  RFSignInScreen({this.showDialog = false});

  @override
  _RFSignInScreenState createState() => _RFSignInScreenState();
}

class _RFSignInScreenState extends State<RFSignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  FocusNode emailFocusNode = FocusNode();
  FocusNode passWordFocusNode = FocusNode();

  Timer? timer;
  bool isLoading = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    init();
  }

  Future<void> _loadCredentials() async {
    final credentials = await _userService.loadCredentials();
    if (credentials['username'] != null && credentials['password'] != null) {
      setState(() {
        emailController.text = credentials['username']!;
        passwordController.text = credentials['password']!;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
    });

    final result = await _userService.loginUser(
      emailController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result != null && result['success'] == true) {
      toast("Profile exists. Navigating to main screen...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      toast(result?['error'] ?? "Login failed");
    }
  }

  void init() async {
    setStatusBarColor(rf_primaryColor, statusBarIconBrightness: Brightness.light);

    widget.showDialog
        ? Timer.run(() {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) {
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.of(context).pop(true);
                });
                return Material(type: MaterialType.transparency, child: RFConformationDialog());
              },
            );
          })
        : SizedBox();
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
        mainWidgetHeight: 230,
        subWidgetHeight: 170,
        cardWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sign In to Continue', style: boldTextStyle(size: 18)),
            16.height,
            AppTextField(
              controller: emailController,
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
              textFieldType: TextFieldType.PASSWORD,
              decoration: rfInputDecoration(
                lableText: 'Password',
                showLableText: true,
              ),
            ),
            32.height,
            AppButton(
              color: rf_primaryColor,
              child: isLoading 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: white))
                : Text('Log In', style: boldTextStyle(color: white)),
              width: context.width(),
              elevation: 0,
              onTap: isLoading ? null : _handleLogin,
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                  child: Text("Reset Password?", style: primaryTextStyle()),
                  onPressed: () {
                    RFResetPasswordScreen().launch(context);
                  }),
            ),
          ],
        ),
        subWidget: socialLoginWidget(context, title1: "New Member? ", title2: "Sign up Here", callBack: () {
          RFSignUpScreen().launch(context);
        }),
      ),
    );
  }
}