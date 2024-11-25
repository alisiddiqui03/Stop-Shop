import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stopshop/Screens/splash_screen.dart';
import 'package:stopshop/const.dart';
import 'package:stopshop/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Map<String, dynamic>? paymentIntent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "$stripePublishableKey";
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
