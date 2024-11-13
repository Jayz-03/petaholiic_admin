import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class UpdateProductScreen extends StatefulWidget {
  final String productKey;

  const UpdateProductScreen({super.key, required this.productKey});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final DatabaseReference _productsRef = FirebaseDatabase.instance.ref().child('Products');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  bool _isLoading = true;

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
          _statusController.text = productData['status'] ?? '';
          _photoUrlController.text = productData['photoUrl'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Failed to load product details!')), backgroundColor: Colors.red),
      );
    }
  }

  void _updateProduct() async {
    try {
      double? price = double.tryParse(_priceController.text.trim());
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('Please enter a valid price')), backgroundColor: Colors.orange,),
        );
        return;
      }

      await _productsRef.child(widget.productKey).update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'category': _categoryController.text.trim(),
        'status': _statusController.text.trim(),
        'photoUrl': _photoUrlController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Product updated successfully')), backgroundColor: Colors.green,),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Failed to update product!')), backgroundColor: Colors.red),
      );
    }
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
                      controller: _statusController,
                      hintText: 'Status',
                      icon: Iconsax.info_circle,
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _photoUrlController,
                      hintText: 'Photo URL',
                      icon: Iconsax.image,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProduct,
                      child: Text(
                        'Update Product',
                        style: GoogleFonts.lexend(color: Color.fromARGB(255, 0, 86, 99)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
