import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stopshop/Screens/home_screen.dart';

class ScanProduct extends StatefulWidget {
  final Function(Product) onProductScanned;

  const ScanProduct({super.key, required this.onProductScanned});

  @override
  State<ScanProduct> createState() => _ScanProductState();
}

class _ScanProductState extends State<ScanProduct> {
  String result = 'Scan Result will be displayed here';

  // Check for camera permissions and open scanner
  Future<void> checkCameraPermission(BuildContext context) async {
    if (await Permission.camera.request().isGranted) {
      // If permission is granted, start scanning
      scanBarcode();
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is not granted')),
      );
    }
  }

  // Scan barcode and handle the result
  Future<void> scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String scannedBarcode = scanResult.rawContent;

      setState(() {
        result = scannedBarcode.isEmpty ? 'Failed to get the scan result' : '';
      });
      print("Scanned Result: $result");
      if (scannedBarcode.isNotEmpty) {
        checkBarcodeInFirebase(scannedBarcode);
      }
    } catch (e) {
      setState(() {
        result = 'Error occurred while scanning: $e';
      });
    }
  }

  Future<void> checkBarcodeInFirebase(String barcode) async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
        return;
      }

      // Check if product exists in products collection
      var productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('product_Barcode', isEqualTo: barcode)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        var productData = productSnapshot.docs.first.data();

        // Check user's cart to prevent duplicate products
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        bool productAlreadyInCart = false;
        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>?;
          var cartItems = userData?['cartItems'] as List?;

          if (cartItems != null) {
            productAlreadyInCart = cartItems
                .any((item) => item['name'] == productData['produnct_Name']);
          }
        }

        if (productAlreadyInCart) {
          // Show snackbar if product is already in cart
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                    '${productData['produnct_Name']} is already in your cart'),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // Create and add product if not in cart
          var scannedProduct = Product(
            name: productData['produnct_Name'],
            price: productData['product_Price'],
            description: productData['product_Description'],
          );

          widget.onProductScanned(scannedProduct);

          setState(() {
            result = 'Product added to cart';
          });
        }
      } else {
        setState(() {
          result = 'Product not found in database';
        });

        // Show snackbar for product not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product not found in database'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        result = 'Error checking barcode: $e';
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking barcode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/scan.png",
              ),
              const SizedBox(height: 100),
              Container(
                width: 318,
                height: 59,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
                  ),
                  child: const Text(
                    'CLICK TO SCAN',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color.fromRGBO(232, 234, 246, 1)),
                  ),
                  onPressed: () => checkCameraPermission(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
