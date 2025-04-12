import 'dart:async';
import 'dart:convert';
import 'dart:math' show min, pi;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grab_umh/src/models/ride_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grab_umh/src/modules/directions_model.dart';
import 'package:grab_umh/src/modules/directions_repository.dart';
import 'package:grab_umh/src/settings/settings_view.dart';
import 'package:grab_umh/src/stt/speech_transcriber';
import 'package:grab_umh/src/stt/speech_transcriber';
import 'package:grab_umh/src/utils/constants/colors.dart';
import 'package:grab_umh/src/utils/api/intent_classifier_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_tts/flutter_tts.dart'; //tts

import 'package:grab_umh/src/pages/chat/chat.dart';

import 'package:grab_umh/src/pages/chat/chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = "/home";

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final SpeechTranscriber speechTranscriber = SpeechTranscriber();
  String? _recognizedText;

  final SpeechTranscriber speechTranscriber = SpeechTranscriber();
  String? _recognizedText;

  //tts
  final FlutterTts _flutterTts = FlutterTts();

  final String _selectedLanguage = 'English';
  final Map<String, String> _langCodeMap = {
    'English': 'en-US',
    'Malay': 'ms-MY',
    'Chinese': 'zh-CN',
  };

  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  Timer? _timer;
  // Change _progress to be a ValueNotifier
  final ValueNotifier<double> _progress = ValueNotifier(1.0);
  List<RideModel>? _rides;
  final driverResponse = "Yes, I can accept the ride";

  // Add this to store pending rides
  List<RideModel> _pendingRides = [];

  // Add this field to store current user
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Add this field to store current ride details
  RideModel? _currentRide;

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
      final ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('details.status', isEqualTo: 'pending')
          .get();

      _pendingRides = ridesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['rideId'] = doc.id;
        return RideModel.fromJson(data, doc.id);
      }).toList();

      if (_pendingRides.isNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () async {
          if (mounted) {
            // Check if widget is still mounted
            _showRideAlert(_pendingRides.first);
            _speakRideDetails(_pendingRides.first); //tts

            // TODO: change based on the intent @mjlee01
            final detectedIntent = await detectIntent(driverResponse);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Detected intent: $detectedIntent')),
            );
          }
        });
      }
    } catch (e) {
      throw 'Error loading ride data: $e';
    }
  }

  void _showNextRide() {
    if (_pendingRides.isNotEmpty) {
      _pendingRides.removeAt(0);

      // Show next ride if available
      if (_pendingRides.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _showRideAlert(_pendingRides.first);
            _speakRideDetails(_pendingRides.first);
          }
        });
      }
    }
  }

  void _showRideAlert(RideModel ride) {

  if (!mounted) return;

    const int timeoutSeconds = 20; // duration to show pop up
    _progress.value = 1.0; // Use .value to update ValueNotifier

  _timer?.cancel();
  _timer = Timer.periodic(
    const Duration(milliseconds: 100),
    (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

        _progress.value -= (1.0 / (timeoutSeconds * 10));
        if (_progress.value <= 0) {
          _progress.value = 0;
          timer.cancel();
          Navigator.of(context).pop();

          // Add this to show next ride after timeout
          _showNextRide();
        }
      },
    );

    final SpeechTranscriber speech = SpeechTranscriber();
    speech.startListening().then((command) {
      if (!mounted) return;
      final normalized = command?.toLowerCase().trim() ?? "";

      if (normalized.contains('accept')) {
        _timer?.cancel();
        _rideAccepted(ride);
        Navigator.of(context).pop();
      } else if (normalized.contains('skip') || normalized.contains('reject')) {
        _timer?.cancel();
        _speakRideRejected(ride);
        Navigator.of(context).pop();
      }
    }).catchError((e) {
      debugPrint('Speech error: $e');
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: false, // Prevent back button from closing dialog
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
                        speech.stopListening();
                        Navigator.of(context).pop();
                        _showNextRide(); // Add this to show next ride when manually closed
                      },
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pick-up: ${ride.locations.start.name}'),
                    const SizedBox(height: 8),
                    Text('Drop-off: ${ride.locations.drop.name}'),
                    const SizedBox(height: 8),
                    Text('No of pax: ${ride.details.pax}'),
                    const SizedBox(height: 8),
                    Text('Distance: ${ride.details.distance}'),
                    const SizedBox(height: 8),
                    Text('Fare: RM ${ride.details.fare.toStringAsFixed(2)}'),
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
                              speech.stopListening();
                              _speakRideRejected(ride);
                              Navigator.of(context).pop();
                              _showNextRide(); // Add this line to show next ride
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
                                speech.stopListening();
                                _rideAccepted(ride);
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
      speech.stopListening();
    });
  }

  void _rideAccepted(RideModel ride) async {
    try {
      if (_currentUserId == null) {
        throw 'No authenticated user found';
      }

      // First fetch driver details from Firestore
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(_currentUserId)
          .get();

      if (!driverDoc.exists) {
        throw 'Driver profile not found';
      }

      final driverData = driverDoc.data()!;
      final carDetails = driverData['car'] as Map<String, dynamic>;

      // Update Firestore with both driver and car details
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(ride.rideId)
          .update({
        'details.status': 'picking',
        'driverDetails': {
          'id': _currentUserId,
          'name': driverData['name'],
          'phone': driverData['phone'],
          'car': {
            'name': carDetails['name'],
            'color': carDetails['color'],
            'plate': carDetails['plate'],
          },
        },
      });

      // Remove the accepted ride from pending rides
      _pendingRides.removeAt(0);

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
        _currentRide = ride; // Add this line
      });

      // Animate camera to show both markers
      if (_googleMapController != null && _info != null) {
        _googleMapController!.animateCamera(
          CameraUpdate.newLatLngBounds(_info!.bounds, 100),
        );
      }
      _speakRideAccepted(ride);
    } catch (e) {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept ride: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //tts
  Future<void> _speakRideDetails(RideModel ride) async {
    String langCode = _langCodeMap[_selectedLanguage]!;
    await _flutterTts.setLanguage(langCode);
    await _flutterTts.setSpeechRate(0.5);

    String message;

    switch (_selectedLanguage) {
      case 'Malay':
        message =
            "Anda ada permintaan perjalanan baharu. Lokasi pengambilan di ${ride.locations.start.name}, dan perturunan di ${ride.locations.drop.name}. Bilangan penumpang: ${ride.details.pax}. Jarak: ${ride.details.distance}. Harga: ${ride.details.fare.toStringAsFixed(2)}. Adakah anda ingin terima?";
        break;
      case 'Chinese':
        message =
            "您有一个新的订单请求。上车地点是${ride.locations.start.name}，下车地点是${ride.locations.drop.name}。乘客人数：${ride.details.pax}人。距离是${ride.details.distance}。费用是${ride.details.fare.toStringAsFixed(2)}。您要接受吗？";
        break;
      default:
        message =
            "New ride request. To ${ride.locations.drop.name}.${ride.details.distance}. RM ${ride.details.fare.toStringAsFixed(2)}. Do you want to accept?";
    }

    await _flutterTts.speak(message);
  }

  Future<void> _speakRideAccepted(RideModel ride) async {
    String langCode = _langCodeMap[_selectedLanguage]!;
    await _flutterTts.setLanguage(langCode);
    await _flutterTts.setSpeechRate(0.5);

    String message;

    switch (_selectedLanguage) {
      case 'Malay':
        message =
            "Anda telah menerima permintaan perjalanan. Lokasi pengambilan di ${ride.locations.start.name}, dan penurunan di ${ride.locations.drop.name}. Bilangan penumpang: ${ride.details.pax}. Jarak: ${ride.details.distance}. Harga: ${ride.details.fare.toStringAsFixed(2)}.";
        break;
      case 'Chinese':
        message =
            "您已接受新的订单请求。上车地点是${ride.locations.start.name}，下车地点是${ride.locations.drop.name}。乘客人数：${ride.details.pax}人。距离是${ride.details.distance}。费用是${ride.details.fare.toStringAsFixed(2)}。";
        break;
      default:
        message =
            "You have accepted the ride request. Pick-up at ${ride.locations.start.name}, drop-off at ${ride.locations.drop.name}. Number of passengers: ${ride.details.pax}. Distance: ${ride.details.distance}. Fare: ${ride.details.fare.toStringAsFixed(2)}.";
    }

    await _flutterTts.speak(message);
  }

  // Method to speak Ride Rejected details
  Future<void> _speakRideRejected(RideModel ride) async {
    String langCode = _langCodeMap[_selectedLanguage]!;
    await _flutterTts.setLanguage(langCode);
    await _flutterTts.setSpeechRate(0.5);

    String message;

    switch (_selectedLanguage) {
      case 'Malay':
        message =
            "Anda telah menolak permintaan perjalanan ke ${ride.locations.drop.name}.";
        break;
      case 'Chinese':
        message = "您已拒绝新的订单请求。目的地是${ride.locations.drop.name}。";
        break;
      default:
        message =
            "You have rejected the ride request to ${ride.locations.drop.name}.";
    }

    await _flutterTts.speak(message);
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
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          },
        ),
      ]),
      body: Stack(
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
            // onLongPress: _addMarker,
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
          // Add the floating action button here instead of using floatingActionButton property
          Positioned(
            right: 16,
            bottom:
                _info != null ? MediaQuery.of(context).size.height * 0.45 : 16,
            child: FloatingActionButton(
              backgroundColor: GCrabColors.buttonPrimary,
              foregroundColor: GCrabColors.white,
              onPressed: () => _googleMapController?.animateCamera(
                _info != null
                    ? CameraUpdate.newLatLngBounds(_info!.bounds, 100)
                    : CameraUpdate.newCameraPosition(_kGooglePlex),
              ),
              child: const Icon(Icons.center_focus_strong),
            ),
          ),
          // Add the ride details panel when a ride is accepted
          if (_info != null)
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.4,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Location and Fare
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _origin?.infoWindow.title ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'RM ${_currentRide?.details.fare.toStringAsFixed(2) ?? '0.00'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: GCrabColors.buttonPrimary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Drop-off location
                          Text(
                            'To: ${_destination?.infoWindow.title ?? ''}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          // Passenger name
                          Text(
                            'Passenger: ${_currentRide?.passenger.name ?? ''}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          // Payment method
                          Text(
                            'Payment: ${_currentRide?.payment.method ?? ''}'
                                .toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Divider(height: 24),
                          // Driver section
                          Text(
                            'Driver',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Name: ${_currentRide?.driverDetails?.name ?? ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Car: ${_currentRide?.driverDetails?.car.plate ?? ''} '
                            '(${_currentRide?.driverDetails?.car.color ?? ''})',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton.filled(
                                onPressed: () {
                                  // Implement call passenger
                                },
                                icon: const Icon(Icons.phone),
                                style: IconButton.styleFrom(
                                  backgroundColor: GCrabColors.buttonPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              IconButton.filled(
                                onPressed: () {
                                  // Implement chat with passenger
                                },
                                icon: const Icon(Icons.chat),
                                style: IconButton.styleFrom(
                                  backgroundColor: GCrabColors.buttonPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Implement fetched action
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GCrabColors.buttonPrimary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(120, 40),
                                ),
                                child: const Text('Fetched?'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Future<void> _addMarker(LatLng pos) async {
  //   if (_origin == null || (_origin != null && _destination != null)) {
  //     setState(() {
  //       _origin = Marker(
  //         markerId: const MarkerId('origin'),
  //         infoWindow: const InfoWindow(title: 'Origin'),
  //         icon:
  //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //         position: pos,
  //       );
  //       _destination = null;
  //       _info = null;
  //     });
  //   } else {
  //     setState(() {
  //       _destination = Marker(
  //         markerId: const MarkerId('destination'),
  //         infoWindow: const InfoWindow(title: 'Destination'),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         position: pos,
  //       );
  //     });

  //     final directionsRepo = DirectionsRepository(dio: Dio());
  //     final directions = await directionsRepo.getDirections(
  //       origin: _origin!.position,
  //       destination: pos,
  //     );
  //     setState(() {
  //       _info = directions;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose(); // Don't forget to dispose the ValueNotifier
    _googleMapController?.dispose();
    super.dispose();
  }
}

class BorderPainter extends CustomPainter {
  final double progress; // Keep this as double, not ValueNotifier
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
