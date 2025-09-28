import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class RFEmailSignInScreen extends StatefulWidget {
  bool showDialog;

  RFEmailSignInScreen({this.showDialog = false});

  @override
  _RFEmailSignInScreenState createState() => _RFEmailSignInScreenState();
}

class _RFEmailSignInScreenState extends State<RFEmailSignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passWordFocusNode = FocusNode();

  Timer? timer;
bool isLoading = false;  // To manage the loading state

  @override
  void initState() {
    super.initState();
    _loadCredentials();  // Load saved credentials on app start
    init();
  }

  // Future<void> init() async {}

  // Function to load username and password from secure storage
  Future<void> _loadCredentials() async {
    String? savedUsername = await _secureStorage.read(key: 'username');
    String? savedPassword = await _secureStorage.read(key: 'password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        emailController.text = savedUsername;
        passwordController.text = savedPassword;
      });
    }
  }

  // Function to save username and password to secure storage
  Future<void> _saveCredentials(String username, String password) async {
    await _secureStorage.write(key: 'username', value: username);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    String username = emailController.text.toLowerCase();
    String password = passwordController.text;

    var url = Uri.parse('http://127.0.0.1:8000/api/auth/login/');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        var jsonResponse = jsonDecode(response.body);
        var token = jsonResponse['token'];
        var profile = jsonResponse['profile'];

        // Save the token and the credentials securely
        await setValue('auth_token', token);
        await setValue('profile', profile);
        await _saveCredentials(username, password);  // Save credentials securely

        // Call the function to verify if the user profile exists
        // await verifyUserProfile(token);
        toast("Profile exists. Navigating to main screen...");
        // HomeScreen().launch(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('Username: $username, Password: $password');
        print(response.body);
        toast("Login Failed: ${response.body}");
      }
    } catch (e) {
      toast("An error occurred");
      print(e);
    }

    setState(() {
      isLoading = false;
    });
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
              child: Text('Log In', style: boldTextStyle(color: white)),
              width: context.width(),
              elevation: 0,
              onTap: () {
                loginUser();
                // HomeScreen().launch(context);

              },
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
