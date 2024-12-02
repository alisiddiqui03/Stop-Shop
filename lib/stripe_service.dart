import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stopshop/const.dart';
import 'package:stopshop/main.dart';

class StripeService {
  Future<bool> makePayment(BuildContext context, String amount) async {
    try {
      // Step 1: Create Payment Intent with dynamic amount
      final paymentIntent = await createPaymentIntent(amount, 'PKR');

      if (paymentIntent == null) {
        print('Failed to create payment intent');
        return false;
      }

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent['client_secret'],
              style: ThemeMode.light,
              merchantDisplayName: 'Ikay'));

      // Step 3: Display Payment Sheet
      try {
        // Explicitly present the payment sheet
        await Stripe.instance.presentPaymentSheet();

        // If we reach this point without an exception, payment was successful
        print('Payment Successful');

        // Optional: Show success dialog
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 100.0),
                SizedBox(height: 10.0),
                Text("Payment Successful!"),
              ],
            ),
          ),
        );

        return true;
      } on StripeException catch (e) {
        // Handle Stripe-specific exceptions
        print('Stripe Payment Error: ${e.error.message}');

        // Optional: Show error dialog
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 100.0),
                SizedBox(height: 10.0),
                Text("Payment Failed: ${e.error.message}"),
              ],
            ),
          ),
        );

        return false;
      }
    } catch (err) {
      // Catch any other unexpected errors
      print('Unexpected Payment Error: $err');
      return false;
    }
  }

  // Future<bool> makePayment(BuildContext context, String amount) async {
  //   try {
  //     // Step 1: Create Payment Intent with dynamic amount
  //     paymentIntent = await createPaymentIntent(amount, 'PKR');

  //     //STEP 2: Initialize Payment Sheet
  //     await Stripe.instance
  //         .initPaymentSheet(
  //             paymentSheetParameters: SetupPaymentSheetParameters(
  //                 paymentIntentClientSecret: paymentIntent!['client_secret'],
  //                 style: ThemeMode.light,
  //                 merchantDisplayName: 'Ikay'))
  //         .then((value) {});

  //     //STEP 3: Display Payment sheet
  //     return displayPaymentSheet(context);
  //   } catch (err) {
  //     return false;
  //   }
  // }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount':
              amount, // Amount should be in the smallest currency unit (e.g., cents)
          'currency': currency,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('client_secret')) {
          return {'client_secret': data['client_secret']};
        } else {
          print('Error: Missing client_secret in response');
          return null;
        }
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  Future<bool> displayPaymentSheet(BuildContext context) async {
    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Show success dialog
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100.0,
              ),
              SizedBox(height: 10.0),
              Text("Payment Successful!"),
            ],
          ),
        ),
      );

      paymentIntent = null; // Clear payment intent
      return true; // Indicate payment success
    } on StripeException catch (e) {
      print('StripeException: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 100.0,
              ),
              SizedBox(height: 10.0),
              Text("Payment Failed!"),
            ],
          ),
        ),
      );
      return false; // Indicate payment failure
    } catch (e) {
      print('Exception: $e');
      return false; // Handle unexpected errors
    }
  }
}
