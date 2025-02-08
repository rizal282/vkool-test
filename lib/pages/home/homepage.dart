import 'package:ecommerce_vkool/pages/auth/login.dart';
import 'package:ecommerce_vkool/pages/cart/cart_page.dart';
import 'package:ecommerce_vkool/pages/face_recognition/face_recognition.dart';
import 'package:ecommerce_vkool/pages/home/homescreen.dart';
import 'package:ecommerce_vkool/pages/product/product_page.dart';
import 'package:ecommerce_vkool/pages/transaction/transaction_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Homescreen(),
    ProductPage(),
    CartPage(),
    TransactionPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Fungsi untuk logout
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Setelah logout, navigasi ke halaman login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));

      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Logout successfully')),
                      );
    } catch (e) {
      // Tampilkan error jika gagal logout
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  void _toFaceRecognitionPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FaceRecognition()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("E-Commerce App", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),),
        actions: [
          // Menambahkan ikon user di AppBar
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Menampilkan PopupMenuButton ketika icon user diklik
              _showLogoutMenu(context);
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent, // Menambahkan warna latar belakang
        selectedItemColor: Colors.blue, // Warna untuk ikon yang dipilih
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(
          color: Colors.grey, // Warna untuk teks unselected
        ),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Products',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Transaction',
          ),
         
        ],
      ),
    );
  }

  // Menampilkan Popup Menu untuk logout
  void _showLogoutMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50, // Posisi horizontal menu
        kToolbarHeight, // Posisi vertikal menu, di bawah AppBar
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          child: Text("Face Detect"),
          value: "face detect",
        ),
        PopupMenuItem(
          child: Text("Logout"),
          value: "logout",
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == "logout") {
        _logout(); // Proses logout jika opsi "Logout" dipilih
      }

       if (value == "face detect") {
        _toFaceRecognitionPage(); // Proses logout jika opsi "Logout" dipilih
      }
    });
  }
}
