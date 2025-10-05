import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:room_finder_flutter/main.dart';
import 'package:room_finder_flutter/models/Models.dart';
import 'package:room_finder_flutter/screens/PaymentScreen.dart';
import 'package:room_finder_flutter/services/CheckoutService.dart';
import 'package:room_finder_flutter/utils/SSWidgets.dart';

class BillingAddressScreen extends StatefulWidget {
  final Cart cart;

  const BillingAddressScreen({Key? key, required this.cart}) : super(key: key);

  @override
  State<BillingAddressScreen> createState() => _BillingAddressScreenState();
}

class _BillingAddressScreenState extends State<BillingAddressScreen> {
  bool mIsCheck = true;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  List<ShippingAddress> _savedAddresses = [];
  ShippingAddress? _selectedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final addresses = await CheckoutService.getShippingAddresses();
      print('Loaded ${addresses.length} saved addresses');
      final addressesBody = addresses.map((e) => e.toJson()).toList();
      print('Addresses: $addressesBody.');
      setState(() {
        _savedAddresses = addresses;
        if (addresses.isNotEmpty) {
          _selectedAddress = addresses.first;
          _populateFormWithAddress(_selectedAddress!);
        }
      });
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  void _populateFormWithAddress(ShippingAddress address) {
    _fullNameController.text = address.fullName;
    _emailController.text = address.email;
    _address1Controller.text = address.address1;
    _address2Controller.text = address.address2 ?? '';
    _cityController.text = address.city;
    _stateController.text = address.state ?? '';
    _zipcodeController.text = address.zipcode ?? '';
    _countryController.text = address.country;
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final address = ShippingAddress(
          fullName: _fullNameController.text,
          email: _emailController.text,
          address1: _address1Controller.text,
          address2: _address2Controller.text.isEmpty ? null : _address2Controller.text,
          city: _cityController.text,
          state: _stateController.text.isEmpty ? null : _stateController.text,
          zipcode: _zipcodeController.text.isEmpty ? null : _zipcodeController.text,
          country: _countryController.text,
        );

        ShippingAddress savedAddress;
        if (_selectedAddress != null) {
          savedAddress = await CheckoutService.updateShippingAddress(
            address.copyWith(id: _selectedAddress!.id, user: _selectedAddress!.user),
          );
        } else {
          savedAddress = await CheckoutService.createShippingAddress(address);
        }

        setState(() {
          _selectedAddress = savedAddress;
        });

        toast('Address saved successfully');
      } catch (e) {
        toast('Error saving address: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Checkout", style: boldTextStyle()),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: context.iconColor, size: 20),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(),
                    32.height,
                    
                    // Saved Addresses
                    if (_savedAddresses.isNotEmpty) ...[
                      Text("Saved Addresses", style: boldTextStyle()),
                      8.height,
                      DropdownButtonFormField<ShippingAddress>(
                        initialValue: _selectedAddress,
                        isExpanded: true, // ⬅️ this makes dropdown take full width
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select saved address',
                        ),
                        items: _savedAddresses.map((address) {
                          return DropdownMenuItem(
                            value: address,
                            child: Text(
                              '${address.fullName} - ${address.address1}, ${address.city}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (address) {
                          setState(() {
                            _selectedAddress = address;
                            if (address != null) {
                              _populateFormWithAddress(address);
                            }
                          });
                        },
                      ),

                      24.height,
                      Center(child: Text('OR', style: secondaryTextStyle())),
                      16.height,
                    ],
                    
                    // Address Form
                    Text("Billing Address", style: boldTextStyle()),
                    16.height,
                    
                    _buildTextField(
                      controller: _fullNameController,
                      label: "Full Name",
                      hint: "Full Name",
                      isRequired: true,
                    ),
                    16.height,
                    
                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      hint: "Email Address",
                      isRequired: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    16.height,
                    
                    _buildTextField(
                      controller: _address1Controller,
                      label: "Address Line 1",
                      hint: "Apartment, Suite, etc",
                      isRequired: true,
                    ),
                    16.height,
                    
                    _buildTextField(
                      controller: _address2Controller,
                      label: "Address Line 2 (Optional)",
                      hint: "Apartment, Suite, etc.",
                    ),
                    16.height,
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: "City",
                            hint: "City",
                            isRequired: true,
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: "State/Province",
                            hint: "State",
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _zipcodeController,
                            label: "Postal Code",
                            hint: "Zipcode",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: _buildTextField(
                            controller: _countryController,
                            label: "Country",
                            hint: "USA",
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    24.height,
                    
                    // Save address checkbox
                    Theme(
                      data: ThemeData(unselectedWidgetColor: appStore.isDarkModeOn ? Colors.white : Colors.black),
                      child: CheckboxListTile(
                        checkColor: appStore.isDarkModeOn ? Colors.black : Colors.white,
                        activeColor: appStore.isDarkModeOn ? Colors.white : Colors.black,
                        value: mIsCheck,
                        title: Text('Save as default billing address', style: primaryTextStyle()),
                        onChanged: (val) {
                          setState(() {
                            mIsCheck = !mIsCheck;
                          });
                        },
                      ),
                    ),
                    
                    // Save Address Button
                    if (_savedAddresses.isEmpty || _selectedAddress == null)
                      AppButton(
                        text: 'Save Address',
                        onTap: _saveAddress,
                        color: Colors.blue,
                        textColor: Colors.white,
                      ).center(),
                    32.height,
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: sSAppButton(
          context: context,
          title: 'Continue to payment',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final shippingAddress = ShippingAddress(
                fullName: _fullNameController.text,
                email: _emailController.text,
                address1: _address1Controller.text,
                address2: _address2Controller.text.isEmpty ? null : _address2Controller.text,
                city: _cityController.text,
                state: _stateController.text.isEmpty ? null : _stateController.text,
                zipcode: _zipcodeController.text.isEmpty ? null : _zipcodeController.text,
                country: _countryController.text,
              );
              
              PaymentScreen(
                cart: widget.cart,
                shippingAddress: _savedAddresses.contains(shippingAddress) ? _selectedAddress! : shippingAddress,
              ).launch(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart, color: Color(0xff808080), size: 24),
        ...List.generate(3, (index) => _buildProgressDot(true)),
        Icon(Icons.location_on, color: Colors.blue, size: 24),
        ...List.generate(3, (index) => _buildProgressDot(false)),
        Icon(Icons.credit_card, color: Color(0xff808080), size: 24),
        ...List.generate(3, (index) => _buildProgressDot(false)),
        Icon(Icons.verified, color: Color(0xff808080), size: 24),
      ],
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Color(0x1f000000),
        shape: BoxShape.circle,
        border: Border.all(color: isActive ? Colors.blue : Color(0x4d9e9e9e), width: 1),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? " *" : ""),
          style: secondaryTextStyle(),
        ),
        4.height,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}