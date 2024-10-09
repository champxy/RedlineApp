import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class testcount extends StatefulWidget {
  const testcount({super.key});

  @override
  State<testcount> createState() => _testcountState();
}

class _testcountState extends State<testcount> {

  Future<void> _startsevice() async {
    final service = FlutterBackgroundService();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Count'),
      ),
    );
  }
}