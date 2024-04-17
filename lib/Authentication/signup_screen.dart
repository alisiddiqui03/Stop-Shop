import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: Form(
      key: formKey,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Onboard!',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            )
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stay on track with Suffa bus tracking',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 0.72)),
            )
          ],
        ),

        const Padding(padding: EdgeInsets.only(bottom: 30)),

        Container(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                labelText: 'Enter Your Full Name',
                filled: true, //<-- SEE HERE
                fillColor: const Color.fromRGBO(238, 238, 238, 1)),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                labelText: 'Enter Your Email',
                filled: true, //<-- SEE HERE
                fillColor: const Color.fromRGBO(238, 238, 238, 1)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(),
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            onSaved: (value) {
              password = value!;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                labelText: 'Enter Password',
                filled: true, //<-- SEE HERE
                fillColor: const Color.fromRGBO(238, 238, 238, 1)),
          ),
        ),

        const Padding(padding: EdgeInsets.only(bottom: 50)),

        // ignore: sized_box_for_whitespace
        Container(
            width: 318,
            height: 59,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    // side: BorderSide(color: Colors.red)
                  ),
                  backgroundColor: const Color.fromARGB(255, 24, 181, 0),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
                onPressed: () async {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  FirebaseFirestore firestore = FirebaseFirestore.instance;

                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Please fill in all the required fields.",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                    return; // Return without proceeding further
                  }

                  if (formKey.currentState!.validate())
                    // ignore: curly_braces_in_flow_control_structures
                    formKey.currentState!.save();

                  try {
                    // Create user with email and password
                    // ignore: unused_local_variable
                    UserCredential userCredential =
                        await auth.createUserWithEmailAndPassword(
                      email: emailController.text.toString(),
                      password: passwordController.text.toString(),
                    );

                    // Send email verification
                    User? user = auth.currentUser;
                    await user?.sendEmailVerification();

                    // Save user data to Firestore
                    await firestore.collection('users').doc(user?.uid).set({
                      'email': emailController.text.toString(),
                      'name': nameController.text.toString(),
                      'password': passwordController.text.toString(),
                    });

                    // Display success message
                    Fluttertoast.showToast(
                      msg: "Signup successful. Please verify your email.",
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    // Clear text fields
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();

                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } catch (e) {
                    // Display error message
                    Fluttertoast.showToast(
                      msg: "Signup failed: $e",
                      toastLength: Toast.LENGTH_SHORT,
                    );

                    // Clear text fields
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                  }
                })),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Already have an account ?'),
            TextButton(
              child: const Text(
                'Sign in',
                style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 24, 181, 0),
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            )
          ],
        ),
      ]),
    ))));
  }
}
