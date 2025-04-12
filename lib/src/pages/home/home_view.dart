import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      ]),
      body: GoogleMap(
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
        onLongPress: _addMarker,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GCrabColors.buttonPrimary,
        foregroundColor: GCrabColors.white,
        onPressed: () => _googleMapController
          ?..animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex)),
        child: const Icon(
          Icons.center_focus_strong,
        ),
      ),
    );
  }

  void _addMarker(LatLng pos) {
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
    }
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }
}
