import 'package:evflutterapp/screens/slot_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChargingCard extends StatefulWidget {
  const ChargingCard({
    super.key,
    required this.chargerType,
    required this.chargerQunatity,
    required this.chargerName,
    required this.chargingCost,
    required this.rateOfCharge,
    required this.stationId,
    required this.address,
    required this.stationName,
  });

  final String chargerType;
  final String chargerQunatity;
  final String chargerName;
  final String chargingCost;
  final String rateOfCharge;
  final String stationId;
  final String address;
  final String stationName;

  @override
  _ChargingCardState createState() => _ChargingCardState();
}

class _ChargingCardState extends State<ChargingCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                "${widget.chargerType} (${widget.chargerQunatity})",
                style: const TextStyle(
                    backgroundColor: Colors.green, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Icon(Icons.charging_station),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.chargerName,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w300),
          ),
          Text(
            "${widget.chargingCost}/${widget.rateOfCharge} mins",
            style: const TextStyle(fontSize: 11),
          ),
          const Divider(
            thickness: 0.3,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(
                        stationId: widget.stationId,
                        portType: widget.chargerType,
                        chargerName: widget.chargerName,
                        cost: widget.chargingCost,
                        rateOfCharge: widget.rateOfCharge,
                        address: widget.address,
                        stationName: widget.stationName,
                      ),
                    ));
              },
              child: Text(
                "Book Now",
                style: GoogleFonts.aBeeZee(
                    fontWeight: FontWeight.w600, color: Colors.green),
              ),
            ),
          ),
          SizedBox(
            height: 4,
          )
        ],
      ),
    );
  }
}
