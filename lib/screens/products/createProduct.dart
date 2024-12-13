import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart'; // Assuming you use Iconsax for icons
import 'dart:io';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectExpirationDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _expirationDateController.text =
            '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl;
        if (_selectedImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
              'product_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_selectedImage!);
          imageUrl = await storageRef.getDownloadURL();
        }

        final productData = {
          'name': _nameController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'quantity': int.tryParse(_quantityController.text) ?? 0,
          'expirationDate': _expirationDateController.text,
          'photoUrl': imageUrl,
        };

        final databaseRef = FirebaseDatabase.instance.ref().child('Products');
        await databaseRef.push().set(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Center(child: Text('Product created successfully')),
              backgroundColor: Colors.green),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
          'Create Product',
          style: GoogleFonts.lexend(
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
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
                              : null,
                        ),
                        child: _selectedImage == null
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
                    const SizedBox(height: 16),
                    _buildStyledTextFormField(
                      controller: _nameController,
                      hintText: 'Product Name',
                      icon: Iconsax.box,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextFormField(
                      controller: _categoryController,
                      hintText: 'Product Category',
                      icon: Iconsax.category,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextFormField(
                      controller: _descriptionController,
                      hintText: 'Product Description',
                      icon: Iconsax.clipboard_text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextFormField(
                      controller: _priceController,
                      hintText: 'Price',
                      icon: Iconsax.money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        final price = int.parse(value);
                        if (price < 0) {
                          return 'Price cannot be negative';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextFormField(
                      controller: _quantityController,
                      hintText: 'Quantity',
                      icon: Iconsax.add_square,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        final price = int.parse(value);
                        if (price < 0) {
                          return 'Price cannot be negative';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectExpirationDate,
                      child: AbsorbPointer(
                        child: _buildStyledTextFormField(
                          controller: _expirationDateController,
                          hintText: 'Expiration Date',
                          icon: Iconsax.calendar_1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an expiration date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _uploadProduct,
                      child: Text(
                        'Create Product',
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
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
      validator: validator,
    );
  }
}
