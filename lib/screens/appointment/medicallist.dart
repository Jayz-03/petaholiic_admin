import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class PetProfilesScreen extends StatelessWidget {
  final DatabaseReference _petProfilesRef =
      FirebaseDatabase.instance.ref("PetProfiles");

  PetProfilesScreen({super.key});

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
          'Pet Profiles List',
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
      body: FutureBuilder(
        future: _petProfilesRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No Pet Profiles Found'));
          }

          final profiles =
              <Map<dynamic, dynamic>>[]; // List to collect all pet profiles

          final data =
              (snapshot.data as DataSnapshot).value as Map<dynamic, dynamic>;
          data.forEach((userId, pets) {
            pets.forEach((petKey, petData) {
              profiles.add({'petKey': petKey, ...petData});
            });
          });

          if (profiles.isEmpty) {
            return const Center(child: Text('No Pet Profiles Found'));
          }

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final pet = profiles[index];

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    backgroundImage: pet['profileImage'] != null
                        ? NetworkImage(pet[
                            'profileImage']) // Load the profile image from Firebase
                        : AssetImage(
                                'assets/images/questionmark.png') // Default placeholder image
                            as ImageProvider, // Specify type to handle both
                  ),
                  title: Text(
                    pet['petName'] ?? 'Unknown Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Breed: ${pet['breed'] ?? 'Unknown Breed'}",
                        style: GoogleFonts.lexend(),
                      ),
                      Text(
                        "DOB: ${pet['dateOfBirth'] ?? 'N/A'}",
                        style: GoogleFonts.lexend(),
                      ),
                      Text(
                        "Color: ${pet['color'] ?? 'N/A'}",
                        style: GoogleFonts.lexend(),
                      ),
                      Text(
                        "Sex: ${pet['sex'] ?? 'N/A'}",
                        style: GoogleFonts.lexend(),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalListScreen(
                          petId: pet['petKey'],
                          medicalRecords: pet['medicalRecords'] ?? {},
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MedicalListScreen extends StatelessWidget {
  final String petId;
  final Map<dynamic, dynamic> medicalRecords;

  const MedicalListScreen({
    super.key,
    required this.petId,
    required this.medicalRecords,
  });

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
          'Medical Records',
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
      body: medicalRecords.isEmpty
          ? const Center(
              child: Text('No Medical Records Found'),
            )
          : ListView.builder(
              itemCount: medicalRecords.length,
              itemBuilder: (context, index) {
                final recordKey = medicalRecords.keys.elementAt(index);
                final record = medicalRecords[recordKey];

                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text(
                      "Date: ${record['timestamp'] != null ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(record['timestamp'])) : 'N/A'}",
                      style: GoogleFonts.lexend(),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Complaint: ${record['complaint'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                        Text(
                          "Treatment: ${record['treatment'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                        Text(
                          "Diagnosis: ${record['diagnosis'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                        Text(
                          "Recommendation: ${record['recommendation'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
