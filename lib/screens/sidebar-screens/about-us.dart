import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'About',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 223, 223, 223),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14.0),
        children: [
          SizedBox(
            width: mediaSize.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/petaholic-logo.png",
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'App Description\n',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Welcome to Petaholic Veterinary Clinic, where we are dedicated to providing the highest quality of care for your beloved pets. As a leading veterinary clinic, we understand the unique bond between pets and their owners, and we strive to enhance this relationship by offering cutting-edge services and innovative solutions.',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: Divider(
              thickness: 1,
              color: Colors.white,
            ),
          ),
          ListTile(
            title: Text('Developed by',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            subtitle: Text('Team Petaholic',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.white,
                )),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: Divider(
              thickness: 1,
              color: Colors.white,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Text('© BK Petaholic Veterinary Clinic 2024',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
    );
  }
}
