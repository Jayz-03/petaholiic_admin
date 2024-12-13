import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting

class UpdateProductScreen extends StatefulWidget {
  final String productKey;

  const UpdateProductScreen({super.key, required this.productKey});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('Products');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _expirationController = TextEditingController();

  bool _isLoading = true;
  File? _selectedImage; // To hold the selected image

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  void _loadProductDetails() async {
    try {
      DataSnapshot snapshot = await _productsRef.child(widget.productKey).get();
      if (snapshot.exists) {
        Map productData = snapshot.value as Map;
        setState(() {
          _nameController.text = productData['name'] ?? '';
          _descriptionController.text = productData['description'] ?? '';
          _priceController.text = productData['price']?.toString() ?? '';
          _categoryController.text = productData['category'] ?? '';
          _photoUrlController.text = productData['photoUrl'] ?? '';
          _expirationController.text = productData['expirationDate'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Center(child: Text('Failed to load product details!')),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('product_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void _updateProduct() async {
    try {
      double? price = double.tryParse(_priceController.text.trim());
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Center(child: Text('Please enter a valid price')),
              backgroundColor: Colors.orange),
        );
        return;
      }

      // Upload the selected image if it's changed
      String imageUrl =
          _photoUrlController.text.trim(); // Default to current URL
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      // Parse expiration date
      String expirationDate = _expirationController.text.trim();
      if (expirationDate.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Center(child: Text('Please select an expiration date')),
              backgroundColor: Colors.orange),
        );
        return;
      }

      await _productsRef.child(widget.productKey).update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'category': _categoryController.text.trim(),
        'photoUrl': imageUrl, // Save the new photo URL
        'expirationDate': expirationDate, // Save expiration date
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Center(child: Text('Product updated successfully')),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Center(child: Text('Failed to update product!')),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isDateField = false,
  }) {
    return TextFormField(
      style: GoogleFonts.lexend(color: Colors.white),
      controller: controller,
      cursorColor: Colors.white54,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.white54),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.white.withOpacity(0.2),
        filled: true,
        prefixIcon: Icon(icon, color: Colors.white),
      ),
      keyboardType: keyboardType,
      onTap: isDateField
          ? () async {
              FocusScope.of(context)
                  .requestFocus(FocusNode()); // Close keyboard
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                });
              }
            }
          : null,
      validator: validator,
      readOnly: isDateField, // Make the date field read-only
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Update Product',
          style: GoogleFonts.lexend(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Open the image picker when tapped
                      child: Container(
                        height: 150,
                        width: double
                            .infinity, // Make the container fill horizontally
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withOpacity(
                              0.2), // Set the background color with opacity
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : (_photoUrlController.text.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          _photoUrlController.text),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: _selectedImage == null &&
                                _photoUrlController.text.isEmpty
                            ? Center(
                                child: Icon(
                                  Iconsax.image,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ) // Center the placeholder icon
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _nameController,
                      hintText: 'Product Name',
                      icon: Iconsax.box,
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _categoryController,
                      hintText: 'Category',
                      icon: Iconsax.category,
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _descriptionController,
                      hintText: 'Description',
                      icon: Iconsax.clipboard_text,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _priceController,
                      hintText: 'Price',
                      icon: Iconsax.money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _expirationController,
                      hintText: 'Expiration Date',
                      icon: Iconsax.calendar_1,
                      isDateField: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width:
                          double.infinity, // Makes the button take full width
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        child: Text(
                          'Update Product',
                          style: GoogleFonts.lexend(
                            color: Color.fromARGB(255, 0, 86, 99),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
