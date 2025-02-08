import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser; // Mendapatkan informasi user yang login
    String welcomeText = "Selamat datang, ${user?.email ?? 'Pengguna'}!";
    
    return Scaffold(
      body: Center(
        child: Text(
                welcomeText, // Menampilkan pesan selamat datang
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }
}