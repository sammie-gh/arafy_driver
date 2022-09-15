import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fuodz/services/firebase.service.dart';

class GeneralAppService {
  //

//Hnadle background message
  static Future<void> onBackgroundMessageHandler(
    RemoteMessage remoteMessage,
  ) async {
    await Firebase.initializeApp();
    FirebaseService().saveNewNotification(remoteMessage);
    //normal notifications
    FirebaseService().showNotification(remoteMessage);
  }
}
