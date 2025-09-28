// EditProfileScreen.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/services/UserService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFImages.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  EditProfileScreen({this.profileData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _languageController;
  String? _profileImage;
  static const String _baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profileData?['username']);
    _emailController = TextEditingController(text: widget.profileData?['email']);
    _dobController = TextEditingController(text: widget.profileData?['date_of_birth']);
    _languageController = TextEditingController(text: widget.profileData?['language']);
    _profileImage = widget.profileData?['image'];
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'date_of_birth': _dobController.text,
        'language': _languageController.text,
        'image': _profileImage,
      };

      // Call API to update profile
      try {
        await UserService.updateUserProfile(updatedData);
        toast('Profile updated successfully');
        finish(context, true);
      } catch (e) {
        toast('Failed to update profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: boldTextStyle(color: Colors.white)),
        backgroundColor: rf_primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              20.height,
              GestureDetector(
                onTap: () => _pickImage(),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null 
                          ? NetworkImage(_baseUrl+ _profileImage!) as ImageProvider
                          : AssetImage(rf_user),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: rf_primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              30.height,
              AppTextField(
                controller: _usernameController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(lableText: 'Username', hintText: "Enter your Username"),
                validator: (value) => value.isEmptyOrNull ? 'Required field' : null,
              ),
              16.height,
              AppTextField(
                controller: _emailController,
                textFieldType: TextFieldType.EMAIL,
                decoration: rfInputDecoration(lableText: 'Email', hintText: "Enter your email address"),
                validator: (value) => value.isEmptyOrNull ? 'Required field' : null,
              ),
              16.height,
              AppTextField(
                controller: _dobController,
                textFieldType: TextFieldType.OTHER,
                decoration: rfInputDecoration(
                  lableText: 'Date of Birth',
                  hintText: "Select your date of birth",
                  suffixIcon: Icon(Icons.calendar_today, size: 20),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dobController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              16.height,
              AppTextField(
                controller: _languageController,
                textFieldType: TextFieldType.OTHER,
                decoration: rfInputDecoration(lableText: 'Language', hintText: "Preferred language"),
              ),
              30.height,
              AppButton(
                text: 'Save Changes',
                color: rf_primaryColor,
                textColor: Colors.white,
                onTap: _updateProfile,
                width: context.width(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage() {
    // Implement image picking logic
    toast('Image picker will be implemented');
  }
}