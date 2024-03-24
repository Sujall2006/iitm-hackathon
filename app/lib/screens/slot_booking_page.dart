import 'dart:convert';

import 'package:evflutterapp/widgets/loading_dialog.dart';
import 'package:evflutterapp/widgets/slot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/functions/axios.dart';
import '../services/provider/station_filter_handler.dart';
import '../widgets/nothing_to_show_here.dart';

class BookingPage extends StatefulWidget {
  BookingPage(
      {super.key,
      required this.stationId,
      required this.portType,
      required this.chargerName,
      required this.cost,
      required this.rateOfCharge,
      required this.address,
      required this.stationName});

  final String stationId;
  final String portType;
  final String chargerName;
  final String cost;
  final String rateOfCharge;
  final String address;
  final String stationName;

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  var widgets;
  final Axios axios = Axios();
  var resData;
  List<String> slots = [];
  int _rating = 0;

  Future<void> _setRating(int rating) async {
    var res;
    setState(() {
      _rating = rating;
    });
    final Map<String, dynamic> data = {
      "rating": rating,
      "id": widget.stationId
    };
    LoadingDialog.show(context);
    res = await axios.post("/driver/star", data: jsonEncode(data));
    LoadingDialog.hide(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks for your feedback!")));
  }

  @override
  void initState() {
    super.initState();
    getAvailableSlots();
  }

  getAvailableSlots() async {
    var res;
    print("--------------${widget.chargerName}--${widget.stationId}");
    res = await axios.get(
        "/driver/booking?id=${widget.stationId}&portName=${widget.chargerName}");
    setState(() {
      resData = json.decode(res.body);
    });
    print(resData);
    return resData;
  }

  bookASlot() async {
    var res;
    List slot = Provider.of<StationFilters>(context, listen: false).slots;
    final Map<String, dynamic> data = {
      "id": widget.stationId,
      "portName": widget.chargerName,
      "slot": slot
    };
    LoadingDialog.show(context);
    res = await axios.post("/driver/booking", data: jsonEncode(data));
    var resData = json.decode(res.body);
    print(resData);
    if (res.statusCode == 200) {
      print("SUCCESSSSSSSSSSSSSSSSS");
    } else {
      print("FLOOOOOOP");
    }
    LoadingDialog.hide(context);
    getAvailableSlots();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Booked Successfully")));
    Provider.of<StationFilters>(context, listen: false).removeAllSlots();
  }

  List<Widget> createCards(List records) {
    int i = 0;
    int outpassLength = records.length;
    if (outpassLength != 0) {
      widgets = List.filled(
          outpassLength, const SlotCard(slot: '', isAvailable: false),
          growable: false);
      for (var data in records) {
        widgets[i] =
            SlotCard(slot: data['slot'], isAvailable: data['isAvailable']);
        i++;
      }
      return widgets;
    } else {
      return [const NothingToShowHere()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book your slot",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                widget.stationName,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),
            Center(
              child: Text(
                widget.address,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    Icons.charging_station,
                    size: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.portType,
                        style: GoogleFonts.aBeeZee(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.chargerName,
                        style: GoogleFonts.aBeeZee(fontSize: 16),
                      ),
                      Text(
                        "${widget.cost} / ${widget.rateOfCharge} mins  (Estimated*)",
                        style: GoogleFonts.aBeeZee(),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            Text(
              "Available Slots",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 24),
            ),
            const SizedBox(
              height: 5,
            ),
            (resData != null)
                ? Expanded(
                    child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 2.8,
                        mainAxisSpacing: 7,
                        crossAxisSpacing: 7,
                        children: createCards(resData)),
                  )
                : const SpinKitCircle(
                    color: Colors.green,
                  ),
            SizedBox(
              height: 25,
            ),
            Flexible(
              child: Row(
                children: [
                  Text(
                    "Rate ",
                    style: GoogleFonts.poppins(fontSize: 23),
                  ),
                  Text(
                    widget.stationName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 23),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(_rating >= 1 ? Icons.star : Icons.star_border),
                  onPressed: () {
                    _setRating(1);
                  },
                ),
                IconButton(
                  icon: Icon(_rating >= 2 ? Icons.star : Icons.star_border),
                  onPressed: () {
                    _setRating(2);
                  },
                ),
                IconButton(
                  icon: Icon(_rating >= 3 ? Icons.star : Icons.star_border),
                  onPressed: () {
                    _setRating(3);
                  },
                ),
                IconButton(
                  icon: Icon(_rating >= 4 ? Icons.star : Icons.star_border),
                  onPressed: () {
                    _setRating(4);
                  },
                ),
                IconButton(
                  icon: Icon(_rating >= 5 ? Icons.star : Icons.star_border),
                  onPressed: () {
                    _setRating(5);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () async {
                print(
                    Provider.of<StationFilters>(context, listen: false).slots);
                await bookASlot();
              },
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(
                  "Book Now",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 23),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
