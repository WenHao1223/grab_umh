import 'dart:async';
import 'dart:convert';
import 'dart:math' show min, pi;
import 'package:flutter/services.dart' show rootBundle;
import 'package:grab_umh/src/models/ride_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grab_umh/src/modules/directions_model.dart';
import 'package:grab_umh/src/modules/directions_repository.dart';
import 'package:grab_umh/src/settings/settings_view.dart';
import 'package:grab_umh/src/utils/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = "/";

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  Timer? _timer;
  // Change _progress to be a ValueNotifier
  final ValueNotifier<double> _progress = ValueNotifier(1.0);
  List<RideModel>? _rides;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(5.285153, 100.456238),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    // Add this to ensure Flutter bindings are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRideData();
    });
  }

  Future<void> _loadRideData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/ride.json');

      final List<dynamic> jsonList = json.decode(jsonString);
      _rides = jsonList.map((json) => RideModel.fromJson(json)).toList();

      // Find pending rides
      final pendingRides =
          _rides?.where((ride) => ride.details.status == 'pending').toList();

      if (pendingRides != null && pendingRides.isNotEmpty) {
        // Show ride alert after 5 seconds
        Future.delayed(const Duration(seconds: 2), () {
          // TODO: change based on the intent @mjlee01
          if (mounted) {
            // Check if widget is still mounted
            _showRideAlert(pendingRides.first);
          }
        });
      }
    } catch (e) {
      throw 'Error loading ride data: $e';
    }
  }

  void _showRideAlert(RideModel ride) {
    if (!mounted) return;

    const int timeoutSeconds = 5;
    _progress.value = 1.0;  // Use .value to update ValueNotifier

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        // Update the ValueNotifier directly
        _progress.value = _progress.value - (1.0 / (timeoutSeconds * 10));
        if (_progress.value <= 0) {
          _progress.value = 0;
          timer.cancel();
          Navigator.of(context).pop();
        }
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {  // Rename setState to setDialogState for clarity
            return PopScope(
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Ride Request'),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance: ${ride.details.distance}'),
                    const SizedBox(height: 8),
                    Text('Fare: RM ${ride.details.fare.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    Text('Drop-off: ${ride.locations.drop.name}'),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<double>(
                      valueListenable: _progress,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            GCrabColors.buttonPrimary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: GCrabColors.buttonPrimary),
                            ),
                            onPressed: () {
                              _timer?.cancel();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Skip Ride'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CustomPaint(
                            painter: BorderPainter(
                              progress: _progress.value,
                              color: GCrabColors.darkGrey,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GCrabColors.buttonPrimary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                _timer?.cancel();
                                _rideAccepted(ride);  // Pass the ride data
                                Navigator.of(context).pop();
                              },
                              child: const Text('Accept Ride'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _timer?.cancel();
    });
  }

  void _rideAccepted(RideModel ride) async {
    // Create origin marker from ride start location
    final origin = Marker(
      markerId: const MarkerId('origin'),
      infoWindow: InfoWindow(title: ride.locations.start.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: LatLng(
        ride.locations.start.location.lat,
        ride.locations.start.location.lng,
      ),
    );

    // Create destination marker from ride drop location
    final destination = Marker(
      markerId: const MarkerId('destination'),
      infoWindow: InfoWindow(title: ride.locations.drop.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(
        ride.locations.drop.location.lat,
        ride.locations.drop.location.lng,
      ),
    );

    // Get directions between origin and destination
    final directionsRepo = DirectionsRepository(dio: Dio());
    final directions = await directionsRepo.getDirections(
      origin: origin.position,
      destination: destination.position,
    );

    setState(() {
      _origin = origin;
      _destination = destination;
      _info = directions;
    });

    // Animate camera to show both markers
    if (_googleMapController != null && _info != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_info!.bounds, 100),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GCrab'), actions: [
        TextButton(
          onPressed: () {
            if (_origin != null) {
              _googleMapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              );
            }
          },
          child: const Text('ORIGIN'),
        ),
        TextButton(
          onPressed: () {
            if (_origin != null) {
              _googleMapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              );
            }
          },
          child: const Text('DEST'),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.restorablePushNamed(context, SettingsView.routeName);
          },
        ),
      ]),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _googleMapController = controller;
              });
            },
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: GCrabColors.accent,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((point) => LatLng(point.latitude, point.longitude))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
          ),
          if (_info != null)
            Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: GCrabColors.borderSecondary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GCrabColors.buttonPrimary,
        foregroundColor: GCrabColors.white,
        onPressed: () => _googleMapController
          ?..animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info!.bounds, 100)
                : CameraUpdate.newCameraPosition(_kGooglePlex),
          ),
        child: const Icon(
          Icons.center_focus_strong,
        ),
      ),
    );
  }

  Future<void> _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _destination = null;
        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      final directionsRepo = DirectionsRepository(dio: Dio());
      final directions = await directionsRepo.getDirections(
        origin: _origin!.position,
        destination: pos,
      );
      setState(() {
        _info = directions;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();  // Don't forget to dispose the ValueNotifier
    _googleMapController?.dispose();
    super.dispose();
  }
}

class BorderPainter extends CustomPainter {
  final double progress;  // Keep this as double, not ValueNotifier
  final Color color;

  BorderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const radius = 5.0;

    // Calculate the total length of the border
    final perimeter = (size.width + size.height) * 2;
    final currentLength = perimeter * progress;

    // Start from top-left
    path.moveTo(radius, 0);

    var remainingLength = currentLength;

    // Top line
    if (remainingLength > 0) {
      final lineLength = min(size.width - radius * 2, remainingLength);
      path.lineTo(lineLength + radius, 0);
      remainingLength -= lineLength;
    }

    // Top-right corner
    if (remainingLength > 0) {
      path.arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
        clockwise: true,
      );
      remainingLength -= radius * pi / 2;
    }

    // Right line
    if (remainingLength > 0) {
      final lineLength = min(size.height - radius * 2, remainingLength);
      path.lineTo(size.width, lineLength + radius);
      remainingLength -= lineLength;
    }

    // Bottom-right corner
    if (remainingLength > 0) {
      path.arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
        clockwise: true,
      );
      remainingLength -= radius * pi / 2;
    }

    // Bottom line
    if (remainingLength > 0) {
      final lineLength = min(size.width - radius * 2, remainingLength);
      path.lineTo(size.width - lineLength - radius, size.height);
      remainingLength -= lineLength;
    }

    // Bottom-left corner
    if (remainingLength > 0) {
      path.arcToPoint(
        Offset(0, size.height - radius),
        radius: const Radius.circular(radius),
        clockwise: true,
      );
      remainingLength -= radius * pi / 2;
    }

    // Left line
    if (remainingLength > 0) {
      final lineLength = min(size.height - radius * 2, remainingLength);
      path.lineTo(0, size.height - lineLength - radius);
      remainingLength -= lineLength;
    }

    // Top-left corner
    if (remainingLength > 0) {
      path.arcToPoint(
        Offset(radius, 0),
        radius: const Radius.circular(radius),
        clockwise: true,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
