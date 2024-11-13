import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productKey;

  const ProductDetailScreen({super.key, required this.productKey});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference productRef =
        FirebaseDatabase.instance.ref().child('Products').child(productKey);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        title: Text('Product Details', style: GoogleFonts.lexend(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<DatabaseEvent>(
        future: productRef.once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.lexend(),
              ),
            );
          } else if (snapshot.hasData &&
              snapshot.data!.snapshot.value != null) {
            // Extract the product data
            Map<dynamic, dynamic> productDetails =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productDetails['photoUrl'] != null
                      ? Center(
                          child: Image.network(
                            productDetails['photoUrl'],
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(child: Icon(Icons.image, size: 100)),
                  const SizedBox(height: 16),
                  Text(
                    '${productDetails['name'] ?? 'N/A'}',
                    style: GoogleFonts.lexend(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '${productDetails['category'] ?? 'N/A'}',
                    style: GoogleFonts.lexend(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${productDetails['price']?.toStringAsFixed(2) ?? 'N/A'}',
                    style: GoogleFonts.lexend(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    'Status: ${productDetails['status'] ?? 'N/A'}',
                    style: GoogleFonts.lexend(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${productDetails['description'] ?? 'N/A'}',
                    style: GoogleFonts.lexend(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'Product not found!',
                style: GoogleFonts.lexend(),
              ),
            );
          }
        },
      ),
    );
  }
}
