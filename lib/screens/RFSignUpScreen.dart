import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/components/RFCommonAppComponent.dart';
import 'package:room_finder_flutter/screens/CompleteProfileScreen.dart';
import 'package:room_finder_flutter/screens/RFSignInScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import '../utils/RFString.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

    final _secureStorage = const FlutterSecureStorage();

    // Function to load username and password from secure storage
  Future<void> _loadCredentials() async {
    String? savedUsername = await _secureStorage.read(key: 'username');
    String? savedPassword = await _secureStorage.read(key: 'password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        usernameController.text = savedUsername;
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

    String username = usernameController.text.toLowerCase();
    String password = passwordController.text;

    var url = Uri.parse('http://127.0.0.1:5000/api/auth/login/');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'client': false,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        var token = jsonResponse['token'];

        // Save the token and the credentials securely
        await setValue('auth_token', token);
        await _saveCredentials(username, password);  // Save credentials securely

        // Call the function to verify if the user profile exists
        // await verifyUserProfile(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RFCompleteProfileScreen()),
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
  }

  Future<void> registerUser() async {

    String username = usernameController.text.toLowerCase();
    String email = usernameController.text.toLowerCase();
    String password = passwordController.text;
    String passwordConfirm = confirmPasswordController.text;

    if (passwordConfirm != password){
      toast("Password does not match ...");
      return;
    }

    var url = Uri.parse('http://127.0.0.1:5000/api-signup/');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      print("response.statusCode");
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        String responseBool = jsonResponse['response'];

        if (responseBool == 'success') {
          toast("Creation success. Time to set up your profile...");
          print("Creation success. Time to set up your profile...");
          loginUser();
        } else {
          toast("Problem creating profile. Please try again.");
          // WACompleteProfileScreen().launch(context);
        }
      } else {
        toast("Failed to verify profile: ${response.body}");
      }
    } catch (e) {
      toast("An error occurred while verifying profile.");
      print(e);
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
              child: Text('Create Account', style: boldTextStyle(color: white)),
              width: context.width(),
              height: 45,
              elevation: 0,
              onTap: () {
                registerUser();
                toast("Account created successfully. Please log in.");
                // Save the credentials securely
                _saveCredentials(usernameController.text, passwordController.text); 
                
                // Navigate to the login screen after successful registration
                RFSignInScreen(showDialog: true).launch(context);
              },
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
