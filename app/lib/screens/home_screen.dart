import 'dart:async';

import 'package:evflutterapp/screens/history_page.dart';
import 'package:evflutterapp/screens/my_favourites_page.dart';
import 'package:evflutterapp/screens/profile_page.dart';
import 'package:evflutterapp/screens/search_page.dart';
import 'package:evflutterapp/screens/stations_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/functions/get_user_location.dart';
import '../services/provider/station_filter_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(45.521563, -122.677433);

  final List<Marker> _markers = <Marker>[
    const Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void getCoordinates() {
    getUserCurrentLocation().then((value) async {
      print(value.latitude.toString() + " / " + value.longitude.toString());

      Provider.of<StationFilters>(context, listen: false)
          .setCoordinates(value.latitude, value.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    getCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> _markers = <Marker>[
      const Marker(
          markerId: MarkerId('1'),
          position: LatLng(20.42796133580664, 75.885749655962),
          infoWindow: InfoWindow(
            title: 'My Position',
          )),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Ev Station App",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              // color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_active_outlined,
              // color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
        ],
      ),
      drawer: Drawer(
        shadowColor: Colors.grey.withOpacity(0.6),
        width: MediaQuery.of(context).size.width * 0.6,
        backgroundColor: Colors.green.shade100,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
                duration: Duration(seconds: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome,',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic),
                    ),
                    Center(
                      child: Text(
                        "Sujil",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    Text(
                      "sujil@gmail.com",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                )),
            ListTile(
              leading: const Icon(
                Icons.home_filled,
                color: Colors.green,
              ),
              title: const Text(
                'Home',

                // style: ksidemenu_fontstyle,
              ),
              onTap: () => {Navigator.of(context).pop()},
            ),
            ListTile(
              leading: const Icon(
                Icons.account_box_rounded,
                color: Colors.green,
              ),
              title: const Text(
                'My Profile',
                // style: ksidemenu_fontstyle,
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()))
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_activity_rounded,
                color: Colors.green,
              ),
              title: const Text(
                'My Activity',
                // style: ksidemenu_fontstyle,
              ),
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingHistoryList(
                        bookingHistory: [
                          {
                            "_id": "65fe802797dd3d129a9be45b",
                            "username": "driver1",
                            "slotsTaken": ["18:30 - 18:45"],
                            "evStationId": "65fbb1bb0812b8aa7c5c8250",
                            "portName": "AC Type-1(1)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T07:09:27.095Z"
                          },
                          {
                            "_id": "65ff015518ab0d46ad9a18c4",
                            "username": "driver1",
                            "slotsTaken": [
                              "18:15 - 18:30",
                              "18:30 - 18:45",
                              "18:15 - 18:30",
                              "18:30 - 18:45"
                            ],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(2)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T16:20:37.678Z"
                          },
                          {
                            "_id": "65ff01b918ab0d46ad9a18cf",
                            "username": "driver1",
                            "slotsTaken": [
                              "18:15 - 18:30",
                              "18:30 - 18:45",
                              "18:15 - 18:30",
                              "18:30 - 18:45",
                              "19:15 - 19:30",
                              "19:30 - 19:45",
                              "19:15 - 19:30",
                              "19:30 - 19:45"
                            ],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(1)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T16:22:17.070Z"
                          },
                          {
                            "_id": "65ff02ee18ab0d46ad9a18e7",
                            "username": "driver1",
                            "slotsTaken": [
                              "18:15 - 18:30",
                              "18:30 - 18:45",
                              "18:15 - 18:30",
                              "18:30 - 18:45",
                              "19:15 - 19:30",
                              "19:30 - 19:45",
                              "19:15 - 19:30",
                              "19:30 - 19:45",
                              "19:15 - 19:30",
                              "19:30 - 19:45",
                              "18:15 - 18:30",
                              "18:30 - 18:45"
                            ],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(3)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T16:27:26.529Z"
                          },
                          {
                            "_id": "65ff03d518ab0d46ad9a18f5",
                            "username": "driver1",
                            "slotsTaken": ["19:00 - 19:15", "19:45 - 20:00"],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(1)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T16:31:17.237Z"
                          },
                          {
                            "_id": "65ff03f418ab0d46ad9a1904",
                            "username": "driver1",
                            "slotsTaken": ["18:45 - 19:00"],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(2)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T16:31:48.323Z"
                          },
                          {
                            "_id": "65ff0dc818ab0d46ad9a1941",
                            "username": "driver1",
                            "slotsTaken": ["18:15 - 18:30", "18:30 - 18:45"],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "CHAdeMO(2)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T17:13:44.205Z"
                          },
                          {
                            "_id": "65ff1f3d668849028bc45da5",
                            "username": "driver1",
                            "slotsTaken": ["18:15 - 18:30", "18:30 - 18:45"],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(2)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T18:28:13.837Z"
                          },
                          {
                            "_id": "65ff1f98668849028bc45daf",
                            "username": "driver1",
                            "slotsTaken": ["18:45 - 19:00", "19:00 - 19:15"],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(2)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T18:29:44.973Z"
                          },
                          {
                            "_id": "65ff1fa2668849028bc45db5",
                            "username": "driver1",
                            "slotsTaken": ["19:15 - 19:30"],
                            "evStationId": "65fd19597ef39f7498d0c421",
                            "portName": "AC Type-1(2)",
                            "dateOfBooking": "23-03-2024",
                            "createdAt": "2024-03-23T18:29:54.109Z"
                          }
                        ], // Pass your booking history data here
                      ),
                    ))
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.location_city_outlined,
                color: Colors.green,
              ),
              title: const Text(
                'Ev Stations',
                // style: ksidemenu_fontstyle,
              ),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StationPage()))
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.favorite,
                color: Colors.green,
              ),
              title: const Text(
                'My Favourites',
                // style: ksidemenu_fontstyle,
              ),
              onTap: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FavouritesPage()));
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
            )
          ],
        ),
      ),
      // body: Scaffold(),
      body: WebView(
        initialUrl: 'https://www.google.com/maps', // URL of the map
        javascriptMode: JavascriptMode.unrestricted,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: () async {
            // CameraPosition cameraPosition = new CameraPosition(
            //   target: LatLng(20.42796133580664, 75.8),
            //   zoom: 1,
            // );
            //
            // final GoogleMapController controller = await _controller.future;
            // controller
            //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            // setState(() {});
            // getUserCurrentLocation().then((value) async {
            //   print(value.latitude.toString() +
            //       " / " +
            //       value.longitude.toString());
            //
            //   Provider.of<StationFilters>(context, listen: false)
            //       .setCoordinates(value.latitude, value.longitude);
            //
            //   // marker added for current users location
            //   _markers.add(Marker(
            //     markerId: const MarkerId("2"),
            //     position: LatLng(value.latitude, value.longitude),
            //     infoWindow: const InfoWindow(
            //       title: 'My Current Location',
            //     ),
            //   ));
            //   setState(() {});
            //
            //   // specified current users location
            //   CameraPosition cameraPosition = CameraPosition(
            //     target: LatLng(value.latitude, value.longitude),
            //     zoom: 14,
            //   );
            //
            //   final GoogleMapController controller = await _controller.future;
            //   controller.animateCamera(
            //       CameraUpdate.newCameraPosition(cameraPosition));
            //   setState(() {});
            // });
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => StationPage()));
          },
          tooltip: 'Stations',
          child: const Icon(Icons.list),
        ),
      ),
    );
  }
}
