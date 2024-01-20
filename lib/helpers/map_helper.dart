import 'dart:async';
import 'dart:math';
import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:fluster/fluster.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:housearch/helpers/map_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:housearch/helpers/window_helper.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  ///
  /// You can resize the marker image by providing a [targetWidth].
  static Future<BitmapDescriptor> getMarkerImageFromUrl(
    String url,
    // { int? targetWidth,}
  ) async {
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    // if (targetWidth != null) {
    //   markerImageBytes = await _resizeImageBytes(
    //     markerImageBytes,
    //     targetWidth,
    //   );
    // }

    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  // static Future<BitmapDescriptor> getMarkerImageFromAssets(String path) async {
  //   ByteData data = await rootBundle.load(path);
  //   Codec codec = await instantiateImageCodec(data.buffer.asUint8List());
  //   FrameInfo frameInfo = await codec.getNextFrame();
  //   Uint8List array =
  //       (await frameInfo.image.toByteData(format: ImageByteFormat.png))!
  //           .buffer
  //           .asUint8List();
  //   return BitmapDescriptor.fromBytes(array);
  // }

  // static Future<BitmapDescriptor> getMarkerImageFromIcon(IconData icon) async {
  //   final iconData = icon;
  //   final pictureRecorder = PictureRecorder();
  //   final canvas = Canvas(pictureRecorder);
  //   final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   final iconStr = String.fromCharCode(iconData.codePoint);
  //   textPainter.text = TextSpan(
  //       text: iconStr,
  //       style: TextStyle(
  //         letterSpacing: 0.0,
  //         fontSize: 48.0,
  //         fontFamily: iconData.fontFamily,
  //         color: Colors.red,
  //       ));
  //   textPainter.layout();
  //   textPainter.paint(canvas, const Offset(0.0, 0.0));
  //   final picture = pictureRecorder.endRecording();
  //   final image = await picture.toImage(48, 48);
  //   final bytes = await image.toByteData(format: ImageByteFormat.png);
  //   final bitmapDescriptor =
  //       BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  //   return bitmapDescriptor;
  // }

  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.
  // static Future<BitmapDescriptor> _getClusterMarker(
  //   int clusterSize,
  //   Color clusterColor,
  //   Color textColor,
  //   int width,
  // ) async {
  //   final PictureRecorder pictureRecorder = PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color = clusterColor;
  //   final TextPainter textPainter = TextPainter(
  //     textDirection: TextDirection.ltr,
  //   );

  //   final double radius = width / 2;

  //   canvas.drawCircle(
  //     Offset(radius, radius),
  //     radius,
  //     paint,
  //   );

  //   textPainter.text = TextSpan(
  //     text: clusterSize.toString(),
  //     style: TextStyle(
  //       fontSize: radius - 5,
  //       fontWeight: FontWeight.bold,
  //       color: textColor,
  //     ),
  //   );

  //   textPainter.layout();
  //   textPainter.paint(
  //     canvas,
  //     Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
  //   );

  //   final image = await pictureRecorder.endRecording().toImage(
  //         radius.toInt() * 2,
  //         radius.toInt() * 2,
  //       );
  //   final data = await image.toByteData(format: ImageByteFormat.png);

  //   return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  // }

  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.
  // static Future<Uint8List> _resizeImageBytes(
  //   Uint8List imageBytes,
  //   int targetWidth,
  // ) async {
  //   final Codec imageCodec = await instantiateImageCodec(
  //     imageBytes,
  //     targetWidth: targetWidth,
  //   );

  //   final FrameInfo frameInfo = await imageCodec.getNextFrame();

  //   final data = await frameInfo.image.toByteData(format: ImageByteFormat.png);

  //   return data!.buffer.asUint8List();
  // }

  static double toDouble(String price) {
    double d = double.parse(price.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (price.contains("Thousand")) {
      d *= 1000;
    }
    if (price.contains("Lakh")) {
      d *= 100000;
    }
    if (price.contains("Crore")) {
      d *= 10000000;
    }
    if (price.contains("Arab")) {
      d *= 1000000000;
    }
    return d.roundToDouble();
  }

  static String toWords(double price) {
    String s = "";
    int length = price.toString().length;
    if (length < 8) {
      s = "${price / 1000} Thousand";
    }
    if (length == 8 || length == 9) {
      s = "${price / 100000} Lakh";
    }
    if (length == 10 || length == 11) {
      s = "${price / 10000000} Crore";
    }
    if (length >= 12) {
      s = "${price / 1000000000} Arab";
    }
    return s;
  }

  static List<double> children = [];
  static void childrens(Fluster<MapMarker> clusterManager, MapMarker marker) {
    List<MapMarker>? childs = clusterManager.children(marker.clusterId);
    if (childs != null) {
      for (MapMarker child in childs) {
        if (child.isCluster!) {
          childrens(clusterManager, child);
        } else {
          if (child.price.isNotEmpty) {
            children.add(toDouble(child.price));
          } else {
            children
                .addAll([toDouble(child.minPrice), toDouble(child.maxPrice)]);
          }
        }
      }
    }
  }

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    BitmapDescriptor markerImage,
    int minZoom,
    int maxZoom,
  ) async {
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 128,
      points: markers,
      createCluster: (
        BaseCluster? cluster,
        double? lng,
        double? lat,
      ) =>
          MapMarker(
        id: cluster!.id.toString(),
        position: LatLng(lat!, lng!),
        icon: markerImage,
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static Future<List<Marker>> getClusterMarkers(
    CustomInfoWindowController customInfoWindowController,
    Fluster<MapMarker>? clusterManager,
    double currentZoom,
    // Color clusterColor,
    // Color clusterTextColor,
    // int clusterWidth,
  ) {
    if (clusterManager == null) return Future.value([]);

    return Future.wait(clusterManager.clusters(
      [-180, -85, 180, 85],
      currentZoom.toInt(),
    ).map((mapMarker) async {
      // if (mapMarker.isCluster!) {
      //   mapMarker.icon = await _getClusterMarker(
      //     mapMarker.pointsSize!,
      //     clusterColor,
      //     clusterTextColor,
      //     clusterWidth,
      //   );
      // }

      if (mapMarker.isCluster!) {
        // List<MapMarker> temp = [mapMarker];
        // List<MapMarker> c = [];
        // for (var o in temp) {
        //   var h = clusterManager.children(o.clusterId);
        //   if (h != null) {
        //     for (var p in h) {
        //       if (p.isCluster!) {
        //         temp.add(p);
        //       } else {
        //         c.add(p);
        //       }
        //     }
        //   }
        // }
        childrens(clusterManager, mapMarker);
        // for (MapMarker child in children) {
        //   mapMarker.title += " + ${child.title}";
        // }
        // mapMarker.price =
        //     "Max: ${children.reduce(max)} Min: ${children.reduce(min)}";
        String maximum =
            children.isEmpty ? "Analyzing..." : toWords(children.reduce(max));
        String minimum =
            children.isEmpty ? "Analyzing..." : toWords(children.reduce(min));
        mapMarker.onTap = () => WindowHelper.clusterInfowindow(
            customInfoWindowController, maximum, minimum, mapMarker.position);
        children.clear();
      }
      return mapMarker.toMarker();
    }).toList());
  }
}
