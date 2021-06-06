import 'package:flutter/material.dart';
import 'package:litterally/pages/addNewWasteBag.dart';
import 'package:litterally/pages/signuppage1.dart';
import 'package:litterally/pages/viewMyWasteBags.dart';
import 'pages/splashpage.dart';
import 'pages/signuppage1.dart';
import 'pages/homepage.dart';
import 'pages/redeemCoins.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomePage(),
        '/redeem': (context) => redeemCoin(),
        '/history': (context) => viewMyWasteBags(),
        '/addnew': (context) => addNewWasteBag(),
      },
    );
  }
}
