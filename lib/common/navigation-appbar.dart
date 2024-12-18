import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholiic_admin/screens/appbar-screens/notification.dart';
import 'package:petaholiic_admin/screens/appointment/appointment.dart';
import 'package:petaholiic_admin/screens/appointment/medicallist.dart';
import 'package:petaholiic_admin/screens/authentication/login.dart';
import 'package:petaholiic_admin/screens/products/products.dart';
import 'package:petaholiic_admin/screens/sidebar-screens/about-us.dart';
import 'package:petaholiic_admin/screens/sidebar-screens/my-profile.dart';
import 'package:petaholiic_admin/screens/telemedicine/telemedicine.dart';

class SideAndTabsNavs extends StatefulWidget {
  @override
  _SideAndTabsNavsState createState() => _SideAndTabsNavsState();
}

class _SideAndTabsNavsState extends State<SideAndTabsNavs> {
  int _selectedIndex = 0;
  String _userName = '';

  static List<Widget> _widgetOptions = <Widget>[
    ProductScreen(),
    TelemedicineScreen(),
    AdminAppointmentScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid);
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        String firstName = userData['firstName'] ?? '';
        String lastName = userData['lastName'] ?? '';
        setState(() {
          _userName = '$firstName $lastName';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Iconsax.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Image.asset(
            'assets/images/petaholic-logo.png',
            width: 50,
            height: 50,
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () {
                  // Navigate to search screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()),
                  );
                },
                child: Icon(Iconsax.notification, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/bgside1.png',
              fit: BoxFit.cover,
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(height: 50),
                Image.asset(
                  'assets/images/petaholic-logo.png',
                  width: 120,
                  height: 120,
                ),
                SizedBox(height: 20),
                if (_userName.isNotEmpty)
                  ListTile(
                    title: Text(
                      _userName,
                      style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0),
                    ),
                  ),
                ListTile(
                  leading: Icon(Iconsax.user, color: Colors.white),
                  title: Text('My Profile',
                      style: GoogleFonts.lexend(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Iconsax.message_question, color: Colors.white),
                  title: Text('About Us',
                      style: GoogleFonts.lexend(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.white),
                  title: Text('Medical Records',
                      style: GoogleFonts.lexend(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PetProfilesScreen()),
                    );
                  },
                ),
                SizedBox(height: 50),
                ListTile(
                  leading: Icon(Iconsax.logout, color: Colors.white),
                  title: Text('Log out',
                      style: GoogleFonts.lexend(color: Colors.white)),
                  onTap: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: null,
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Confirm Logout',
                                  style: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Are you sure you want to log out?',
                                  style: GoogleFonts.lexend(fontSize: 16.0),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Color.fromARGB(255, 0, 86, 99),
                                        minimumSize: Size(100, 40),
                                      ),
                                      child: Text('Logout'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Color.fromARGB(255, 0, 86, 99),
                                        minimumSize: Size(100, 40),
                                      ),
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (confirm == true) {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      } catch (e) {
                        print('Sign out error: $e');
                      }
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color.fromARGB(255, 0, 86, 99),
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: GoogleFonts.lexend(color: Colors.white70),
              ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Iconsax.box),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.call),
              label: 'Telemedicine',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.calendar),
              label: 'Appointment',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: GoogleFonts.lexend(
            color: Color.fromARGB(255, 55, 28, 28),
            fontSize: 12.0,
          ),
          unselectedLabelStyle: GoogleFonts.lexend(
            color: Colors.white70,
            fontSize: 12.0,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
