import 'dart:async';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:housearch/helpers/dbhelper.dart';
import 'package:housearch/helpers/map_helper.dart';
import 'package:housearch/helpers/map_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:housearch/helpers/scraper_helper.dart';
import 'package:housearch/helpers/window_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _mapController = Completer();

  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  String? _type;

  // DbHelper dbHelper = DbHelper();

  // Database? database;
  final Completer<Database> database = Completer();

  /// Set of displayed markers and cluster markers on the map
  final Set<Marker> _markers = {};

  Marker? locationMarker;

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker>? _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 15;

  /// Current location zoom
  final double _currentLocationZoom = 16;

  /// Search location zoom
  final double _searchLocationZoom = 15;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _houseImageUrl =
      'https://img.icons8.com/external-flaticons-lineal-color-flat-icons/120/000000/external-home-map-and-navigation-flaticons-lineal-color-flat-icons-4.png';

  final String _plotImageUrl =
      "https://img.icons8.com/stickers/120/land-sales.png";

  final String _locationMarkerUrl =
      "https://img.icons8.com/bubbles/128/000000/user-location.png";

  /// Color of the cluster circle
  // final Color _clusterColor = Colors.blue;

  // /// Color of the cluster text
  // final Color _clusterTextColor = Colors.white;

  /// Example marker coordinates
  final List<LatLng> _areaLocations = [
    const LatLng(33.709102063971486, 73.03965837343085),
    const LatLng(33.69105455538911, 73.00542260645706),
    const LatLng(33.68262823588299, 72.99066935642895),
    const LatLng(33.69765844168563, 73.05139146199403),
    const LatLng(33.688303334979, 73.03482613915591),
    const LatLng(33.67701872188129, 73.01508507978231),
    const LatLng(33.6695657370022, 72.9969653736376),
    const LatLng(33.655713949382104, 72.9798533814447),
    const LatLng(33.682976402197326, 73.06464110918758),
    const LatLng(33.66832134576865, 73.04481420386062),
    const LatLng(33.664272830453555, 73.02634193189566),
    const LatLng(33.65540642884579, 73.01076365004144),
    const LatLng(33.643617312979075, 72.99321499192445),
    const LatLng(33.71834721866346, 73.07083065728294),
    const LatLng(33.66026300588132, 73.08283795270738),
    const LatLng(33.62054267138889, 73.14086032375934),
    const LatLng(33.565396263344674, 73.15157145939789),
    const LatLng(33.57369668673771, 73.17313627265185),
    const LatLng(33.53703848103255, 73.1641277184464),
    const LatLng(33.496034328066195, 73.19667549432714),
  ];

  final List<String> _areaNames = [
    "F-8",
    "F-10",
    "F-11",
    "G-8",
    "G-9",
    "G-10",
    "G-11",
    "G-12",
    "H-8",
    "H-9",
    "H-10",
    "H-11",
    "H-12",
    "BLUE AREA",
    "FAIZABAD",
    "GHAURI TOWN",
    "SOAN GARDENS",
    "JINNAH GARDEN",
    "DHA PHASE II",
    "RAWAT"
  ];

  final List<String> _types = ["Houses", "Plots"];

  // final List<String> prices = [
  //   "50000",
  //   "40000",
  //   "55000",
  //   "45000",
  //   "42000",
  //   "35000",
  //   "30000",
  //   "48000",
  //   "60000",
  //   "80000"
  // ];

//   void getAllTableNames() async {
// // you can use your initial name for dbClient
//     var dbClient = await dbHelper.initDb();
//     List<Map> maps = await dbClient.rawQuery('SELECT * FROM houses Limit 10;');
//     List<String> tableNameList = [];
//     if (maps.isNotEmpty) {
//       for (int i = 0; i < maps.length; i++) {
//         try {
//           tableNameList.add(maps[i]['location'].toString());
//         } catch (e) {}
//       }
//     }
//     print(tableNameList.map((e) => e));
//   }

  /// Called when the Google Map widget is created. Updates the map loading state
  /// and inits the markers.
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    customInfoWindowController.googleMapController = controller;
    database.complete(DbHelper.initDb());
    // database.complete(SQLiteApp.getDatabase());
    setState(() {
      _isMapLoading = false;
    });
    // getAllTableNames();
    // _initMarkers();
  }

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];
    final BitmapDescriptor markerImage = await MapHelper.getMarkerImageFromUrl(
        _type == "Houses" ? _houseImageUrl : _plotImageUrl);

    // final BitmapDescriptor markerImage =
    //     await MapHelper.getMarkerImageFromAssets("Icons/home.png");

    // final BitmapDescriptor markerImage
    //     await MapHelper.getMarkerImageFromIcon(Icons.house);

    Database db = await database.future;
    List<Map> maps = await db.rawQuery(
        'SELECT *, COUNT(*) AS entry_count, MIN(int_price) AS min_value, MAX(int_price) AS max_value FROM $_type GROUP BY latitude, longitude;');

    //for (LatLng markerLocation in _markerLocations) {
    // for (var i = 0; i < 10; i++) {
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        markers.add(
          MapMarker(
            // id: _markerLocations.indexOf(markerLocation).toString(),
            id: maps[i]['id'].toString(),
            position: LatLng(maps[i]['latitude'], maps[i]['longitude']),
            price:
                maps[i]['entry_count'] == 1 ? maps[i]['price'].toString() : "",
            minPrice: maps[i]['entry_count'] == 1
                ? ""
                : MapHelper.toWords(maps[i]['min_value']),
            maxPrice: maps[i]['entry_count'] == 1
                ? ""
                : MapHelper.toWords(maps[i]['max_value']),
            area: maps[i]['area'].toString(),
            bedrooms: maps[i]['bedrooms'].toString(),
            bathrooms: maps[i]['bathrooms'].toString(),
            phone: maps[i]['phone'].toString(),
            ownerName: maps[i]['contact_name'].toString(),
            details: maps[i]['details_url'].toString(),
            icon: markerImage,
            onTap: maps[i]['entry_count'] == 1
                ? () {
                    WindowHelper.customInfoWindow(
                      customInfoWindowController,
                      maps[i]['price'].toString(),
                      maps[i]['area'].toString(),
                      maps[i]['bedrooms'].toString(),
                      maps[i]['bathrooms'].toString(),
                      maps[i]['phone'].toString(),
                      maps[i]['contact_name'].toString(),
                      maps[i]['details_url'].toString(),
                      LatLng(maps[i]['latitude'], maps[i]['longitude']),
                    );
                  }
                : () {
                    WindowHelper.clusterInfowindow(
                        customInfoWindowController,
                        MapHelper.toWords(maps[i]['max_value'].toDouble()),
                        MapHelper.toWords(maps[i]['min_value'].toDouble()),
                        LatLng(maps[i]['latitude'], maps[i]['longitude']));
                  },
          ),
        );
      }
    }

    _clusterManager = (await MapHelper.initClusterManager(
      markers,
      markerImage,
      _minClusterZoom,
      _maxClusterZoom,
    ));

    await _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers([double? updatedZoom]) async {
    customInfoWindowController.onCameraMove!();
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
      customInfoWindowController,
      _clusterManager,
      _currentZoom,
      // _clusterColor,
      // _clusterTextColor,
      // 80,
    );

    _markers
      ..clear()
      ..addAll(updatedMarkers);

    if (locationMarker != null) {
      _markers.add(locationMarker!);
    }

    setState(() {
      _areMarkersLoading = false;
    });
  }

  // Future<bool> permissionRequest() async {
  //   final status = await (Permission.location.request());
  //   if (status == PermissionStatus.granted) {
  //     return true;
  //     // setState(() {});
  //   }
  //   return false;
  // }

  Future<Position> _determinePosition() async {
    // Location location = Location();
    // PermissionStatus permission;

    // bool serviceEnabled = await location.serviceEnabled();

    // if (!serviceEnabled) {
    //   serviceEnabled = await location.requestService();
    //   if (!serviceEnabled) {
    //     return Future.error('Location services are disabled');
    //   }
    // }

    // permission = await location.hasPermission();

    // if (permission == PermissionStatus.denied) {
    //   permission = await location.requestPermission();

    //   if (permission == PermissionStatus.denied) {
    //     return Future.error("Location permission denied");
    //   }
    // }

    // if (permission == PermissionStatus.deniedForever) {
    //   return Future.error('Location permissions are permanently denied');
    // }

    // // LocationData position = await location.getLocation();
    // Position position = await Geolocator.getCurrentPosition();
    // print(position);
    // return position;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await Location().requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled');
      }
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Future<void> animateCamera(LatLng target, double zoom) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  // scheduletask() async {
  //   //schedule repeated corn job every 1 minute
  //   cron.schedule(Schedule.parse('* * * * *'), () async {
  //     SQLiteApp.downloadDatabase();
  //     setState(() {});
  //   });
  // }

  // @override
  // void initState() async {

  //   super.initState();
  // }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Housearch'),
        actions: [
          Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: const Text(
                  "Select Area",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                items: _areaNames
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  animateCamera(
                      _areaLocations[_areaNames.indexOf(selectedValue!)],
                      _searchLocationZoom);
                },
                iconStyleData: const IconStyleData(
                  iconEnabledColor: Colors.white,
                ),
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.only(right: 10),
                  height: 40,
                  width: 120,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // isOverButton: true,
                  maxHeight: 200,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: selectedValue ?? "Search Area...",
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value.toString().contains(searchValue);
                  },
                ),
                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),
          Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: const Text(
                  "Select Type",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                items: _types
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                value: _type,
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                  _initMarkers();
                },
                iconStyleData: const IconStyleData(
                  iconEnabledColor: Colors.white,
                ),
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.only(right: 10),
                  height: 40,
                  width: 120,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Google Map widget
          // Opacity(
          //   // opacity: _isMapLoading ? 0 : 1,
          //   opacity: 1,
          //   child:
          GoogleMap(
            mapToolbarEnabled: false,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: const LatLng(33.6844, 73.0479),
              zoom: _currentZoom,
            ),
            markers: _markers,
            onMapCreated: (controller) => _onMapCreated(controller),
            onCameraMove: (position) => _updateMarkers(position.zoom),
            onTap: (position) => customInfoWindowController.hideInfoWindow!(),
          ),
          // ),

          CustomInfoWindow(
            controller: customInfoWindowController,
            height: 202,
            width: 302,
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () async {
                  Position position = await _determinePosition();
                  animateCamera(LatLng(position.latitude, position.longitude),
                      _currentLocationZoom);
                  final BitmapDescriptor locationImage =
                      await MapHelper.getMarkerImageFromUrl(_locationMarkerUrl);
                  locationMarker = Marker(
                    markerId: const MarkerId("currentLocation"),
                    position: LatLng(position.latitude, position.longitude),
                    icon: locationImage,
                  );
                  _markers.add(locationMarker!);
                  setState(() {});
                  // markers.add(MapMarker(
                  //     id: 'currentLocation',
                  //     position: LatLng(position.latitude, position.longitude),
                  //     price: "My Location"));
                  // _initMarkers();
                },
                child: const Icon(Icons.my_location),
              ),
            ),
          ),

          // Map loading indicator
          if (_isMapLoading) const Center(child: CircularProgressIndicator()),

          // Map markers loading indicator
          if (_areMarkersLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  elevation: 2,
                  color: Colors.blue.withOpacity(0.9),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Loading',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

          // No property type is selected
          if (_type == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  elevation: 2,
                  color: Colors.blue.withOpacity(0.9),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Select property type',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
