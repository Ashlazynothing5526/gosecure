// import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:gosecure/db/db_services.dart';
// import 'package:gosecure/model/contactsm.dart';

// class FamilyEmergency extends StatelessWidget {
//   _callNumber(String number) async {
//     await FlutterPhoneDirectCaller.callNumber(number);
//   }

//   familyContact() async {
//     List<TContact> contactList = await DatabaseHelper().getContactList();
//     _callNumber(contactList[0].number);
//   }

//  Future<String> getNumber() async {
//     List<TContact> contactList = await DatabaseHelper().getContactList();
//     if (contactList.isNotEmpty) {
//       return contactList[0].number.toString();
//     } else {
//       return 'No contact available'; // Default message if no contact found
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10.0, bottom: 5),
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: InkWell(
//           onTap: () => familyContact(),
//           child: Container(
//             height: 180,
//             width: MediaQuery.of(context).size.width * 0.7,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color.fromARGB(255, 48, 226, 226),
//                     Color.fromARGB(255, 61, 149, 175),
//                     Color.fromARGB(255, 173, 183, 187),
//                   ],
//                 )),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundColor: Colors.white.withOpacity(0.5),
//                     child: Image.asset('assets/add_pic.png', width: 28,),
//                   ),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'ICE',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: MediaQuery.of(context).size.width * 0.06,
//                           ),
//                         ),
//                         Text(
//                           'Call To Action Family Members',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: MediaQuery.of(context).size.width * 0.045,
//                           ),
//                         ),
//                         Container(
//                           height: 30,
//                           width: 80,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Center(
//                             child: Text(
//                               getNumber(),
//                               style: TextStyle(
//                                 color: Colors.red[300],
//                                 fontWeight: FontWeight.bold,
//                                 fontSize:
//                                     MediaQuery.of(context).size.width * 0.055,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:gosecure/db/db_services.dart';
import 'package:gosecure/model/contactsm.dart'; // Assuming you have a database helper class

class Emergency extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency'),
      ),
      body: Center(
        child: FamilyEmergency(),
      ),
    );
  }
}

class FamilyEmergency extends StatelessWidget {
  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future<String> getNumber() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();
    if (contactList.isNotEmpty) {
      return contactList[0].number.toString();
    } else {
      return 'No contact available'; // Default message if no contact found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () async {
            String number = await getNumber();
            if (number != 'No contact available') {
              await _callNumber(number);
            }
          },
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 48, 226, 226),
                  Color.fromARGB(255, 61, 149, 175),
                  Color.fromARGB(255, 173, 183, 187),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: Image.asset('assets/add_pic.png', width: 28,),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ICE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                          ),
                        ),
                        Text(
                          'Call To Action Family Members',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                          ),
                        ),
                        FutureBuilder<String>(
                          future: getNumber(),
                          builder: (context, snapshot) {
                            return Container(
                              height: 30,
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  snapshot.data ?? '',
                                  style: TextStyle(
                                    color: Colors.red[300],
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.055,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
