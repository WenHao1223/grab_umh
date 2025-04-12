import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String rideId;
  final RideDetails details;
  final DriverDetails? driverDetails;
  final RideLocations locations;
  final RidePassenger passenger;
  final Payment payment;
  final Rating? rating;
  final Feedback? feedback;

  RideModel({
    required this.rideId,
    required this.details,
    this.driverDetails,
    required this.locations,
    required this.passenger,
    required this.payment,
    this.rating,
    this.feedback,
  });

  factory RideModel.fromJson(Map<String, dynamic> json, String docId) {
    return RideModel(
      rideId: docId,
      details: RideDetails.fromJson(json['details'] ?? {}),
      driverDetails: json['driverDetails'] != null 
          ? DriverDetails.fromJson(json['driverDetails']) 
          : null,
      locations: RideLocations.fromJson(json['locations'] ?? {}),
      passenger: RidePassenger.fromJson(json['passenger'] ?? {}),
      payment: Payment.fromJson(json['payment'] ?? {}),
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
      feedback: json['feedback'] != null ? Feedback.fromJson(json['feedback']) : null,
    );
  }
}

class RideDetails {
  final String distance;
  final Timestamp? dropTime;
  final double fare;
  final Timestamp? fetchTime;
  final Timestamp orderTime;
  final int pax; 
  final String status;

  RideDetails({
    required this.distance,
    this.dropTime,
    required this.fare,
    this.fetchTime,
    required this.orderTime,
    required this.pax,
    required this.status,
  });

  factory RideDetails.fromJson(Map<String, dynamic> json) {
    return RideDetails(
      distance: json['distance'] ?? '',
      dropTime: json['dropTime'],
      fare: (json['fare'] ?? 0).toDouble(),
      fetchTime: json['fetchTime'],
      orderTime: json['orderTime'] ?? Timestamp.now(),
      pax: json['pax'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }
}

class DriverDetails {
  final CarInfo car;
  final String id;
  final String name;
  final String phone;

  DriverDetails({
    required this.car,
    required this.id,
    required this.name,
    required this.phone,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      car: CarInfo.fromJson(json['car'] ?? {}),
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class CarInfo {
  final String color;
  final String name;
  final String plate;

  CarInfo({
    required this.color,
    required this.name,
    required this.plate,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      color: json['color'] ?? '',
      name: json['name'] ?? '',
      plate: json['plate'] ?? '',
    );
  }
}

class RideLocations {
  final LocationInfo start;
  final LocationInfo drop;

  RideLocations({
    required this.start,
    required this.drop,
  });

  factory RideLocations.fromJson(Map<String, dynamic> json) {
    return RideLocations(
      start: LocationInfo.fromJson(json['start'] ?? {}),
      drop: LocationInfo.fromJson(json['drop'] ?? {}),
    );
  }
}

class LocationInfo {
  final Location location;
  final String name;

  LocationInfo({
    required this.location,
    required this.name,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      location: Location.fromJson(json['location'] ?? {}),
      name: json['name'] ?? '',
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class RidePassenger {
  final String id;
  final String name;
  final String phone;

  RidePassenger({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory RidePassenger.fromJson(Map<String, dynamic> json) {
    return RidePassenger(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class Payment {
  final String method;
  final String status;

  Payment({
    required this.method,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: json['method'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class Rating {
  final double? driver;
  final double? passenger;

  Rating({
    this.driver,
    this.passenger,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      driver: json['driver']?.toDouble(),
      passenger: json['passenger']?.toDouble(),
    );
  }
}

class Feedback {
  final String? driver;
  final String? passenger;

  Feedback({
    this.driver,
    this.passenger,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      driver: json['driver'],
      passenger: json['passenger'],
    );
  }
}
