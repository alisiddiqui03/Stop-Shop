import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String name = "Name Loading";

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
    TabController tabController = TabController(length: 2, vsync: this);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 24, 181, 0),
            title: const Text('STOP & SHOP',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    "Hello, $name",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://cdn3.iconfinder.com/data/icons/essential-rounded/64/Rounded-31-512.png"),
                    backgroundColor: Colors.white,
                  ),
                  accountEmail: null,
                ),
                // Add other drawer items here
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('Scan'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_basket),
                  title: const Text('Cart'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                // Add more list tiles as needed
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(5.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              TabBar(
                labelColor: const Color.fromARGB(255, 255, 255, 255),
                unselectedLabelColor: const Color.fromARGB(255, 0, 0, 0),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: const Color.fromARGB(255, 255, 152, 114),
                indicator: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(15)),
                controller: tabController,
                isScrollable: true,
                labelPadding:
                    EdgeInsets.symmetric(horizontal: size.width * 0.06),
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Scan Product",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Tab(
                      child: Text(
                        "Cart",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                    controller: tabController,
                    children: const [ScanProduct(), Cart()]),
              )
            ]),
          )),
    );
  }
}

class ScanProduct extends StatefulWidget {
  const ScanProduct({super.key});

  @override
  State<ScanProduct> createState() => _ScanProductState();
}

class _ScanProductState extends State<ScanProduct> {
  String result = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.network(
                "https://cdn-icons-png.flaticon.com/512/241/241528.png",
                width: 300,
                height: 300,
              ),
              const SizedBox(
                height: 100,
              ),
              // ignore: sized_box_for_whitespace
              Container(
                  width: 318,
                  height: 59,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        // side: BorderSide(color: Colors.red)
                      ),
                      backgroundColor: const Color.fromARGB(255, 24, 181, 0),
                    ),
                    child: const Text(
                      'CLICK TO SCAN',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    onPressed: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SimpleBarcodeScannerPage(),
                          ));
                      // ignore: avoid_print
                      print(res);
                      setState(() {
                        if (res is String) {
                          result = res;
                          // ignore: avoid_print
                          print(result);
                        }
                      });
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Map<String, dynamic>> productDetails = [
    {
      "name": "Product 1",
      "price": 10.99,
      "description": "Description of Product 1"
    },
    {
      "name": "Product 2",
      "price": 20.99,
      "description": "Description of Product 2"
    },
    {
      "name": "Product 1",
      "price": 10.99,
      "description": "Description of Product 1"
    },
    {
      "name": "Product 2",
      "price": 20.99,
      "description": "Description of Product 2"
    },
    {
      "name": "Product 1",
      "price": 10.99,
      "description": "Description of Product 1"
    },
    {
      "name": "Product 2",
      "price": 20.99,
      "description": "Description of Product 2"
    },
    {
      "name": "Product 1",
      "price": 10.99,
      "description": "Description of Product 1"
    },
    {
      "name": "Product 2",
      "price": 20.99,
      "description": "Description of Product 2"
    },
    // Add more product details as needed
  ];

  void _deleteProduct(int index) {
    setState(() {
      productDetails.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("SHOP")),
      ),
      body: ListView.builder(
        itemCount: productDetails.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 90,
              decoration: BoxDecoration(
                color: Color.fromRGBO(232, 234, 246, 1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productDetails[index]["name"],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(36, 34, 921, 1)),
                        ),
                        Text(productDetails[index]["description"],
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(36, 34, 921, 1))),
                        Text(
                            "Price: \Rs${productDetails[index]["price"]}"
                                .toString(),
                            style: TextStyle(
                                fontSize: 17,
                                color: Color.fromRGBO(36, 34, 921, 1))),
                      ],
                    ),
                    Spacer(),
                    CounterApp(),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => _deleteProduct(index),
                      child: Icon(
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
    );
  }
}

class CounterApp extends StatefulWidget {
  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        GestureDetector(
          onTap: _decrementCounter,
          child: Icon(
            Icons.remove,
            size: 22,
          ),
        ),
        Text(
          '$_counter',
          style: TextStyle(fontSize: 20.0),
        ),
        GestureDetector(
            onTap: _incrementCounter, child: Icon(Icons.add, size: 22)),
      ],
    );
  }
}
