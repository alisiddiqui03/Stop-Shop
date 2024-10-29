import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        result = scannedBarcode.isEmpty
            ? 'Failed to get the scan result'
            : scannedBarcode;
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
      var productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('product_Barcode', isEqualTo: barcode)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        var productData = productSnapshot.docs.first.data();
        var scannedProduct = Product(
          name: productData['produnct_Name'],
          price: productData['product_Price'],
          description: productData['product_Description'],
        );

        widget.onProductScanned(scannedProduct);
        // widget.onProductScanned(scannedProduct);
      }

      // else if (productSnapshot.docs.isEmpty) {
      //   var scannedProductdummy = Product(
      //     name: 'surf excel',
      //     price: '340',
      //     description: 'dhshshshshshsh',
      //   );
      //   widget.onProductScanned(scannedProductdummy);
      // }

      else {
        setState(() {
          result = 'Product not found';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error checking barcode: $e';
      });
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
