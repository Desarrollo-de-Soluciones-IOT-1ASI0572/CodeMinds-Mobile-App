import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/home_driver_screen.dart';
import '../../shared/notification_screen.dart';
import '../../profiles/presentation/account_screen.dart';
import '../infrastructure/data_sources/trip_provider.dart';

class MapScreen extends StatefulWidget {
  final int selectedIndex;
  const MapScreen({super.key, this.selectedIndex = 1});

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
  Timer? _refreshTimer;
  bool _autoRefresh = false;
  BitmapDescriptor? _vehicleIcon;
  LatLng? _currentVehiclePosition;
  double? _currentSpeed;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadCustomMarker();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tripProvider = Provider.of<TripProvider>(context);
    _loadRoute();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomMarker() async {
    _vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/bus_marker_2.png', // Replace with your asset
    );
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);

    final driverId = _tripProvider.getCurrentTrip(1)?.driverId ?? 1;
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

      _originLatLng = LatLng(originLocations.first.latitude, originLocations.first.longitude);
      _destinationLatLng = LatLng(destinationLocations.first.latitude, destinationLocations.first.longitude);

      _updateMarkers();
      await _fetchRoute();
      await _updateVehicleLocation();

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

  Future<void> _updateVehicleLocation() async {
    try {
      if (_originLatLng != null && _destinationLatLng != null) {
        final driverId = _tripProvider.getCurrentTrip(1)?.driverId ?? 1;
        if (_tripProvider.isTripStarted(driverId)) {
          setState(() {
            _currentVehiclePosition = LatLng(
              _originLatLng!.latitude + (_destinationLatLng!.latitude - _originLatLng!.latitude) * 0.3,
              _originLatLng!.longitude + (_destinationLatLng!.longitude - _originLatLng!.longitude) * 0.3,
            );
            _currentSpeed = 45.0;
          });
          _updateMarkers();
        }
      }
    } catch (e) {
      debugPrint('Error updating vehicle location: $e');
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_originLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: _originLatLng!,
        infoWindow: const InfoWindow(title: 'Origen'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (_destinationLatLng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLatLng!,
        infoWindow: const InfoWindow(title: 'Destino'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    if (_currentVehiclePosition != null && _vehicleIcon != null) {
      _markers.add(Marker(
        markerId: const MarkerId('vehicle'),
        position: _currentVehiclePosition!,
        infoWindow: InfoWindow(
          title: 'Vehículo',
          snippet: 'Velocidad: ${_currentSpeed?.toStringAsFixed(1) ?? '--'} km/h',
        ),
        icon: _vehicleIcon!,
        rotation: 45.0,
      ));
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
      if (_autoRefresh) {
        _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          _updateVehicleLocation();
        });
      } else {
        _refreshTimer?.cancel();
      }
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Emergencia'),
        content: const Text('¿Estás seguro de que deseas activar la alerta de emergencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alerta de emergencia activada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      // Already on map screen
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
        title: const Text('Mapa del Viaje'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoute,
            tooltip: 'Actualizar ruta',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
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
                  mapToolbarEnabled: false,
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

          // Info Section
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
                    // Trip Information
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.flag,
                            'Origen',
                            _originText,
                            colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.flag_circle,
                            'Destino',
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
                            'Estado',
                            _status,
                            _status == 'En camino' ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.speed,
                            'Distancia',
                            _distance,
                            colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    // Controls
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Actualización automática'),
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
                            label: const Text('Emergencia'),
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