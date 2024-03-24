import 'package:flutter/material.dart';

class BookingHistoryWidget extends StatelessWidget {
  final String stationName;
  final List<String> slotsTaken;
  final String evStationId;
  final String portName;
  final String dateOfBooking;
  final String createdAt;

  const BookingHistoryWidget({
    Key? key,
    required this.stationName,
    required this.slotsTaken,
    required this.evStationId,
    required this.portName,
    required this.dateOfBooking,
    required this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Station Name: $stationName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Slots Taken:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: slotsTaken.map((slot) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(slot),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            Text('EV Station ID: $evStationId'),
            SizedBox(height: 8),
            Text('Port Name: $portName'),
            SizedBox(height: 8),
            Text('Date of Booking: $dateOfBooking'),
            SizedBox(height: 8),
            Text('Created At: $createdAt'),
          ],
        ),
      ),
    );
  }
}
