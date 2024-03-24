import "dart:convert";

import "package:evflutterapp/screens/profile_page.dart";
import "package:evflutterapp/services/functions/axios.dart";
import "package:evflutterapp/widgets/custom_text_form_field.dart";
import "package:evflutterapp/widgets/loading_dialog.dart";
import "package:evflutterapp/widgets/nothing_to_show_here.dart";
import "package:evflutterapp/widgets/operator/ev_station_form.dart";
import "package:evflutterapp/widgets/operator/ev_stations_card.dart";
import "package:flutter/material.dart";
import "package:form_validator/form_validator.dart";
import "package:google_fonts/google_fonts.dart";

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  final Axios axios = Axios();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mailId = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  Future<dynamic> getStations() async {
    var response = await axios.get("/operator");
    var res = jsonDecode(response.body);
    return res;
  }

  Future<void> onRefresh() async {
    setState(() {});
  }

  Future<void> registerOperator() async {
    try {
      if (_formKey.currentState!.validate()) {
        LoadingDialog.show(context);
        var data = {
          "username": _username.text.trim(),
          "name": _name.text.trim(),
          "phoneNumber": _phoneNumber.text.trim(),
          "mailId": _mailId.text.trim(),
        };
        var response = await axios.post("/admin", data: jsonEncode(data));
        var res = jsonDecode(response.body);
        print(res);
        if (response.statusCode == 201) {
          LoadingDialog.hide(context);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res["message"],
              ),
            ),
          );
          setState(() {});
        } else {
          LoadingDialog.hide(context);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res["error"],
              ),
            ),
          );
        }
      }
    } catch (e) {
      LoadingDialog.hide(context);
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _mailId.dispose();
    _phoneNumber.dispose();
    _username.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getStations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: const Text("Operator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder<dynamic>(
          future: getStations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              if (snapshot.data.length == 0) {
                return const NothingToShowHere();
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var station = snapshot.data[index];
                    return EVStationCard(
                      evStation: station,
                      onChange: () {
                        setState(() {});
                      },
                    );
                  },
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: IconButton(
        color: Colors.black,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: EVStationForm(onChange: () => setState(() {})),
                ),
              );
            },
          );
        },
        icon: const Icon(
          Icons.add,
          size: 25,
        ),
      ),
    );
  }
}
