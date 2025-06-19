import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripMap extends StatefulWidget {
  final List<LatLng>? routeCoordinates;
  final bool showInitialPlaceholder;

  const TripMap({
    Key? key,
    this.routeCoordinates,
    this.showInitialPlaceholder = false,
  }) : super(key: key);

  @override
  _TripMapState createState() => _TripMapState();
}

class _TripMapState extends State<TripMap> {
  late GoogleMapController _mapController;
  late Set<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _polylines = {};
  }

  @override
  void didUpdateWidget(TripMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routeCoordinates != oldWidget.routeCoordinates) {
      _updateMapRoute();
    }
  }

  void _updateMapRoute() {
    if (widget.routeCoordinates == null || widget.routeCoordinates!.isEmpty) {
      return;
    }

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('trip_route'),
          points: widget.routeCoordinates!,
          color: Colors.blue,
          width: 5,
        ),
      };
    });

    // Ajustar la cámara para mostrar toda la ruta
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        _boundsFromLatLngList(widget.routeCoordinates!),
        50, // Margen
      ),
    );
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showInitialPlaceholder) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Icon(Icons.map, size: 50, color: Colors.grey),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
        if (widget.routeCoordinates != null) {
          _updateMapRoute();
        }
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(0.0, 0.0),
        zoom: 1,
      ),
      polylines: _polylines,
    );
  }
}