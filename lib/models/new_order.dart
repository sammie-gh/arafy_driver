import 'dart:convert';

import 'package:fuodz/constants/app_strings.dart';

NewOrder newOrderFromJson(String str) => NewOrder.fromJson(json.decode(str));

String newOrderToJson(NewOrder data) => json.encode(data.toJson());

class NewOrder {
  NewOrder({
    this.amount,
    this.total,
    this.dropoff,
    this.id,
    this.pickup,
    this.range,
    this.distance,
    this.earthDistance,
    this.vendorId,
    this.isParcel,
    this.packageType,
    this.expiresAt,
  });

  String amount;
  String total;
  Dropoff dropoff;
  int id;
  Pickup pickup;
  double range;
  double distance;
  double orderDistance;
  double earthDistance;
  int vendorId;
  bool isParcel;
  String packageType;
  int expiresAt;

  factory NewOrder.fromJson(Map<String, dynamic> json, {bool clean = false}) =>
      NewOrder(
        amount: json["amount"] == null ? "" : json["amount"],
        total: json["total"] == null ? null : json["total"],
        earthDistance: json["earth_distance"] == null
            ? 0
            : double.parse(json["earth_distance"].toString()),
        dropoff: json["dropoff"] == null
            ? null
            : Dropoff.fromJson(
                clean ? json["dropoff"] : jsonDecode(json["dropoff"])),
        id: json["id"] == null ? null : int.parse(json["id"].toString()),
        pickup: json["pickup"] == null
            ? null
            : Pickup.fromJson(
                clean ? json["pickup"] : jsonDecode(json["pickup"])),
        range: json["range"] == null
            ? null
            : double.parse(json["range"].toString()),
        vendorId: json["vendor_id"] == null
            ? null
            : int.parse(json["vendor_id"].toString()),
        isParcel: json["is_parcel"] == null
            ? false
            : clean
                ? json["is_parcel"]
                : (bool.fromEnvironment(json["is_parcel"]) ?? false),
        packageType: json["package_type"],
        expiresAt: json["expiresAt"] != null
            ? json["expiresAt"]
            : DateTime.now().millisecondsSinceEpoch + (AppStrings.alertDuration * 1000),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount == null ? null : amount,
        "total": total,
        "earth_distance": earthDistance,
        "dropoff": dropoff == null ? null : dropoff.toJson(),
        "id": id == null ? null : id,
        "pickup": pickup == null ? null : pickup.toJson(),
        "range": range == null ? null : range,
        "vendor_id": vendorId == null ? null : vendorId,
        "is_parcel": isParcel,
        "package_type": packageType,
        "expiresAt": expiresAt,
      };

  //
  int get initialAlertDuration {
    int duration = 0;
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final timePast = expiresAt - now;
      print("expiresAt ==> $expiresAt");
      print("now ==> $now");
      print("timePast ==> $timePast");
      if (timePast > 0) {
        duration = AppStrings.alertDuration - (timePast ~/ 1000);
      } else {
        duration = AppStrings.alertDuration - 1;
      }
    }
    return duration;
  }
}

class Dropoff {
  Dropoff({
    this.address,
    this.distance,
    this.country,
    this.state,
    this.city,
    this.lat,
    this.long,
  });

  String address;
  String city;
  String country;
  String state;
  double lat;
  double long;
  double distance;

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
        distance: json["distance"] == null
            ? 0.00
            : double.parse(
                json["distance"].toString().replaceAll(",", ""),
              ),
        address: json["address"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        lat: json["lat"] == null ? null : double.parse(json["lat"].toString()),
        long:
            json["long"] == null ? null : double.parse(json["long"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "distance": distance ?? 0.00,
        "country": country,
        "city": city,
        "state": state,
        "lat": lat == null ? null : lat,
        "long": long == null ? null : long,
      };
}

class Pickup {
  Pickup({
    this.address,
    this.distance,
    this.city,
    this.state,
    this.country,
    this.lat,
    this.long,
  });

  String address;
  String city;
  String state;
  String country;
  double lat;
  double long;
  double distance;

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
        address: json["address"] == null ? null : json["address"],
        distance: json["distance"] == null
            ? 0.00
            : double.parse(
                json["distance"].toString().replaceAll(",", ""),
              ),
        city: json["city"],
        state: json["state"],
        country: json["country"],
        lat: json["lat"] == null ? null : double.parse(json["lat"].toString()),
        long: json["long"] == null
            ? json["lng"] == null
                ? null
                : double.parse(json["lng"].toString())
            : double.parse(json["long"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "distance": distance ?? 0.00,
        "country": country,
        "state": state,
        "city": city,
        "lat": lat,
        "long": long,
      };
}
