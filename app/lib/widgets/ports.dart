import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Port extends StatelessWidget {
  const Port({
    Key? key,
    required this.name,
    required this.image,
  }) : super(key: key);
  final String name;
  final String image;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15, bottom: 25),
      padding: EdgeInsets.all(3),
      child: Column(
        children: [
          Image.asset(
            image,
            scale: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Center(
                child: Text(
              name,
              style: GoogleFonts.cabin(fontSize: 12, letterSpacing: 1.3),
            )),
          ),
        ],
      ),
    );
  }
}
