import 'dart:convert';
import 'package:evflutterapp/services/functions/axios.dart';
import 'package:flutter/material.dart';

class OperatorCard extends StatelessWidget {
  OperatorCard(
      {super.key, required this.operatorData, required this.onOperatorDeleted});

  final Axios axios = Axios();
  final Map<String, dynamic> operatorData;
  final Function onOperatorDeleted;

  Future<void> deleteOperator(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      var response =
          await axios.delete("/admin?username=${operatorData["username"]}");
      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(res["message"])));
        onOperatorDeleted();
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(res["error"])));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Failed to delete operator")));
    }
  }

  showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Operator"),
          content: const Text("Are you sure you want to delete this operator?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteOperator(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  String parseCreatedAt(String createdAt) {
    DateTime parsedDate = DateTime.parse(createdAt);
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light gray background color
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4CAF50), // Green color for avatar
                  child: Text(
                    operatorData['name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operatorData['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        operatorData['role'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => showDeleteConfirmationDialog(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  iconData: Icons.person,
                  label: 'Username',
                  value: operatorData['username'],
                ),
                _buildDetailRow(
                  iconData: Icons.phone,
                  label: 'Phone Number',
                  value: operatorData['phoneNumber'],
                ),
                _buildDetailRow(
                  iconData: Icons.email,
                  label: 'Email',
                  value: operatorData['mailId'],
                ),
                _buildDetailRow(
                  iconData: Icons.calendar_today,
                  label: 'Created At',
                  value: parseCreatedAt(operatorData['createdAt']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData iconData,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(iconData, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12.0),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
