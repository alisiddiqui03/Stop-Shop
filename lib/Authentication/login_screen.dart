import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stopshop/Authentication/forget_password.dart';
import 'package:stopshop/Authentication/signup_screen.dart';
import 'package:stopshop/Screens/home_screen.dart';

// Login Function
void loginUser(BuildContext context, String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    // Sign in user with email and password
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if email is verified
    if (userCredential.user!.emailVerified) {
      // Navigate to Home Page or Dashboard after successful login
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // If email is not verified, sign out user and show error message
      await auth.signOut();
      Fluttertoast.showToast(
        msg: "Please verify your email before logging in.",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  } catch (e) {
    // Handle login errors
    // ignore: avoid_print
    print('Login failed: $e');
    Fluttertoast.showToast(
      msg: "Login failed. Please check your email and password.",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

// Login Page
// ignore: use_key_in_widget_constructors
class LoginPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      body: SingleChildScrollView(
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
                  filled: true, //<-- SEE HERE
                  fillColor: const Color.fromARGB(255, 255, 255, 255)),
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
                  filled: true, //<-- SEE HERE
                  fillColor: const Color.fromARGB(255, 255, 255, 255)),
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
                    // side: BorderSide(color: Colors.red)
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
                  loginUser(context, email, password);
                },
              )),
          const SizedBox(height: 13.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Dont have an account ?'),
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
    );
  }
}
