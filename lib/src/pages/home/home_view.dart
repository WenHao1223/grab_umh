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

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(5.285153, 100.456238),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _googleMapController = controller;
          });
        },
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

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }
}
