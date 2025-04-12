class Driver {
  final String driverId;
  final String name;
  final String email;
  final String phone;
  final double credit;
  final Car car;
  final double rating;
  final Feedback feedback;
  final int ridesCompleted;
  final String nationality;
  final License license;
  final List<FeedbackComment> feedbackComments;

  Driver({
    required this.driverId,
    required this.name,
    required this.email,
    required this.phone,
    required this.credit,
    required this.car,
    required this.rating,
    required this.feedback,
    required this.ridesCompleted,
    required this.nationality,
    required this.license,
    required this.feedbackComments,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      credit: json['credit'].toDouble(),
      car: Car.fromJson(json['car']),
      rating: json['rating'].toDouble(),
      feedback: Feedback.fromJson(json['feedback']),
      ridesCompleted: json['ridesCompleted'],
      nationality: json['nationality'],
      license: License.fromJson(json['license']),
      feedbackComments: (json['feedbackComments'] as List)
          .map((comment) => FeedbackComment.fromJson(comment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'name': name,
      'email': email,
      'phone': phone,
      'credit': credit,
      'car': car.toJson(),
      'rating': rating,
      'feedback': feedback.toJson(),
      'ridesCompleted': ridesCompleted,
      'nationality': nationality,
      'license': license.toJson(),
      'feedbackComments':
          feedbackComments.map((comment) => comment.toJson()).toList(),
    };
  }
}

class Car {
  final String id;
  final String name;
  final String color;
  final String plate;

  Car({
    required this.id,
    required this.name,
    required this.color,
    required this.plate,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      plate: json['plate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'plate': plate,
    };
  }
}

class Feedback {
  final int positive;
  final int negative;

  Feedback({
    required this.positive,
    required this.negative,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      positive: json['positive'],
      negative: json['negative'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive': positive,
      'negative': negative,
    };
  }
}

class License {
  final String number;
  final String expiryDate;

  License({
    required this.number,
    required this.expiryDate,
  });

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      number: json['number'],
      expiryDate: json['expiryDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'expiryDate': expiryDate,
    };
  }
}

class FeedbackComment {
  final String passengerName;
  final String comment;
  final int rating;

  FeedbackComment({
    required this.passengerName,
    required this.comment,
    required this.rating,
  });

  factory FeedbackComment.fromJson(Map<String, dynamic> json) {
    return FeedbackComment(
      passengerName: json['passengerName'],
      comment: json['comment'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerName': passengerName,
      'comment': comment,
      'rating': rating,
    };
  }
}