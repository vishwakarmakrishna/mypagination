import 'dart:convert';

PassengerModel passengerModelFromJson(String str) =>
    PassengerModel.fromJson(json.decode(str));

String passengerModelToJson(PassengerModel data) => json.encode(data.toJson());

class PassengerModel {
  PassengerModel({
    required this.totalPassengers,
    required this.totalPages,
    required this.data,
  });

  final int totalPassengers;
  final int totalPages;
  final List<Passenger> data;

  factory PassengerModel.fromJson(Map<String, dynamic> json) => PassengerModel(
        totalPassengers: json["totalPassengers"],
        totalPages: json["totalPages"],
        data: List<Passenger>.from(
            json["data"].map((x) => Passenger.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalPassengers": totalPassengers,
        "totalPages": totalPages,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Passenger {
  Passenger({
    required this.id,
    required this.name,
    required this.trips,
    required this.airline,
    required this.v,
  });

  final String id;
  final String name;
  final int trips;
  final List<Airline> airline;
  final int v;

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        id: json["_id"],
        name: json["name"],
        trips: json["trips"],
        airline:
            List<Airline>.from(json["airline"].map((x) => Airline.fromJson(x))),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "trips": trips,
        "airline": List<dynamic>.from(airline.map((x) => x.toJson())),
        "__v": v,
      };
}

class Airline {
  Airline({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.slogan,
    required this.headQuaters,
    required this.website,
    required this.established,
  });

  final int id;
  final String name;
  final String country;
  final String logo;
  final String slogan;
  final String headQuaters;
  final String website;
  final String established;

  factory Airline.fromJson(Map<String, dynamic> json) => Airline(
        id: json["id"],
        name: json["name"],
        country: json["country"],
        logo: json["logo"],
        slogan: json["slogan"],
        headQuaters: json["head_quaters"],
        website: json["website"],
        established: json["established"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country": country,
        "logo": logo,
        "slogan": slogan,
        "head_quaters": headQuaters,
        "website": website,
        "established": established,
      };
}
