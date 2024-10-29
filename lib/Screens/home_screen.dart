import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stopshop/Screens/billing_details.dart';
import 'package:stopshop/Screens/cart_screen.dart';
import 'package:stopshop/Screens/profile_page.dart';
import 'package:stopshop/Screens/scan_product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String name = "Name Loading";
  List<Product> scannedProducts = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> saveCartToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // Map the products into a list of maps (Firestore format)
    List<Map<String, dynamic>> cartItems = scannedProducts.map((product) {
      return {
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'quantity': product.quantity,
      };
    }).toList();
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update(
        {'cartItems': cartItems, 'updatedAt': FieldValue.serverTimestamp()});
    // Save cart data under user's document
    await _firestore.collection('carts').doc(user.uid).set({
      'cartItems': cartItems,
      'updatedAt':
          FieldValue.serverTimestamp(), // Optional: to track last update time
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
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   iconTheme:
          //       const IconThemeData(color: Color.fromRGBO(232, 234, 246, 1)),
          //   centerTitle: true,
          //   backgroundColor: const Color.fromRGBO(251, 118, 44, 1),
          //   title: const Text('STOP & SHOP',
          //       style: TextStyle(
          //           color: Color.fromRGBO(0, 0, 0, 1),
          //           fontSize: 22,
          //           fontWeight: FontWeight.bold)),
          // ),
          // drawer: Drawer(
          //   child: ListView(
          //     padding: EdgeInsets.zero,
          //     children: <Widget>[
          //       UserAccountsDrawerHeader(
          //         accountName: Text(
          //           "Hello, $name",
          //           style: const TextStyle(
          //               color: Color.fromARGB(255, 255, 255, 255),
          //               fontSize: 17,
          //               fontWeight: FontWeight.bold),
          //         ),
          //         currentAccountPicture: const CircleAvatar(
          //           backgroundImage: NetworkImage(
          //               "https://cdn3.iconfinder.com/data/icons/essential-rounded/64/Rounded-31-512.png"),
          //           backgroundColor: Colors.white,
          //         ),
          //         accountEmail: null,
          //       ),
          //       // Add other drawer items here
          //       ListTile(
          //         leading: const Icon(Icons.qr_code),
          //         title: const Text('Scan'),
          //         onTap: () {
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //                 builder: (context) => const HomeScreen()),
          //           );
          //         },
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.shopping_basket),
          //         title: const Text('Cart'),
          //         onTap: () {
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //                 builder: (context) => const HomeScreen()),
          //           );
          //         },
          //       ),
          //       // Add more list tiles as needed
          //     ],
          //   ),
          // ),
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
                          saveCartToFirestore();
                        });
                      }),
                      Cart(
                        scannedProducts: scannedProducts,
                      ),
                      const BillingDetail(),
                      ProfilePage(
                        tabController: tabController,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class Product {
  String name;
  String price;
  String description;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.description,
    this.quantity = 0,
  });
}

class CounterApp extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  // ignore: use_super_parameters
  const CounterApp({
    Key? key,
    required this.initialValue,
    required this.onValueChanged,
  }) : super(key: key);

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
