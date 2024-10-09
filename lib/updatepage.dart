import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'displayuserdb.dart';

class editpage extends StatefulWidget {
  const editpage({super.key,required Map this.data});
  final Map data;
  @override
  State<editpage> createState() => _editpageState();
}

class _editpageState extends State<editpage> {
  final nameController = TextEditingController();
  final lnameController = TextEditingController();
  final EmailController = TextEditingController();
  late DatabaseReference dbRef;
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child("contact");
    getdata();
  }

  void getdata(){
    nameController.text = widget.data['fname'];
    lnameController.text = widget.data['lname'];
    EmailController.text = widget.data['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(label: Text('name')),
          ),
          TextField(
            controller: lnameController,
            decoration: InputDecoration(label: Text('Lastname')),
          ),
          TextField(
            controller: EmailController,
            decoration: InputDecoration(label: Text('Email')),
          ),
          ElevatedButton(
              onPressed: () {
                Map<String, dynamic> contact = {
                  'fname': nameController.text,
                  'lname': lnameController.text,
                  'email': EmailController.text,
                };
                dbRef.child(widget.data['key']).update(contact);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Displaydb()));
              },
              child: Text('Update')),
        ],
      ),
    ));
  }
}
