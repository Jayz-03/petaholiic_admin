import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late DatabaseReference _databaseRef;
  late String name;
  late String description;
  late String imageUrl;
  late String price;
  late String category;
  late String location;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseRef =
        FirebaseDatabase.instance.ref('Products/${widget.productId}');
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final DataSnapshot snapshot = await _databaseRef.get();
      if (snapshot.exists) {
        final productData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          name = productData['productName'] ?? 'Product Name';
          description =
              productData['description'] ?? 'Description not available.';
          imageUrl = productData['imageUrl'] ?? '';
          price = productData['price'] ?? '0';
          category = productData['category'] ?? 'N/A';
          location = "Dagatan, Batangas City";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to add items to the cart.')),
      );
      return;
    }

    final userId = user.uid;
    final cartRef = FirebaseDatabase.instance.ref('Carts/$userId/${widget.productId}');

    try {
      await cartRef.set({
        'userId': userId,
        'productId': widget.productId,
        'imageUrl': imageUrl,
        'productName': name,
        'price': price,
        'quantity': 1, // Default quantity
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added to cart successfully.')),
      );
    } catch (e) {
      print('Error adding product to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product to cart.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 68, 46),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : SingleChildScrollView(
              child: Container(
                height: height,
                width: width,
                color: Color.fromARGB(255, 10, 68, 46),
                child: Column(
                  children: [
                    Container(
                      height: height * 0.57,
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage("assets/images/placeholder.png")
                                  as ImageProvider,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.40),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(35),
                                bottomRight: Radius.circular(35),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              height: height * 0.1,
                              width: width * 0.9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: height * 0.051,
                                      width: width * 0.1,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.black,
                                          size: width * 0.05,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: height * 0.051,
                                    width: width * 0.1,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Iconsax.search_normal,
                                        color: Colors.black,
                                        size: width * 0.05,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: height * 0.23,
                              width: width * 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 10, 68, 46),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      category,
                                      style: GoogleFonts.lexend(
                                        fontSize: width * 0.066,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    name,
                                    style: GoogleFonts.lexend(
                                      fontSize: width * 0.066,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: width * 0.03,
                                      ),
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: width * 0.07,
                                      ),
                                      Text(
                                        location,
                                        style: GoogleFonts.lexend(
                                          fontSize: width * 0.038,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(25),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Iconsax.heart,
                                color: Colors.white,
                                size: width * 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: width * 0.9,
                        child: Text(
                          description,
                          style: GoogleFonts.lexend(
                            fontSize: width * 0.038,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.05),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            color: Colors.white,
                            size: width * 0.08,
                          ),
                          SizedBox(
                            height: height * 0.02,
                          ),
                          Text(
                            " 9AM - 10PM",
                            style: GoogleFonts.lexend(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.05),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            color: Colors.white,
                            size: width * 0.08,
                          ),
                          SizedBox(
                            height: height * 0.02,
                          ),
                          Text(
                            " Monday - Saturday",
                            style: GoogleFonts.lexend(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    SizedBox(
                      height: height * 0.15,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: height * 0.07,
                            width: width * 0.45,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 10, 68, 46),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              onTap: _addToCart,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Add to cart",
                                    style: GoogleFonts.lexend(
                                      fontSize: width * 0.05,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}