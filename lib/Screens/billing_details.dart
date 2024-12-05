import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingDetail extends StatefulWidget {
  const BillingDetail({super.key});

  @override
  State<BillingDetail> createState() => _BillingDetailState();
}

class _BillingDetailState extends State<BillingDetail> {
  List<Map<String, dynamic>> paymentDetails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPaymentDetails();
  }

  Future<void> fetchPaymentDetails() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(); // Get user document

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          var paymentsData = userData['payments']; // Access payments field

          List<Map<String, dynamic>> loadedPayments = [];
          if (paymentsData != null) {
            loadedPayments = (paymentsData as List).map((item) {
              return {
                'amount': item['amount'],
                'currency': item['currency'],
                'date': item['date'], // The date comes as a string
                'items': item['items'],
              };
            }).toList();
          }

          setState(() {
            paymentDetails = loadedPayments;
            isLoading = false; // Set loading to false
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching payment details: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateTimeFormat = DateFormat('dd-MM-yyyy   HH:mm:ss');

    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Billing Details',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentDetails.isEmpty
              ? const Center(child: Text('No payment details found.'))
              : ListView.builder(
                  itemCount: paymentDetails.length,
                  itemBuilder: (context, index) {
                    final payment = paymentDetails[index];
                    final amount = payment['amount'];
                    final currency = payment['currency'];
                    String dateString = payment['date']; // Get date string
                    DateTime date =
                        DateTime.parse(dateString); // Parse to DateTime
                    final items = payment['items'] as List<dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount: $currency $amount',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(36, 34, 921, 1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${dateTimeFormat.format(date)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(36, 34, 921, 1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Items:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(36, 34, 921, 1),
                                  ),
                                ),
                                for (final item in items)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      '- ${item['name']} (x${item['quantity']}), \Rs${item['price']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(36, 34, 921, 1),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
