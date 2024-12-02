import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // For generating random numbers
import 'package:stopshop/Screens/home_screen.dart';
import 'package:stopshop/stripe_service.dart';

class Cart extends StatefulWidget {
  final List<Product> scannedProducts;

  const Cart({super.key, required this.scannedProducts});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Product> cartItems = [];
  bool isLoading = true;
  bool isProcessingPayment = false;
  StripeService stripeServicee = StripeService();

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> uploadPaymentData(
      List<Product> cartItems, double totalCost) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Prepare the payment data
        final paymentData = {
          'amount': totalCost, // Total amount paid
          'currency': 'Rs', // Currency of the transaction
          'date':
              DateTime.now().toIso8601String(), // Timestamp in ISO 8601 format
          'status':
              'success', // You can change this depending on the payment status
          'items': cartItems.map((product) {
            return {
              'name': product.name,
              'price': product.price,
              'quantity': product.quantity,
            };
          }).toList(),
        };

        // Upload to Firestore under the user's document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Get the user's document by UID
            .set({
          'payments': FieldValue.arrayUnion([paymentData]),
        }, SetOptions(merge: true));

        // Optionally, clear the cart after successful payment
        cartItems.clear();
        print("Payment data uploaded successfully!");
      } catch (e) {
        print("Error uploading payment data: $e");
      }
    } else {
      print("No user is logged in.");
    }
  }

  Future<void> fetchCartItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          var cartData = userData['cartItems'];
          List<Product> loadedCartItems = [];
          if (cartData != null) {
            loadedCartItems = (cartData as List).map((item) {
              return Product(
                name: item['name'],
                price: item['price'],
                description: item['description'],
                quantity: item['quantity'] ?? 1,
              );
            }).toList();
          }
          setState(() {
            cartItems = loadedCartItems;
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching cart items: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double getTotalCost() {
    return cartItems.fold(0.0, (total, product) {
      final parsedPrice = double.tryParse(product.price);
      if (parsedPrice != null) {
        return total + (parsedPrice * product.quantity);
      }
      print('Invalid price format for product: ${product.name}');
      return total;
    });
  }

  void _showPaymentOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedOption = 'Stripe'; // Default selection
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Select Payment Method'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Stripe'),
                    value: 'Stripe',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Cash'),
                    value: 'Cash',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (selectedOption == 'Stripe') {
                      _processStripePayment();
                    } else {
                      _showCashReceipt();
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _processStripePayment() async {
    double totalAmount = getTotalCost();
    String totalAmountInCents = (totalAmount * 100).toInt().toString();

    try {
      bool paymentSuccessful =
          await stripeServicee.makePayment(context, totalAmountInCents);
      await uploadPaymentData(cartItems, totalAmount);

      if (paymentSuccessful) {
        setState(() {
          cartItems.clear(); // Clear cart only after successful payment
        });
      } else {
        print("Payment failed.");
      }
    } catch (e) {
      print("Error during Stripe payment: $e");
    }
  }

  void _showCashReceipt() {
    // Generate a random receipt number
    String receiptNo = _generateReceiptNumber();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Header
                  const Center(
                    child: Text(
                      'Stop Shop',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Receipt Number
                  Text(
                    'Receipt No: $receiptNo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Customer Details
                  const Text(
                    'Customer Details:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      'Name: ${FirebaseAuth.instance.currentUser?.email ?? "Unknown"}'),
                  const SizedBox(height: 12),

                  // Purchased Items Section
                  const Text(
                    'Items Purchased:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Item Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Qty',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ...cartItems.map(
                        (item) => TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item.name),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item.quantity.toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Rs${item.price}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Total Cost Section
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: Rs${getTotalCost().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Function to generate a random receipt number
  String _generateReceiptNumber() {
    final random = Random();
    final timestamp =
        DateTime.now().millisecondsSinceEpoch; // Current time in milliseconds
    final randomNumber =
        random.nextInt(10000); // Generate a random number between 0 and 9999
    return 'R${timestamp % 1000000}${randomNumber.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(232, 234, 246, 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItems[index].name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(36, 34, 921, 1),
                                      ),
                                    ),
                                    Text(
                                      cartItems[index].description,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(36, 34, 921, 1),
                                      ),
                                    ),
                                    Text(
                                      "Price: Rs${cartItems[index].price}",
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Color.fromRGBO(36, 34, 921, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (cartItems[index].quantity > 1) {
                                        setState(() {
                                          cartItems[index].quantity--;
                                        });
                                      }
                                    },
                                  ),
                                  Text(
                                    cartItems[index].quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(36, 34, 921, 1),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        cartItems[index].quantity++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(2, 27, 60, 1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    'Total: Rs${getTotalCost().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17.0,
                      color: Color.fromRGBO(232, 234, 246, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  _showPaymentOptionsDialog(context);
                },
                child: isProcessingPayment
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Checkout',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Color.fromRGBO(232, 234, 246, 1),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
