import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  setState(() {
                    isProcessingPayment = true;
                  });

                  double totalAmount = getTotalCost();
                  String totalAmountInCents =
                      (totalAmount * 100).toInt().toString();

                  try {
                    await stripeServicee.makePayment(
                        context, totalAmountInCents);
                  } catch (e) {
                    print("Error making payment: $e");
                  } finally {
                    setState(() {
                      isProcessingPayment = false;
                    });
                  }
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
                        'Pay with Card',
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
