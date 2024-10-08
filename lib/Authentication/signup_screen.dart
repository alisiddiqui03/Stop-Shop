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
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
        body: Center(
            child: SingleChildScrollView(
                child: Form(
          key: formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                    image: const AssetImage('assets/images/stopshoplogo.png'),
                    height: 220,
                    width: MediaQuery.of(context).size.width)
              ],
            ),

            //const Padding(padding: EdgeInsets.only(bottom: 30)),

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
                    fillColor: const Color.fromARGB(255, 255, 255, 255)),
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
                    fillColor: const Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                obscureText: _isObscured,
                controller: passwordController,
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
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        }),
                    filled: true, //<-- SEE HERE
                    fillColor: const Color.fromARGB(255, 255, 255, 255)),
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
                      backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color.fromRGBO(232, 234, 246, 1)),
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
                        color: Color.fromARGB(255, 7, 6, 54),
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
