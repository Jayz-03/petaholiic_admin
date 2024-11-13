import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholiic_admin/screens/authentication/login.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users');
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser != null) {
      try {
        final snapshot = await databaseRef.child(currentUser!.uid).get();
        if (snapshot.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'My Profile',
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 0, 86, 99)))
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        userData?['profileImageUrl'] ??
                            "https://i.pinimg.com/originals/73/17/a5/7317a548844e0d0cccd211002e0abc45.jpg",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${userData?['firstName'] ?? 'John'} ${userData?['lastName'] ?? 'Doe'}",
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData?['email'] ?? "No email available",
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 7,
                        margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 0, 86, 99),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 35),
                ...List.generate(
                  customListTiles.length,
                  (index) {
                    final tile = customListTiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        color: Color.fromARGB(255, 0, 86, 99),
                        elevation: 4,
                        shadowColor: Colors.black12,
                        child: ListTile(
                          leading: Icon(
                            tile.icon,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          title: Text(
                            tile.title,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          trailing: Icon(
                            Iconsax.arrow_right_2,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          onTap: () {
                            if (tile.title == "Sign Out") {
                              _signOut(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    title: "Sign Out",
    icon: Iconsax.logout,
  ),
];
