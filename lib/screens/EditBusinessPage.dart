// screens/EditBusinessPage.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/BusinessService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class EditBusinessPage extends StatefulWidget {
  final Business business;

  const EditBusinessPage({Key? key, required this.business}) : super(key: key);

  @override
  _EditBusinessPageState createState() => _EditBusinessPageState();
}

class _EditBusinessPageState extends State<EditBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final BusinessService _businessService = BusinessService();
  
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _businessTypeController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactInfoController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  TextEditingController _businessHoursController = TextEditingController();
  TextEditingController _targetAudienceController = TextEditingController();
  TextEditingController _socialMediaController = TextEditingController();
  TextEditingController _dealsController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.business.name;
    _descriptionController.text = widget.business.description;
    _businessTypeController.text = widget.business.businessType;
    _locationController.text = widget.business.location;
    _addressController.text = widget.business.address;
    _contactInfoController.text = widget.business.contactInfo ?? '';
    _websiteController.text = widget.business.website ?? '';
    _businessHoursController.text = widget.business.businessHours ?? '';
    _targetAudienceController.text = widget.business.targetAudience ?? '';
    _socialMediaController.text = widget.business.socialMedia ?? '';
    _dealsController.text = widget.business.deals ?? '';
  }

  Future<void> _updateBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBusiness = Business(
        id: widget.business.id,
        name: _nameController.text,
        description: _descriptionController.text,
        businessType: _businessTypeController.text,
        location: _locationController.text,
        address: _addressController.text,
        image: widget.business.image,
        views: widget.business.views,
        rating: widget.business.rating,
        contactInfo: _contactInfoController.text.isEmpty ? null : _contactInfoController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        businessHours: _businessHoursController.text.isEmpty ? null : _businessHoursController.text,
        targetAudience: _targetAudienceController.text.isEmpty ? null : _targetAudienceController.text,
        socialMedia: _socialMediaController.text.isEmpty ? null : _socialMediaController.text,
        deals: _dealsController.text.isEmpty ? null : _dealsController.text,
        valuation: widget.business.valuation,
        totalInvestment: widget.business.totalInvestment,
        monthlyGrowthRate: widget.business.monthlyGrowthRate,
      );

      final success = await _businessService.updateBusiness(updatedBusiness);
      
      if (success) {
        toast('Business updated successfully');
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        toast('Failed to update business');
      }
    } catch (e) {
      toast('Error updating business: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Business', style: boldTextStyle()),
        backgroundColor: rf_primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                controller: _nameController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(
                  lableText: "Business Name",
                  showLableText: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: _businessTypeController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(
                  lableText: "Business Type",
                  showLableText: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business type';
                  }
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: _locationController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(
                  lableText: "Location",
                  showLableText: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: _addressController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 2,
                maxLines: 3,
                decoration: rfInputDecoration(
                  lableText: "Address",
                  showLableText: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: _descriptionController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 3,
                maxLines: 5,
                decoration: rfInputDecoration(
                  lableText: "Description",
                  showLableText: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: _contactInfoController,
                textFieldType: TextFieldType.PHONE,
                decoration: rfInputDecoration(
                  lableText: "Contact Information",
                  showLableText: true,
                ),
              ),
              16.height,
              AppTextField(
                controller: _websiteController,
                textFieldType: TextFieldType.MULTILINE,
                decoration: rfInputDecoration(
                  lableText: "Website",
                  showLableText: true,
                ),
              ),
              16.height,
              AppTextField(
                controller: _businessHoursController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 2,
                maxLines: 3,
                decoration: rfInputDecoration(
                  lableText: "Business Hours",
                  showLableText: true,
                ),
              ),
              16.height,
              AppTextField(
                controller: _targetAudienceController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 2,
                maxLines: 3,
                decoration: rfInputDecoration(
                  lableText: "Target Audience",
                  showLableText: true,
                ),
              ),
              16.height,
              AppTextField(
                controller: _socialMediaController,
                textFieldType: TextFieldType.MULTILINE,
                decoration: rfInputDecoration(
                  lableText: "Social Media",
                  showLableText: true,
                ),
              ),
              16.height,
              AppTextField(
                controller: _dealsController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 2,
                maxLines: 3,
                decoration: rfInputDecoration(
                  lableText: "Special Deals",
                  showLableText: true,
                ),
              ),
              32.height,
              AppButton(
                color: rf_primaryColor,
                child: _isLoading 
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: white))
                  : Text('Update Business', style: boldTextStyle(color: white)),
                width: context.width(),
                onTap: _isLoading ? null : _updateBusiness,
              ),
            ],
          ),
        ),
      ),
    );
  }
}