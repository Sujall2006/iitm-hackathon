import 'package:flutter/material.dart';

List<Widget> buildStars(int rating) {
  switch (rating) {
    case 5:
      return const [
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
      ];
    case 1:
      return const [
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
      ];
    case 2:
      return const [
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
      ];
    case 3:
      return const [
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
      ];
    case 4:
      return const [
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star, color: Colors.orange),
        Icon(Icons.star_border),
      ];
    default:
      return const [
        Icon(Icons.star_border),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
        Icon(Icons.star_border),
      ];
  }
}
