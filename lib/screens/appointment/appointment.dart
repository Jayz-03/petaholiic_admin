import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petaholiic_admin/screens/appointment/medicalRecords.dart';
import 'package:petaholiic_admin/screens/messages/messages.dart';
import 'dart:async';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class AdminAppointmentScreen extends StatefulWidget {
  const AdminAppointmentScreen({Key? key}) : super(key: key);

  @override
  _AdminAppointmentScreenState createState() => _AdminAppointmentScreenState();
}

class _AdminAppointmentScreenState extends State<AdminAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];
  List<Map<String, dynamic>> _rejectAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
  }

  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/questionmark2.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Confirm $action Appointment',
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 86, 99),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  'Are you sure you want to $action this appointment?',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 86, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 86, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  void _fetchAppointments() {
    final Stream<DatabaseEvent> appointmentsStream = _appointmentsRef.onValue;

    appointmentsStream.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        print('No appointments found.');
        setState(() {
          _upcomingAppointments = [];
          _pastAppointments = [];
          _rejectAppointments = [];
        });
        return;
      }

      List<Map<String, dynamic>> upcoming = [];
      List<Map<String, dynamic>> past = [];
      List<Map<String, dynamic>> reject = [];

      _usersRef.once().then((userEvent) {
        final userData = userEvent.snapshot.value as Map<dynamic, dynamic>?;

        data.forEach((userId, appointments) {
          final userAppointments = appointments as Map<dynamic, dynamic>;

          userAppointments.forEach((appointmentId, appointmentData) {
            final appointment = Map<String, dynamic>.from(appointmentData);
            appointment['userId'] = userId;
            appointment['appointmentId'] = appointmentId;

            if (userData != null && userData.containsKey(userId)) {
              final userInfo = userData[userId] as Map<dynamic, dynamic>;
              appointment['firstName'] = userInfo['firstName'] ?? '';
              appointment['lastName'] = userInfo['lastName'] ?? '';
            }

            if (appointment['status'] == 'Pending') {
              upcoming.add(appointment);
            } else if (appointment['status'] == 'Rejected') {
              reject.add(appointment);
            } else if (appointment['status'] == 'Approved') {
              past.add(appointment);
            }
          });
        });

        if (mounted) {
          setState(() {
            _upcomingAppointments = upcoming;
            _pastAppointments = past;
            _rejectAppointments = reject;
          });
        }
      });
    });
  }

  void _updateAppointmentStatus(
      String userId, String fcmToken, String appointmentId, String newStatus) {
    _appointmentsRef
        .child(userId)
        .child(appointmentId)
        .update({'status': newStatus}).then((_) {
      if (mounted) {
        setState(() {});
      }

      // Determine the notification title and message
      String title;
      String message;

      if (newStatus == 'Approved') {
        title = 'Appointment Approved';
        message =
            'Your appointment with the vet has been approved. Please check your schedule for details.';
      } else if (newStatus == 'Rejected') {
        title = 'Appointment Rejected';
        message =
            'Unfortunately, your appointment with the vet has been rejected. Please contact us for assistance.';
      } else {
        return;
      }

      // Send push notification
      _sendPushNotification(
        fcmToken: fcmToken,
        title: title,
        body: message,
      );
    }).catchError((error) {
      print("Failed to update appointment: $error");
    });
  }

  Future<void> _sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    const String projectId = 'petaholic-4b075';
    final String url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    try {
      String accessToken = await _getAccessToken();

      final Map<String, dynamic> message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'new',
          },
        },
      };

      print("Sending message: ${jsonEncode(message)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully.');
      } else {
        print('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<String> _getAccessToken() async {
    try {
      final serviceAccountKey = await rootBundle
          .loadString('assets/petaholic-4b075-ab9d200ab6d8.json');

      final Map<String, dynamic> keyData = jsonDecode(serviceAccountKey);

      final accountCredentials = ServiceAccountCredentials.fromJson(keyData);

      const List<String> scopes = [
        'https://www.googleapis.com/auth/cloud-platform',
      ];

      final client = await clientViaServiceAccount(accountCredentials, scopes);

      final accessToken = client.credentials.accessToken;

      return accessToken.data;
    } catch (e) {
      throw Exception('Error getting access token: $e');
    }
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${appointment['firstName']} ${appointment['lastName']}',
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 86, 99),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appointment['status']?.toString() ?? 'No Status',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                ),
              ],
            ),
            Divider(),
            Text(
              appointment['service']?.toString() ?? 'No Service',
              style: GoogleFonts.lexend(
                fontSize: 20,
                color: Color.fromARGB(255, 0, 86, 99),
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  appointment['appointmentDate']?.toString() ?? 'No Date',
                  style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(width: 10),
                Text(
                  appointment['appointmentTime']?.toString() ?? 'No Time',
                  style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            if (appointment['status'] == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool confirmed = await _showConfirmationDialog('approve');
                      if (confirmed) {
                        _updateAppointmentStatus(
                          appointment['userId']?.toString() ?? '',
                          appointment['fcmToken']?.toString() ?? '',
                          appointment['appointmentId']?.toString() ?? '',
                          'Approved',
                        );
                      }
                    },
                    child: Text(
                      'Approve',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 86, 99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      bool confirmed = await _showConfirmationDialog('reject');
                      if (confirmed) {
                        _updateAppointmentStatus(
                          appointment['userId']?.toString() ?? '',
                          appointment['fcmToken']?.toString() ?? '',
                          appointment['appointmentId']?.toString() ?? '',
                          'Rejected',
                        );
                      }
                    },
                    child: Text(
                      'Reject',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            if (appointment['status'] == 'Approved')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagesScreen(
                            userId: appointment['userId'],
                            appointmentId: appointment['appointmentId'],
                            senderId:
                                'w6yXRl9X6cW9VMgNDJubW2o4itx2', // Admin sender ID
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Chat',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 86, 99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicalRecordScreen(
                            userId: appointment['userId'],
                            appointmentId: appointment['appointmentId'], // Admin sender ID
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Create Medical Record',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 86, 99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        title: Text(
          'Appointments',
          style: GoogleFonts.lexend(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.lexend(fontSize: 16),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: [
                if (_upcomingAppointments.isEmpty)
                  Expanded(
                    child: Center(
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
                            'Currently, there is no pending \nappointment list here.',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 86, 99),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _upcomingAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _upcomingAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
                  ),
              ],
            ),
            Column(
              children: [
                if (_pastAppointments.isEmpty)
                  Expanded(
                    child: Center(
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
                            'Currently, there is no approved \nappointment list here.',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 86, 99),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pastAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _pastAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
                  ),
              ],
            ),
            Column(
              children: [
                if (_rejectAppointments.isEmpty)
                  Expanded(
                    child: Center(
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
                            'Currently, there is no rejected \nappointment list here.',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 86, 99),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _rejectAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _rejectAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
