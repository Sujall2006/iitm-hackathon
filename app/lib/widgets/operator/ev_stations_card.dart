import 'dart:convert';

import 'package:evflutterapp/services/functions/axios.dart';
import 'package:evflutterapp/services/functions/rating_star_builder.dart';
import 'package:evflutterapp/widgets/operator/ev_station_form.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EVStationCard extends StatelessWidget {
  EVStationCard({
    Key? key,
    required this.evStation,
    required this.onChange,
  }) : super(key: key);

  final Map<String, dynamic> evStation;
  final VoidCallback onChange;

  final Axios axios = Axios();

  Future<void> deleteEVStation(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      var response = await axios.delete("/operator?id=${evStation['_id']}");
      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(res["message"])));
        onChange();
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(res["error"])));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Failed to delete EVStation")));
    }
  }

  showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete EVStation"),
          content:
              const Text("Are you sure you want to delete this EVStation?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteEVStation(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _openMaps(String coordinates) async {
    List<String> parts = coordinates.split("/");
    double lat = double.parse(parts[0]);
    double lng = double.parse(parts[1]);
    String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void editEVStation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: EVStationForm(onChange: onChange, isEdit: true),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        Icons.ev_station,
                        size: 24.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          _openMaps(evStation["location"]["points"]);
                        },
                        child: Icon(
                          Icons.location_on,
                          size: 24.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evStation['evStationName'],
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${evStation['location']['city']}, ${evStation['location']['state']}',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: buildStars(evStation["stars"] as int),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Colors.blue),
                        title: Text('Edit'),
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'delete') {
                      showDeleteConfirmationDialog(context);
                    } else if (value == 'edit') {
                      editEVStation(context);
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 12.0),
            const Divider(height: 1.0),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailColumn(
                  iconData: Icons.calendar_today,
                  label: 'Created',
                  value: parseCreatedAt(evStation['createdAt']),
                ),
                _buildDetailColumn(
                  iconData: Icons.access_time,
                  label: 'Hours',
                  value:
                      '${evStation['workingHours']['from']} - ${evStation['workingHours']['to']}',
                ),
                _buildDetailColumn(
                  iconData: evStation['operatingStatus']
                      ? Icons.check_circle
                      : Icons.cancel,
                  label: 'Status',
                  value: evStation['operatingStatus']
                      ? 'Operational'
                      : 'Not Operational',
                  valueColor:
                      evStation['operatingStatus'] ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12.0),
              title: Text(
                'Port Information',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  height: 140.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: evStation['portInfo'].length,
                    itemBuilder: (context, index) {
                      final port = evStation['portInfo'][index];
                      return Container(
                        margin: const EdgeInsets.all(8),
                        width: 150.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.grey[200],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              port['type'],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Output: ${port['output']} kW',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Cost: ${port['cost']} units',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Count: ${port['count']}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            ExpansionTile(
              expandedAlignment: Alignment.topLeft,
              tilePadding: const EdgeInsets.symmetric(horizontal: 12.0),
              title: Text(
                'Location',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressRow("Address Lane 1", evStation["address1"]),
                      _buildAddressRow("Address Lane 2", evStation["address2"]),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4), // Adding spacing between label and value
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8), // Adding spacing between address rows
      ],
    );
  }

  Widget _buildDetailColumn({
    required IconData iconData,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          iconData,
          size: 20.0,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            color: valueColor ?? Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String parseCreatedAt(String createdAt) {
    DateTime parsedDate = DateTime.parse(createdAt);
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
  }
}
