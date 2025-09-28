
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/screens/HomeScreen.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RFCompleteProfileScreen extends StatefulWidget {
  static String tag = '/RFCompleteProfileScreen';

  const RFCompleteProfileScreen({super.key});

  @override
  RFCompleteProfileScreenState createState() => RFCompleteProfileScreenState();
}

class RFCompleteProfileScreenState extends State<RFCompleteProfileScreen> {
 var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var businessNameController = TextEditingController();
  var businessTypeController = TextEditingController();
  var languageController = TextEditingController();
  var descriptionController = TextEditingController();
  File? _image; // For storing the selected business image

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode businessNameFocusNode = FocusNode();
  FocusNode businessTypeFocusNode = FocusNode();
  FocusNode languageFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  bool isLoading = false;  // To manage loading state
  String? token;  // To store the token

  @override
  void initState() {
    super.initState();
    getToken();  // Retrieve the token when the screen initializes
  }

  Future<void> getToken() async {
    // Retrieve the token stored during login
    token = getStringAsync('auth_token');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> submitProfile() async {
    setState(() {
      isLoading = true;
    });

    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String businessName = businessNameController.text;
    String businessType = businessTypeController.text;
    String language = languageController.text;
    String description = descriptionController.text;

    var url = Uri.parse('https://iblinkco-44fdffec55ba.herokuapp.com/api/profiles/'); // Update with your actual endpoint
    // var url = Uri.parse('https://iblinkco-44fdffec55ba.herokuapp.comapi/profiles/'); // Update with your actual endpointhttps://iblinkco-44fdffec55ba.herokuapp.comapi

    try {
      var request = http.MultipartRequest('POST', url);

      // Add the token to the headers
      request.headers['Authorization'] = 'Token $token';  // Use the retrieved token

      // Add text fields
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['business_name'] = businessName;
      request.fields['business_type'] = businessType;
      request.fields['language'] = language;
      request.fields['description'] = description;

      request.fields['busy'] = "false";
      request.fields['can_post'] = "true";
      request.fields['is_manager'] = "false";
      request.fields['is_client'] = "true";

      // Add image if selected
      // if (_image != null) {
      //   request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      // }

      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        toast("Profile updated successfully");

        // Navigate to another screen or show success message
        HomeScreen().launch(context);
      } else {
        print("Failed to update profile. Response code: ${response.statusCode}");
        toast("Failed to update profile");
      }
    } catch (e) {
      print("Error: $e");
      toast("An error occurred");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile', style: boldTextStyle(size: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Note: This data will be shown to managers you work with in the future. This can be changed later.", style: primaryTextStyle()),
              30.height,
              Text("First Name", style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                decoration: rfInputDecoration(lableText: 'Enter your first name'),
                textFieldType: TextFieldType.NAME,
                controller: firstNameController,
                focus: firstNameFocusNode,
                nextFocus: lastNameFocusNode,
              ),
              16.height,
              Text("Last Name", style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                decoration: rfInputDecoration(lableText: 'Enter your last name'),
                textFieldType: TextFieldType.NAME,
                controller: lastNameController,
                focus: lastNameFocusNode,
                nextFocus: businessNameFocusNode,
              ),
              16.height,
              Text("Business Name", style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                decoration: rfInputDecoration(lableText: 'Enter your business name'),
                textFieldType: TextFieldType.NAME,
                controller: businessNameController,
                focus: businessNameFocusNode,
                nextFocus: businessTypeFocusNode,
              ),
              16.height,
              Text("Business Type", style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                decoration: rfInputDecoration(lableText: 'Enter your business type'),
                textFieldType: TextFieldType.NAME,
                controller: businessTypeController,
                focus: businessTypeFocusNode,
                nextFocus: languageFocusNode,
              ),
              16.height,
              Text("Language", style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                decoration: rfInputDecoration(lableText: 'Enter your language'),
                textFieldType: TextFieldType.NAME,
                controller: languageController,
                focus: languageFocusNode,
                nextFocus: descriptionFocusNode,
              ),
              16.height,
              Text("Business Description", style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                decoration: rfInputDecoration(lableText: 'What does your business do? (Max 500 characters)'),
                textFieldType: TextFieldType.MULTILINE,
                maxLines: 5,
                controller: descriptionController,
                focus: descriptionFocusNode,
              ),
              16.height,
              Text("Business Image(Logo)", style: boldTextStyle(size: 14)),
              8.height,
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: boxDecorationRoundedWithShadow(8, backgroundColor: Colors.grey[200] ?? Colors.grey),
                  child: Center(
                    child: _image == null
                        ? Text('No file chosen', style: primaryTextStyle())
                        : Text('Image selected', style: boldTextStyle()),
                  ),
                ),
              ),
              30.height,
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      text: "Submit",
                      color: rf_primaryColor,
                      textColor: Colors.white,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      width: context.width(),
                      onTap: submitProfile,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
