import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'displayuserdb.dart';

class realtimedb extends StatefulWidget {
  const realtimedb({super.key});

  @override
  State<realtimedb> createState() => _realtimedbState();
}

class _realtimedbState extends State<realtimedb> {
  final nameController = TextEditingController();
  final lnameController = TextEditingController();
  final EmailController = TextEditingController();
  late DatabaseReference dbRef;
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child("contact");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(label: Text('firstname')),
          ),
          TextField(
            controller: lnameController,
            decoration: InputDecoration(label: Text('lastname')),
          ),
          TextField(
            controller: EmailController,
            decoration: InputDecoration(label: Text('email')),
          ),
          ElevatedButton(
              onPressed: () {
                Map<String, dynamic> contact = {
                  'fname': nameController.text,
                  'lname': lnameController.text,
                  'email': EmailController.text,
                };
                dbRef.push().set(contact);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Displaydb()));
              },
              child: Text('save')),
        ],
      ),
    ));
  }
}
