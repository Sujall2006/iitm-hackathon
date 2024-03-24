import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/history_card.dart';

// Your BookingHistoryWidget definition here...

class BookingHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> bookingHistory;

  const BookingHistoryList({
    Key? key,
    required this.bookingHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Activity")),
      body: ListView.builder(
        itemCount: bookingHistory.length,
        itemBuilder: (context, index) {
          final booking = bookingHistory[index];
          return BookingHistoryWidget(
            stationName: booking['username'],
            slotsTaken: List<String>.from(booking['slotsTaken']),
            evStationId: booking['evStationId'],
            portName: booking['portName'],
            dateOfBooking: booking['dateOfBooking'],
            createdAt: DateFormat.yMd()
                .add_jm()
                .format(DateTime.parse(booking['createdAt'])),
          );
        },
      ),
    );
  }
}
