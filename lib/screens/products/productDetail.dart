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
        title: Text('Product Details',
            style: GoogleFonts.lexend(color: Colors.white)),
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

            // Get the product quantity and determine stock status
            int quantity = productDetails['quantity'] ?? 0;
            String status = quantity < 20 ? 'Low Stock' : 'In Stock';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  productDetails['photoUrl'] != null
                      ? Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              productDetails['photoUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Center(child: Icon(Icons.image, size: 100)),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            '${productDetails['name'] ?? 'N/A'}',
                            style: GoogleFonts.lexend(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            '${productDetails['category'] ?? 'N/A'}',
                            style: GoogleFonts.lexend(
                                fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),

                      // Price
                      Text(
                        '₱${productDetails['price']?.toStringAsFixed(2) ?? 'N/A'}',
                        style: GoogleFonts.lexend(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Stock Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: quantity < 20 ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stocks (Quantity)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    color: Colors.white.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stocks Available:',
                                style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Expiration Date: ${productDetails['expirationDate']}',
                                style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$quantity',
                              style: GoogleFonts.lexend(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product Description
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    color: Colors.white.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description:',
                            style: GoogleFonts.lexend(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${productDetails['description'] ?? 'N/A'}',
                            style: GoogleFonts.lexend(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'Product not found!',
                style: GoogleFonts.lexend(fontSize: 18, color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}
