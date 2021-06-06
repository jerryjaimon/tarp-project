import 'package:flutter/material.dart';
import 'package:litterally/pages/authorizeTransaction.dart';
import 'package:litterally/pages/signuppage1.dart';
import 'pages/splashpage.dart';
import 'pages/signuppage1.dart';
import 'pages/homepage.dart';
import 'pages/authorizeTransaction.dart';
import 'pages/modifyStatus.dart';
import 'pages/wastebinstats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authorizeTransaction(),
    );
  }
}
