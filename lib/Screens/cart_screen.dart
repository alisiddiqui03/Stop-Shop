// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:stopshop/Screens/home_screen.dart';
// class Cart extends StatefulWidget {
//   final List<Product> scannedProducts;
//
//   const Cart({super.key, required this.scannedProducts});
//
//   @override
//   State<Cart> createState() => _CartState();
// }
//
// class _CartState extends State<Cart> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     fetchCartItems();
//   }
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Product> cartItems = [];
//   bool isLoading = true; // Loading state
//
//   double getTotalCost() {
//     double total = 0.0;
//
//     for (var product in cartItems) {
//       final parsedPrice = double.tryParse(product.price);
//
//       if (parsedPrice != null) {
//         total += parsedPrice * product.quantity;
//       } else {
//         print('Invalid price format for product: ${product.name}');
//       }
//     }
//     return total;
//   }
//
//   Future<void> fetchCartItems() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//         if (userDoc.exists) {
//           var userData = userDoc.data() as Map<String, dynamic>,
//               cartData = userData['cartItems'];
//           List<Product> loadedCartItems = [];
//           if (cartData != null) {
//             loadedCartItems = (cartData as List).map((item) {
//               return Product(
//                 name: item['name'],
//                 price: item['price'],
//                 description: item['description'],
//                 quantity:
//                     item['quantity'] ?? 1, // Default to 1 if quantity is null
//               );
//             }).toList();
//           }
//           setState(() {
//             cartItems = loadedCartItems;
//             isLoading = false;
//           });
//         }
//       } catch (e) {
//         print("Error fetching cart items: $e");
//       }
//     }
//   }
//
//   Future<void> updateCartItemQuantity(String productName, int quantity) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'cartItems': FieldValue.arrayUnion([
//             {
//               'name': productName,
//               'price': 'price', // Include other fields as necessary
//               'description':
//                   'description', // Modify this as per your data structure
//               'quantity': quantity,
//             }
//           ]),
//         }, SetOptions(merge: true));
//       } catch (e) {
//         print("Error updating cart item quantity: $e");
//       }
//     }
//   }
//
//   void _deleteProduct(int index) {
//     setState(() {
//       widget.scannedProducts.removeAt(index);
//     });
//   }
//   // double getTotalCost() {
//   //   double total = 0.0;
//   //   for (var product in products) {
//   //     total += product.price * product.quantity;
//   //   }
//   //   return total;
//   // }
//
//   // void _deleteProduct(int index) {
//   //   setState(() {
//   //     products.removeAt(index);
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
//         body: cartItems.isEmpty
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                 ),
//               )
//             : ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       width: MediaQuery.of(context).size.width,
//                       height: 90,
//                       decoration: BoxDecoration(
//                         color: const Color.fromRGBO(232, 234, 246, 1),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: Row(children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   cartItems[index].name,
//                                   style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color.fromRGBO(36, 34, 921, 1)),
//                                 ),
//                                 Text(cartItems[index].description,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Color.fromRGBO(36, 34, 921, 1))),
//                                 Text(
//                                     "Price: Rs${cartItems[index].price}"
//                                         .toString(),
//                                     style: const TextStyle(
//                                         fontSize: 17,
//                                         color: Color.fromRGBO(36, 34, 921, 1))),
//                               ],
//                             ),
//                             const Spacer(),
//                             CounterApp(
//                               initialValue: cartItems[index].quantity,
//                               onValueChanged: (value) {
//                                 setState(() {
//                                   cartItems[index].quantity = value;
//                                 });
//                                 // updateCartItemQuantity(
//                                 //     cartItems[index].name, value, cartItems[index]);
//                               },
//                             ),
//                             const SizedBox(width: 15),
//                             GestureDetector(
//                               onTap: () => _deleteProduct(index),
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: Colors.red,
//                                 size: 25,
//                               ),
//                             ),
//                           ])),
//                     ),
//                   );
//                 },
//               ),
//         bottomNavigationBar: Row(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(2.0),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: const Color.fromRGBO(2, 27, 60, 1),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Total: Rs${getTotalCost().toStringAsFixed(2)}',
//                       style: const TextStyle(
//                           fontSize: 17.0,
//                           color: Color.fromRGBO(232, 234, 246, 1),
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const Spacer(),
//             Expanded(
//               // ignore: sized_box_for_whitespace
//               child: Padding(
//                 padding: const EdgeInsets.all(2.0),
//                 // ignore: sized_box_for_whitespace
//                 child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                           // side: BorderSide(color: Colors.red)
//                         ),
//                         backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Checkout',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 17,
//                               color: Color.fromRGBO(232, 234, 246, 1)),
//                         ),
//                       ),
//                       onPressed: () {
//                         // Navigator.of(context).push(
//                         //   MaterialPageRoute(
//                         //     builder: (context) => CartScreen(
//                         //       totalAmount: getTotalCost(),
//                         //     ),
//                         //   ),
//                         // );
//                       },
//                     )),
//               ),
//             ),
//           ],
//         ));
//   }
// }
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';

class Cart extends StatefulWidget {
  final List<Product> scannedProducts;

  const Cart({super.key, required this.scannedProducts});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Product> cartItems = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    // Stripe.publishableKey = 'pk_test_51MuPI0E0tQHP3XRphl3fcoZh4cyxOr4a4gxYRFkrrEoIqWGYHx4a1J2Q2jLNTpqzCv9gjUVkDHPjNnBTFYuiCcWs00BTIPbJ6L'; // Set your publishable key here
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
          var userData = userDoc.data() as Map<String, dynamic>,
              cartData = userData['cartItems'];
          List<Product> loadedCartItems = [];
          if (cartData != null) {
            loadedCartItems = (cartData as List).map((item) {
              return Product(
                name: item['name'],
                price: item['price'],
                description: item['description'],
                quantity:
                    item['quantity'] ?? 1, // Default to 1 if quantity is null
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
      }
    }
  }

  double getTotalCost() {
    double total = 0.0;

    for (var product in cartItems) {
      final parsedPrice = double.tryParse(product.price);

      if (parsedPrice != null) {
        total += parsedPrice * product.quantity;
      } else {
        print('Invalid price format for product: ${product.name}');
      }
    }
    return total;
  }

  // Future<void> _checkout() async {
  //   try {
  //     double totalAmount = getTotalCost();
  //     final paymentIntent = await createPaymentIntent(totalAmount);
  //
  //     // Show the Stripe Payment Sheet
  //     // Handle successful payment here
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: paymentIntent['clientSecret'],
  //         // You can also set other parameters such as `style`, `merchantDisplayName`, etc.
  //       ),
  //     );
  //
  //     // await Stripe.instance.presentPaymentSheet(
  //     //   parameters: PresentPaymentSheetParameters(
  //     //     clientSecret: paymentIntent['clientSecret'],
  //     //     // Additional parameters like 'returnUrl' can be added here if needed
  //     //   ),
  //     // );
  //
  //     // Handle successful payment here
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Payment Successful!')),
  //     );
  //   } catch (e) {
  //     print('Error during payment: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Payment Failed!')),
  //     );
  //   }
  // }

  Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    // Mock the response instead of making a network call
    // In reality, you should handle this on a server
    return {
      'clientSecret':
          'sk_test_51MuPI0E0tQHP3XRp6Q3g0OyXJgS8heQ2weoBbnkCF3K3XLRQVGRqRUI1JvZoTatgUgA6hObmvVRlEWhhQ5ovA0ql00FmkNbjSN', // Replace with a mocked client secret
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      body: cartItems.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
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
                      child: Row(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItems[index].name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(36, 34, 921, 1)),
                            ),
                            Text(cartItems[index].description,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(36, 34, 921, 1))),
                            Text(
                                "Price: Rs${cartItems[index].price}".toString(),
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromRGBO(36, 34, 921, 1))),
                          ],
                        ),
                        const Spacer(),
                        // Add your quantity counter widget here
                        const SizedBox(width: 15),
                        // Add your delete button here
                      ]),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
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
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(2.0),
          //     child: Container(
          //       width: MediaQuery.of(context).size.width,
          //       height: 50,
          //       child: ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10.0),
          //           ),
          //           backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
          //         ),
          //         child: const Center(
          //           child: Text(
          //             'Checkout',
          //             style: TextStyle(
          //                 fontWeight: FontWeight.w700,
          //                 fontSize: 17,
          //                 color: Color.fromRGBO(232, 234, 246, 1)),
          //           ),
          //         ),
          //         // onPressed: _checkout,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
