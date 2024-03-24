import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/functions/axios.dart';
import '../services/provider/station_filter_handler.dart';
import '../utils/images.dart';
import '../widgets/no_connection_page.dart';
import '../widgets/nothing_to_show_here.dart';
import '../widgets/ports.dart';
import '../widgets/station_card.dart';

class StationPage extends StatefulWidget {
  StationPage({super.key});

  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  String? state, city, portType = "AC|AC Type-1";
  bool isActive = false;
  String lat = "", long = "";
  var widgets;
  final Axios axios = Axios();

  @override
  void initState() {
    super.initState();
    lat =
        Provider.of<StationFilters>(context, listen: false).latitude.toString();
    long =
        Provider.of<StationFilters>(context, listen: false).latitude.toString();
    resetFilters();
  }

  void resetFilters() {
    StationFilters stationFilters =
        Provider.of<StationFilters>(context, listen: false);
    stationFilters.setPortType("AC|AC Type-1");
    stationFilters.setCity(null);
    stationFilters.setState(null);
    stationFilters.setIsFilterActive(false);
  }

  void clearFilters() {
    StationFilters stationFilters =
        Provider.of<StationFilters>(context, listen: false);
    setState(() {
      state = null;
      city = null;
      portType = "AC|AC Type-1";
    });
    stationFilters.setPortType("AC|AC Type-1");
    stationFilters.setCity(null);
    stationFilters.setState(null);
    stationFilters.setIsFilterActive(false);
    Navigator.pop(context);
  }

  Future<void> handleApplyFilters() async {
    int flag = 1;
    StationFilters stationFilters =
        Provider.of<StationFilters>(context, listen: false);

    // Apply filters based on selected values
    if (portType != "AC|AC Type-1") {
      stationFilters.setPortType(portType!);
      flag = 0;
    }

    if (city != null && state != null) {
      stationFilters.setCity(city!);
      stationFilters.setState(state!);
      flag = 0;
    }

    // Set filter status
    if (flag == 0) {
      Provider.of<StationFilters>(context, listen: false)
          .setIsFilterActive(true);
    }
    // Close the bottom sheet or perform any other necessary action
    Navigator.pop(context);
  }

  getStations() async {
    var res;
    if (state != null && city != null) {
      res = await axios.get("/public/evstation/?city=$city&state=$state");
    } else {
      res = await axios.get(
          "/public/evstation/nearest?long=$long&lat=$lat&portType=$portType");
    }
    var resData = json.decode(res.body);
    print(resData);
    return resData;
  }

  List<Widget> createCards(List records) {
    int i = 0;
    int outpassLength = records.length;
    if (outpassLength != 0) {
      widgets = List.filled(
          outpassLength,
          const StationCard(
            stationStatus: false,
            stationName: '',
            rating: 0,
            stationCoordinates: '',
            city: '',
            state: '',
            distance: '',
            stationId: '',
            isAlterPage: false,
          ),
          growable: false);
      for (var data in records) {
        widgets[i] = StationCard(
          stationStatus: data['operatingStatus'],
          stationName: data['evStationName'],
          rating: data['stars'],
          stationCoordinates: data['location']['points'],
          city: data['location']['city'],
          state: data['location']['state'],
          distance: data['distance'].toString(),
          stationId: data['_id'],
          isAlterPage: false,
        );
        i++;
      }
      return widgets;
    } else {
      return [const NothingToShowHere()];
    }
  }

  @override
  Widget build(BuildContext context) {
    isActive = context.watch<StationFilters>().isFilterActive;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ev Stations",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: (isActive) ? Colors.green : Colors.black54,
              size: 27,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: Text(
                            "Filters",
                            style: GoogleFonts.cabin(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                                color: Colors.green),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Port(
                              name: "DC|GB/T",
                              image: DCGB,
                            ),
                            Port(
                              name: "DC|CCS-2",
                              image: CCSTYPE2,
                            ),
                            Port(
                              name: "AC|AC Type-1",
                              image: ACTYPE1,
                            ),
                            Port(
                              name: "DC|CHAdeMO",
                              image: CHADEMO,
                            ),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          value: portType,
                          onChanged: (value) {
                            setState(() {
                              portType = value;
                            });
                          },
                          items: <String>[
                            'AC|AC Type-1',
                            'AC|AC Type-2',
                            'AC|Bharat AC001',
                            'AC|AC Plug Point',
                            'DC|CCS-1',
                            'DC|CCS-2',
                            'DC|Bharat DC001 GB/T',
                            'DC|Tesla Charger',
                            'DC|CHAdeMO',
                            'DC|GB/T'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Port Type',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: city,
                          onChanged: (value) async {
                            setState(() {
                              city = value;
                            });
                          },
                          items: <String>[
                            'Coimbatore',
                            'Dindigul',
                            'Salem',
                            'Chennai',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: state,
                          onChanged: (value) {
                            setState(() {
                              state = value;
                            });
                          },
                          items: <String>[
                            'Tamil Nadu',
                            'Maharashta',
                            'Uttar Pradesh',
                            'Kerala',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 45),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: clearFilters,
                                  child: Text(
                                    "Clear All Filters",
                                    style: GoogleFonts.cabin(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: handleApplyFilters,
                                  child: Text(
                                    "Apply Filters",
                                    style: GoogleFonts.cabin(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            setState(() {});
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    "${isActive ? "Applied Filters" : "Nearest Stations"}",
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        letterSpacing: 1.5,
                        color: Colors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                FutureBuilder(
                  future: getStations(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: createCards(snapshot.data),
                      );
                    } else if (snapshot.hasError) {
                      return const NoConnectionPage();
                    } else {
                      return const SizedBox(
                        height: 500,
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.green,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
