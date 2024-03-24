import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/provider/station_filter_handler.dart';

class SlotCard extends StatefulWidget {
  const SlotCard({
    super.key,
    required this.slot,
    required this.isAvailable,
  });

  final String slot;
  final bool isAvailable;

  @override
  _SlotCardState createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> {
  Color isSelected = Colors.black;
  @override
  void initState() {
    super.initState();
    Provider.of<StationFilters>(context, listen: false).removeAllSlots();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isAvailable) {
          setState(() {
            isSelected =
                (isSelected == Colors.black) ? Colors.deepOrange : Colors.black;
            if (isSelected == Colors.deepOrange) {
              Provider.of<StationFilters>(context, listen: false)
                  .setSlots(widget.slot);
            } else {
              Provider.of<StationFilters>(context, listen: false)
                  .removeSlot(widget.slot);
            }
          });
        }
      },
      child: Container(
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: (widget.isAvailable)
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3)),
          child: Center(
            child: Text(
              widget.slot,
              style: GoogleFonts.cabin(
                  fontWeight: FontWeight.bold, color: isSelected),
            ),
          )),
    );
  }
}
