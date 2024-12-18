import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class MedicalRecordScreen extends StatelessWidget {
  final String userId;
  final String appointmentId;

  MedicalRecordScreen({
    Key? key,
    required this.userId,
    required this.appointmentId,
  }) : super(key: key);

  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');
  final DatabaseReference _petProfilesRef =
      FirebaseDatabase.instance.ref().child('PetProfiles');

  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _recommendationController =
      TextEditingController();

  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);
  final ValueNotifier<String?> _petId = ValueNotifier<String?>(null);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _fetchPetId() async {
    try {
      final snapshot = await _appointmentsRef
          .child(userId)
          .child(appointmentId)
          .child('petProfile')
          .get();

      if (snapshot.exists) {
        // Safely extract petId if available
        final petId = snapshot.child('petId').value?.toString();
        if (petId != null && petId.isNotEmpty) {
          _petId.value = petId;
        } else {
          _showSnackbar('Pet ID not found in the appointment.', Colors.red);
        }
      } else {
        _showSnackbar(
            'Failed to fetch Pet ID. Appointment not found.', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Error fetching Pet ID: $e', Colors.red);
    } finally {
      _isLoading.value = false;
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _saveMedicalRecord(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Ensure petId is available before saving
      String? petId = _petId.value;

      if (petId == null || petId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pet ID not found. Cannot save the medical record.',
              style: GoogleFonts.lexend(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _isSaving.value = true;

      // Create the medical record data
      final record = {
        'complaint': _complaintController.text,
        'treatment': _treatmentController.text,
        'diagnosis': _diagnosisController.text,
        'recommendation': _recommendationController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      try {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

        // Save medical record to the PetProfiles node
        await _petProfilesRef
            .child(userId)
            .child(petId) // Safely using petId
            .child('medicalRecords')
            .push()
            .set(record);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Medical record saved successfully.',
              style: GoogleFonts.lexend(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the fields after saving
        _complaintController.clear();
        _treatmentController.clear();
        _diagnosisController.clear();
        _recommendationController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save medical record. Please try again.',
              style: GoogleFonts.lexend(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint("Error saving medical record: $e");
      } finally {
        _isSaving.value = false;
      }
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _fetchPetId();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Medical Record',
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
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 0, 86, 99),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // Connect the form with the form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                    ),
                    controller: _complaintController,
                    cursorColor: Colors.white54,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.white54),
                      hintText: "Complaint",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.assignment,
                        color: Colors.white,
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a complaint';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                    ),
                    controller: _treatmentController,
                    cursorColor: Colors.white54,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.white54),
                      hintText: "Treatment",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a treatment';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                    ),
                    controller: _diagnosisController,
                    cursorColor: Colors.white54,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.white54),
                      hintText: "Diagnosis",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.healing,
                        color: Colors.white,
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a diagnosis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                    ),
                    controller: _recommendationController,
                    cursorColor: Colors.white54,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.white54),
                      hintText: "Recommendation",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.recommend,
                        color: Colors.white,
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a recommendation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isSaving,
                    builder: (context, isSaving, _) {
                      return isSaving
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 0, 86, 99),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _saveMedicalRecord(context),
                                child: Text(
                                  'Save Medical Record',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 86, 99),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                    },
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
