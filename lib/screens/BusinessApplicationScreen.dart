import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class BusinessApplicationScreen extends StatefulWidget {
  @override
  _BusinessApplicationScreenState createState() => _BusinessApplicationScreenState();
}

class _BusinessApplicationScreenState extends State<BusinessApplicationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _audienceController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _socialController = TextEditingController();
  final TextEditingController _dealsController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  
  File? _imageFile;
  File? _logoFile;
  bool _isLoading = false;

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(image.path);
        } else {
          _imageFile = File(image.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final uri = Uri.parse('http://127.0.0.1:5000/api/businesses/');
      final token = getStringAsync('auth_token', defaultValue: '');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Token $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      
      // Add text fields - REMOVE 'owner' field as it's read-only
      request.fields.addAll({
        'name': _nameController.text,
        'business_type': _typeController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'contact_info': _contactController.text,
        'target_audience': _audienceController.text,
        'website': _websiteController.text ?? '', // handle null
        'social_media': _socialController.text ?? '', // handle null
        'deals': _dealsController.text,
        'business_hours': _hoursController.text,
        'total_investment': '0', // default value
        'monthly_growth_rate': '0.05', // default value
      });
      
      // Add image files with CORRECT field names
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // CORRECTED: matches model field name
          _imageFile!.path,
        ));
      }
      
      if (_logoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'logo', // CORRECTED: matches model field name
          _logoFile!.path,
        ));
      }
      
      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString(); // ADD THIS
        
        if (response.statusCode == 201) {
          toast('Business created successfully!');
          finish(context);
        } else {
          print('Error response: $responseBody'); // DEBUGGING
          toast('Error: ${response.reasonPhrase}. Details: $responseBody');
        }
      } catch (e) {
        toast('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Application'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePicker('Business Image', _imageFile, false),
                  SizedBox(height: 20),
                  _buildImagePicker('Business Logo (optional)', _logoFile, true),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    label: 'What is the name of your business?',
                    isRequired: true,
                  ),
                  _buildTextField(
                    controller: _typeController,
                    label: 'What type of business do you own?',
                    isRequired: true,
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Business location/address',
                    hint: 'Full physical address of the business',
                    maxLines: 3,
                    isRequired: true,
                  ),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Give a description of your business',
                    hint: 'Brief description of the business and client count',
                    maxLines: 3,
                    isRequired: true,
                  ),
                  _buildTextField(
                    controller: _contactController,
                    label: 'Business contact information',
                    hint: 'Email and phone number',
                    isRequired: true,
                  ),
                  _buildTextField(
                    controller: _audienceController,
                    label: 'Who is your target audience/customer base?',
                    maxLines: 3,
                  ),
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Business website (if applicable)',
                  ),
                  _buildTextField(
                    controller: _socialController,
                    label: 'Social media accounts (Instagram/Facebook)',
                  ),
                  _buildTextField(
                    controller: _dealsController,
                    label: 'Deals/vouchers to offer on our app',
                    maxLines: 3,
                  ),
                  _buildTextField(
                    controller: _hoursController,
                    label: 'Business hours',
                  ),
                  SizedBox(height: 30),
                  AppButton(
                    color: rf_primaryColor,
                    text: 'Submit Application',
                    textStyle: boldTextStyle(color: white),
                    width: context.width(),
                    onTap: _submitForm,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading) Loader().center(),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String title, File? file, bool isLogo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: boldTextStyle()),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(isLogo),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40),
                      Text('Tap to add image', style: secondaryTextStyle()),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: primaryTextStyle(),
              children: isRequired
                  ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                  : null,
            ),
          ),
          SizedBox(height: 4),
          AppTextField(
            controller: controller,
            textFieldType: TextFieldType.MULTILINE,
            minLines: maxLines,
            maxLines: maxLines,
            decoration: rfInputDecoration(hintText: hint ?? label),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}