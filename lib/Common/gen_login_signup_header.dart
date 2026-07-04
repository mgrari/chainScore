import 'package:flutter/material.dart';

class GenLoginSignupHeader extends StatelessWidget {
  final String headerName;

  const GenLoginSignupHeader(this.headerName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Text(
          headerName,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 40.0),
        ),
        //const SizedBox(height: 5.0),
        Image.asset(
          "assets/blockchain.png",
          height: 100.0,
          width: 100.0,
        ),
      ],
    );
  }
}
