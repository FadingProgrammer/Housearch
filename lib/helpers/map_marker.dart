import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// [Fluster] can only handle markers that conform to the [Clusterable] abstract class.
///
/// You can customize this class by adding more parameters that might be needed for
/// your use case. For instance, you can pass an onTap callback or add an
/// [InfoWindow] to your marker here, then you can use the [toMarker] method to convert
/// this to a proper [Marker] that the [GoogleMap] can read.
class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final String area;
  final String bedrooms;
  final String bathrooms;
  final String phone;
  final String ownerName;
  final String price;
  final String minPrice;
  final String maxPrice;
  final String details;
  BitmapDescriptor? icon;
  void Function()? onTap;

  MapMarker({
    required this.id,
    required this.position,
    this.price = "",
    this.minPrice = "",
    this.maxPrice = "",
    this.area = "",
    this.bedrooms = "",
    this.bathrooms = "",
    this.phone = "",
    this.ownerName = "",
    this.details = "",
    this.icon,
    this.onTap,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  Marker toMarker() => Marker(
        markerId: MarkerId(isCluster! ? 'cl_$id' : id),
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        icon: icon!,
        onTap: onTap,
        // infoWindow: InfoWindow(
        //   title: price,
        // ),
      );
}
