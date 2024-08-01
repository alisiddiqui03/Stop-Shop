import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingDetail extends StatefulWidget {
  const BillingDetail({super.key});

  @override
  State<BillingDetail> createState() => _BillingDetailState();
}

class _BillingDetailState extends State<BillingDetail> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> billingDetails = [
      {
        'customerName': 'John Doe',
        'amount': 100.0,
        'date': DateTime(2023, 7, 10),
      },
      {
        'customerName': 'John Doe',
        'amount': 150.5,
        'date': DateTime(2023, 8, 1),
      },
      {
        'customerName': 'John Doe',
        'amount': 200.75,
        'date': DateTime(2023, 9, 15),
      },
    ];

    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
          title: const Center(
        child: Text(
          'Billing Details',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      )),
      body: ListView.builder(
        itemCount: billingDetails.length,
        itemBuilder: (context, index) {
          final billingDetail = billingDetails[index];
          final customerName = billingDetail['customerName'];
          final amount = billingDetail['amount'];
          final date = billingDetail['date'] as DateTime;

          return ListTile(
            title: Text(customerName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: 'Amount: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: '\$${amount.toStringAsFixed(2)}\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: dateFormat.format(date),
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
