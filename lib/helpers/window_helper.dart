import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WindowHelper {
  static void customInfoWindow(
      CustomInfoWindowController controller,
      String price,
      String area,
      String bedrooms,
      String bathrooms,
      String phone,
      String ownerName,
      String details,
      LatLng position) {
    controller.addInfoWindow!(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.house,
                            color: Colors.cyan.shade400,
                          ),
                          Expanded(
                            child: Text(
                              area,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sell,
                            color: Colors.amber,
                          ),
                          Expanded(
                            child: Text(
                              price,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bedroom_parent,
                            color: Colors.pink.shade300,
                          ),
                          Expanded(
                            child: Text(
                              bedrooms,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bathroom,
                            color: Colors.green.shade300,
                          ),
                          Expanded(
                            child: Text(
                              bathrooms,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          Expanded(
                            child: Text(
                              ownerName,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.red.shade400,
                          ),
                          Expanded(
                            child: Text(
                              phone,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: InkWell(
                    child: const Text(
                      "More Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () => launchUrlString(details),
                  ),
                ),
              ),
            ],
          ),
        ),
        position);
  }

  static void clusterInfowindow(CustomInfoWindowController controller,
      String maximum, String minimum, LatLng position) {
    controller.addInfoWindow!(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: Colors.black),
            color: Colors.white70,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Maximum Price: ",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              Text(
                maximum,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              Text(
                "Minimum Price: ",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade400),
              ),
              Text(
                minimum,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade400),
              ),
            ],
          ),
        ),
        position);
  }
}
