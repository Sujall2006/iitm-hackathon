import 'dart:convert';

import 'package:evflutterapp/widgets/favourites_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/functions/axios.dart';
import '../services/functions/get_user_location.dart';
import '../widgets/no_connection_page.dart';
import '../widgets/nothing_to_show_here.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage({super.key});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  bool isLiked = true;
  String currentLat = "", currentLong = "";
  var widgets;
  final Axios axios = Axios();

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
  }

  getFavStations() async {
    var res = await axios.get("/driver/evstation/favourite");
    var resData = json.decode(res.body);
    return resData;
  }

  List<Widget> createCards(List records) {
    int i = 0;
    int outpassLength = records.length;
    if (outpassLength != 0) {
      widgets = List.filled(
          outpassLength,
          FavCard(
            isLiked: true,
            stationStatus: false,
            stationName: '',
            rating: 0,
            stationCoordinates: '',
            city: '',
            state: '',
            stationId: '',
            notifyParentPage: () {},
          ),
          growable: false);
      for (var data in records) {
        widgets[i] = FavCard(
          isLiked: true,
          stationStatus: data['operatingStatus'],
          stationName: data['evStationName'],
          rating: data['stars'],
          stationCoordinates: data['location']['points'],
          city: data['location']['city'],
          state: data['location']['state'],
          stationId: data['_id'],
          notifyParentPage: () {
            setState(() {});
          },
        );
        i++;
      }
      return widgets;
    } else {
      return [const NothingToShowHere()];
    }
  }

  fetchCurrentLocation() {
    getUserCurrentLocation().then((value) async {
      setState(() {
        currentLat = value.latitude.toString();
        currentLong = value.longitude.toString();
      });
      print(value.latitude.toString() + " " + value.longitude.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Favourites",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            setState(() {});
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FutureBuilder(
            future: getFavStations(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
        ),
      ),
    );
  }
}
