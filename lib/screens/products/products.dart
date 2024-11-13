import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholiic_admin/screens/products/createProduct.dart';
import 'package:petaholiic_admin/screens/products/productDetail.dart';
import 'package:petaholiic_admin/screens/products/updateProduct.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('Products');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 86, 99),
        title: Text(
          'Inventory',
          style: GoogleFonts.lexend(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by product name...',
                hintStyle: GoogleFonts.lexend(),
                prefixIcon:
                    const Icon(Iconsax.search_normal, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _productsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                      child: Text('No products available!',
                          style: GoogleFonts.lexend(color: Colors.white)));
                } else {
                  Map<dynamic, dynamic> products =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<MapEntry<dynamic, dynamic>> productEntries =
                      products.entries.toList();

                  // Filter products by search query
                  if (_searchQuery.isNotEmpty) {
                    productEntries = productEntries
                        .where((entry) => entry.value['name']
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();
                  }

                  return ListView.builder(
                    itemCount: productEntries.length,
                    itemBuilder: (context, index) {
                      var productKey = productEntries[index].key;
                      var product = productEntries[index].value;

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(productKey: productKey),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: product['photoUrl'] != null
                                ? Image.network(product['photoUrl'],
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.image),
                            title: Text(
                              product['name'] ?? 'No Name',
                              style: GoogleFonts.lexend(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${product['category'] ?? 'N/A'}\n${product['status']}',
                              style: GoogleFonts.lexend(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Iconsax.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateProductScreen(
                                                productKey: productKey),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.trash,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(productKey);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String productKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.lexend(), textAlign: TextAlign.center,
        ),
        content: Text(
          'Are you sure you want to delete this product?',
          style: GoogleFonts.lexend(), textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 0, 86, 99),
                  minimumSize: Size(100, 40),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lexend(),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 0, 86, 99),
                  minimumSize: Size(100, 40),
                ),
                onPressed: () {
                  _productsRef.child(productKey).remove();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                          child: Text(
                        'Product deleted successfully!',
                        style: GoogleFonts.lexend(),
                      )),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Delete', style: GoogleFonts.lexend()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
