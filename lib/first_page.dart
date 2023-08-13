import 'package:flutter/material.dart';
import 'package:galli_package_demo/home.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage())),
              child: Text("homepage"))),
    ));
  }
}
