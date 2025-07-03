import 'package:codeminds_mobile_application/features/tracking/domain/location.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_service.dart';
import 'package:codeminds_mobile_application/features/tracking/domain/trip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'trip_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastTripsScreen extends StatefulWidget {
  const PastTripsScreen({super.key});

  @override
  _PastTripsScreenState createState() => _PastTripsScreenState();
}

class _PastTripsScreenState extends State<PastTripsScreen> {
  late final TripService _tripService;
  late final Map<int, List<Location>> _tripLocationsCache;
  List<Trip> _trips = [];
  int _currentPage = 1;
  final int _itemsPerPage = 6;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tripService = TripService();
    _tripLocationsCache = {};
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final tripDTOs = await _tripService.getCompletedTripsByDriver(userId!);

      setState(() {
        _trips = tripDTOs.map((dto) => dto.toTrip()).toList().reversed.take(_itemsPerPage).toList();
        _hasMore = tripDTOs.length > _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error loading trips: ${e.toString()}');
    }
  }

  Future<void> _loadMoreTrips() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final tripDTOs = await _tripService.getCompletedTripsByDriver(userId!);
      final newTrips = tripDTOs
          .map((dto) => dto.toTrip())
          .toList()
          .reversed
          .skip(_itemsPerPage * _currentPage)
          .take(_itemsPerPage)
          .toList();

      setState(() {
        _trips.addAll(newTrips);
        _currentPage++;
        _hasMore = newTrips.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error loading more trips: ${e.toString()}');
    }
  }

  String _calculateAverageDuration(List<Trip> trips) {
    if (trips.isEmpty) return '0 mins';

    final totalDuration = trips.fold(
      Duration.zero,
          (sum, trip) => sum + trip.endTime.difference(trip.startTime),
    );

    final averageInMinutes = totalDuration.inMinutes ~/ trips.length;

    if (averageInMinutes < 60) return '$averageInMinutes mins';

    final hours = averageInMinutes ~/ 60;
    final minutes = averageInMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text('Past Trips'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildStatisticsCard(theme),
              const SizedBox(height: 16),

              // Trip List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Your Trips',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // List of trips
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadTrips,
                  child: ListView.separated(
                    itemCount: _trips.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _trips.length) {
                        return _buildLoadMoreButton();
                      }
                      final trip = _trips[index];
                      final formattedDate = DateFormat('MMM d, y').format(trip.startTime);
                      return _buildTripCard(trip, formattedDate, index, theme);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Total Trips',
                  '${_trips.length}',
                  Icons.directions_car,
                  theme,
                ),
                _buildStatItem(
                  'Avg Duration',
                  _calculateAverageDuration(_trips),
                  Icons.timer,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripCard(Trip trip, String formattedDate, int index, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTripInfoDialog(context, trip),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Map thumbnail
              Hero(
                tag: 'trip-map-${trip.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.primaryContainer,
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Trip information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip ${trip.id}",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.origin,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        const Text('Edit Name'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _editTripName(trip, index);
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, trip);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'No more trips to load',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : TextButton(
          onPressed: _loadMoreTrips,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Load More Trips'),
        ),
      ),
    );
  }

  void _editTripName(Trip trip, int index) {
    final TextEditingController _titleController =
    TextEditingController(text: "Trip ${trip.id}");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Trip Name'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Trip Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save logic here
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTripInfoDialog(BuildContext context, Trip trip) async {
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat('MMMM d, y');
    final locations = await _getTripLocations(trip.id);
    final routeCoordinates = _convertLocationsToLatLng(locations);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'trip-map-${trip.id}',
                      child: SizedBox(
                        height: 200,
                        child: TripMap(
                          routeCoordinates: routeCoordinates,
                          showFullMap: true,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        dateFormat.format(trip.startTime),
                      ),
                      _buildDetailRow(
                        Icons.timer,
                        'Duration',
                        '${trip.endTime.difference(trip.startTime).inMinutes} mins',
                      ),
                      _buildDetailRow(
                        Icons.flag,
                        'Start',
                        '${timeFormat.format(trip.startTime)} • ${trip.origin}',
                      ),
                      _buildDetailRow(
                        Icons.flag_circle,
                        'End',
                        '${timeFormat.format(trip.endTime)} • ${trip.destination}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip?'),
          content: const Text(
              "This action cannot be undone. The trip data will be permanently deleted."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await _tripService.deleteTrip(trip.id);
                if (success) {
                  _showSuccessSnackbar('Trip deleted successfully');
                  setState(() {
                    _tripLocationsCache.remove(trip.id);
                    _trips.remove(trip);
                  });
                } else {
                  _showErrorSnackbar('Failed to delete trip');
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<List<Location>> _getTripLocations(int tripId) async {
    if (_tripLocationsCache.containsKey(tripId)) {
      return _tripLocationsCache[tripId]!;
    }

    final locations = await _tripService.getTripLocations(tripId);
    _tripLocationsCache[tripId] = locations;
    return locations;
  }

  List<LatLng> _convertLocationsToLatLng(List<Location> locations) {
    return locations.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();
  }
}