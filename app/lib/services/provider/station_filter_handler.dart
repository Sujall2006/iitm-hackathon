import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StationFilters extends ChangeNotifier {
  List slots = []; // inputList
  String portType = "";
  String? city = "";
  String? state = "";
  bool isFilterActive = false;
  double latitude = 0.0;
  double longitude = 0.0;

  // final output for all filter reflects here !!
  List<Widget> widgets = [
    const Center(
      child: SpinKitCubeGrid(color: Colors.blue),
    ),
  ];

  void setSlots(String exp) {
    slots.add(exp);
  }

  void removeSlot(String exp) {
    slots.remove(exp);
  }

  void removeAllSlots() {
    slots.clear();
  }

  // set coordinates
  void setCoordinates(double lat, double long) {
    latitude = lat;
    longitude = long;
  }

  // set port
  void setPortType(String port) {
    portType = port;
  }

  // set state
  void setState(String? currState) {
    state = currState;
  }

  // set city
  void setCity(String? currCity) {
    city = currCity;
  }

  // set filter status
  void setIsFilterActive(bool isActive) {
    isFilterActive = isActive;
    notifyListeners();
  }
}
