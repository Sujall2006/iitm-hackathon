import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/images.dart';

class NothingToShowHere extends StatelessWidget {
  const NothingToShowHere({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.asset(nothingFound),
            ),
            Text(
              "No Items Found",
              style: GoogleFonts.aBeeZee(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
