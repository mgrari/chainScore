import 'dart:io';

import 'package:flutter/material.dart';

import 'Screens/login.dart';

void main() async {
  Socket socket = await Socket.connect("192.168.129.5", 3000);

  runApp(MyApp(socket));
}

class MyApp extends StatelessWidget {
  final Socket socket;
  MyApp(this.socket, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login and signup',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: LoginForm(socket),
    );
  }
}
