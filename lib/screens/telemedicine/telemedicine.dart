import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petaholiic_admin/screens/messages/messages.dart';

class TelemedicineScreen extends StatefulWidget {
  @override
  _TelemedicineScreenState createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  late StreamSubscription _appointmentsSubscription;
  List<Map<String, dynamic>> _usersWithAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsersWithAppointments();
  }

  void _fetchUsersWithAppointments() {
    _appointmentsSubscription = _appointmentsRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _usersWithAppointments = [];
          });
        }
        return;
      }

      List<Map<String, dynamic>> users = [];
      Set<String> uniqueUserIds = {};

      for (var userId in data.keys) {
        if (uniqueUserIds.contains(userId)) continue;

        final userAppointments = data[userId] as Map<dynamic, dynamic>;
        bool hasApprovedAppointment = false;

        for (var appointmentId in userAppointments.keys) {
          final appointmentData =
              Map<String, dynamic>.from(userAppointments[appointmentId]);
          if (appointmentData['status'] == 'Approved') {
            hasApprovedAppointment = true;
            break;
          }
        }

        if (hasApprovedAppointment) {
          final userSnapshot = await _usersRef.child(userId).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.value as Map<dynamic, dynamic>;
            users.add({
              'userId': userId,
              'firstName': userData['firstName'],
              'lastName': userData['lastName'],
            });
            uniqueUserIds.add(userId);
          }
        }
      }

      if (mounted) {
        setState(() {
          _usersWithAppointments = users;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _appointmentsSubscription.cancel();
    super.dispose();
  }

  void _showUserAppointments(String userId, String firstName, String lastName) {
    _appointmentsRef.child(userId).onValue.listen((event) {
      final userAppointments = event.snapshot.value as Map<dynamic, dynamic>?;

      if (userAppointments == null) return;

      List<Map<String, dynamic>> appointments = [];

      for (var appointmentId in userAppointments.keys) {
        final appointmentData =
            Map<String, dynamic>.from(userAppointments[appointmentId]);
        if (appointmentData['status'] == 'Approved') {
          appointments.add({
            'appointmentId': appointmentId,
            'service': appointmentData['service'],
            'appointmentDate': appointmentData['appointmentDate'],
            'userId': userId,
          });
        }
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              '$firstName $lastName\'s Appointments',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 86, 99),
              ),
            ),
            content: appointments.isEmpty
                ? Text(
                    'No approved appointments available.',
                    style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
                  )
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return ListTile(
                          title: Text(
                            appointment['service'],
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 86, 99),
                            ),
                          ),
                          subtitle: Text(
                            appointment['appointmentDate'],
                            style: GoogleFonts.lexend(fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagesScreen(
                                  userId: appointment['userId'],
                                  appointmentId: appointment['appointmentId'],
                                  senderId: 'w6yXRl9X6cW9VMgNDJubW2o4itx2',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Close',
                  style: GoogleFonts.lexend(
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        title: Text(
          'Telemedicine',
          style: GoogleFonts.lexend(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 0, 86, 99),
              ),
            )
          : _usersWithAppointments.isEmpty
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/questionmark.png',
                        width: 200,
                        height: 200,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Currently, there are no users with \napproved appointments.',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 86, 99),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _usersWithAppointments.length,
                  itemBuilder: (context, index) {
                    final user = _usersWithAppointments[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      elevation: 4,
                      color: Colors.white,
                      child: ListTile(
                        leading: Image.asset(
                          "assets/images/petaholic-logo.png",
                          height: 30,
                        ),
                        title: Text(
                          '${user['firstName']} ${user['lastName']}',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            color: Color.fromARGB(255, 0, 86, 99),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _showUserAppointments(
                          user['userId'],
                          user['firstName'],
                          user['lastName'],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
