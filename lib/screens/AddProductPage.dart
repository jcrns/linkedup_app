// screens/AddProductPage.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/ProductService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class AddProductPage extends StatefulWidget {
  final Business? business;

  const AddProductPage({Key? key, this.business}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  String? _selectedCategory;
  
  // Common product categories
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Home & Garden',
    'Beauty & Personal Care',
    'Sports & Outdoors',
    'Books & Media',
    'Toys & Games',
    'Automotive',
    'Health & Wellness',
    'Jewelry & Accessories',
    'Art & Crafts',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      toast('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      toast('Error taking photo: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      toast('Please fill all required fields correctly');
      return;
    }

    if (_imageFile == null) {
      toast('Please add a product image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare product data
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'category': _selectedCategory ?? _categoryController.text.trim(),
        // Note: The business will be automatically set by Django from the user's business_profile
      };

      // Create product
      final response = await ProductService.createProduct(productData);
      
      toast('Product created successfully!');
      
      // Navigate back and refresh the business page
      finish(context, true); // Pass true to indicate success

    } catch (e) {
      toast('Failed to create product: $e');
      print('Error creating product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                finish(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () {
                finish(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
        backgroundColor: rf_primaryColor,
        elevation: 0,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Info
              if (widget.business != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business, color: Colors.blue, size: 24),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adding to:', style: secondaryTextStyle(size: 12)),
                            Text(widget.business!.name, style: boldTextStyle(size: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                16.height,
              ],

              // Product Image
              Text('Product Image *', style: boldTextStyle(size: 16)),
              8.height,
              Container(
                width: context.width(),
                height: 200,
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.dividerColor),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                          8.height,
                          Text('Add Product Image', style: secondaryTextStyle()),
                        ],
                      ),
              ).onTap(_showImageSourceDialog),
              8.height,
              Text(
                'Tap to add product image (required)',
                style: secondaryTextStyle(size: 12),
              ),
              24.height,

              // Product Name
              Text('Product Name *', style: boldTextStyle(size: 16)),
              8.height,
              AppTextField(
                controller: _nameController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(
                  hintText: 'Enter product name',
                  showLableText: false,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              16.height,

              // Description
              Text('Description', style: boldTextStyle(size: 16)),
              8.height,
              AppTextField(
                controller: _descriptionController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 3,
                maxLines: 5,
                decoration: rfInputDecoration(
                  hintText: 'Describe your product...',
                  showLableText: false,
                ),
              ),
              16.height,

              // Price and Stock
              Row(
                children: [
                  // Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price *', style: boldTextStyle(size: 16)),
                        8.height,
                        AppTextField(
                          controller: _priceController,
                          textFieldType: TextFieldType.NUMBER,
                          decoration: rfInputDecoration(
                            hintText: '0.00',
                            showLableText: false,
                            prefixIcon: Icon(Icons.attach_money, size: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter valid price';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  16.width,
                  // Stock
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock *', style: boldTextStyle(size: 16)),
                        8.height,
                        AppTextField(
                          controller: _stockController,
                          textFieldType: TextFieldType.NUMBER,
                          decoration: rfInputDecoration(
                            hintText: '0',
                            showLableText: false,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Stock is required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.height,

              // Category
              Text('Category *', style: boldTextStyle(size: 16)),
              8.height,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Select category',
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ),
              8.height,
              Text(
                'Or enter custom category:',
                style: secondaryTextStyle(size: 12),
              ),
              8.height,
              AppTextField(
                controller: _categoryController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(
                  hintText: 'Custom category',
                  showLableText: false,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  }
                },
              ),
              32.height,

              // Submit Button
              AppButton(
                text: 'Create Product',
                textColor: white,
                color: rf_primaryColor,
                width: context.width(),
                onTap: _isLoading ? null : _submitForm,
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }
}