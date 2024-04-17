import 'package:flutter/material.dart';
import 'package:stopshop/Authentication/signup_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(
              image: const AssetImage('assets/images/logo.png'),
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 45,
              color: const Color.fromARGB(255, 0, 0, 0),
              child: const Center(
                child: Text('STOP & SHOP',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: Colors.white)),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 150,
        ),
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
                'GET START',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
            )),
      ])),
    );
  }
}
