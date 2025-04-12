class RideModel {
  final String rideId;
  final RideDetails details;
  final RideLocations locations;
  final Passenger passenger;

  RideModel({
    required this.rideId,
    required this.details,
    required this.locations,
    required this.passenger,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['rideId'],
      details: RideDetails.fromJson(json['details']),
      locations: RideLocations.fromJson(json['locations']),
      passenger: Passenger.fromJson(json['passenger']),
    );
  }
}

class RideDetails {
  final String distance;
  final double fare;
  final int pax;
  final String status;
  final String orderTime;

  RideDetails({
    required this.distance,
    required this.fare,
    required this.pax,
    required this.status,
    required this.orderTime,
  });

  factory RideDetails.fromJson(Map<String, dynamic> json) {
    return RideDetails(
      distance: json['distance'],
      fare: json['fare'].toDouble(),
      pax: json['pax'],
      status: json['status'],
      orderTime: json['orderTime'],
    );
  }
}

class RideLocations {
  final LocationInfo drop;

  RideLocations({required this.drop});

  factory RideLocations.fromJson(Map<String, dynamic> json) {
    return RideLocations(
      drop: LocationInfo.fromJson(json['drop']),
    );
  }
}

class LocationInfo {
  final String name;

  LocationInfo({required this.name});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'],
    );
  }
}

class Passenger {
  final String id;
  final String name;

  Passenger({required this.id, required this.name});

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      name: json['name'],
    );
  }
}