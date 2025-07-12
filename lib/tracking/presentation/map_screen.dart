import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/home_driver_screen.dart';
import '../../notifications/presentation/notification_screen.dart';
import '../../profiles/presentation/account_screen.dart';
import '../application/services/trip_service.dart';
import '../infrastructure/data_sources/trip_provider.dart';

class MapScreen extends StatefulWidget {
  final int driverId;
  final int selectedIndex;
  const MapScreen({super.key, required this.driverId, this.selectedIndex = 1});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _originLatLng;
  LatLng? _destinationLatLng;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  late TripProvider _tripProvider;
  String _status = 'No iniciado';
  String _originText = '';
  String _destinationText = '';
  String _distance = '-- km';
  int _selectedIndex = 1;
  Timer? _locationUpdateTimer;
  bool _autoRefresh = false;
  BitmapDescriptor? _vehicleIcon;
  LatLng? _currentVehiclePosition;
  LatLng? _previousVehiclePosition;
  double? _currentSpeed;
  double _currentBearing = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadCustomMarker();
    _startLocationUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tripProvider = Provider.of<TripProvider>(context);
    _loadRoute();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadCustomMarker() async {
    try {
      _vehicleIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/bus_marker_2.png',
      );
      debugPrint('✅ Vehicle icon loaded successfully');
    } catch (e) {
      debugPrint('❌ Failed to load vehicle icon: $e');
    }
  }


  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);

    final driverId = widget.driverId;
    final trip = _tripProvider.getCurrentTrip(driverId);

    _originText = trip?.originAddress ?? '';
    _destinationText = trip?.destinationAddress ?? '';
    _status = _tripProvider.isTripStarted(driverId) ? 'En camino' : 'Pendiente';

    if (_originText.isEmpty || _destinationText.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final originLocations = await locationFromAddress(_originText);
      final destinationLocations = await locationFromAddress(_destinationText);

      _originLatLng = LatLng(
        originLocations.first.latitude,
        originLocations.first.longitude,
      );
      _destinationLatLng = LatLng(
        destinationLocations.first.latitude,
        destinationLocations.first.longitude,
      );

      _updateMarkers();
      await _fetchRoute();
      await _fetchVehicleLocation();

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _calculateBounds(),
          100,
        ),
      );
    } catch (e) {
      debugPrint('Error loading route: $e');
    }

    setState(() => _isLoading = false);
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: _autoRefresh ? 3 : 10),
          (_) => _fetchVehicleLocation(),
    );
  }

  Future<void> _fetchVehicleLocation() async {
    try {
      final tripId = _tripProvider.getCurrentTripId(widget.driverId);
      debugPrint('📌 Trip ID: $tripId');
      final isStarted = _tripProvider.isTripStarted(widget.driverId);
      debugPrint('🚦 Is trip started? $isStarted');

      if (tripId == null || !isStarted) {
        debugPrint('⚠️ Trip ID null or trip not started. Aborting location fetch.');
        return;
      }

      final locations = await TripService().getTripLocations(tripId);
      debugPrint('📍 Fetched Locations: $locations');

      if (locations.isNotEmpty) {
        final latestLocation = locations.last;
        debugPrint('✅ Latest Location -> lat: ${latestLocation.latitude}, lng: ${latestLocation.longitude}, speed: ${latestLocation.speed}');

        setState(() {
          _previousVehiclePosition = _currentVehiclePosition;
          _currentVehiclePosition = LatLng(
            latestLocation.latitude,
            latestLocation.longitude,
          );
          _currentSpeed = latestLocation.speed ?? 0.0;

          if (_previousVehiclePosition != null) {
            _currentBearing = _calculateBearing(
              _previousVehiclePosition!,
              _currentVehiclePosition!,
            );
          }
          debugPrint('🧭 New Bearing: $_currentBearing');
        });

        _updateMarkers();
      } else {
        debugPrint('⚠️ No locations returned for trip.');
      }
    } catch (e) {
      debugPrint('❌ Error fetching vehicle location: $e');
    }
  }


  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lon1 = from.longitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final lon2 = to.longitude * math.pi / 180;

    final y = math.sin(lon2 - lon1) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  LatLngBounds _calculateBounds() {
    final positions = <LatLng>[
      if (_originLatLng != null) _originLatLng!,
      if (_destinationLatLng != null) _destinationLatLng!,
      if (_currentVehiclePosition != null) _currentVehiclePosition!,
    ];

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final position in positions) {
      minLat = position.latitude < minLat ? position.latitude : minLat;
      maxLat = position.latitude > maxLat ? position.latitude : maxLat;
      minLng = position.longitude < minLng ? position.longitude : minLng;
      maxLng = position.longitude > maxLng ? position.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _updateMarkers() {
    _markers.clear();

    if (_originLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: _originLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (_destinationLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    if (_currentVehiclePosition != null) {
      debugPrint('🚗 Adding vehicle marker at $_currentVehiclePosition, speed: $_currentSpeed, bearing: $_currentBearing');

      _markers.add(Marker(
        markerId: const MarkerId('vehicle'),
        position: _currentVehiclePosition!,
        infoWindow: InfoWindow(
          title: 'Vehículo',
          snippet: _currentSpeed != null
              ? 'Velocidad: ${_currentSpeed!.toStringAsFixed(1)} km/h'
              : 'Velocidad: -- km/h',
        ),
        icon: _vehicleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: _currentBearing.isNaN ? 0 : _currentBearing,
      ));
    } else {
      debugPrint('⚠️ No vehicle position to show.');
    }
  }


  Future<void> _fetchRoute() async {
    if (_originLatLng == null || _destinationLatLng == null) return;

    const String apiKey = 'AIzaSyB2DorxXIhbGywM8B6YYf5PDkfNToa-wIE';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_originLatLng!.latitude},${_originLatLng!.longitude}'
        '&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        final meters = data['routes'][0]['legs'][0]['distance']['value'];
        _distance = '${(meters / 1000).toStringAsFixed(2)} km';

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 4,
          ));
        });
      }
    } catch (e) {
      debugPrint('Directions API error: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
      _startLocationUpdates();
    });
  }

  void _showEmergencyDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Activate Emergency?"),
        content: const Text("This will notify authorities and parents immediately and end the trip. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    final tripId = _tripProvider.getCurrentTripId(widget.driverId);
    if (tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active trip found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      HapticFeedback.heavyImpact();
      final success = await TripService().activateEmergency(tripId);

      if (success) {
        // ✅ También termina el viaje localmente:
        _tripProvider.endTrip(widget.driverId);
        _tripProvider.resetTrip(widget.driverId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 Alerta de emergencia activada. Trip terminado.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al activar emergencia'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNavTap(int index) async {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        final prefs = await SharedPreferences.getInstance();
        final userName = prefs.getString('user_name') ?? "Default Name";
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeDriverScreen(name: userName, selectedIndex: 0)),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountScreen(selectedIndex: 3)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Map'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoute,
            tooltip: 'Update Route',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _originLatLng ?? const LatLng(0, 0),
                    zoom: 13.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  compassEnabled: true,
                ),
                if (!_isLoading)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'btn1',
                          mini: true,
                          onPressed: () {
                            if (_currentVehiclePosition != null) {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(_currentVehiclePosition!, 16),
                              );
                            }
                          },
                          child: const Icon(Icons.gps_fixed),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'btn2',
                          mini: true,
                          onPressed: () {
                            if (_originLatLng != null && _destinationLatLng != null) {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
                              );
                            }
                          },
                          child: const Icon(Icons.zoom_out_map),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.flag,
                            'Origin',
                            _originText,
                            colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.flag_circle,
                            'Destination',
                            _destinationText,
                            colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            _status == 'En camino' ? Icons.directions_car : Icons.access_time,
                            'Status',
                            _status,
                            _status == 'En camino' ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.speed,
                            'Distance',
                            _distance,
                            colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Auto Update'),
                            value: _autoRefresh,
                            onChanged: (value) => _toggleAutoRefresh(),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showEmergencyDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.warning),
                            label: const Text('Emergency'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : '--',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}