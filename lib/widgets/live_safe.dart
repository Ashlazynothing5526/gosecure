import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_widgets/live_safe/BusStationCard.dart';
import 'home_widgets/live_safe/HospitalCard.dart';
import 'home_widgets/live_safe/PharmacyCard.dart';
import 'home_widgets/live_safe/PoliceStationCard.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({Key? key}) : super(key: key);

  static Future<void> openMap(String location) async {
    final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');

    try {
      // Always try to launch directly
      final bool launched = await launchUrl(
        googleUrl,
        mode: LaunchMode.externalApplication, // ensures opening Google Maps app/browser
      );
      if (!launched) {
        Fluttertoast.showToast(msg: 'Could not open Google Maps');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong! Please call emergency number.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceStationCard(onMapFunction: openMap),
          HospitalCard(onMapFunction: openMap),
          PharmacyCard(onMapFunction: openMap),
          BusStationCard(onMapFunction: openMap),
        ],
      ),
    );
  }
}
