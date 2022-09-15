import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:georange/georange.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class LocationService {
  //
  static GeoRange georange = GeoRange();
  static Location location = new Location();
  static DeliveryAddress currentLocation;
  static bool serviceEnabled;
  static FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  static BehaviorSubject<bool> locationDataAvailable =
      BehaviorSubject<bool>.seeded(false);
  static BehaviorSubject<double> driverLocationEarthDistance =
      BehaviorSubject<double>.seeded(0.00);
  static int lastUpdated = 0;

  //
  static Future<void> prepareLocationListener() async {
    _startLocationListner();
  }

 

  static void _startLocationListner() async {
    //
    //update location every 100meters
    await location.changeSettings(
      distanceFilter: AppStrings.distanceCoverLocationUpdate,
      interval: AppStrings.timePassLocationUpdate,
    );
    //listen
    location.onLocationChanged.listen((LocationData mCurrentLocation) async {
      print("Location changed ==> $mCurrentLocation");
      // Use current location
      if (currentLocation == null) {
        currentLocation = DeliveryAddress();
        locationDataAvailable.add(true);
      }

      currentLocation.latitude = mCurrentLocation.latitude;
      currentLocation.longitude = mCurrentLocation.longitude;
      //
      syncLocationWithFirebase(mCurrentLocation);
      //
    }, onError: (error) {
      print("Location listen error => $error");
    });
  }

  //
  static syncLocationWithFirebase(LocationData currentLocation) async {
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    //
    if (AppService().driverIsOnline) {
      print("Send to fcm");
      //get distance to earth center
      Point driverLocation = Point(
        latitude: currentLocation.latitude ?? 0.00,
        longitude: currentLocation.longitude ?? 0.00,
      );
      Point earthCenterLocation = Point(
        latitude: 0.00,
        longitude: 0.00,
      );
      //
      var earthDistance =
          georange.distance(earthCenterLocation, driverLocation);

      //
      final driverLocationDocs =
          await firebaseFireStore.collection("drivers").doc(driverId).get();

      //
      final docRef = driverLocationDocs.reference;

      if (driverLocationDocs.data() == null) {
        docRef.set(
          {
            "id": driverId,
            "lat": currentLocation.latitude,
            "long": currentLocation.longitude,
            "rotation": currentLocation.heading,
            "earth_distance": earthDistance,
            "range": AppStrings.driverSearchRadius,
          },
        );
      } else {
        docRef.update(
          {
            "id": driverId,
            "lat": currentLocation.latitude,
            "long": currentLocation.longitude,
            "rotation": currentLocation.heading,
            "earth_distance": earthDistance,
            "range": AppStrings.driverSearchRadius,
          },
        );
      }

      driverLocationEarthDistance.add(earthDistance);
      lastUpdated = DateTime.now().millisecondsSinceEpoch;
    }
  }

  //
  static clearLocationFromFirebase() async {
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    await firebaseFireStore.collection("drivers").doc(driverId).delete();
  }
}
