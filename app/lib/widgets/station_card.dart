import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/station_details_page.dart';
import '../services/functions/coordinates_formater.dart';
import '../services/functions/rating_star_builder.dart';
import '../utils/intent_utils/intent_utils.dart';

class StationCard extends StatefulWidget {
  const StationCard(
      {super.key,
      required this.stationStatus,
      required this.stationName,
      required this.rating,
      required this.city,
      required this.state,
      required this.stationCoordinates,
      required this.distance,
      required this.stationId,
      required this.isAlterPage});

  final String stationCoordinates;
  final int rating;
  final bool stationStatus;
  final String stationName;
  final String city;
  final String state;
  final String distance;
  final String stationId;
  final bool isAlterPage;

  @override
  _StationCardState createState() => _StationCardState();
}

class _StationCardState extends State<StationCard> {
  List<String> coordinates = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      coordinates = coordinatesFormatter(widget.stationCoordinates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // navigate station details on bookings
        if (widget.isAlterPage) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StationDetailsPage(
                    stationId: widget.stationId, isLiked: false),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StationDetailsPage(
                        stationId: widget.stationId,
                        isLiked: false,
                      )));
        }
      },
      child: Container(
        // height: 120,
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(
                5.0,
                5.0,
              ),
              blurRadius: 10.0,
              spreadRadius: 0.5,
            ), //BoxShadow
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ), //BoxShadow
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                      child: Text(
                        widget.stationName,
                        style: GoogleFonts.cabin(
                            fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                      child: Text(
                        "Status: ",
                        style: GoogleFonts.cabin(
                            fontSize: 17, fontWeight: FontWeight.w100),
                      ),
                    ),
                    (widget.stationStatus)
                        ? Text(
                            "Active",
                            style: GoogleFonts.cabin(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          )
                        : Text(
                            "InActive",
                            style: GoogleFonts.cabin(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 2, 0, 2),
                  child: Row(children: buildStars(widget.rating)),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18.0, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Coordinates ",
                            style: GoogleFonts.aBeeZee(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "${coordinates[0]} / ${coordinates[1]}",
                            style: GoogleFonts.aBeeZee(
                                fontSize: 14, fontWeight: FontWeight.w100),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            "${widget.city}, ${widget.state}.",
                            style: GoogleFonts.aBeeZee(
                                fontSize: 14, fontWeight: FontWeight.w100),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text("${widget.distance} "),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                          child: GestureDetector(
                              onTap: () {
                                IntentUtils.launchGoogleMaps(
                                    coordinates[0], coordinates[1]);
                              },
                              child: const Icon(
                                Icons.directions,
                                size: 28,
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
