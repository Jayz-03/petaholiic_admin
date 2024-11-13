import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholiic_admin/common/navigation-appbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        resizeToAvoidBottomInset: true,
        body: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/images/bgscreen1.png',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 20),
                _header(context),
                Form(
                  key: _formKey,
                  child: _inputField(context),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        Image.asset(
          "assets/images/petaholic-logo.png",
          height: 150,
          width: 150,
        ),
        SizedBox(height: 20),
        Text(
          "Welcome to BK Petaholic",
          style: GoogleFonts.lexend(
            fontSize: width * 0.068,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Please fill up the necessary credentials.",
          style: GoogleFonts.lexend(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TextFormField(
          style: GoogleFonts.lexend(
            color: Colors.white,
          ),
          controller: _emailController,
          cursorColor: Colors.white54,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white54),
            hintText: "Email Address",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.2),
            filled: true,
            prefixIcon: const Icon(
              Iconsax.sms,
              color: Colors.white,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        TextFormField(
          style: GoogleFonts.lexend(
            color: Colors.white,
          ),
          controller: _passwordController,
          cursorColor: Colors.white54,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white54),
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.2),
            filled: true,
            prefixIcon: const Icon(
              Iconsax.lock,
              color: Colors.white,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _loginUser,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  "Login",
                  style: GoogleFonts.lexend(
                    color: Color.fromARGB(255, 0, 86, 99),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      // Validate form before login
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SideAndTabsNavs()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Invalid email or password!')), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
