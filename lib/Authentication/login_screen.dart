import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stopshop/Authentication/forget_password.dart';
import 'package:stopshop/Authentication/signup_screen.dart';
import 'package:stopshop/Screens/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isObscured = true;

  // Login Function
  void login(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        User? user = FirebaseAuth.instance.currentUser;

        // Check if email is verified
        if (user != null && user.emailVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email before logging in.'),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else {
          errorMessage = 'Login failed: ${e.message}';
        }
        // Show toast message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 110),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                    image: const AssetImage('assets/images/stopshoplogo.png'),
                    height: 220,
                    width: MediaQuery.of(context).size.width)
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    labelText: 'Enter Your Email',
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: const BoxDecoration(),
              child: TextFormField(
                controller: passwordController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        }),
                    labelText: 'Enter Password',
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ForgetPassword()),
                    );
                  },
                  child: const Text(
                    'Forget Password?',
                    style: TextStyle(
                        color: Color.fromRGBO(11, 10, 41, 1),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 7),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                    'Login',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color.fromRGBO(232, 234, 246, 1)),
                  ),
                  onPressed: () {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    login(email, password);
                  },
                )),
            const SizedBox(height: 13.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Don’t have an account?'),
                TextButton(
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
