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

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(5.285153, 100.456238),
    zoom: 14.4746,
  );

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
    _googleMapController?.dispose();
    super.dispose();
  }
}
