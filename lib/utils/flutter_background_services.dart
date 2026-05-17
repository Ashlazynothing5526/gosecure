import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:another_telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import 'package:gosecure/db/db_services.dart';
import 'package:gosecure/model/contactsm.dart';

sendMessage(String messageBody) async {
  List<TContact> contactList = await DatabaseHelper().getContactList();
  if (contactList.isEmpty) {
    Fluttertoast.showToast(msg: "No number exist please add a number");
  } else {
    for (var i = 0; i < contactList.length; i++) {
      Telephony.backgroundInstance
          .sendSms(to: contactList[i].number, message: messageBody)
          .then((value) {
        Fluttertoast.showToast(msg: "Message sent");
      }).catchError((e) {
        Fluttertoast.showToast(msg: "Failed to send message: $e");
      });
    }
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "GoSecure",
    "Foreground service",
    importance: Importance.high,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: "GoSecure",
        initialNotificationTitle: "Foreground service",
        initialNotificationContent: "Initializing",
        foregroundServiceNotificationId: 888,
      ));
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  DateTime lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);
  Position? _currentPosition;

  ShakeDetector.autoStart(
    shakeThresholdGravity: 3.2,
    shakeSlopTimeMS: 800,
    shakeCountResetTime: 4000,
    minimumShakeCount: 4,
    onPhoneShake: (ShakeEvent event) {
      unawaited(() async {
        final now = DateTime.now();
        if (now.difference(lastShakeTime).inSeconds < 15) {
          print("Shake ignored due to cooldown");
          return;
        }
        lastShakeTime = now;

        print("Shake detected");
        if (_currentPosition != null) {
          String messageBody =
              "Help!!\nI am in Trouble https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}";
          if (await Vibration.hasVibrator() ?? false) {
            if (await Vibration.hasCustomVibrationsSupport() ?? false) {
              Vibration.vibrate(duration: 1000);
            } else {
              Vibration.vibrate();
              await Future.delayed(const Duration(milliseconds: 1000));
              Vibration.vibrate();
            }
          }
          await Future.delayed(const Duration(milliseconds: 1000));
          sendMessage(messageBody);
        } else {
          Fluttertoast.showToast(msg: "Location not available yet");
        }
      }());
    },
  );

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
                forceAndroidLocationManager: true)
            .then((Position position) {
          _currentPosition = position;
          print("bg location ${position.latitude}");
        }).catchError((e) {
          Fluttertoast.showToast(msg: e.toString());
        });

        await flutterLocalNotificationsPlugin.show(
          id: 888,
          title: "GoSecure",
          body: "Shake feature enabled",
          notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                  "GoSecure", "Foreground service",
                  icon: 'ic_bg_service_small',
                  onlyAlertOnce: true)),
          payload: "shake",
        );
      }
    }
  });
}
