// screens/EditProductPage.dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/services/ProductService.dart';
import 'package:room_finder_flutter/utils/RFColors.dart';
import 'package:room_finder_flutter/utils/RFWidget.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description ?? '';
    _priceController.text = widget.product.price.toStringAsFixed(2);
    _stockController.text = widget.product.stock.toString();
    _categoryController.text = widget.product.category ?? '';
    _selectedCategory = widget.product.category;
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        image: widget.product.image,
        business: widget.product.business,
        // created_at: widget.product.created_at,
        // updated_at: DateTime.now(),
      );

      final success = await _productService.updateProduct(updatedProduct);
      
      if (success) {
        toast('Product updated successfully');
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        toast('Failed to update product');
      }
    } catch (e) {
      toast('Error updating product: $e');
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
        title: Text('Edit Product', style: boldTextStyle()),
        backgroundColor: rf_primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
        ],
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
                  lableText: "Product Name",
                  showLableText: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
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
              ),
              16.height,
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      textFieldType: TextFieldType.PHONE,
                      decoration: rfInputDecoration(
                        lableText: "Price",
                        showLableText: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: AppTextField(
                      controller: _stockController,
                      textFieldType: TextFieldType.PHONE,
                      decoration: rfInputDecoration(
                        lableText: "Stock",
                        showLableText: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              16.height,
              AppTextField(
                controller: _categoryController,
                textFieldType: TextFieldType.NAME,
                decoration: rfInputDecoration(
                  lableText: "Category",
                  showLableText: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              32.height,
              AppButton(
                color: rf_primaryColor,
                child: _isLoading 
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: white))
                  : Text('Update Product', style: boldTextStyle(color: white)),
                width: context.width(),
                onTap: _isLoading ? null : _updateProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product', style: boldTextStyle()),
          content: Text('Are you sure you want to delete this product? This action cannot be undone.', style: primaryTextStyle()),
          actions: [
            TextButton(
              child: Text('Cancel', style: primaryTextStyle()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: boldTextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProduct();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _productService.deleteProduct(widget.product.id!);
      if (success) {
        toast('Product deleted successfully');
        Navigator.pop(context, true); // Return true to indicate deletion
      } else {
        toast('Failed to delete product');
      }
    } catch (e) {
      toast('Error deleting product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}