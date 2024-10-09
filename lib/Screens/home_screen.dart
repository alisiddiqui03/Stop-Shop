import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stopshop/Screens/billing_details.dart';
import 'package:stopshop/Screens/checkout_page.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:stopshop/Screens/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String name = "Name Loading";
  List<Product> scannedProducts = [];

  final firestore = FirebaseFirestore.instance.collection('users').snapshots();

  void get() async {
    // ignore: await_only_futures
    User? user = await FirebaseAuth.instance.currentUser;
    // ignore: non_constant_identifier_names
    var get_name = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    setState(() {
      name = get_name.data()!['name'];
    });
  }

  @override
  void initState() {
    get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 4, vsync: this);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
          body: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 70.0,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TabBar(
                      labelColor: const Color.fromARGB(255, 255, 255, 255),
                      unselectedLabelColor: const Color.fromARGB(255, 0, 0, 0),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: const Color.fromARGB(255, 255, 152, 114),
                      indicator: BoxDecoration(
                        color: const Color.fromRGBO(2, 27, 60, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      controller: tabController,
                      isScrollable: false,
                      labelPadding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      tabs: const [
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 35,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Tab(
                            child: Icon(Icons.shopping_cart_outlined, size: 35),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Tab(
                            child: Icon(Icons.edit_document, size: 35),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Tab(
                            child: Icon(Icons.person, size: 35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      ScanProduct(onProductScanned: (product) {
                        setState(() {
                          scannedProducts.add(product);
                        });
                      }),
                      Cart(scannedProducts: scannedProducts),
                      BillingDetail(),
                      ProfilePage(tabController: tabController)
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

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
      scanBarcode();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is not granted')),
      );
    }
  }

  Future<void> scanBarcode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String scannedBarcode = scanResult.rawContent;

      setState(() {
        result = scannedBarcode.isEmpty
            ? 'Failed to get the scan result'
            : scannedBarcode;
      });

      if (scannedBarcode.isNotEmpty) {
        checkBarcodeInFirebase(scannedBarcode);
      }
    } catch (e) {
      setState(() {
        result = 'Error occurred while scanning: $e';
      });
    }
  }

  // Check if barcode exists in Firebase
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
      } else {
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

class Product {
  final String name;
  final String price;
  final String description;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.description,
    this.quantity = 1, // default quantity set to 1
  });
}

class Cart extends StatefulWidget {
  final List<Product> scannedProducts;

  const Cart({super.key, required this.scannedProducts});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  double getTotalCost() {
    double total = 0.0;

    for (var product in widget.scannedProducts) {
      final parsedPrice = double.tryParse(product.price);

      if (parsedPrice != null) {
        total += parsedPrice * product.quantity;
      } else {
        print('Invalid price format for product: ${product.name}');
      }
    }

    return total;
  }

  void _deleteProduct(int index) {
    setState(() {
      widget.scannedProducts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
        body: widget.scannedProducts.isEmpty
            ? const Center(child: Text("No products in the cart"))
            : ListView.builder(
                itemCount: widget.scannedProducts.length,
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
                                  widget.scannedProducts[index].name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(36, 34, 921, 1)),
                                ),
                                Text(widget.scannedProducts[index].description,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(36, 34, 921, 1))),
                                Text(
                                  "Price: Rs${widget.scannedProducts[index].price}"
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      color: Color.fromRGBO(36, 34, 921, 1)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            CounterApp(
                              initialValue:
                                  widget.scannedProducts[index].quantity,
                              onValueChanged: (value) {
                                setState(() {
                                  widget.scannedProducts[index].quantity =
                                      value;
                                });
                              },
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => _deleteProduct(index),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 25,
                              ),
                            ),
                          ])),
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
            Expanded(
              // ignore: sized_box_for_whitespace
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                // ignore: sized_box_for_whitespace
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          // side: BorderSide(color: Colors.red)
                        ),
                        backgroundColor: const Color.fromRGBO(2, 27, 60, 1),
                      ),
                      child: const Center(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color.fromRGBO(232, 234, 246, 1)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Checkout()));
                      },
                    )),
              ),
            ),
          ],
        ));
  }
}

class CounterApp extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  const CounterApp({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      widget.onValueChanged(_counter);
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        widget.onValueChanged(_counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        GestureDetector(
          onTap: _decrementCounter,
          child: const Icon(
            Icons.remove,
            size: 22,
          ),
        ),
        Text(
          '$_counter',
          style: const TextStyle(fontSize: 20.0),
        ),
        GestureDetector(
          onTap: _incrementCounter,
          child: const Icon(Icons.add, size: 22),
        ),
      ],
    );
  }
}
