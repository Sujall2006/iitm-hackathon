import "dart:convert";

import "package:evflutterapp/services/functions/axios.dart";
import "package:evflutterapp/services/functions/get_user_location.dart";
import "package:evflutterapp/widgets/custom_text_form_field.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:form_validator/form_validator.dart";
import "package:geolocator/geolocator.dart";
import "package:google_fonts/google_fonts.dart";

class EVStationForm extends StatefulWidget {
  const EVStationForm({
    super.key,
    required this.onChange,
    this.isEdit = false,
    this.evStation,
  });

  final Map<String, dynamic>? evStation;
  final VoidCallback onChange;
  final bool isEdit;

  @override
  State<EVStationForm> createState() => _EVStationFormState();
}

class _EVStationFormState extends State<EVStationForm> {
  late String _selectedState = "";
  late String _selectedCity = "";
  List<String> _states = [];
  Map<String, List<String>> _citiesMap = {};

  late String _selectedPort = "";
  late List<dynamic> _inputPorts = [];

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  late String coordinates;

  late TimeOfDay _selectedFromTime = TimeOfDay.now();
  late TimeOfDay _selectedToTime = TimeOfDay.now();

  final TextEditingController _evStationName = TextEditingController();
  final TextEditingController selectedFromTime = TextEditingController();
  final TextEditingController selectedToTime = TextEditingController();
  final TextEditingController _addressLane1 = TextEditingController();
  final TextEditingController _addressLane2 = TextEditingController();

  final Axios axios = Axios();

  Future<void> getDropDownFields() async {
    try {
      var inputPortsResponse = await axios.get("/public/ports");
      var inputPlacesResponse = await axios.get("/public/states-cities");
      var inputPorts = jsonDecode(inputPortsResponse.body);
      var inputPlaces = jsonDecode(inputPlacesResponse.body);
      print(inputPorts);
      print(inputPlaces);
      for (var placeData in inputPlaces) {
        placeData.forEach((state, cities) {
          _states.add(state);
          _citiesMap[state] = List<String>.from(cities);
        });
      }
      setState(() {
        _selectedState = _states[0];
        _inputPorts = inputPorts;
        _selectedPort = inputPorts[0]["name"];
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _selectedFromTime : _selectedToTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    setState(() {
      if (isFrom) {
        _selectedFromTime = picked!;
        selectedFromTime.text =
            '${_selectedFromTime.hour.toString().padLeft(2, '0')}:${_selectedFromTime.minute.toString().padLeft(2, '0')}';
      } else {
        _selectedToTime = picked!;
        selectedToTime.text =
            '${_selectedToTime.hour.toString().padLeft(2, '0')}:${_selectedToTime.minute.toString().padLeft(2, '0')}';
      }
    });
  }

  @override
  void initState() {
    getDropDownFields();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _selectedCity = _citiesMap[_selectedState]?[0] ?? "Chennai";
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEdit ? "Edit EVStation" : "Register EVStation",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  controller: _evStationName,
                  hintText: "Enter Station Name",
                  labelText: "EVStation Name",
                  icon: Icons.ev_station,
                  validator: ValidationBuilder().required().build(),
                ),
                const SizedBox(height: 10),
                Text(
                  "Working Hours (24 hr)",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          _selectTime(context, true);
                        },
                        decoration: InputDecoration(
                          labelText: "From",
                          labelStyle: const TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(Icons.access_time), // Add icon here
                        ),
                        controller: selectedFromTime,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          _selectTime(context, false);
                        },
                        decoration: InputDecoration(
                          labelText: "To",
                          labelStyle: const TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(Icons.access_time), // Add icon here
                        ),
                        controller: selectedToTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Address Lanes
                !widget.isEdit
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 10),
                          Text(
                            "Select State - City",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField(
                                  value: _selectedState,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedState = value!;
                                    });
                                  },
                                  items: _states
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  decoration: InputDecoration(
                                    labelText: "State",
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    contentPadding: const EdgeInsets.all(15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField(
                                  value: _selectedCity,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCity = value.toString();
                                    });
                                  },
                                  items:
                                      _citiesMap[_selectedState]?.map((city) {
                                            return DropdownMenuItem(
                                              value: city,
                                              child: Text(city),
                                            );
                                          }).toList() ??
                                          [],
                                  decoration: InputDecoration(
                                    labelText: "City",
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    contentPadding: const EdgeInsets.all(15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Address Lanes",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            maxLines: null,
                            maxLength: 200,
                            decoration: InputDecoration(
                              labelText: "Address Line 1",
                              labelStyle: const TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              prefixIcon: const Icon(Icons.home_filled),
                            ),
                            controller: _addressLane1,
                            // Add controller for Address Line 1
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            maxLines: null,
                            maxLength: 200,
                            decoration: InputDecoration(
                              labelText: "Address Line 1",
                              labelStyle: const TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              prefixIcon: const Icon(
                                  Icons.home_filled), // Add icon here
                            ),
                            controller: _addressLane2,
                            // Add controller for Address Line 1
                          ),
                          Row(
                            children: [
                              Text(
                                "Use Current Location :",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                child: IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    Position pos =
                                        await getUserCurrentLocation();
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (pos != null) {
                                      setState(() {
                                        coordinates =
                                            "${pos.latitude}/${pos.longitude}";
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Successful"),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Try Getting Location again"),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.place_outlined),
                                ),
                              ),
                              const SizedBox(width: 10),
                              isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : const SizedBox(height: 0)
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    : const SizedBox(height: 0),
                const Divider(),
                const SizedBox(height: 10),

                // Ports Information
                Text(
                  "Port Information",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            value: _selectedPort,
                            onChanged: (value) {
                              setState(() {
                                _selectedPort = value.toString();
                              });
                            },
                            items: _inputPorts.map((port) {
                              return DropdownMenuItem(
                                value: port['name'],
                                child: Text(port['name']!),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Select Port',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                          ),
                        ),
                        IconButton(
                          color: Colors.red,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.cancel,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Output Voltage',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                            // Add controller and validation as needed
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Cost in Rupees',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                            // Add controller and validation as needed
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Count',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                            // Add controller and validation as needed
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
