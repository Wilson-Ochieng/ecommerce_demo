import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  static const routName= "/Profilescreen ";

  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Text('Profile screen'),
    );
  }
}