import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class testrb extends StatefulWidget {
  const testrb({super.key});

  @override
  State<testrb> createState() => _testrbState();
}

class _testrbState extends State<testrb> {
  late DatabaseReference deRef;
  final _namecontroller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deRef = FirebaseDatabase.instance.ref().child('test');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Realtime Database'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          TextField(
            controller: _namecontroller,
            decoration: InputDecoration(label: Text('name')),
          ),
          ElevatedButton(onPressed: (){
            deRef.push().set(_namecontroller.text);
          }, child: Text('Save')),
          Text(_namecontroller.text == null ? 'No data' : _namecontroller.text)
        ],
      )),
    );
  }
}
