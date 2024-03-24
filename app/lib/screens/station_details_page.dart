import 'dart:convert';

import 'package:evflutterapp/services/functions/24_to_12hrs_converter.dart';
import 'package:evflutterapp/widgets/charging_cards.dart';
import 'package:evflutterapp/widgets/station_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/functions/axios.dart';
import '../widgets/nothing_to_show_here.dart';

class StationDetailsPage extends StatefulWidget {
  const StationDetailsPage(
      {super.key, required this.stationId, required this.isLiked});
  final String stationId;
  final bool isLiked;

  @override
  _StationDetailsPageState createState() => _StationDetailsPageState();
}

class _StationDetailsPageState extends State<StationDetailsPage> {
  final Axios axios = Axios();
  var resData, portsWidgets, stationWidgets;
  bool likeStat = false;

  @override
  void initState() {
    super.initState();
    getStationDetails();
  }

  List<Widget> createAlterStationCards(var data) {
    int i = 0;
    int stationLength = data['alternatives'].length;
    print("ports Length: $stationLength");
    if (stationLength != 0) {
      portsWidgets = List.filled(
          stationLength,
          const StationCard(
            stationStatus: false,
            stationName: '',
            rating: 0,
            city: '',
            state: '',
            stationCoordinates: '',
            distance: '',
            stationId: '',
            isAlterPage: true,
          ),
          growable: false);
      for (var dat in data['alternatives']) {
        portsWidgets[i] = StationCard(
          stationStatus: dat['operatingStatus'],
          stationName: dat['evStationName'],
          rating: dat['stars'],
          city: dat['location']['city'],
          state: dat['location']["state"],
          stationCoordinates: dat['location']['points'],
          distance: dat['distance'].toString(),
          stationId: dat['_id'],
          isAlterPage: true,
        );
        i++;
      }
      return portsWidgets;
    } else {
      return [const NothingToShowHere()];
    }
  }

  getStationDetails() async {
    var res = await axios.get("/public/evstation/info?id=${widget.stationId}");
    setState(() {
      resData = json.decode(res.body);
    });
    print(resData);
  }

  List<Widget> createChargingPortCards(Map<dynamic, dynamic> ports) {
    int i = 0;
    int portsLength = ports['ports'].length;
    print("ports Length: $portsLength");
    if (portsLength != 0) {
      portsWidgets = List.filled(
          portsLength,
          const ChargingCard(
            chargerType: '',
            chargerQunatity: '',
            chargerName: '',
            chargingCost: '',
            rateOfCharge: '',
            stationId: '',
            address: '',
            stationName: '',
          ),
          growable: false);
      for (var data in ports['ports']) {
        portsWidgets[i] = ChargingCard(
          chargerType: data['type'],
          chargerQunatity: '2',
          chargerName: data['name'],
          chargingCost: data['cost'].toString(),
          rateOfCharge: '15',
          stationId: widget.stationId,
          address: ports['address1'],
          stationName: ports['evStationName'],
        );
        i++;
      }
      return portsWidgets;
    } else {
      return [const NothingToShowHere()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "EV Station Details",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (resData != null)
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                resData['evStationName'],
                                overflow: TextOverflow.fade,
                                style: GoogleFonts.poppins(
                                    fontSize: 25, fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final Map<String, String> data = {
                                  "id": widget.stationId,
                                };
                                var res;
                                String message = "";
                                if (likeStat) {
                                  res = await axios.delete(
                                      "/driver/evstation/favourite?id=${widget.stationId}");
                                  message = "Removed from your favourites";
                                } else {
                                  res = await axios.put(
                                      "/driver/evstation/favourite",
                                      data: jsonEncode(data));
                                  message = "Added to your favourites";
                                }
                                if (res.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));
                                  setState(() {
                                    likeStat = (likeStat) ? false : true;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("An error occurred")));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: (likeStat)
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 28,
                                      )
                                    : const Icon(
                                        Icons.favorite_border,
                                        size: 24,
                                      ),
                              ),
                            )
                          ],
                        ),
                        Text(
                          "${resData['address1']},${resData['address2']}",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            (resData['operatingStatus'])
                                ? Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 3, 6, 3),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      "Open",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )
                                : Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 3, 6, 3),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      "Closed",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.access_time_outlined,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                                convert24To12(resData['workingHours']['from'])),
                            const Text(' - '),
                            Text(convert24To12(resData['workingHours']['to'])),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Available Connectors"),
                        const SizedBox(
                          height: 5,
                        ),
                        // widget
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: createChargingPortCards(resData),
                          ),
                        ),

                        GestureDetector(
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Station Down Voted.")));
                            final Map<String, String> data = {
                              "id": widget.stationId,
                            };
                            var res;
                            res = await axios.put(
                                "/driver/evstation/workstatus-down",
                                data: jsonEncode(data));
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 10, 0, 4),
                            padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                Text(
                                  " Down vote",
                                  style: GoogleFonts.poppins(
                                      color: Colors.green, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Operator Info"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Name",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              resData['operatorInfo']['name'],
                                              style: GoogleFonts.poppins(),
                                            )
                                          ],
                                        ),
                                        const Divider(
                                          thickness: 0.3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Phone",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              resData['operatorInfo']
                                                  ['phoneNumber'],
                                              style: GoogleFonts.poppins(),
                                            )
                                          ],
                                        ),
                                        const Divider(
                                          thickness: 0.3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "MailId",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              resData['operatorInfo']['mailId'],
                                              style: GoogleFonts.poppins(),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 8, 4, 4),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  size: 22,
                                ),
                              ),
                              Text(
                                "Contact us",
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox(
                    height: 600,
                    child: Center(
                      child: SpinKitDoubleBounce(
                        color: Colors.green,
                        size: 150,
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            (resData != null)
                ? Text(
                    "Other Alternatives",
                    style: GoogleFonts.poppins(
                        fontSize: 25, fontWeight: FontWeight.w600),
                  )
                : Container(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: (resData != null)
                        ? createAlterStationCards(resData)
                        : [Container()],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
