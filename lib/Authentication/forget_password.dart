import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stopshop/Authentication/login_screen.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image(
                    image: const AssetImage('assets/images/gmail.png'),
                    height: 300,
                    width: MediaQuery.of(context).size.width)
              ]),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forget',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Password ?',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter your email and we send you a link to',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.5)),
                  )
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'reset your password',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.5)),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      prefixIcon: const Icon(Icons.email,
                          color: Color.fromRGBO(0, 0, 0, 0.5)),
                      labelText: 'Xyz123@gmail.com',
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.5), //<-- SEE HERE
                      ),
                      filled: true, //<-- SEE HERE
                      fillColor: const Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 67),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          // side: BorderSide(color: Colors.red)
                        ),
                        backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Color.fromRGBO(232, 234, 246, 1)),
                      ),
                      onPressed: () {
                        auth
                            .sendPasswordResetEmail(
                                email: emailController.text.toString())
                            .then((value) {
                          // Fluttertoast.showToast(
                          //   msg:
                          //       "We have sent you email to recover password, please check email",
                          //   toastLength: Toast.LENGTH_SHORT,
                          // );
                          emailController.clear();
                        }).onError((error, stackTrace) {
                          // Fluttertoast.showToast(
                          //   msg: (error.toString()),
                          //   toastLength: Toast.LENGTH_SHORT,
                          // );
                        });
                      })),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Back to login',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ]))));
  }
}
