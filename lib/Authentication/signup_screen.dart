import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stopshop/Authentication/login_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late String password;
  late String confirmPassword;
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image:
                            const AssetImage('assets/images/stopshoplogo.png'),
                        height: 220,
                        width: MediaQuery.of(context).size.width)
                  ],
                ),

                //const Padding(padding: EdgeInsets.only(bottom: 30)),

                // Name Field
                _buildTextField(
                  controller: nameController,
                  label: 'Enter Your Full Name',
                ),
                // Email Field
                _buildTextField(
                  controller: emailController,
                  label: 'Enter Your Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                // Password Field
                _buildTextField(
                  controller: passwordController,
                  label: 'Enter Password',
                  obscureText: _isObscured,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a password';
                    } else if (value.length < 6 ||
                        !RegExp(r'[!@#\$%\^&\*]').hasMatch(value)) {
                      return 'Password must be at least 6 characters with a unique character';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Register Button
                SizedBox(
                  width: 318,
                  height: 59,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color.fromRGBO(232, 234, 246, 1),
                      ),
                    ),
                    onPressed: _registerUser,
                  ),
                ),
                // Sign in Redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 7, 6, 54),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (!formKey.currentState!.validate()) return;

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // ignore: unused_local_variable
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = auth.currentUser;

      await user?.sendEmailVerification();
      await firestore.collection('users').doc(user?.uid).set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Registration successful! Please verify your email.')),
      );

      nameController.clear();
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    }
  }
}
