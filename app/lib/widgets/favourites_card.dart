import 'package:evflutterapp/screens/station_details_page.dart';
import 'package:evflutterapp/services/functions/axios.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/functions/coordinates_formater.dart';
import '../services/functions/rating_star_builder.dart';
import '../utils/intent_utils/intent_utils.dart';

class FavCard extends StatefulWidget {
  const FavCard(
      {super.key,
      required this.isLiked,
      required this.stationStatus,
      required this.stationName,
      required this.rating,
      required this.stationCoordinates,
      required this.city,
      required this.state,
      required this.stationId,
      required this.notifyParentPage});

  final String stationCoordinates;
  final bool isLiked;
  final bool stationStatus;
  final String stationName;
  final int rating;
  final String city;
  final String state;
  final String stationId;
  final Function() notifyParentPage;

  @override
  _FavCardState createState() => _FavCardState();
}

class _FavCardState extends State<FavCard> {
  List<String> coordinates = [];
  bool likeStat = false;
  Axios axios = Axios();
  @override
  void initState() {
    super.initState();
    setState(() {
      coordinates = coordinatesFormatter(widget.stationCoordinates);
    });
  }

  @override
  Widget build(BuildContext context) {
    likeStat = widget.isLiked;
    return GestureDetector(
      onTap: () {
        // navigate station details on bookings
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StationDetailsPage(
                      stationId: widget.stationId,
                      isLiked: true,
                    )));
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                      child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title:
                                        const Text("Remove from favourites ? "),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("No"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          var res = await axios.delete(
                                              "/driver/evstation/favourite?id=${widget.stationId}");
                                          if (res.statusCode == 200) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Removed from favourites'),
                                            ));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'An error occurred during the process.'),
                                            ));
                                          }
                                          Navigator.pop(context);
                                          widget.notifyParentPage();
                                        },
                                        child: const Text("Yes"),
                                      )
                                    ],
                                  );
                                });
                            setState(() {
                              likeStat = (likeStat) ? false : true;
                            });
                          },
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )),
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
                            "Inactive",
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                      child: GestureDetector(
                        onTap: () {
                          IntentUtils.launchGoogleMaps(
                              coordinates[0], coordinates[1]);
                        },
                        child: const Icon(
                          Icons.directions,
                          size: 26,
                        ),
                      ),
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
