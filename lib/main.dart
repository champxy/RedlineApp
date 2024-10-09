import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goog/displayuserdb.dart';
import 'package:goog/model/testrd.dart';
import 'package:goog/redlineXd.dart';
import 'package:goog/testcount.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'map.dart';
import 'map_search.dart';
import 'realtimedb.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ขออนุญาต permission สำหรับการแจ้งเตือน
  await _requestNotificationPermission();

  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // แสดงหน้าต่างแอปพลิเคชัน
  // await initializeService();
  runApp(const MyApp());
}

Future<void> _requestNotificationPermission() async {
  var noffstatus = await Permission.notification.status;
    if(noffstatus != PermissionStatus.granted) { //here
      var status = await Permission.notification.request();

      if(status != PermissionStatus.granted) {  //here
        await openAppSettings();
      }
    }
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
      // home: Displaydb(),
    );
  }
}

  