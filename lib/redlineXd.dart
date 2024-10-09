import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:goog/displayuserdb.dart';
import 'package:goog/home.dart';
import 'package:goog/map_search.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'map.dart';
import 'model/mmap.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:background_location/background_location.dart';

bool isServiceRunning = false;
String openMap = '';
void countNumbers(SendPort sendPort) {
  int count = 0;
  Timer.periodic(Duration(seconds: 1), (timer) {
    count++;
    sendPort.send(count);
  });
}

class redliadXD extends StatefulWidget {
  const redliadXD({Key? key}) : super(key: key);

  @override
  State<redliadXD> createState() => _redliadXDState();
}

class _redliadXDState extends State<redliadXD>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final map = GlobalKey<LongdoMapState>();
  // Query refquery = FirebaseDatabase.instance.ref().child("contact");
  // DatabaseReference refdelete =
  //     FirebaseDatabase.instance.ref().child("contact");

  List<Map<String, dynamic>> pointmarkpolyline1 = [];
  List<Map<String, dynamic>> pointmarkpolyline2 = [];
  List<Map<String, dynamic>> pathways1 = [];
  List<Map<String, dynamic>> pathways2 = [];
  List<Map<String, dynamic>> station = [];
  List<Map<String, dynamic>> yourpathway1 = [];
  List<Map<String, dynamic>> yourpathway2 = [];
  List<Map<String, dynamic>> namepathway1 = [];
  List<Map<String, dynamic>> namepathway2 = [];
  List<Map<String, dynamic>> successyourway = [];
  List<Map<String, dynamic>> Bike = [];
  List<Map<String, dynamic>> Bus = [];
  List<Map<String, dynamic>> Taxi = [];
  List<Map<String, dynamic>> Van = [];
  List<Map<String, dynamic>> Omnibus = [];
  List<Map<String, dynamic>> Train = [];
  List<Map<String, dynamic>> BTS = [];
  List<Map<String, dynamic>> MRT = [];
  List<Map<String, dynamic>> successfac = [];
  List<Map<String, dynamic>> commentList = [];
  List<Map<String, dynamic>> timetableList = [];
  var Landmarkdata = [];
  late StreamSubscription<Position> positionStream;
  var namestationfirst = '';
  var namestationlast = '';
  var street = '';
  dynamic exitdoor;
  dynamic indoor;
  dynamic mycategory = '';
  String lat = "";
  String lon = "";
  double alt = 0;
  double distance = 0;
  Object? mark;
  Object? markme;
  bool isLoading = false;
  bool isopenMap = false;
  bool isIconVisible = false;
  bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;
  bool isExpanded4 = false;
  bool isBikeDataVisible = false;
  bool isBusDataVisible = false;
  bool isTaxiDataVisible = false;
  bool isVanDataVisible = false;
  bool isOmnibusVisible = false;
  bool isTrainVisible = false;
  bool isBTSVisible = false;
  bool isMRTVisible = false;
  bool futureCompleted = false;
  bool changeoutpathway = false;
  bool startengine = false;
  bool checkend = false;
  bool success_station = false;
  bool checknearstation = false;
  bool checkconfirmgo = false;
  bool checkbeforelatlon = false;
  bool checkcompletearrviefirststation = false;
  bool checkcompletearrvielaststation = false;
  bool checkmyselfadd = false;
  bool checkuploaddataway = false;
  bool isButtonstart = true;
  bool endcheck = false;
  bool endcheck2 = false;
  bool endcheck3 = false;
  bool textFieldReadOnly = false;
  bool checknearstation2 = false;
  Map<int, bool> isLikedMap = {};
  var dataSearch = [];
  var ttimetext = '';
  TextEditingController _messageController = TextEditingController();
  List<String> beforelatlon = ["", ""];
  Map mylocation = {'start': [], 'end': []};
  var startname = {'start': '', 'end': ''};
  Map<String, double> nearfirststation = {};
  Map<String, double> nearlaststation = {};
  List<Map<String, dynamic>> locationtofirststation = [];
  List<Map<String, double>> itsme = [];
  List<Map<String, double>> nearstation2 = [];
  String? dropdownValue;
  String? dropdownValuelandmark;
  List<String> dropdownItems = [];
  String selectedVehicle = ''; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<List> _successyourwayController =
      StreamController<List>.broadcast();
  int _seconds = 0;
  late Timer _timer;
  late Isolate _isolate;
  late ReceivePort _receivePort;
  String? _selectedStation;
  String _selecx = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    timetable();
    // _determinePosition();
    _requestLocationPermission();
    // startTimer();
    // FlutterBackgroundService().invoke('setAsBackground');
    requestLocationPermission();
    backgroundLocationPermission();
    BackgroundLocation.isServiceRunning().then((value) {
      print('Service running: $value');
    });
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Permission granted');
      backgroundLocation();
    } else if (status.isDenied) {
      await Permission.location.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isRestricted) {
      print('Permission restricted');
    }
  }

  Future<void> backgroundLocationPermission() async {
    var status = await Permission.locationAlways.request();
    if (status.isGranted) {
      print('Permission granted');
      backgroundLocation();
    } else if (status.isDenied) {
      await Permission.locationAlways.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isRestricted) {
      print('Permission restricted');
    }
  }

  Future<void> backgroundLocation() async {
    print('Background location');
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BackgroundLocation.startLocationService(distanceFilter: 0.0);
    // await BackgroundLocation.getLocationUpdates((location) {
    //   print('show location now');
    //   print('Location: ${location.latitude}, ${location.longitude}');

    // });
  }

  @override
  void dispose() {
    _successyourwayController.close();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        print('Seconds: $_seconds');
      });
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> checktimetogo(
      double flon, double flat, double tlon, double tlat) async {
    int totalDistance = 0; // Initialize totalDistance
    int totalTime = 0; // Initialize totalTime

// จตุจักร 13.8040926,100.5422681
// หลักสี่ 13.883801510787217, 100.5806980861036
    try {
      const apikey = "fdd00a0426fcf1019f3b442d5d8ed7dc";
      final url = Uri.parse(
          'https://api.longdo.com/RouteService/json/route/guide?flon=$flon&flat=$flat&tlon=$tlon&tlat=$tlat&mode=t&type=25&locale=th&key=$apikey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        dataSearch = jsonData['data'];
        setState(() {
          dataSearch = dataSearch;
        });
        for (var segment in dataSearch[0]['guide']) {
          totalTime += segment['interval'].toInt() as int;
        }
        print(totalTime);
        int hours = totalTime ~/ 3600; // Calculate hours
        int minutes = (totalTime % 3600) ~/ 60; // Calculate minutes

        String totalTimeText;

        if (hours > 0) {
          totalTimeText = '$hours ชั่วโมง $minutes นาทีโดยประมาณ';
          ttimetext = totalTimeText;
        } else {
          totalTimeText = '$minutes นาทีโดยประมาณ';
          ttimetext = totalTimeText;
        }
        print(totalTimeText);
        setState(() {
          ttimetext = totalTimeText;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> sendcomment(
      String message, dynamic door, dynamic category, dynamic user) async {
    setState(() {
      isLoading = true; // เริ่มต้นโหลดข้อมูล
    });
    print('sendcomment');
    print('message $message');
    print('door $door');
    print('category $category');
    print('user $user');
    DateTime now = DateTime.now();
    String formattedDateTime = now.toString().substring(0, 19);
    if (user != null) {
      if (category != '') {
        DatabaseReference commentRef =
            FirebaseDatabase.instance.ref('Comment/$category/$door');
        await commentRef.push().set({
          'user': user,
          'message': message,
          'time': formattedDateTime,
        });
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          isLoading = false; // โหลดข้อมูลเสร็จสิ้น
        });
        getcomment(door, category);

        _messageController.clear();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Text(
                      "ส่งข้อความสำเร็จ",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontFamily: 'custom_font',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    top: -100,
                    child: Image.asset(
                      "assets/redtrain.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print('category is empty');
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Text(
                    "กรุณาเข้าสู่ระบบก่อนส่งข้อความ",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontFamily: 'custom_font',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: -100,
                  child: Image.asset(
                    "assets/redtrain.png",
                    width: 150,
                    height: 150,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> getcomment(dynamic door, dynamic category) async {
    commentList = [];
    print('getcomment');
    print('door $door');
    print('category $category');
    DatabaseReference commentRef =
        FirebaseDatabase.instance.ref('Comment/$category/$door');
    try {
      DatabaseEvent event = await commentRef.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> comments =
            snapshot.value as Map<dynamic, dynamic>;
        commentList = [];
        comments.forEach((commentKey, commentData) {
          List<dynamic>?
              wholike; // Declare wholike variable outside the forEach block
          if (commentData is Map) {
            var commentDetails = commentData['message'];
            var user = commentData['user'];
            var time = commentData['time'];
            var likes = commentData['likes'];
            wholike = commentData['wholike'] as List<dynamic>?;
            int love = 0; // Assign value to wholike variable
            print('wholike $wholike');
            if (wholike != null) {
              love = wholike.length;
            }
            print('ค่ากดไลก์ ${love}');
            if (commentDetails is String) {
              print("Comment $commentKey: Message: $commentDetails");
              bool userLiked = checkUserLikedComment(wholike, user);
              commentList.add({
                "message": commentDetails,
                "user": user,
                "time": time,
                "likes": love,
                "userLiked": userLiked,
              });
            } else {
              print("Comment $commentKey does not have a valid 'message' list");
            }
          }
        });
        print("Comment data: $commentList");
        setState(() {
          commentList = commentList;
        });
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

// ฟังก์ชันใหม่เพื่อเช็คว่า user ได้กด like ใน comment นั้นๆ หรือไม่
  bool checkUserLikedComment(List<dynamic>? wholike, dynamic user) {
    if (wholike != null && wholike.contains(user)) {
      return true;
    }
    return false;
  }

  Future<void> updatelikecomment(
      int index, dynamic door, dynamic category, dynamic user) async {
    print('updatelikecomment');
    print('door $door');
    print('category $category');
    print('index $index');

    int count = 0;
    DatabaseReference finddatacomment =
        FirebaseDatabase.instance.ref('Comment/$category/$door');
    try {
      DatabaseEvent event = await finddatacomment.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic>? comments = snapshot.value
            as Map<dynamic, dynamic>?; // Convert to Map<dynamic, dynamic>
        if (comments != null) {
          comments.forEach((commentKey, commentData) async {
            if (count == index) {
              print('commentKey $commentKey');
              print('commentData $commentData');
              var likes = (commentData['likes'] ?? 0) as int; // Convert to int
              print('likes $likes');
              DatabaseReference commentRef = FirebaseDatabase.instance
                  .ref('Comment/$category/$door/$commentKey');
              try {
                DatabaseEvent event = await commentRef.once();
                final snapshot = event.snapshot;
                if (snapshot.exists) {
                  print('realdata: ${snapshot.value}');
                  var data = snapshot.value as Map<dynamic,
                      dynamic>; // Convert to Map<dynamic, dynamic>
                  var wholike = (data['wholike'] ?? [])
                      as List<dynamic>?; // Convert to List<dynamic>?
                  if (wholike != null && !wholike.contains(user)) {
                    wholike = List.from(wholike)
                      ..add(
                          user); // Add the element to List and create a new List
                    commentRef.update({
                      // Increase likes by 1
                      'wholike': wholike,
                    });
                    getcomment(door, category);
                  } else {
                    print('User has already liked this comment');
                  }
                } else {
                  print('No data available');
                }
              } catch (e) {
                print('An error occurred: $e');
              }
              // getcomment(door, category);
            }
            count++;
          });
        }
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> removedlikecomment(
      int index, dynamic door, dynamic category, dynamic user) async {
    print('removedlikecomment');
    print('door $door');
    print('category $category');
    print('index $index');

    int count = 0;
    DatabaseReference finddatacomment =
        FirebaseDatabase.instance.ref('Comment/$category/$door');
    try {
      DatabaseEvent event = await finddatacomment.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic>? comments = snapshot.value
            as Map<dynamic, dynamic>?; // Convert to Map<dynamic, dynamic>
        if (comments != null) {
          comments.forEach((commentKey, commentData) {
            if (count == index) {
              print('commentKey $commentKey');
              print('commentData $commentData');
              List<dynamic>? wholike = (commentData['wholike'] ?? [])
                  as List<dynamic>?; // Convert to List<dynamic>?
              if (wholike != null && wholike.contains(user)) {
                var likes =
                    (commentData['likes'] ?? 0) as int; // Convert to int
                print('likes $likes');
                DatabaseReference commentRef = FirebaseDatabase.instance
                    .ref('Comment/$category/$door/$commentKey');
                if (wholike.contains(user)) {
                  wholike = List.from(wholike)
                    ..remove(
                        user); // Remove the element from List and create a new List
                }
                commentRef.update({
                  // Ensure likes is not negative
                  'wholike': wholike,
                });
                getcomment(door, category);
              } else {
                print('User has not liked this comment');
              }
            }
            count++;
          });
        }
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> showpeoplelike(int index, dynamic door, dynamic category) async {
    print('showpeoplelike');
    print('door $door');
    print('category $category');
    print('index $index');

    int count = 0;
    DatabaseReference finddatacomment =
        FirebaseDatabase.instance.ref('Comment/$category/$door');
    try {
      DatabaseEvent event = await finddatacomment.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic>? comments = snapshot.value
            as Map<dynamic, dynamic>?; // Convert to Map<dynamic, dynamic>
        if (comments != null) {
          comments.forEach((commentKey, commentData) {
            if (count == index) {
              print('commentKey $commentKey');
              print('commentData $commentData');
              List<dynamic>? wholike =
                  (commentData['wholike']) as List<dynamic>?;
              print('wholike $wholike');
              if (wholike != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                              width: double.infinity,
                              height: 500,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                              child: Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    //icon
                                    Image.asset(
                                      "assets/thumbs-up.png",
                                      width: 100,
                                    ),
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 218, 218, 218),
                                        ),
                                      ),
                                      child: ListView.builder(
                                        itemCount: wholike.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ListTile(
                                              title: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  wholike[index],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'custom_font',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          Positioned(
                            top: -100,
                            child: Image.asset(
                              "assets/redtrain.png",
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                print('No one has liked this comment');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: Text(
                              "ไม่มีคนไลค์โพสต์นี้",
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.black,
                                fontFamily: 'custom_font',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: -100,
                            child: Image.asset(
                              "assets/redtrain.png",
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }
            count++;
          });
        }
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> _shownotifition(String message) async {
    print('แจ้งดิ');
    const String channelId = 'TheRedline';
    const String channelName = 'TheRedline';
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'TheRedline',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'train', // This is where you specify the icon
      color: Color.fromARGB(255, 194, 3, 3),
    );

    const NotificationDetails platformChannelDetals = NotificationDetails(
      android: androidNotificationDetails,
    );

    await FlutterLocalNotificationsPlugin().show(
      0,
      'TheRedline',
      '${message}',
      platformChannelDetals,
    );
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      // ขออนุญาตสำเร็จ
      _startLocationUpdates();
    } else {
      // ไม่ได้รับอนุญาต, คุณสามารถจัดการการไม่ได้รับอนุญาตที่นี่
    }
  }

  void _startLocationUpdates() async {
    print('startLocationUpdates');
    // positionStream = Geolocator.getPositionStream().listen((Position position) {
    //   if (mounted) {
    //     setState(() {
    //       lat = position.latitude.toString();
    //       lon = position.longitude.toString();
    //       alt = position.altitude.toDouble();
    //     });
    //     // checkyoursef(position.latitude, position.longitude);
    //     checkstart(position.latitude, position.longitude, position.altitude);
    //   }
    // });
    await BackgroundLocation.getLocationUpdates((position) async {
      // รอการหน่วงเวลาด้วย async/await
      await Future.delayed(Duration(seconds: 3));
      print('Location: ${position.latitude}, ${position.longitude}');
      if (mounted) {
        setState(() {
          lat = position.latitude!.toString();
          lon = position.longitude!.toString();
          alt = position.altitude!.toDouble();
        });
        checkstart(position.latitude, position.longitude, position.altitude);
      }
    });
  }

  void checkstart(lat, lon, alt) {
    Timer(Duration(seconds: 10), () {
      if (checkconfirmgo == true) {
        add_mark(lat, lon, alt);
        print('checkstart go ' + checkconfirmgo.toString());
      } else {
        print('checkstart go ' + checkconfirmgo.toString());
      }
    });
  }

  void add_mark(lat, lon, alt) async {
    print('hi');
    var markme = map.currentState?.LongdoObject(
      "Marker",
      args: [
        {
          "lon": lon,
          "lat": lat,
        },
      ],
    );
    if (markme != null) {
      // map.currentState?.call("location", args: [
      //   {
      //     "lon": lon,
      //     "lat": lat,
      //   }
      // ]);
      if (successyourway.isEmpty && endcheck2 == false) {
        setState(() {
          endcheck = true;
          endcheck2 = true;
        });
        print("หมดการเดินทาง");
        print("endcheck = $endcheck");
        print("endcheck2 = $endcheck2");
        print(successyourway);
      }
      if (endcheck == true && checkend == false) {
        print("นำทางไปปลายทางที่มาร์ค");
        _shownotifition('สิ้นสุดการเดินทาง ขอให้เดินทางปลอดภัยจาก TheRedline');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Text(
                      "การเดินทางในสถานีของคุณได้สิ้นสุดลงแล้ว \n ทางเราจะมีเส้นทางให้คุณไปถึงปลายทางที่คุณมาร์กไว้ \n ถ้าคุณไม่ต้องการ สามารถกดเครื่องหมายสีเขียวเพื่อเสร็จสิ้นการเดินทางได้เลย",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontFamily: 'custom_font',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    top: -100,
                    child: Image.asset(
                      "assets/redtrain.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              ),
            );
          },
        );
        var start = Longdo.LongdoObject(
          "Marker",
          args: [
            {
              "lon": nearlaststation['lon']!,
              "lat": nearlaststation['lat']!,
            },
          ],
        );
        var end = Longdo.LongdoObject(
          "Marker",
          args: [
            {
              "lon": mylocation['end'][0]['lon']!,
              "lat": mylocation['end'][0]['lat']!,
            },
          ],
        );

        map.currentState?.call("Route.add", args: [start]);
        map.currentState?.call("Route.add", args: [end]);
        map.currentState?.call("Route.search");
        checkend = true;
        success_station = false;
        checkcompletearrvielaststation = true;
      }
      var marklist = await map.currentState?.call("Overlays.list");
      // print(marklist);
      var ListMark = jsonDecode(marklist!.toString());
      // print(ListMark);
      print('ความยาวของ ListMark คือ ${ListMark.length}');
      print('beforelatlon[0] = ${beforelatlon[0]}');
      print('beforelatlon[1] =  ${beforelatlon[1]}');
      if (successyourway.isNotEmpty) {
        if (checkbeforelatlon == true) {
          print("more");
          if (beforelatlon[0] != lat.toString() &&
              beforelatlon[1] != lon.toString()) {
            print("not same");
            map.currentState?.call("Overlays.remove",
                args: [ListMark[ListMark.length - 1]]);
            map.currentState?.call("Overlays.add", args: [markme!]);

            //แอดใส่อเรย์
            itsme.clear();
            itsme.add({'lat': lat, 'lon': lon, 'alt': alt});
            print('ตำแหน่งที่เราอยู่');
            print(itsme[0]['lon']);
            print(itsme[0]['lat']);
            print(itsme[0]['alt']);

            // for (var pointmarks in successyourway) {
            //   double lat = pointmarks['lat']!;
            //   double lon = pointmarks['lon']!;
            //   print('Latitude: $lat, Longitude: $lon');
            // }
            double distanceeary2staion = 0;
            if (successyourway.length != 0) {
              distance = calculateDistance([itsme[0]['lat'], itsme[0]['lon']],
                  [successyourway[0]['lat'], successyourway[0]['lon']]);
              distanceeary2staion = calculateDistance(
                  [itsme[0]['lat'], itsme[0]['lon']],
                  [nearstation2[0]['lat'], nearstation2[0]['lon']]);
              print('distanceทางเดิน $distance');
            }

            // print("Distance between points: $distance kilometers");
            // print("Distance between points: ${distance * 1000} meters");
            setState(() {
              beforelatlon[0] = lat.toString();
              beforelatlon[1] = lon.toString();
              distance = distance;
              itsme = itsme;
              checkend = checkend;
            });

            if (distanceeary2staion * 1000 < 30 && checknearstation == false) {
              _shownotifition('คุณได้ถึงสถานี ${namestationlast} แล้ว');
              setState(() {
                checknearstation = true;
              });
            }

            if (distance * 1000 > 1000 && distance * 1000 < 40000) {
              _shownotifition('คุณอยู่ห่างกับสถานีเกิน 1 กิโลเมตร');
            } else {
              if (distance * 1000 < 300 && checknearstation2 == false) {
                _shownotifition('คุณได้ถึงสถานี ${namestationfirst} แล้ว');
                setState(() {
                  success_station = true;
                  checkcompletearrviefirststation = true;
                  checknearstation2 = true;
                });
                map.currentState?.call("Route.clear");
              }
            }

            if (success_station == true) {
              if (distance * 1000 < 5) {
                if (successyourway[0]['alt'] != null) {
                  if (itsme[0]['alt']! > successyourway[0]['alt']! - 3 &&
                      itsme[0]['alt']! < successyourway[0]['alt']! + 3) {
                    successyourway.removeAt(0);
                  }
                } else {
                  successyourway.removeAt(0);
                  setState(() {
                    successyourway = successyourway;
                  });
                }
              } else if (distance * 1000 <= 100) {
                _shownotifition('คุณเดินผิดทาง กรุณากลับเข้าเส้นทาง!');
              }
            }
          } else {
            print("same");
            setState(() {
              // checkbeforelatlon = false;
            });
          }
        } else {
          setState(() {
            beforelatlon[0] = lat.toString();
            beforelatlon[1] = lon.toString();
          });
          addMemark(lon, lat);
          print('giii');
        }
      } else {
        'successyourway is empty';
      }
    }
  }

  void addMemark(double lon, double lat) {
    var marker;
    marker = Longdo.LongdoObject(
      "Marker",
      args: [
        {
          "lon": lon,
          "lat": lat,
        },
      ],
    );
    // // add5point();
    map.currentState?.call("Overlays.add", args: [marker]);
    setState(() {
      checkbeforelatlon = true;
    });
  }

  void toggleDataVisibility(String vehicle) {
    setState(() {
      if (vehicle == selectedVehicle) {
        // Toggle visibility for the selected vehicle
        if (vehicle == 'Bike') {
          isBikeDataVisible = !isBikeDataVisible;
        } else if (vehicle == 'Bus') {
          isBusDataVisible = !isBusDataVisible;
        } else if (vehicle == 'Taxi') {
          isTaxiDataVisible = !isTaxiDataVisible;
        } else if (vehicle == 'Van') {
          isVanDataVisible = !isVanDataVisible;
        } else if (vehicle == 'Omnibus') {
          isOmnibusVisible = !isOmnibusVisible;
        } else if (vehicle == 'Train') {
          isTrainVisible = !isTrainVisible;
        } else if (vehicle == 'BTS') {
          isBTSVisible = !isBTSVisible;
        } else if (vehicle == 'MRT') {
          isMRTVisible = !isMRTVisible;
        }
      } else {
        // If a different vehicle is selected, hide data for the previous one
        isBikeDataVisible = false;
        isBusDataVisible = false;
        isTaxiDataVisible = false;
        isVanDataVisible = false;
        isOmnibusVisible = false;
        isTrainVisible = false;
        isBTSVisible = false;
        isMRTVisible = false;
        // Show data for the newly selected vehicle
        if (vehicle == 'Bike') {
          isBikeDataVisible = true;
        } else if (vehicle == 'Bus') {
          isBusDataVisible = true;
        } else if (vehicle == 'Taxi') {
          isTaxiDataVisible = true;
        } else if (vehicle == 'Van') {
          isVanDataVisible = true;
        } else if (vehicle == 'Omnibus') {
          isOmnibusVisible = true;
        } else if (vehicle == 'Train') {
          isTrainVisible = true;
        } else if (vehicle == 'BTS') {
          isBTSVisible = true;
        } else if (vehicle == 'MRT') {
          isMRTVisible = true;
        }

        // Update the selected vehicle
        selectedVehicle = vehicle;
        print('selectedVehicle: $selectedVehicle');
      }
    });
  }

  void onLocationSelected(Map selectedLocation) {
    // print("Test ${selectedLocation}");
    print("Test End ${selectedLocation['end']}");
    if (selectedLocation['start'].length != 0) {
      setState(() {
        mylocation = selectedLocation;
        startname['start'] = mylocation['start'][0]['name'];
        print(mylocation['start'][0]);
      });
    }
    if (selectedLocation['end'].length != 0) {
      setState(() {
        mylocation = selectedLocation;
        startname['end'] = mylocation['end'][0]['name'];
        print(mylocation['end'][0]);
      });
    }

    // if (selectedLocation['end'] != null) {
    //   setState(() {
    //     mylocation = selectedLocation;
    //     startname['end'] = mylocation['end'][0]['name'];
    //     print(mylocation['end'][0]);
    //   });
    // }
    // setState(() {
    //   mylocation = selectedLocation;
    //   startname['start'] = mylocation['start'][0]['name'];
    //   startname['end'] = mylocation['end'][0]['name'];
    //   print(mylocation['start'][0]);
    // });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var localtion = await Geolocator.getCurrentPosition();
    print(
        "lat: ${localtion.latitude} lon: ${localtion.longitude} hight ${localtion.altitude}");
    return await Geolocator.getCurrentPosition();
  }

  Future<void> logout() async {
    final GoogleSignIn googleSign = GoogleSignIn();
    await googleSign.signOut();
    await FirebaseAuth.instance.signOut();
  }

  double imageOpacity = 1.0;

  Future<String?> namestation(int index) async {
    DatabaseReference namestation =
        FirebaseDatabase.instance.ref('TranStation');
    List<String> namestations = []; // Define namestations list
    print('index สถานีชื่อ $index');
    try {
      DatabaseEvent event = await namestation.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> stations =
            snapshot.value as Map<dynamic, dynamic>;
        stations.forEach((stationKey, stationData) {
          if (stationData is Map) {
            var stationDetails = stationData['station_name'];
            if (stationDetails is String) {
              print("Station $stationKey: Name: $stationDetails");
              namestations.add(stationDetails);
            } else {
              print("Station $stationKey does not have a valid 'name' list");
            }
          }
        });
        print("Station name data: $namestations");
        if (index >= 0 && index < namestations.length) {
          return namestations[index];
        } else {
          print("Index out of range");
          return null;
        }
      }
    } catch (e) {
      print("An error occurred: $e");
    }
    return null; // Return null if something goes wrong
  }

  Future<String?> keystation(int index) async {
    DatabaseReference namestation =
        FirebaseDatabase.instance.ref('TranStation');
    List<String> namestations = []; // Define namestations list
    print('index สถานีชื่อ $index');
    try {
      DatabaseEvent event = await namestation.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> stations =
            snapshot.value as Map<dynamic, dynamic>;
        stations.forEach((stationKey, stationData) {
          if (stationData is Map) {
            var stationDetails = stationData['station_name'];
            if (stationDetails is String) {
              print("Station $stationKey: Name: $stationDetails");
              namestations.add(stationKey);
            } else {
              print("Station $stationKey does not have a valid 'name' list");
            }
          }
        });
        print("Station name data: $namestations");
        if (index >= 0 && index < namestations.length) {
          return namestations[index];
        } else {
          print("Index out of range");
          return null;
        }
      }
    } catch (e) {
      print("An error occurred: $e");
    }
    return null; // Return null if something goes wrong
  }

  Future<void> checkstation() async {
    print('checkstation');
    DatabaseReference tranStationRef =
        FirebaseDatabase.instance.ref('TranStation');
    try {
      DatabaseEvent event = await tranStationRef.once();
      final snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> stations =
            snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, double>> station = [];
        List<double> firstdistances =
            []; // เก็บระยะทางที่คำนวณได้จากแต่ละสถานีที่ใกล้จุดแรก
        List<double> lastdistances =
            []; // เก็บระยะทางที่คำนวณได้จากแต่ละสถานีที่ใกล้จุดที่สอง
        dynamic keystation1;
        dynamic keystation2;

        nearfirststation = {};
        nearlaststation = {};
        stations.forEach((stationKey, stationData) {
          if (stationData is Map) {
            var stationDetails = stationData['station'];
            if (stationDetails is List) {
              // Assuming the first two elements in the list are latitude and longitude.
              var latitude = stationDetails[0];
              var longitude = stationDetails[1];
              print(
                  "Station $stationKey: Latitude: $latitude, Longitude: $longitude");
              station.add({
                "lon": longitude,
                "lat": latitude,
              });
            } else {
              print("Station $stationKey does not have a valid 'station' list");
            }
          }
        });
        print("Station data: $station");

        station.forEach((station) {
          double distance = calculateDistance(
              [mylocation['start'][0]['lat'], mylocation['start'][0]['lon']],
              [station['lat'], station['lon']]);
          firstdistances.add(distance); // เก็บระยะทางลงในรายการ
          print("Distance to station: $distance km");
        });

        print("Distances to stations first: $firstdistances");

        station.forEach((station) {
          double distance = calculateDistance(
              [mylocation['end'][0]['lat'], mylocation['end'][0]['lon']],
              [station['lat'], station['lon']]);
          lastdistances.add(distance); // เก็บระยะทางลงในรายการ
          print("Distance to station last: $distance km");
        });
        print("Distances to stations last: $lastdistances");
        // หาข้อมูลที่น้อยที่สุดใน distancesจุดแรก
        double? minDistance1 = firstdistances.isNotEmpty
            ? firstdistances.reduce((a, b) => a < b ? a : b)
            : null;
        int minIndex1 = firstdistances.indexOf(minDistance1!);

        // แสดงข้อมูลสถานีที่ใกล้ที่สุด
        double? minDistance2 = lastdistances.isNotEmpty
            ? lastdistances.reduce((a, b) => a < b ? a : b)
            : null;
        int minIndex2 = lastdistances.indexOf(minDistance2!);
        namestationfirst = (await namestation(minIndex1))!;
        namestationlast = (await namestation(minIndex2))!;
        keystation1 = (await keystation(minIndex1))!;
        keystation2 = (await keystation(minIndex2))!;
        nearfirststation = {
          "lat": station[minIndex1]['lat']!,
          "lon": station[minIndex1]['lon']!
        };
        nearlaststation = {
          "lat": station[minIndex2]['lat']!,
          "lon": station[minIndex2]['lon']!
        };
        if ((namestationfirst == "สถานีบางซ่อน" ||
                namestationfirst == "สถานีบางบำหรุ" ||
                namestationfirst == "สถานีตลิ่งชัน" ||
                namestationfirst == "สถานีกลางบางซื่อ") &&
            (namestationlast == "สถานีบางซ่อน" ||
                namestationlast == "สถานีบางบำหรุ" ||
                namestationlast == "สถานีตลิ่งชัน" ||
                namestationlast == "สถานีกลางบางซื่อ")) {
          print("เข้า if แล้ว");
        } else {
          print("เข้า else แล้ว");
          if (namestationfirst == "สถานีบางบำหรุ" ||
              namestationfirst == "สถานีตลิ่งชัน" ||
              namestationfirst == "สถานีบางซ่อน") {
            print("สถานีต้นทางเป็นสถานีกลางบางซื่อ");
            namestationfirst = "สถานีกลางบางซื่อ";
            keystation1 = "000";
            nearfirststation = {
              "lat": station[1]['lat']!,
              "lon": station[1]['lon']!
            };
          }

          if (namestationlast == "สถานีบางบำหรุ" ||
              namestationlast == "สถานีตลิ่งชัน" ||
              namestationlast == "สถานีบางซ่อน") {
            print("สถานีปลายทางเป็นสถานีกลางบางซื่อ");
            namestationlast = "สถานีกลางบางซื่อ";
            keystation2 = "000";
            nearlaststation = {
              "lat": station[1]['lat']!,
              "lon": station[1]['lon']!
            };
          }
        }
        print("Name station first: $namestationfirst");
        print("Name station last: $namestationlast");
        print("keystation1: $keystation1");
        print("keystation2: $keystation2");
        if (minIndex1 != -1) {
          print("Minimum distance first: $minDistance1 km");
          print("Index of minimum distance: $minIndex1");

          // นำข้อมูลสถานีที่ใกล้ที่สุดไปเก็บไว้ใน nearstation

          print("Nearest station first: $nearfirststation");
          mark = map.currentState?.LongdoObject(
            "Marker",
            args: [
              {
                "lon": nearfirststation['lon'],
                "lat": nearfirststation['lat'],
              },
              {
                "title": "$namestationfirst",
                "detail": "สถานีต้นทาง",
              },
            ],
          );
          if (mark != null) {
            map.currentState?.call("Overlays.add", args: [mark!]);
          }
        } else {
          print("Distances list is empty.");
        }
        if (minIndex2 != -1) {
          print("Minimum distance last: $minDistance2 km");
          print("Index of minimum distance: $minIndex2");

          // นำข้อมูลสถานีที่ใกล้ที่สุดไปเก็บไว้ใน nearstation

          print("Nearest station last: $nearlaststation");
          mark = map.currentState?.LongdoObject(
            "Marker",
            args: [
              {
                "lon": nearlaststation['lon'],
                "lat": nearlaststation['lat'],
              },
              {
                "title": "$namestationlast",
                "detail": "สถานีปลายทาง",
              },
            ],
          );
          if (mark != null) {
            map.currentState?.call("Overlays.add", args: [mark!]);
          }

          var marklist = await map.currentState?.call("Overlays.list");
          print(marklist);
          var ListMark = jsonDecode(marklist!.toString());
          print(ListMark);
          print('ความยาวของ ListMark คือ ${ListMark.length}');
          if (ListMark.length == 4) {
            print("minIndex1 : $minIndex1 , minIndex2 : $minIndex2");
            getPathwayDatakek(keystation1, keystation2);
            if (checkuploaddataway == false) {
              uploaddatauserforfuture(keystation1, keystation2);
              setState(() {
                checkuploaddataway = true;
              });
            }
          }
        } else {
          print("Distances list is empty.");
        }
      } else {
        print("No data available.");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  double calculateDistance(List<dynamic> point1, List<dynamic> point2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    double lat1 = radians(point1[0]);
    double lon1 = radians(point1[1]);
    double lat2 = radians(point2[0]);
    double lon2 = radians(point2[1]);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }

  double radians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<String> calculateDistance2(
      List<dynamic> point1, List<dynamic> point2) async {
    const double earthRadius = 6371; // Earth radius in kilometers

    double lat1 = radians(point1[0]);
    double lon1 = radians(point1[1]);
    double lat2 = radians(point2[0]);
    double lon2 = radians(point2[1]);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    if (distance > 1) {
      return distance.toStringAsFixed(0) + " กิโลเมตร";
    } else {
      return (distance * 1000).toStringAsFixed(0) + " เมตร";
    }
  }

  Future<void> getPathwayDatakek(String index1, String index2) async {
    print('index1 : $index1 , index2 : $index2');
    print('hi');

    DatabaseReference pathway1 =
        FirebaseDatabase.instance.ref('MapMarking/in/$index1');
    List<Map<String, dynamic>> pathways1 =
        []; // For storing pathways corresponding to index1
    try {
      DatabaseEvent event = await pathway1.once();
      final snapshot = event.snapshot;
      var snapshotValue = snapshot.value;
      if (snapshot.exists && snapshotValue != null) {
        if (snapshotValue is List) {
          // Handle list data
          for (var item in snapshotValue) {
            if (item is List && item.length > 1) {
              pathways1.add({
                "all": item,
              });
            }
          }
        } else {
          print('Snapshot value is not in the expected format');
          return;
        }

        // print("Pathway data: $pathways1");
        List<List<dynamic>> pathways1last = [];
        for (var item in pathways1) {
          pathways1last.add(item["all"].first);
        }
        print('pathways1last $pathways1last');
        List<double> disnearfirst = [];
        pathways1last.forEach((element) {
          var lat = element[0]!;
          var lon = element[1]!;
          double distance = calculateDistance(
              [mylocation['start'][0]['lat'], mylocation['start'][0]['lon']],
              [lat, lon]);
          disnearfirst.add(distance);
          print("Distance to station1: $distance km");
        });
        double? minDistance = disnearfirst.isNotEmpty
            ? disnearfirst.reduce((a, b) => a < b ? a : b)
            : null;
        int minIndex = disnearfirst.indexOf(minDistance!);
        print("Minimum distance: $minDistance km");
        print("Index of minimum distance: $minIndex");
        indoor = minIndex + 1;
        print("สถานีแรกประตูที่ใกล้ที่สุดคือประตูที่ $indoor");
        pathways1.clear();
        List<Map<String, dynamic>> waittoread1 = [];
        int count = 0;
        for (var item in snapshotValue) {
          if (item is List && item.length > 1) {
            if (count == indoor) {
              waittoread1.add({
                "all": item,
              });
            }
          }
          count++;
        }
        // print('waittoread1 $waittoread1');
        for (var item in waittoread1) {
          var valueData = item["all"] as List<dynamic>;
          valueData.forEach((element) {
            var lat = element[0]!;
            var lon = element[1]!;
            var name = element[2]!;
            pathways1.add({
              "lat": lat,
              "lon": lon,
              "name": name,
            });
          });
        }

        print('pathways1 $pathways1');
      }
    } catch (e) {
      print("An error occurred: $e");
    }

    DatabaseReference pathway2 =
        FirebaseDatabase.instance.ref('MapMarking/out/$index2');
    List<Map<String, dynamic>> pathways2 =
        []; // For storing pathways corresponding to index2
    try {
      DatabaseEvent event = await pathway2.once();
      final snapshot = event.snapshot;
      var snapshotValue = snapshot.value;
      if (snapshot.exists && snapshotValue != null) {
        if (snapshotValue is List) {
          // Handle list data
          for (var item in snapshotValue) {
            if (item is List && item.length > 1) {
              pathways2.add({
                "all": item,
              });
            }
          }
        } else {
          print('Snapshot value is not in the expected format');
          return;
        }

        // print("Pathway data: $pathways2");
        List<List<dynamic>> pathways2last = [];
        for (var item in pathways2) {
          pathways2last.add(item["all"].last);
        }
        List<double> disnearlast = [];
        pathways2last.forEach((element) {
          var lat = element[0]!;
          var lon = element[1]!;
          double distance = calculateDistance(
              [mylocation['end'][0]['lat'], mylocation['end'][0]['lon']],
              [lat, lon]);
          disnearlast.add(distance);
          print("Distance to station2: $distance km");
        });
        double? minDistance = disnearlast.isNotEmpty
            ? disnearlast.reduce((a, b) => a < b ? a : b)
            : null;
        int minIndex = disnearlast.indexOf(minDistance!);
        print("Minimum distance: $minDistance km");
        print("Index of minimum distance: $minIndex");
        exitdoor = minIndex + 1;
        print("สถานีปลายประตูที่ใกล้ที่สุดคือประตูที่ $exitdoor");
        pathways2.clear();
        if (dropdownItems.isEmpty) {
          if (dropdownItems.isEmpty) {
            dropdownItems = [];
            for (int i = 1; i <= disnearlast.length; i++) {
              dropdownItems.add(i.toString());
              print('ประตูทางออกมี' + i.toString() + 'ประตู');
            }
          }
          List<Map<String, dynamic>> waittoread2 = [];
          int count = 0;
          for (var item in snapshotValue) {
            if (item is List && item.length > 1) {
              if (count == exitdoor) {
                waittoread2.add({
                  "all": item,
                });
              }
            }
            count++;
          }
          // print('waittoread2 $waittoread2');
          for (var item in waittoread2) {
            var valueData = item["all"] as List<dynamic>;
            valueData.forEach((element) {
              var lat = element[0]!;
              var lon = element[1]!;
              var name = element[2]!;
              pathways2.add({
                "lat": lat,
                "lon": lon,
                "name": name,
              });
            });
          }
          setState(() {
            dropdownValue = exitdoor.toString();
            dropdownItems = dropdownItems;
          });
        } else {
          List<Map<String, dynamic>> waittoread2 = [];
          int count = 0;
          for (var item in snapshotValue) {
            if (item is List && item.length > 1) {
              if (count == int.parse(dropdownValue!)) {
                waittoread2.add({
                  "all": item,
                });
              }
            }
            count++;
          }
          // print('waittoread2 $waittoread2');
          for (var item in waittoread2) {
            var valueData = item["all"] as List<dynamic>;
            valueData.forEach((element) {
              var lat = element[0]!;
              var lon = element[1]!;
              var name = element[2]!;
              pathways2.add({
                "lat": lat,
                "lon": lon,
                "name": name,
              });
            });
          }
          setState(() {
            dropdownValue = dropdownValue;
            print('ทางออกที่ $dropdownValue');
          });
        }

        print('pathways2 $pathways2');
      }
    } catch (e) {
      print("An error occurred: $e");
    }
    if (checkcompletearrviefirststation == false) {
      var start = Longdo.LongdoObject(
        "Marker",
        args: [
          {
            "lon": mylocation['start'][0]['lon']!,
            "lat": mylocation['start'][0]['lat']!,
          },
        ],
      );
      var end = Longdo.LongdoObject(
        "Marker",
        args: [
          {
            "lon": pathways1[0]['lon']!,
            "lat": pathways1[0]['lat']!,
          },
        ],
      );

      map.currentState?.call("Route.add", args: [start]);
      map.currentState?.call("Route.add", args: [end]);
      map.currentState?.call("Route.search");
    }
    if (checkcompletearrvielaststation == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Text(
                    "การเดินทางของคุณได้สิ้นสุดลงแล้ว ขอให้เดินทางปลอดภัยจาก TheRedline \n ทางเราจะมีเส้นทางให้ท่านไปถึงปลายทางที่ท่านมาร์กไว้",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontFamily: 'custom_font',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: -100,
                  child: Image.asset(
                    "assets/redtrain.png",
                    width: 150,
                    height: 150,
                  ),
                ),
              ],
            ),
          );
        },
      );
      var start = Longdo.LongdoObject(
        "Marker",
        args: [
          {
            "lon": nearlaststation['lon']!,
            "lat": nearlaststation['lat']!,
          },
        ],
      );
      var end = Longdo.LongdoObject(
        "Marker",
        args: [
          {
            "lon": mylocation['end'][0]['lon']!,
            "lat": mylocation['end'][0]['lat']!,
          },
        ],
      );

      map.currentState?.call("Route.add", args: [start]);
      map.currentState?.call("Route.add", args: [end]);
      map.currentState?.call("Route.search");
    }
    print('pathways1 $pathways1');
    print('pathways2 $pathways2');
    if (pathways1.isNotEmpty) {
      addpathwayline(pathways1, 'rgba(32, 0, 255, 1)');
    }
    if (pathways2.isNotEmpty) {
      addpathwayline(pathways2, 'rgba(32, 0, 255, 1)');
    }
    if (successyourway.isEmpty && endcheck == false) {
      successyourway = [];
      addyourpathway(pathways1, pathways2);
    } else if (dropdownValue != exitdoor.toString() &&
        changeoutpathway == true) {
      futureCompleted = false;
      successyourway = [];
      exitdoor = dropdownValue;
      addyourpathway(pathways1, pathways2);
    } else {
      print('มีเส้นทางแล้ว');
      checkconfirmgo = true;
    }
    mycategory = index2;
    if (dropdownValue != null) {
      Loadpublictransport(dropdownValue, index2);
      LoadFacilities(index2);
      getcomment(dropdownValue, index2);
    } else {
      Loadpublictransport(exitdoor.toString(), index2);
      LoadFacilities(index2);
      getcomment(exitdoor.toString(), index2);
    }
  }

  Future<void> LoadFacilities(dynamic category) async {
    DatabaseReference facilityRef = FirebaseDatabase.instance.ref('Facility');
    List<Map<dynamic, dynamic>> facilitiesList = [];

    facilityRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      facilitiesList.clear();

      snapshot.children.forEach((child) {
        String id = child.key as String;
        String facName = child.child('fac_name').value as String;

        facilitiesList.add({"id": id, "name": facName});
      });

      print(facilitiesList);
    });

    print('Category for Facilities: $category');
    DatabaseReference facilitiesRef =
        FirebaseDatabase.instance.ref('TranStation/$category/Facilities/id');
    List<Map<String, dynamic>> facilities = [];
    DatabaseEvent eventname = await facilitiesRef.once();
    // ตรวจสอบว่ามีข้อมูลใน dataSnapshot หรือไม่
    if (eventname.snapshot.exists) {
      DataSnapshot snapshot = eventname.snapshot;
      var id = snapshot.value;
      // print('idFacilities: $id');
      facilities.add({
        "id": id,
      });
    }
    print('Facilities: $facilities');

    successfac = [];
    for (var facility in facilitiesList) {
      for (var fac in facilities) {
        var id = fac['id'];
        if (id is List) {
          for (var value in id) {
            int idFac = int.parse(facility['id']);
            if (idFac == value) {
              // แปลงโครงสร้างข้อมูลของ facility เป็น Map<String, dynamic> ก่อนเพิ่มลงใน successfac
              Map<String, dynamic> facilityMap = {};
              facility.forEach((key, value) {
                facilityMap[key.toString()] = value;
              });
              successfac.add(facilityMap);
            }
          }
        }
      }
    }

    print('successfac: $successfac');
    setState(() {
      successfac = successfac;
    });
  }

  Future<void> Loadpublictransport(dynamic numberdoor, dynamic category) async {
    print('numberdoor: $numberdoor');
    print('Category: $category');
    Bike = [];
    BTS = [];
    MRT = [];
    Van = [];
    Bus = [];
    Omnibus = [];
    Train = [];
    Taxi = [];
    street = '';
    DatabaseReference namestreet = FirebaseDatabase.instance
        .ref('TranStation/$category/ExitDoors/$numberdoor/exdor_desc');
    DatabaseEvent eventname = await namestreet.once();
    if (eventname.snapshot.exists) {
      DataSnapshot snapshot = eventname.snapshot;
      var exdorDesc = snapshot.value;
      print('exdor_desc: $exdorDesc');
      if (exdorDesc is String) {
        street = exdorDesc;
      }
    }

    DatabaseReference transportsRef = FirebaseDatabase.instance
        .ref('TranStation/$category/ExitDoors/$numberdoor/Transports');

    DatabaseEvent event = await transportsRef.once();
    if (event.snapshot.exists) {
      DataSnapshot snapshot = event.snapshot;

      var transports = snapshot.value;

      if (transports is List) {
        // Iterate over the list of transports
        transports.forEach((transport) {
          // Check if each transport is a map
          if (transport is Map) {
            // Check if the transport contains necessary keys
            if (transport.containsKey('tran_name') &&
                transport.containsKey('tran_time')) {
              var name = transport['tran_name'];
              var time = transport['tran_time'];

              // Process the transport data with name and time
              print('Transport Name: $name');
              print('Operating Time: $time');
            }
            var name = transport['tran_name'];
            var time = transport['tran_time'];
            if (transport.containsKey('tran_desc')) {
              print('เข้ามาทำอยู่');
              // If tran_desc exists, it might contain descriptions
              var desc = transport['tran_desc'];

              // Check if desc is a list, as in the case of multiple descriptions
              List<dynamic> stationcar = [];
              List<dynamic> line = [];

              if (desc is List) {
                print('desc length: ${desc.length}');
                var name = transport['tran_name'];
                var time = transport['tran_time'];
                for (var i = 0; i < desc.length; i++) {
                  print('desc: $desc');
                  // var line;

                  // print(desc[i].runtimeType);
                  if (desc[i] is List) {
                    List<String> Listdesc = desc[i].cast<String>();
                    print('Listdesc: $Listdesc');

                    stationcar.add(Listdesc[1]);
                    line.add(Listdesc[0]);
                  } else {
                    // print('not list');
                    if (i == 1) {
                      stationcar.add(desc[i]);
                    } else {
                      line.add(desc[i]);
                    }
                  }
                  // print('Line: $line');
                  // print('Station: $stationcar');
                  // var line = desc[0] ?? '';
                  // var stationcar = desc[1] ?? '';
                  // print('Line: $line');
                  // print('Station: $stationcar');
                  // เพิ่มข้อมูลรถเข้ารายการที่เหมาะสมตามชื่อ
                  if (name.contains("แท็กซี่")) {
                    Taxi.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("รถจักรยานยนต์รับจ้าง")) {
                    Bike.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("รถโดยสารประจำทาง")) {
                    Bus.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("รถตู้โดยสารปรับอากาศ")) {
                    Van.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("รถโดยสารขนาดเล็ก(สองแถว)")) {
                    Omnibus.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("รถไฟทางไกล") ||
                      name.contains("รถไฟฟ้า")) {
                    Train.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("BTS")) {
                    BTS.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else if (name.contains("MRT")) {
                    MRT.add({
                      "name": name,
                      "time": time,
                      "line": line,
                      "station": stationcar,
                    });
                  } else {
                    // จัดการกรณีอื่น ๆ ตามความเหมาะสม
                  }
                }
                print('Station: $stationcar');
                print('Line: $line');
              }
            } else {
              if (name.contains("รถจักรยานยนต์รับจ้าง")) {
                Bike.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("รถโดยสารประจำทาง")) {
                Bus.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("รถตู้โดยสารปรับอากาศ")) {
                Van.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("รถโดยสารขนาดเล็ก(สองแถว)")) {
                Omnibus.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("รถไฟทางไกล") ||
                  name.contains("รถไฟฟ้า")) {
                Train.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("แท็กซี่")) {
                Taxi.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("BTS")) {
                BTS.add({
                  "name": name,
                  "time": time,
                });
              } else if (name.contains("MRT")) {
                MRT.add({
                  "name": name,
                  "time": time,
                });
              }
            }
          } else {
            print('Unexpected data structure for transport: $transport');
          }
        });
      } else {
        print('Unexpected data structure: $transports');
      }
    } else {
      print(
          'No transports found for category $category and numberdoor $numberdoor');
    }
    print('Bike: $Bike');
    print('Bus: $Bus');
    print('Omnibus: $Omnibus');
    print('Train: $Train');
    print('Taxi: $Taxi');
    print('Van: $Van');
    print('BTS: $BTS');
    print('MRT: $MRT');
  }

  Future<void> getPathwayData(int index1, int index2) async {
    DatabaseReference pathway = FirebaseDatabase.instance.ref('MapMarking');
    List<Map<String, dynamic>> pathways1 =
        []; // For storing pathways corresponding to index1
    List<Map<String, dynamic>> pathways2 =
        []; // For storing pathways corresponding to index2

    print('index ทางเดินสถานีแรก $index1');
    print('index ทางเดินสถานีที่สอง $index2');

    try {
      DatabaseEvent event = await pathway.once();
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> pathwayData =
            snapshot.value as Map<dynamic, dynamic>;
        int loopIndex = 0; // Use loop index instead of pathwayKey
        pathwayData.forEach((_, pathwayDetails) {
          // Using _ since we don't need the key

          if (pathwayDetails is Map) {
            var markpoint = pathwayDetails['markpoint'];
            if (markpoint is List) {
              markpoint.forEach((element) {
                if (element is List && element.length > 2) {
                  var latitude = element[0];
                  var longitude = element[1];
                  var name = element[2];

                  print(
                      "Pathway $loopIndex: Latitude: $latitude, Longitude: $longitude, Name: $name");
                  Map<String, dynamic> pathway = {
                    "lon": longitude,
                    "lat": latitude,
                    "name": name,
                  };
                  if (loopIndex == index1) {
                    pathways1.add(pathway);
                  } else if (loopIndex == index2) {
                    pathways2.add(pathway);
                  }
                } else {
                  print(
                      "Pathway $loopIndex does not have a valid 'markpoint' list");
                }
              });
            } else {
              print(
                  "Pathway $loopIndex does not have a valid 'markpoint' list");
            }
          }
          loopIndex++; // Increment loop index
        });
        print("Pathways corresponding to index1: $pathways1");
        print("Pathways corresponding to index2: $pathways2");
        if (pathways1.isNotEmpty) {
          addpathwayline(pathways1, 'rgba(32, 0, 255, 1)');
        }
        if (pathways2.isNotEmpty) {
          addpathwayline(pathways2, 'rgba(32, 0, 255, 1)');
        }
        if (successyourway.isEmpty) {
          successyourway = [];
          addyourpathway(pathways1, pathways2);
        } else {
          print('มีเส้นทางแล้ว');
        }

        // var marklist = await map.currentState?.call("Overlays.list");
        // print(marklist);
        // var ListMark = jsonDecode(marklist!.toString());
        // print('ความยาวของ ListMark คือ ${ListMark.length}');
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  String pictureofFacility(dynamic id) {
    //change to int
    if (id is String) {
      id = int.parse(id);
    }
    if (id == 0) {
      return 'assets/facility/atm-machine.png';
    } else if (id == 1) {
      return 'assets/facility/elevator.png';
    } else if (id == 2) {
      return 'assets/facility/escalator.png';
    } else if (id == 3) {
      return 'assets/facility/toilet.png';
    } else if (id == 4) {
      return 'assets/facility/store.png';
    } else if (id == 5) {
      return 'assets/facility/restaurant.png';
    } else if (id == 6) {
      return 'assets/facility/parking.png';
    } else if (id == 7) {
      return 'assets/facility/disabled.png';
    } else if (id == 8) {
      return 'assets/facility/elevator_ex.png';
    } else if (id == 9) {
      return 'assets/facility/fire-extinguisher.png';
    } else if (id == 10) {
      return 'assets/facility/tactile.png';
    } else if (id == 11) {
      return 'assets/facility/MRT_pink.png';
    } else if (id == 12) {
      return 'assets/facility/MRT_purple.png';
    } else if (id == 13) {
      return 'assets/facility/MRT_blue.png';
    } else if (id == 14) {
      return 'assets/facility/MRT_yellow.png';
    } else if (id == 15) {
      return 'assets/facility/airport.png';
    }
    return 'assets/dek.png';
  }

  String changenamepathIntToString(dynamic k, dynamic value) {
    var name = k;
    if (value == "start") {
      if (name == 1) {
        return 'เดินตรงไป';
      } else if (name == 2) {
        return 'เดินเลี้ยวซ้ายและตรงไป';
      } else if (name == 3) {
        return 'เดินเลี้ยวขวาและตรงไป';
      } else if (name == 4) {
        return 'ขึ้นบันได';
      } else if (name == 5) {
        return 'ลงบันได';
      } else if (name == 6) {
        return 'ขึ้นลิฟต์';
      } else if (name == 7) {
        return 'ลงลิฟต์';
      }
    }
    if (value == "end") {
      if (name == 1) {
        return 'เดินตรงไป';
      } else if (name == 2) {
        return 'เดินเลี้ยวขวาและตรงไป';
      } else if (name == 3) {
        return 'เดินเลี้ยวซ้ายและตรงไป';
      } else if (name == 4) {
        return "ลงสะพานลอย";
      } else if (name == 5) {
        return 'ขึ้นสะพานลอย';
      }
    }
    return ''; // default return statement with an empty string
  }

  //สำคัญ
  Future<void> addyourpathway(List path1, List path2) async {
    yourpathway1 = [];
    yourpathway2 = [];
    successyourway = [];
    List<Map<String, dynamic>> inhere = [];
    print("path1 length");
    print(path1.length);
    print("path2 length");
    print(path2.length);
    print("path1 Data : $path1");
    print("path2 Data : $path2");
    print(namestationfirst);
    print(namestationlast);

    if (checknearstation == false) {
      nearstation2.add({"lat": path2[0]['lat']!, "lon": path2[0]['lon']!});
    }
    // Process path1
    // inhere.add({
    //   "lon": 0.0,
    //   "lat": 0.0,
    //   "name": namestationfirst,
    //   "time": 0.0,
    //   "color": "red",
    //   "width": 24,
    // });
    for (var i = 0; i < path1.length; i++) {
      double lon1 = path1[i]['lon']!;
      double lat1 = path1[i]['lat']!;
      double lon2 = 0;
      double lat2 = 0;
      if (i < path1.length - 1) {
        lon2 = path1[i + 1]['lon']!;
        lat2 = path1[i + 1]['lat']!;
      } else {
        lon2 = path1[i]['lon']!;
        lat2 = path1[i]['lat']!;
      }
      int distance =
          await (calculateDistance([lat1, lon1], [lat2, lon2]) * 1000).round();
      String name = await changenamepathIntToString(path1[i]['name'], 'start');
      String distanceStr = distance.toString();
      if (successyourway.isEmpty && i == 0) {
        yourpathway1.add({
          "lon": lon1,
          "lat": lat1,
          "name":
              name + 'ทางเข้าที่ ' + indoor.toString() + " " + namestationfirst,
          "time": distanceStr,
          "color": "red"
        });
      } else if (i == path1.length - 1) {
        yourpathway1.add({
          "lon": lon1,
          "lat": lat1,
          "name": 'จุดรอรถไฟไป ' + namestationlast,
          "time": distanceStr,
          "color": "red"
        });
      } else {
        yourpathway1.add({
          "lon": lon1,
          "lat": lat1,
          "name": name,
          "time": distanceStr,
          "color": "blue"
        });
      }
    }

    print("==============================");
    print(path2);
    for (var i = 0; i < path2.length; i++) {
      double lon1 = path2[i]['lon']!;
      double lat1 = path2[i]['lat']!;
      double lon2 = 0;
      double lat2 = 0;
      if (i < path2.length - 1) {
        lon2 = path2[i + 1]['lon']!;
        lat2 = path2[i + 1]['lat']!;
      } else {
        lon2 = path2[i]['lon']!;
        lat2 = path2[i]['lat']!;
      }
      int distance =
          await (calculateDistance([lat1, lon1], [lat2, lon2]) * 1000).round();
      String name = await changenamepathIntToString(path2[i]['name'], 'start');

      // Ensure distance is converted to String before concatenation or assignment
      String distanceStr = distance.toString();

      if (i == 0) {
        yourpathway2.add({
          "lon": lon1,
          "lat": lat1,
          "name": 'ลงรถไฟและ' + name,
          "time": distanceStr, // Use converted distance
          "color": "red"
        });
      } else if (i == path2.length - 1) {
        yourpathway2.add({
          "lon": lon1,
          "lat": lat1,
          "name":
              name + 'ทางออกที่ ' + exitdoor.toString() + " " + namestationlast,
          "time": distanceStr, // Use converted distance
          "color": "red"
        });
      } else {
        yourpathway2.add({
          "lon": lon1,
          "lat": lat1,
          "name": name,
          "time": distanceStr, // Use converted distance
          "color": "blue"
        });
      }
    }

    inhere.addAll(yourpathway1);
    inhere.addAll(yourpathway2);
    // inhere.add({
    //   "lon": 0.0,
    //   "lat": 0.0,
    //   "name": "สิ้นสุดปลายทาง ทางออกที่ " + exitdoor.toString(),
    //   "time": 0.0,
    //   "color": "red",
    //   "width": 24,
    // });

    successyourway = inhere;
    print(
        "==============================================================================================\n");
    print("yourpathway1 ${yourpathway1.length}");
    print(yourpathway1);
    print("yourpathway2 ${yourpathway2.length}");
    print(yourpathway2);

    print("successyourway ${successyourway.length}");
    print(successyourway);
    setState(() {
      successyourway = successyourway;
      changeoutpathway = false;
      checkconfirmgo = true;
    });
  }

  Future<void> addpathwayline(
      List<Map<String, dynamic>> pathwayline, color) async {
    List<Map<String, double>> polylineArguments = [];
    // print("pathwayline");
    // print(pathwayline);
    // print(color);
    for (var point in pathwayline) {
      double lon = point['lon']!;
      double lat = point['lat']!;
      polylineArguments.add({
        "lon": lon,
        "lat": lat,
      });
    }
    var polyline = Longdo.LongdoObject(
      "Polyline",
      args: [
        polylineArguments,
        {
          "title": "Dashline",
          "detail": "-",
          "label": "ทางเดินในสถานี",
          "lineWidth": 4,
          "lineColor": "${color}",
          "lineStyle": Longdo.LongdoStatic(
            "LineStyle",
            "Dashed",
          ),
        }
      ],
    );
    map.currentState?.call("Overlays.add", args: [polyline]);
  }

  Future<void> getPolylineData() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('polyline').child('Bled');
    // print("Check Data");
    await databaseReference.onValue.first.then((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      List<dynamic> values = dataSnapshot.value as List;
      pointmarkpolyline1 = [];
      values.forEach((element) {
        // print("lonBled: ${element[0]}");
        // print("latBled: ${element[1]}");
        pointmarkpolyline1.add({
          "lon": element[0],
          "lat": element[1],
        });
      });
      addPolylines(pointmarkpolyline1, 'rgba(199, 17, 17, 1)');
    });

    DatabaseReference databaseReference2 =
        FirebaseDatabase.instance.ref('polyline').child('Nled');
    // print("Check Data");
    await databaseReference2.onValue.first.then((event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      List<dynamic> values = dataSnapshot.value as List;
      pointmarkpolyline2 = [];
      values.forEach((element) {
        // print("lonBled2: ${element[0]}");
        // print("latBled2: ${element[1]}");
        pointmarkpolyline2.add({
          "lon": element[0],
          "lat": element[1],
        });
      });
      addPolylines(pointmarkpolyline2, 'rgba(208,90,99,255)');
    });
  }

  Future<void> addPolylines(
      List<Map<String, dynamic>> pointmarkpolyline, color) async {
    List<Map<String, double>> polylineArguments = [];
    // print("pointmarkpolyline1");
    // print(pointmarkpolyline1);
    // print("pointmarkpolyline2");
    // print(pointmarkpolyline2);
    // print(color);
    for (var point in pointmarkpolyline) {
      double lon = point['lon']!;
      double lat = point['lat']!;

      polylineArguments.add({
        "lon": lon,
        "lat": lat,
      });
    }

    var polyline = Longdo.LongdoObject(
      "Polyline",
      args: [
        polylineArguments,
        {
          "lineWidth": 4,
          "lineColor": "${color}",
        }
      ],
    );
    map.currentState?.call("Overlays.add", args: [polyline]);

    var marklist = await map.currentState?.call("Overlays.list");
    print(marklist);
    var ListMark = jsonDecode(marklist!.toString());
    print(ListMark);
    print('ความยาวของ ListMark คือ ${ListMark.length}');
    if (ListMark.length == 2) {
      // getpathwayData();
      checkstation();
    }
  }

  Future<void> getlandmark(
      String tag, double lat, double lon, StateSetter setState) async {
    Landmarkdata = [];

    var apiKey = "fdd00a0426fcf1019f3b442d5d8ed7dc";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=10&tag=${tag}&span=3000m');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        Landmarkdata = data['data'];
      });
    }
  }

  Future<void> uploaddatauserforfuture(
      dynamic keystation1, dynamic keystation2) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DatabaseReference finduser = FirebaseDatabase.instance.ref('User');
      var useremail = user!.email;
      print('useremail: $useremail');
      int count = 0;
      DatabaseEvent event = await finduser.once();
      if (event.snapshot.exists) {
        DataSnapshot snapshot = event.snapshot;
        // Check if snapshot.value is a List
        if (snapshot.value is List) {
          List<dynamic>? userList = snapshot.value as List<dynamic>?;
          if (userList != null) {
            for (var userEntry in userList) {
              // Assuming userEntry is a Map, adjust this according to your data structure
              if (userEntry is Map && userEntry.containsKey('email')) {
                if (userEntry['email'] == useremail) {
                  print('มีข้อมูลแล้ว');
                  break;
                }
              }
              count++;
            }
          }
        }
      }

      print('count: $count');

      DatabaseReference checkcountuserRoutesRef =
          FirebaseDatabase.instance.ref('User/$count/Routes');
      int routeCount = 0;
      DateTime now = DateTime.now();
      String formattedDateTime = now.toString().substring(0, 19);
      DatabaseEvent eventname = await checkcountuserRoutesRef.once();
      if (eventname.snapshot.exists) {
        DataSnapshot snapshot = eventname.snapshot;

        // Assuming that 'Routes' is a list or map that can be iterated over
        if (eventname.snapshot.exists) {
          // Here, we are iterating over the children of Routes and incrementing routeCount
          eventname.snapshot.children.forEach((child) {
            routeCount++;
          });
        }
      }
      print('hi');
      print('Route count: $routeCount');

      if (routeCount == 0) {
        checkcountuserRoutesRef.child('1').set({
          'start': '${keystation1}',
          'end': '${keystation2}',
          'created_date': formattedDateTime,
        }).then((_) {
          print('Transaction 1 committed.');
        }).catchError((error) {
          print('An error occurred: $error');
        });
      } else if (routeCount > 0) {
        checkcountuserRoutesRef.child('${routeCount + 1}').set({
          'start': '${keystation1}',
          'end': '${keystation2}',
          'created_date': formattedDateTime,
        }).then((_) {
          print('Transaction other committed.');
        }).catchError((error) {
          print('An error occurred: $error');
        });
      }
    } else {
      print('user is guest');
    }
  }

  Future<void> timetable() async {
    DatabaseReference timetableRef = FirebaseDatabase.instance.ref('Timetable');

    timetableRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      timetableList = [];

      snapshot.children.forEach((child) {
        String? id = child.key as String?;
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;

        // Extract time details
        data.forEach((time, timeDetails) {
          List<String> timeList =
              (timeDetails as List).map((e) => e.toString()).toList();
          String timeDetail = timeList.join(", ");

          Map<String, dynamic> entry = {
            'ID': id,
            'Time': time.toString(),
            'TimeDetail': timeDetail,
          };

          timetableList.add(entry);
        });
      });

      // Sort the timetable list by time
      timetableList.sort((a, b) => a['Time'].compareTo(b['Time']));

      // Print sorted timetableList
      timetableList.forEach((entry) {
        print(
            'ID: ${entry['ID']}, Time: ${entry['Time']}, Time Detail: ${entry['TimeDetail']}');
      });

      print('Timetable List: $timetableList');
    });
  }

  Future<void> Reseteveythingnew() async{
    print('Reset');
 pointmarkpolyline1 = [];
   pointmarkpolyline2 = [];
   pathways1 = [];
   pathways2 = [];
   station = [];
   yourpathway1 = [];
   yourpathway2 = [];
   namepathway1 = [];
   namepathway2 = [];
   successyourway = [];
   Bike = [];
   Bus = [];
   Taxi = [];
   Van = [];
   Omnibus = [];
   Train = [];
   BTS = [];
   MRT = [];
   successfac = [];
   commentList = [];
   Landmarkdata = [];
   namestationfirst = '';
   namestationlast = '';
   street = '';
   exitdoor;
   indoor;
   mycategory = '';
   lat = "";
   lon = "";
   alt = 0;
   distance = 0;
   mark;
   markme;
   isLoading = false;
   isopenMap = false;
   isIconVisible = false;
   isExpanded1 = false;
   isExpanded2 = false;
   isExpanded3 = false;
   isExpanded4 = false;
   isBikeDataVisible = false;
   isBusDataVisible = false;
   isTaxiDataVisible = false;
   isVanDataVisible = false;
   isOmnibusVisible = false;
   isTrainVisible = false;
   isBTSVisible = false;
   isMRTVisible = false;
   futureCompleted = false;
   changeoutpathway = false;
   startengine = false;
   checkend = false;
   success_station = false;
   checknearstation = false;
   checkconfirmgo = false;
   checkbeforelatlon = false;
   checkcompletearrviefirststation = false;
   checkcompletearrvielaststation = false;
   checkmyselfadd = false;
   checkuploaddataway = false;
   isButtonstart = true;
   endcheck = false;
   endcheck2 = false;
   endcheck3 = false;
   textFieldReadOnly = false;
   checknearstation2 = false;
   dataSearch = [];
   ttimetext = '';
   beforelatlon = ["", ""];
   mylocation = {'start': [], 'end': []};
   startname = {'start': '', 'end': ''};
   nearfirststation = {};
   nearlaststation = {};
  locationtofirststation = [];
   itsme = [];
   nearstation2 = [];
  dropdownValue;
   dropdownValuelandmark;
   dropdownItems = [];
  selectedVehicle = ''; 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: isopenMap
                  ? NeverScrollableScrollPhysics()
                  : null, // กำหนดว่าถ้า isOpenMap เป็น true ให้ไม่สามารถเลื่อนได้
              children: [
                buildFirstTabContent(),
                buildSecondTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showmap() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          // Handle tap to close the dialog here
        },
        child: Container(
          color: Colors.black.withOpacity(0.5), // Overlay effect
          child: Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.78,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            LongdoMapWidget(
                              apiKey: "fdd00a0426fcf1019f3b442d5d8ed7dc",
                              key: map,
                              eventName: [
                                JavascriptChannel(
                                  name: "ready",
                                  onMessageReceived:
                                      (JavascriptMessage message) async {
                                    // Your ready event handling code here
                                    print("ready click");
                                    print(mylocation['start'][0]['lat']);
                                    print(mylocation['start'][0]['lon']);
                                    var startlat =
                                        mylocation['start'][0]['lat'];
                                    var startlon =
                                        mylocation['start'][0]['lon'];
                                    var endlat = mylocation['end'][0]['lat'];
                                    var endlon = mylocation['end'][0]['lon'];

                                    // map.currentState?.call(
                                    //     "Route.add",
                                    //     args: [
                                    //       {
                                    //         "lat": startlat,
                                    //         "lon": startlon,
                                    //       }
                                    //     ]);
                                    // map.currentState?.call(
                                    //     "Route.add",
                                    //     args: [
                                    //       {
                                    //         "lat": endlat,
                                    //         "lon": endlon,
                                    //       }
                                    //     ]);
                                    // map.currentState
                                    //     ?.call("Route.search");
                                    await checktimetogo(
                                        mylocation['start'][0]['lon'],
                                        mylocation['start'][0]['lat'],
                                        mylocation['end'][0]['lon'],
                                        mylocation['end'][0]['lat']);
                                    if (startengine == true) {
                                      await getPolylineData();
                                    }

                                    var lay = map.currentState
                                        ?.LongdoStatic("Layers", 'RASTER_POI');
                                    if (lay != null) {
                                      print("ready");
                                      map.currentState
                                          ?.call('Layers.setBase', args: [lay]);
                                    }
                                    setState(() {
                                      map.currentState?.call("location", args: [
                                        {
                                          "lon": startlon,
                                          "lat": startlat,
                                        }
                                      ]);
                                    });
                                  },
                                ),
                                JavascriptChannel(
                                  name: "click",
                                  onMessageReceived: (message) {
                                    // Handle icon click event here
                                    print("Icon clicked");
                                    // สามารถเรียกฟังก์ชันหรือกระทำอื่นๆ ที่ต้องการทำเมื่อไอคอนถูกคลิกได้ที่นี่
                                  },
                                ),
                              ],
                              options: {
                                "ui": Longdo.LongdoStatic(
                                  "UiComponent",
                                  "Mobile",
                                )
                              },
                            ),
                            Positioned(
                              bottom: 30,
                              right: 0,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end, // จัดชิดด้านขวา
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      showlandmark(context);
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5, bottom: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                Color.fromARGB(255, 185, 1, 1),
                                            width: 2,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/landmark.png',
                                          width: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      print("beforelatlon ${beforelatlon}");
                                      print(
                                          '---------------------------------');
                                      setState(() {
                                        map.currentState
                                            ?.call("location", args: [
                                          {
                                            "lon": beforelatlon[1],
                                            "lat": beforelatlon[0],
                                          }
                                        ]);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8, right: 5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                Color.fromARGB(255, 185, 1, 1),
                                            width: 2,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/man.png',
                                          width: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      print(
                                          "nearfirststation ${nearfirststation}");
                                      print(
                                          '---------------------------------');
                                      setState(() {
                                        map.currentState
                                            ?.call("location", args: [
                                          {
                                            "lon": nearfirststation['lon'],
                                            "lat": nearfirststation['lat'],
                                          }
                                        ]);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 185, 1, 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                      255, 71, 71, 71)
                                                  .withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              offset: Offset(0,
                                                  1), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            "สถานีต้นทาง",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'custom_font',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      print(
                                          "nearlaststation ${nearlaststation}");
                                      print(
                                          '---------------------------------');
                                      setState(() {
                                        map.currentState
                                            ?.call("location", args: [
                                          {
                                            "lon": nearlaststation['lon'],
                                            "lat": nearlaststation['lat'],
                                          }
                                        ]);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 185, 1, 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                      255, 71, 71, 71)
                                                  .withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              offset: Offset(0,
                                                  1), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            "สถานีปลายทาง",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'custom_font',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 196, 25, 13),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("เส้นทางการเดินในสถานี",
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontFamily: 'custom_font')),
                                      // SingleChildScrollView(
                                      //   scrollDirection: Axis.horizontal,
                                      //   child: Row(
                                      //     children: [
                                      //       IconButton(
                                      //         onPressed: () {
                                      //           _shownotifition('คุณได้ถึงสถานี ${namestationlast} แล้ว');
                                      //         },
                                      //         icon: Icon(
                                      //           Icons.search,
                                      //           color: Color.fromARGB(
                                      //               255, 196, 25, 13),
                                      //           size: 15,
                                      //         ),
                                      //       ),
                                      //       IconButton(
                                      //         onPressed: () {
                                      //           _shownotifition('คุณเดินผิดทาง กรุณากลับเข้าเส้นทาง');
                                      //         },
                                      //         icon: Icon(
                                      //           Icons.search,
                                      //           color: Color.fromARGB(
                                      //               255, 196, 25, 13),
                                      //           size: 15,
                                      //         ),
                                      //       ),
                                      //       IconButton(
                                      //         icon: Icon(
                                      //             Icons.delete_forever_rounded,
                                      //             color: Color.fromARGB(
                                      //                 255, 175, 15, 4)),
                                      //         iconSize: 25,
                                      //         onPressed: () {
                                      //           setState(() {
                                      //             // _shownotifition(
                                      //             //     'คุณได้ถึงสถานี ${namestationlast} แล้ว');
                                      //             successyourway.removeAt(0);
                                      //           });
                                      //         },
                                      //       ),
                                      //     ],
                                      //   ),
                                      // )

                                      if (checkend == false)
                                        Align(
                                          child: IconButton(
                                            icon: Icon(
                                                Icons.delete_forever_rounded,
                                                color: Color.fromARGB(
                                                    255, 175, 15, 4)),
                                            iconSize: 25,
                                            onPressed: () {
                                              showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Dialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child: Stack(
                                                                    clipBehavior:
                                                                        Clip.none,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      Container(
                                                                        height:
                                                                            200, // ปรับความสูงเพื่อให้มีพื้นที่สำหรับปุ่ม
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            20,
                                                                            50,
                                                                            20,
                                                                            20),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              "คุณต้องการยกเลิกเส้นทางใช่หรือไม่ ?",
                                                                              style: TextStyle(
                                                                                fontFamily: 'custom_font',
                                                                                fontSize: 28,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความและปุ่ม
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Color.fromARGB(255, 175, 15, 4),
                                                                                    foregroundColor: Colors.white,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    // ทำงานเมื่อกดปุ่ม "ใช่"
                                                                                    Reseteveythingnew();
                                                                                    Navigator.of(context).pop(); // ปิด Dialog
                                                                                  },
                                                                                  child: Text(
                                                                                    "ใช่",
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'custom_font',
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 10),
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.black,
                                                                                    foregroundColor: Colors.white,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    // ทำงานเมื่อกดปุ่ม "ไม่"
                                                                                    Navigator.of(context).pop(); // ปิด Dialog
                                                                                  },
                                                                                  child: Text(
                                                                                    "ไม่",
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'custom_font',
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top:
                                                                            -100,
                                                                        child: Image
                                                                            .asset(
                                                                          "assets/redtrain.png",
                                                                          width:
                                                                              150,
                                                                          height:
                                                                              150,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                            },
                                          ),
                                        ),
                                      if (checkend == true)
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: Icon(
                                                Icons.check_circle_rounded,
                                                color: Color.fromARGB(
                                                    255, 7, 145, 30)),
                                            iconSize: 25,
                                            onPressed: () {
                                              setState(() {
                                                // _shownotifition(
                                                //     'คุณได้ถึงสถานี ${namestationlast} แล้ว');
                                                successyourway.removeAt(0);
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              //Listview
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      FutureBuilder<void>(
                                        future: futureCompleted
                                            ? null
                                            : Future.delayed(
                                                    Duration(seconds: 15))
                                                .then((_) {
                                                futureCompleted = true;
                                              }), // รอสิบวินาที โดยตรวจสอบตัวแปร futureCompleted เพื่อหยุดการเรียก Future.delayed หลังจากทำงานเสร็จแล้ว
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // แสดง UI สำหรับรอสิบวินาที
                                            return CircularProgressIndicator(); // หรืออะไรก็ตามที่คุณต้องการแสดงในช่วงรอ
                                          } else {
                                            // เมื่อรอครบสิบวินาทีแล้วให้ทำ StreamBuilder
                                            return StreamBuilder<List>(
                                              stream: _successyourwayController
                                                  .stream,
                                              initialData: successyourway,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List>
                                                      snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data!.isNotEmpty) {
                                                  // สร้าง UI โดยใช้ snapshot.data
                                                  return Stack(
                                                    children: [
                                                      Column(
                                                        children: snapshot.data!
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          int index = entry.key;
                                                          var point =
                                                              entry.value;
                                                          Widget listItem =
                                                              Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: ListTile(
                                                              leading:
                                                                  Container(
                                                                width: point[
                                                                            'width'] !=
                                                                        null
                                                                    ? point['width']
                                                                        .toDouble()
                                                                    : 15,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: parseColor(
                                                                      point[
                                                                          'color']), // Circle color
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  point['name'],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'custom_font')),
                                                              subtitle: point[
                                                                          'time'] !=
                                                                      "0"
                                                                  ? Text(
                                                                      '${point['time']} เมตร')
                                                                  : null,
                                                              onTap: () {
                                                                // Handle tap event here
                                                              },
                                                            ),
                                                          );

                                                          // Check if it's not the first or last item
                                                          if (index != 0 &&
                                                              index !=
                                                                  snapshot.data!
                                                                          .length -
                                                                      1) {
                                                            // Apply Positioned only if it's not the first or last item
                                                            return Stack(
                                                              children: [
                                                                listItem,
                                                                Positioned(
                                                                  top: 0,
                                                                  bottom: 0,
                                                                  left:
                                                                      32, // Adjust this value to align with the leading circle's center
                                                                  child:
                                                                      Container(
                                                                    width: 2.5,
                                                                    color: parseColor(
                                                                        point[
                                                                            'color']), // Line color
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          } else {
                                                            // Return the list item without Positioned for the first and last items
                                                            return listItem;
                                                          }
                                                        }).toList(),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  // สร้าง UI สำหรับกรณีที่ successyourway ว่างเปล่าหรือไม่มีข้อมูล
                                                  return Center(
                                                    child: Text(
                                                      'ไม่มีข้อมูลแล้ว',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'custom_font',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 5, // Adjust the position as you see fit
                  right: 30, // Adjust the position as you see fit
                  child: IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.close),
                    color:
                        const Color.fromARGB(255, 168, 19, 8), // Example icon
                    onPressed: () {
                      // Handle the icon tap
                      setState(() {
                        isopenMap = false;
                        checkconfirmgo = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showlandmark(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 600, // ปรับความสูงเพื่อให้มีพื้นที่สำหรับปุ่ม
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FractionallySizedBox(
                            widthFactor: 1,
                            child: Image.asset(
                              "assets/giff2.gif",
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('เลือกสถานี',
                                style: TextStyle(
                                  fontFamily: 'custom_font',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )),
                            DropdownButton<String>(
                              value: dropdownValuelandmark,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    dropdownValuelandmark = newValue;
                                    print("ค่าคือ : ${dropdownValuelandmark}");
                                  });
                                  // ใส่โค้ดที่ต้องการให้ทำเมื่อเลือก dropdown
                                  // สามารถเรียกฟังก์ชันหรือแสดงข้อมูลเพิ่มเติมตามต้องการ
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: namestationfirst,
                                  child:
                                      Text(namestationfirst + " (สถานีต้นทาง)"),
                                ),
                                DropdownMenuItem(
                                  value: namestationlast,
                                  child:
                                      Text(namestationlast + " (สถานีปลายทาง)"),
                                ),
                              ],
                              dropdownColor:
                                  Colors.grey[200], // สีพื้นหลังของ dropdown
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.red,
                              ),
                              iconSize: 32, // ขนาดของไอคอน dropdown
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'custom_font',
                                fontSize: 20,
                              ), //
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 12),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              border: Border.all(
                                color: Color.fromARGB(255, 238, 238, 238),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors
                                              .white, // เปลี่ยนสีตามความต้องการ
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/star.png",
                                            width: 30,
                                          ),
                                          onPressed: () async {
                                            print(
                                                "dropdownValuelandmark : ${dropdownValuelandmark}");
                                            if (dropdownValuelandmark ==
                                                namestationfirst) {
                                              await getlandmark(
                                                  "travel",
                                                  nearfirststation['lat']!,
                                                  nearfirststation['lon']!,
                                                  setState);
                                            } else if (dropdownValuelandmark ==
                                                namestationlast) {
                                              await getlandmark(
                                                  "travel",
                                                  nearlaststation['lat']!,
                                                  nearlaststation['lon']!,
                                                  setState);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.white,
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 50,
                                                                  20, 20),
                                                          child: Text(
                                                            "กรุณาเลือกสถานีก่อนนะ!!!",
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'custom_font',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -100,
                                                          child: Image.asset(
                                                            "assets/redtrain.png",
                                                            width: 150,
                                                            height: 150,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors
                                              .white, // เปลี่ยนสีตามความต้องการ
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/cutlery.png",
                                            width: 30,
                                          ),
                                          onPressed: () async {
                                            if (dropdownValuelandmark ==
                                                namestationfirst) {
                                              await getlandmark(
                                                  "restaurant",
                                                  nearfirststation['lat']!,
                                                  nearfirststation['lon']!,
                                                  setState);
                                            } else if (dropdownValuelandmark ==
                                                namestationlast) {
                                              await getlandmark(
                                                  "restaurant",
                                                  nearlaststation['lat']!,
                                                  nearlaststation['lon']!,
                                                  setState);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.white,
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 50,
                                                                  20, 20),
                                                          child: Text(
                                                            "กรุณาเลือกสถานีก่อนนะ!!!",
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'custom_font',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -100,
                                                          child: Image.asset(
                                                            "assets/redtrain.png",
                                                            width: 150,
                                                            height: 150,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors
                                              .white, // เปลี่ยนสีตามความต้องการ
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/bed.png",
                                            width: 30,
                                          ),
                                          onPressed: () async {
                                            if (dropdownValuelandmark ==
                                                namestationfirst) {
                                              await getlandmark(
                                                  "hotel",
                                                  nearfirststation['lat']!,
                                                  nearfirststation['lon']!,
                                                  setState);
                                            } else if (dropdownValuelandmark ==
                                                namestationlast) {
                                              await getlandmark(
                                                  "hotel",
                                                  nearlaststation['lat']!,
                                                  nearlaststation['lon']!,
                                                  setState);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.white,
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 50,
                                                                  20, 20),
                                                          child: Text(
                                                            "กรุณาเลือกสถานีก่อนนะ!!!",
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'custom_font',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -100,
                                                          child: Image.asset(
                                                            "assets/redtrain.png",
                                                            width: 150,
                                                            height: 150,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors
                                              .white, // เปลี่ยนสีตามความต้องการ
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/police.png",
                                            width: 30,
                                          ),
                                          onPressed: () async {
                                            if (dropdownValuelandmark ==
                                                namestationfirst) {
                                              await getlandmark(
                                                  "police",
                                                  nearfirststation['lat']!,
                                                  nearfirststation['lon']!,
                                                  setState);
                                            } else if (dropdownValuelandmark ==
                                                namestationlast) {
                                              await getlandmark(
                                                  "police",
                                                  nearlaststation['lat']!,
                                                  nearlaststation['lon']!,
                                                  setState);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.white,
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 50,
                                                                  20, 20),
                                                          child: Text(
                                                            "กรุณาเลือกสถานีก่อนนะ!!!",
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'custom_font',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -100,
                                                          child: Image.asset(
                                                            "assets/redtrain.png",
                                                            width: 150,
                                                            height: 150,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors
                                              .white, // เปลี่ยนสีตามความต้องการ
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/hospi.png",
                                            width: 30,
                                          ),
                                          onPressed: () async {
                                            if (dropdownValuelandmark ==
                                                namestationfirst) {
                                              await getlandmark(
                                                  "hospital",
                                                  nearfirststation['lat']!,
                                                  nearfirststation['lon']!,
                                                  setState);
                                            } else if (dropdownValuelandmark ==
                                                namestationlast) {
                                              await getlandmark(
                                                  "hospital",
                                                  nearlaststation['lat']!,
                                                  nearlaststation['lon']!,
                                                  setState);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.white,
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 50,
                                                                  20, 20),
                                                          child: Text(
                                                            "กรุณาเลือกสถานีก่อนนะ!!!",
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'custom_font',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -100,
                                                          child: Image.asset(
                                                            "assets/redtrain.png",
                                                            width: 150,
                                                            height: 150,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors
                                              .white, // เปลี่ยนสีตามความต้องการ
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/7-11.png",
                                            width: 30,
                                          ),
                                          onPressed: () async {
                                            if (dropdownValuelandmark ==
                                                namestationfirst) {
                                              await getlandmark(
                                                  "7-11",
                                                  nearfirststation['lat']!,
                                                  nearfirststation['lon']!,
                                                  setState);
                                            } else if (dropdownValuelandmark ==
                                                namestationlast) {
                                              await getlandmark(
                                                  "7-11",
                                                  nearlaststation['lat']!,
                                                  nearlaststation['lon']!,
                                                  setState);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height: 200,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.white,
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(20, 50,
                                                                  20, 20),
                                                          child: Text(
                                                            "กรุณาเลือกสถานีก่อนนะ!!!",
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'custom_font',
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -100,
                                                          child: Image.asset(
                                                            "assets/redtrain.png",
                                                            width: 150,
                                                            height: 150,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 2,
                                  color: Color.fromARGB(255, 238, 238, 238),
                                ),
                                Expanded(
                                    child: Container(
                                  child: ListView.builder(
                                    itemCount: Landmarkdata.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 238, 238, 238),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                                Landmarkdata[index]['name'],
                                                style: TextStyle(
                                                    fontSize: 19,
                                                    fontFamily: 'custom_font',
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: FutureBuilder<String>(
                                              future: dropdownValuelandmark ==
                                                      namestationfirst
                                                  ? calculateDistance2([
                                                      nearfirststation['lat']!,
                                                      nearfirststation['lon']!
                                                    ], [
                                                      Landmarkdata[index]
                                                          ['lat'],
                                                      Landmarkdata[index]['lon']
                                                    ])
                                                  : dropdownValuelandmark ==
                                                          namestationlast
                                                      ? calculateDistance2([
                                                          nearlaststation[
                                                              'lat']!,
                                                          nearlaststation[
                                                              'lon']!
                                                        ], [
                                                          Landmarkdata[index]
                                                              ['lat'],
                                                          Landmarkdata[index]
                                                              ['lon']
                                                        ])
                                                      : null,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // กำลังโหลดข้อมูล, แสดง progress indicator หรือข้อความว่ากำลังโหลด
                                                  return Text(
                                                    "กำลังคำนวณ...",
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'custom_font'),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  // ถ้ามีข้อผิดพลาดในการคำนวณ, แสดงข้อความข้อผิดพลาด
                                                  return Text(
                                                    "Error: ${snapshot.error}",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14),
                                                  );
                                                } else {
                                                  // ข้อมูลพร้อม, แสดงระยะห่าง
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ระยะห่าง ${snapshot.data}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'custom_font'),
                                                      ),
                                                      
                                                    ],
                                                  );
                                                }
                                              },
                                            ),
                                            leading: CircleAvatar(
                                                backgroundColor: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                child: IconButton(
                                                  icon: Image.network(
                                                    'https://mmmap15.longdo.com/mmmap/images/icons_4x/${Landmarkdata[index]['icon']}',
                                                    width: 50,
                                                  ),
                                                  onPressed: () async {},
                                                )),
                                            trailing: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 238, 238, 238),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: Image.asset(
                                                  'assets/globe.png',
                                                  width: 35,
                                                ),
                                                onPressed: () async {
                                                  await map.currentState
                                                      ?.call("location", args: [
                                                    {
                                                      "lon": Landmarkdata[index]
                                                          ['lon'],
                                                      "lat": Landmarkdata[index]
                                                          ['lat'],
                                                    }
                                                  ]);

                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: -100,
                    child: Image.asset(
                      "assets/redtrain.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget showComment(User? user) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded3 = !isExpanded3;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'คอมเมนต์',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded3 ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: const Color.fromARGB(255, 207, 207, 207),
                  size: 35,
                ),
              ],
            ),
          ),
          if (isExpanded3)
            if (futureCompleted == true)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 500,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.fromARGB(255, 238, 238, 238),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'คอมเมนต์ของคุณสำหรับทางออกที่ ${dropdownValue}',
                                    hintStyle: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 35.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 238, 238, 238),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'custom_font',
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      // โค้ดสำหรับการส่งข้อความ
                                      // สามารถเพิ่มโค้ดที่ทำงานเมื่อกดปุ่มส่งได้ที่นี่
                                      print('Send');
                                      if (_messageController.text.isNotEmpty) {
                                        if (user?.displayName != null) {
                                          showCircularProgressIndicator(
                                              context);
                                        }
                                        sendcomment(
                                          _messageController.text,
                                          dropdownValue,
                                          mycategory,
                                          user?.displayName!,
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding: EdgeInsets.all(10),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: double.infinity,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white,
                                                    ),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            20, 50, 20, 20),
                                                    child: Text(
                                                      "กรุณากรอกข้อความก่อนส่งด้วยครับ!!",
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'custom_font',
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -100,
                                                    child: Image.asset(
                                                      "assets/redtrain.png",
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/send.png', // ที่อยู่ของไฟล์รูปภาพ
                                      width: 32, // กำหนดความกว้างของรูปภาพ
                                      height: 32, // กำหนดความสูงของรูปภาพ
                                      // กำหนดสีของรูปภาพ
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Divider(
                              thickness: 2, // กำหนดความหนาของเส้น

                              color: Color.fromARGB(
                                  255, 238, 238, 238), // กำหนดสีของเส้น
                            ),
                          ),
                          Container(
                            height: 355,
                            child: commentList.isEmpty
                                ? Center(
                                    child: Text(
                                      'ไม่มีคอมเมนต์ใดๆ ในขณะนี้',
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: commentList.length,
                                    itemBuilder: (context, index) {
                                      int commentIndex = index;
                                      bool isLiked = isLikedMap
                                              .containsKey(commentIndex)
                                          ? isLikedMap[commentIndex]!
                                          : false; // สร้างตัวแปรเพื่อเก็บสถานะการกดไลค์ของแต่ละรายการ ListTile

                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return ListTile(
                                            title: Container(
                                              height: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 238, 238, 238),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        " : ${commentList[index]['message']}",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'custom_font',
                                                          fontSize: 20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 40),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        if (user?.displayName !=
                                                            null)
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.favorite,
                                                              color: isLiked
                                                                  ? Colors.red
                                                                  : Colors.grey,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                isLiked =
                                                                    !isLiked;
                                                                print(index);
                                                                if (isLiked) {
                                                                  updatelikecomment(
                                                                    index,
                                                                    dropdownValue,
                                                                    mycategory,
                                                                    user?.displayName!,
                                                                  );
                                                                  isLikedMap[
                                                                          commentIndex] =
                                                                      isLiked;
                                                                } else {
                                                                  removedlikecomment(
                                                                    index,
                                                                    dropdownValue,
                                                                    mycategory,
                                                                    user?.displayName!,
                                                                  );
                                                                  isLikedMap[
                                                                          commentIndex] =
                                                                      isLiked;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            print(index);
                                                            showpeoplelike(
                                                                index,
                                                                dropdownValue,
                                                                mycategory);
                                                          },
                                                          child: Text(
                                                            "Like : ${commentList[index]['likes']} คน",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'custom_font',
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            subtitle: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "By : ${commentList[index]['user']}  ${commentList[index]['time']}",
                                                  style: TextStyle(
                                                    fontFamily: 'custom_font',
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
          Visibility(
            visible: !isExpanded3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showPayment() {
    Divider(
      thickness: 2,
      color: Color.fromARGB(255, 238, 238, 238),
    );
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded4 = !isExpanded4;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'รูปแบบการชำระเงิน',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded4 ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: const Color.fromARGB(255, 207, 207, 207),
                  size: 35,
                ),
              ],
            ),
          ),
          if (isExpanded4)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/money.png', width: 45),
                                ],
                              ),
                              SizedBox(width: 15),
                              Column(
                                children: [
                                  Text(
                                    'เงินสด เหรียญ/ธนบัตร',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/credit-card.png',
                                      width: 45),
                                ],
                              ),
                              SizedBox(width: 15),
                              Column(
                                children: [
                                  Text(
                                    'บัตรเครดิต',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Image.asset('assets/ticket-machine.png',
                                      width: 45, height: 35),
                                ],
                              ),
                              SizedBox(width: 15),
                              Column(
                                children: [
                                  Text(
                                    'ตู้ซื้อตั๋วอัตโนมัติ',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Visibility(
            visible: !isExpanded4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: Text(
                    'คลิกเพื่อดูรายละเอียด',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showfac() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded1 = !isExpanded1;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'สิ่งอำนวยความสะดวก',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded1 ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: const Color.fromARGB(255, 207, 207, 207),
                  size: 35,
                ),
              ],
            ),
          ),
          if (isExpanded1)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color.fromARGB(255, 238, 238, 238),
                        width: 1.5,
                      ),
                    ),
                    child: successfac
                            .isEmpty // ตรวจสอบว่า facilities ว่างหรือไม่
                        ? Container()
                        : Container(
                            height: 300,
                            child: ListView.builder(
                              itemCount: successfac.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Image.asset(
                                    "${pictureofFacility(successfac[index]['id'])}",
                                    width: 28,
                                  ),
                                  title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            "| ",
                                            style: TextStyle(
                                              fontFamily: 'custom_font',
                                              color: Colors.grey,
                                              fontSize: 19,
                                            ),
                                          ),
                                          Text(
                                            '${successfac[index]['name']}',
                                            style: TextStyle(
                                              fontFamily: 'custom_font',
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          Visibility(
            visible: !isExpanded1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: Text(
                    'คลิกเพื่อดูรายละเอียด',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showtranport() {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (!isExpanded2) {}
                isExpanded2 = !isExpanded2;
                // print(isExpanded2);
                isBikeDataVisible = false;
                isBusDataVisible = false;
                isTaxiDataVisible = false;
                isVanDataVisible = false;
                isOmnibusVisible = false;
                isTrainVisible = false;
                isBTSVisible = false;
                isMRTVisible = false;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    'ข้อมูลรถขนส่งโดยสาร',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded2 ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: const Color.fromARGB(255, 207, 207, 207),
                  size: 35,
                ),
              ],
            ),
          ),
          if (isExpanded2)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (Bike.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('Bike'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isBikeDataVisible ? 80.0 : 70.0,
                                      height: isBikeDataVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isBikeDataVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/bike.png',
                                          width: 55,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'วินมอไซต์',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (Bus.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('Bus'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isBusDataVisible ? 80.0 : 70.0,
                                      height: isBusDataVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isBusDataVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/bus.png',
                                          width: 60,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'รถเมย์',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (Taxi.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('Taxi'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isTaxiDataVisible ? 80.0 : 70.0,
                                      height: isTaxiDataVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isTaxiDataVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/taxi.png',
                                          width: 60,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'แท็กซี่',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (Van.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('Van'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isVanDataVisible ? 80.0 : 70.0,
                                      height: isVanDataVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isVanDataVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/van.png',
                                          width: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'รถตู้',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (Omnibus.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('Omnibus'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isOmnibusVisible ? 80.0 : 70.0,
                                      height: isOmnibusVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isOmnibusVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/omibus.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'รถสองแถว',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (Train.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('Train'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isTrainVisible ? 80.0 : 70.0,
                                      height: isTrainVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isTrainVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/traintran.png',
                                          width: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'รถไฟ',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (BTS.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('BTS'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isBTSVisible ? 80.0 : 70.0,
                                      height: isBTSVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isBTSVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/BTS.png',
                                          width: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'BTS',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (MRT.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => toggleDataVisibility('MRT'),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: isMRTVisible ? 80.0 : 70.0,
                                      height: isMRTVisible ? 80.0 : 70.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isMRTVisible
                                            ? Color.fromARGB(255, 241, 241, 241)
                                            : Colors.white,
                                        border: Border.all(
                                          color: Color.fromARGB(
                                              255, 240, 240, 240),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/MRT.png',
                                          width: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'MRT',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Visibility(
            visible: isExpanded2 &&
                (isBikeDataVisible ||
                    isBusDataVisible ||
                    isTaxiDataVisible ||
                    isVanDataVisible ||
                    isOmnibusVisible ||
                    isTrainVisible ||
                    isBTSVisible ||
                    isMRTVisible),
            child: Column(
              children: [
                // Add data widgets here for each vehicle type
                if (isBikeDataVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/bike.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'วินมอไซต์' + street,
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: Bike.length > 0
                                  ? Bike.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ Bike.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (Bike.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Bike[index]['line'] != null
                                              ? Bike[index]['line']
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      Bike[index]['name'] != null
                                          ? Bike[index]['name']
                                          : '',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      Bike[index]['time'] != null
                                          ? 'เปิดให้บริการ ${Bike[index]['time']}'
                                          : 'เปิดให้บริการไม่ทราบเวลาแน่ชัด',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isBusDataVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/bus.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รถเมย์' + street,
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: Bus.length > 0
                                  ? Bus.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ Bus.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (Bus.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Bus[index]['line'].isNotEmpty
                                              ? Bus[index]['line'][index]
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${Bus[index]['station'][index]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'เปิดให้บริการ ${Bus[index]['time']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isTaxiDataVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/taxi.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'แท็กซี่' + street,
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: Taxi.length > 0
                                  ? Taxi.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ Taxi.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (Taxi.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Taxi[index]['line'] != null
                                              ? Taxi[index]['line']
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      Taxi[index]['name'] != null
                                          ? Taxi[index]['name']
                                          : 'ไม่มีสาย',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      Taxi[index]['time'] != null
                                          ? 'เปิดให้บริการ ${Taxi[index]['time']}'
                                          : 'เปิดให้บริการไม่ทราบเวลาแน่ชัด',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isVanDataVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/van.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รถตู้' + street,
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: Van.length > 0
                                  ? Van.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ Bus.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (Van.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Van[index]['line'] == "[ ,]"
                                              ? Van[index]['line'][index]
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${Van[index]['station'][index]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'เปิดให้บริการ ${Van[index]['time']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isOmnibusVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/omibus.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รถสองแถว' + street,
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: Omnibus.length > 0
                                  ? Omnibus.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ Omnibus.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (Omnibus.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Omnibus[index]['line'].isNotEmpty
                                              ? Omnibus[index]['line'][index]
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${Omnibus[index]['station'][index]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'เปิดให้บริการ ${Omnibus[index]['time']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isTrainVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/traintran.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รถไฟ',
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: Train.length > 0
                                  ? Train.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ Omnibus.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (Train.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Train[index]['line'].isNotEmpty
                                              ? Train[index]['line'][index]
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${Train[index]['station'][index]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'เปิดให้บริการ ${Train[index]['time']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isBTSVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/BTS.png',
                                    ),

                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รถสองแถว',
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: BTS.length > 0
                                  ? BTS.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ BTS.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (BTS.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          BTS[index]['line'].isNotEmpty
                                              ? BTS[index]['line']
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${BTS[index]['station'][index]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'เปิดให้บริการ ${BTS[index]['time']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isMRTVisible)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromARGB(255, 230, 230, 230),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Left Element (Image)
                              Container(
                                width: 40, // Adjust the width as needed
                                height: 40, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 223, 223, 223),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/MRT.png'), // Replace with your image asset
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between image and text

                              // Center Element (Text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MRT',
                                      style: TextStyle(
                                        fontFamily: 'custom_font',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 18,
                              left:
                                  5, // Add left padding to separate the line from text
                            ),
                            child: Container(
                              height: 1.5, // Set the height of the line
                              color: const Color.fromARGB(255, 230, 230,
                                  230), // Set the color of the line
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: MRT.length > 0
                                  ? MRT.length
                                  : 1, // เช็คจำนวนรายการ ถ้ามีข้อมูลให้ใช้ MRT.length แต่ถ้าไม่มีให้ใช้ 1 เพื่อให้ ListView ว่าง
                              itemBuilder: (BuildContext context, int index) {
                                if (MRT.length == 0) {
                                  // ถ้าไม่มีข้อมูลให้แสดงข้อความว่าง
                                  return ListTile(
                                    title: Text('ไม่มีข้อมูล'),
                                  );
                                } else {
                                  // ถ้ามีข้อมูลให้แสดงข้อมูลตามปกติ
                                  return ListTile(
                                    leading: Container(
                                      width:
                                          70, // Adjust the width as needed for the circular background
                                      height:
                                          35, // Adjust the height as needed for the circular background
                                      decoration: BoxDecoration(
                                        color: MRT[index]['station'][index] ==
                                                'สายสีเหลือง'
                                            ? Colors.yellow
                                            : MRT[index]['station'][index] ==
                                                    'สายสีน้ำเงิน'
                                                ? const Color.fromARGB(
                                                    255, 33, 37, 243)
                                                : MRT[index]['station']
                                                            [index] ==
                                                        'สายสีม่วง'
                                                    ? Colors.purple
                                                    : MRT[index]['station']
                                                                [index] ==
                                                            'สายสีชมพู'
                                                        ? Colors.pink
                                                        : MRT[index]['station']
                                                                    [index] ==
                                                                'สายสีส้ม'
                                                            ? Colors.orange
                                                            : MRT[index]['station']
                                                                        [
                                                                        index] ==
                                                                    'สายสีแดง'
                                                                ? Colors.red
                                                                : Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          MRT[index]['line'].isNotEmpty
                                              ? MRT[index]['line'][index]
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'custom_font',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${MRT[index]['station'][index]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'custom_font',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'เปิดให้บริการ ${MRT[index]['time']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'custom_font',
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          Visibility(
            visible: !isExpanded2 &&
                !(isBikeDataVisible ||
                    isBusDataVisible ||
                    isTaxiDataVisible ||
                    isVanDataVisible ||
                    isOmnibusVisible ||
                    isBTSVisible ||
                    isMRTVisible ||
                    isTrainVisible),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: Text(
                    'คลิกเพื่อดูรายละเอียด',
                    style: TextStyle(
                      fontFamily: 'custom_font',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color parseColor(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'blue':
        return Color.fromARGB(255, 130, 184, 255);
      case 'red':
        return const Color.fromARGB(255, 255, 17, 0);
      case 'purple':
        return Color.fromARGB(255, 242, 168, 255);
      default:
        return Colors.black; // Default color
    }
  }

  void showCircularProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context, rootNavigator: true).pop();
        });

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('กำลังโหลด...',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'custom_font')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showDialogWithRotatingGIF(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.78,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  children: [
                    // Your dialog content goes here
                  ],
                ),
              ),
              Positioned(
                top: -100,
                child: Image.asset(
                  "assets/load.gif",
                  width: 200,
                  height: 200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFirstTabContent() {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            SizedBox(
              height: 230,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 146, 4, 4),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user != null && user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : AssetImage('assets/dek.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      user != null ? user.displayName ?? 'Guest' : 'Guest',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'custom_font',
                      ),
                    ),
                    Text(
                      user != null ? user.email ?? '' : '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'custom_font',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Color.fromARGB(255, 175, 15, 4),
              ),
              title: Text('Logout',
                  style: TextStyle(fontSize: 18, fontFamily: 'custom_font')),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: Text(
                              "คุณต้องการออกจากระบบหรือไม่ ?",
                              style: TextStyle(
                                  fontSize: 24, fontFamily: 'custom_font'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: -100,
                            child: Image.asset(
                              "assets/redtrain.png",
                              width: 150,
                              height: 150,
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 175, 15, 4),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // รหัสที่จะทำงานเมื่อกดปุ่ม "ตกลง" นี่เช่นกัน
                                    logout();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Home(),
                                      ),
                                    );
                                  },
                                  child: Text('ตกลง',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'custom_font')),
                                ),
                                SizedBox(width: 5),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // ปิด Dialog เมื่อกดปุ่ม "ไม่"
                                  },
                                  child: Text('ไม่',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'custom_font')),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              // Calculate the opacity based on the scroll position
              double newOpacity = 1.0 - (scrollInfo.metrics.pixels / 200);
              newOpacity = newOpacity.clamp(
                  0.0, 1.0); // Ensure opacity is between 0 and 1

              // Update the opacity if it has changed
              if (newOpacity != imageOpacity) {
                setState(() {
                  imageOpacity = newOpacity;
                });
              }
            }
            return false;
          },
          child: Stack(
            children: [
              // Background image with opacity
              Opacity(
                opacity: imageOpacity,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/redline.PNG'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  child: IconButton(
                    onPressed: () {
                      // openDrawer();
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    icon: Icon(Icons.menu, color: Colors.white),
                    iconSize: 45.0, // You can adjust the size as needed
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.8, // Adjust the initial size as needed
                  minChildSize: 0.8, // Adjust the minimum size as needed
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 2500, // ปรับถ้าสูงเต็ม

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              children: [
                                //box1
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 230, 230, 230),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 15)),
                                            Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/dekwoman.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'คุณต้องการจะไปที่ไหน ?',
                                              style: TextStyle(
                                                fontFamily: 'custom_font',
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'โปรดเลือกจุดหมายปลายทางของคุณที่ต้องการ',
                                              style: TextStyle(
                                                fontFamily: 'custom_font',
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            // Existing input
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 14),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'จุดเริ่มต้น :',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: 'custom_font',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 30,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                        color: Color.fromARGB(
                                                            255, 248, 248, 248),
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            TextEditingController(
                                                                text: startname[
                                                                    'start']),
                                                        onTap: () {
                                                          if (!textFieldReadOnly) {
                                                            // ตรวจสอบว่า TextField สามารถแก้ไขได้หรือไม่
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Mymap_search(
                                                                  title:
                                                                      "start",
                                                                  mylo:
                                                                      mylocation,
                                                                  startname:
                                                                      startname,
                                                                  onLocationSelected:
                                                                      onLocationSelected,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        readOnly:
                                                            textFieldReadOnly, // กำหนดให้ TextField สามารถแก้ไขได้ตามค่าของ textFieldReadOnly
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        maxLines: 1,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'custom_font',
                                                          fontSize: startname[
                                                                          'start']!
                                                                      .length >
                                                                  40
                                                              ? 10
                                                              : startname['start']!
                                                                          .length >
                                                                      15
                                                                  ? 14
                                                                  : 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ), // Add spacing between the input and new content
                                            // New input with the same style as "เริ่มต้น :"
                                            Container(
                                              height: 30,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'ปลายทาง :',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: 'custom_font',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                        color: Color.fromARGB(
                                                            255, 248, 248, 248),
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            TextEditingController(
                                                                text: startname[
                                                                    'end']),
                                                        onTap: () {
                                                          if (!textFieldReadOnly) {
                                                            // ตรวจสอบว่า TextField สามารถแก้ไขได้หรือไม่

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Mymap_search(
                                                                  title: "end",
                                                                  mylo:
                                                                      mylocation,
                                                                  startname:
                                                                      startname,
                                                                  onLocationSelected:
                                                                      onLocationSelected,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        readOnly:
                                                            textFieldReadOnly, // กำหนดให้ TextField สามารถแก้ไขได้ตามค่าของ textFieldReadOnly
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'custom_font',
                                                          fontSize: startname[
                                                                          'end']!
                                                                      .length >
                                                                  40
                                                              ? 10
                                                              : startname['end']!
                                                                          .length >
                                                                      15
                                                                  ? 14
                                                                  : 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ), // Add spacing between the input and the button
                                            // Centered button at the bottom
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                width:
                                                    150, // Set the width of the button
                                                height:
                                                    40, // Set the height of the button
                                                child: ElevatedButton(
                                                  onPressed: isButtonstart
                                                      ? () {
                                                          if (startname[
                                                                      'start'] !=
                                                                  "" &&
                                                              startname[
                                                                      'end'] !=
                                                                  "") {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Dialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child: Stack(
                                                                    clipBehavior:
                                                                        Clip.none,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      Container(
                                                                        height:
                                                                            200, // ปรับความสูงเพื่อให้มีพื้นที่สำหรับปุ่ม
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            20,
                                                                            50,
                                                                            20,
                                                                            20),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              "ยืนยันเพื่อเรื่มเดินทาง",
                                                                              style: TextStyle(
                                                                                fontFamily: 'custom_font',
                                                                                fontSize: 30,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความและปุ่ม
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Color.fromARGB(255, 175, 15, 4),
                                                                                    foregroundColor: Colors.white,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    // ทำงานเมื่อกดปุ่ม "ใช่"
                                                                                    setState(() {
                                                                                      isIconVisible = true;
                                                                                      isButtonstart = false;
                                                                                      textFieldReadOnly = true;
                                                                                    });
                                                                                    Navigator.of(context).pop(); // ปิด Dialog
                                                                                  },
                                                                                  child: Text(
                                                                                    "ใช่",
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'custom_font',
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 10),
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    primary: Colors.black,
                                                                                    onPrimary: Colors.white,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    // ทำงานเมื่อกดปุ่ม "ไม่"
                                                                                    Navigator.of(context).pop(); // ปิด Dialog
                                                                                  },
                                                                                  child: Text(
                                                                                    "ไม่",
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'custom_font',
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top:
                                                                            -100,
                                                                        child: Image
                                                                            .asset(
                                                                          "assets/redtrain.png",
                                                                          width:
                                                                              150,
                                                                          height:
                                                                              150,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            if (startname[
                                                                    'start'] !=
                                                                "") {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Dialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    insetPadding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child:
                                                                        Stack(
                                                                      clipBehavior:
                                                                          Clip.none,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      children: <Widget>[
                                                                        Container(
                                                                          height:
                                                                              200, // ปรับความสูงเพื่อให้มีพื้นที่สำหรับปุ่ม
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              20,
                                                                              50,
                                                                              20,
                                                                              20),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                "กรุณาเลือกจุดหมายให้ครบ!",
                                                                                style: TextStyle(
                                                                                  fontFamily: 'custom_font',
                                                                                  fontSize: 30,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความและปุ่ม
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  SizedBox(width: 10),
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      primary: Colors.black,
                                                                                      onPrimary: Colors.white,
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      // ทำงานเมื่อกดปุ่ม "ไม่"
                                                                                      Navigator.of(context).pop(); // ปิด Dialog
                                                                                    },
                                                                                    child: Text(
                                                                                      "กลับ",
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'custom_font',
                                                                                        fontSize: 18,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              -100,
                                                                          child:
                                                                              Image.asset(
                                                                            "assets/redtrain.png",
                                                                            width:
                                                                                150,
                                                                            height:
                                                                                150,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            } else if (startname[
                                                                    'end'] !=
                                                                "") {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Dialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    insetPadding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child:
                                                                        Stack(
                                                                      clipBehavior:
                                                                          Clip.none,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      children: <Widget>[
                                                                        Container(
                                                                          height:
                                                                              200, // ปรับความสูงเพื่อให้มีพื้นที่สำหรับปุ่ม
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              20,
                                                                              50,
                                                                              20,
                                                                              20),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                "กรุณาเลือกปลายทางก่อน",
                                                                                style: TextStyle(
                                                                                  fontFamily: 'custom_font',
                                                                                  fontSize: 30,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความและปุ่ม
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  SizedBox(width: 10),
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      primary: Colors.black,
                                                                                      onPrimary: Colors.white,
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      // ทำงานเมื่อกดปุ่ม "ไม่"
                                                                                      Navigator.of(context).pop(); // ปิด Dialog
                                                                                    },
                                                                                    child: Text(
                                                                                      "กลับ",
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'custom_font',
                                                                                        fontSize: 18,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              -100,
                                                                          child:
                                                                              Image.asset(
                                                                            "assets/redtrain.png",
                                                                            width:
                                                                                150,
                                                                            height:
                                                                                150,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            } else {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Dialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    insetPadding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child:
                                                                        Stack(
                                                                      clipBehavior:
                                                                          Clip.none,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      children: <Widget>[
                                                                        Container(
                                                                          height:
                                                                              200, // ปรับความสูงเพื่อให้มีพื้นที่สำหรับปุ่ม
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              20,
                                                                              50,
                                                                              20,
                                                                              20),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                "กรุณาเลือกการเดินทางก่อน!!",
                                                                                style: TextStyle(
                                                                                  fontFamily: 'custom_font',
                                                                                  fontSize: 30,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              SizedBox(height: 20), // เพิ่มระยะห่างระหว่างข้อความและปุ่ม
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  SizedBox(width: 10),
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      primary: Colors.black,
                                                                                      onPrimary: Colors.white,
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      // ทำงานเมื่อกดปุ่ม "ไม่"
                                                                                      Navigator.of(context).pop(); // ปิด Dialog
                                                                                    },
                                                                                    child: Text(
                                                                                      "กลับ",
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'custom_font',
                                                                                        fontSize: 18,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          top:
                                                                              -100,
                                                                          child:
                                                                              Image.asset(
                                                                            "assets/redtrain.png",
                                                                            width:
                                                                                150,
                                                                            height:
                                                                                150,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          }

                                                          print(
                                                              "mylocation: ${mylocation}");
                                                        }
                                                      : null,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.all(
                                                        0), // Remove padding to control size
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20), // Adjust the button's border radius
                                                    ),
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 37, 37, 37),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        5.0), // Add margin around the text
                                                    child: Text(
                                                      'เริ่ม',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'custom_font',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // ElevatedButton(
                                            //     onPressed: () async {
                                            //       _shownotifition("hi");
                                            //     },
                                            //     child: Text('test')),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isIconVisible)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                print(
                                                    "mylocation: ${mylocation}");

                                                setState(() {
                                                  isopenMap = true;
                                                  startengine = true;
                                                });
                                              },
                                              child: Container(
                                                width: 45,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/maplogo.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/giphy.gif',
                                              width: 45,
                                              height: 40,
                                            )
                                          ],
                                        ),
                                      ),
                                  ],
                                ),

                                //box2
                                SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 230, 230, 230),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(23.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: Color.fromARGB(
                                                      255, 37, 37, 37),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 7),
                                                child: Padding(
                                                  padding: EdgeInsets.all(1.0),
                                                  child: Center(
                                                    child: Text(
                                                      '${namestationfirst != null ? namestationfirst : ""}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'custom_font',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),

                                            // Center Elements
                                            Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 15),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Align(
                                                    alignment: Alignment
                                                        .topCenter, // Align the content to the top center
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        if (ttimetext != '')
                                                          Text(
                                                            'ราคา ',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'custom_font',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        if (ttimetext != '')
                                                          Text(
                                                            '20',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'custom_font',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        if (ttimetext != '')
                                                          Text(
                                                            ' บาท',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'custom_font',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (ttimetext != '')
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              Colors.black,
                                                          radius: 4,
                                                        ),
                                                        Text(
                                                            '- - - - - - - - - - - - - -'),
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              Colors.black,
                                                          radius: 4,
                                                        ),
                                                      ],
                                                    ),
                                                  Text(
                                                    '${ttimetext != null ? ttimetext : ""}',
                                                    style: TextStyle(
                                                      fontFamily: 'custom_font',
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    ttimetext != ''
                                                        ? 'รถไฟจะมาทุกๆ 15 นาที'
                                                        : '',
                                                    style: TextStyle(
                                                      fontFamily: 'custom_font',
                                                      fontSize: 14,
                                                      color: Colors.blue,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),

                                            // Right Element
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: Colors.red[800],
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 7),
                                                child: Padding(
                                                  padding: EdgeInsets.all(1.0),
                                                  child: Center(
                                                    child: Text(
                                                      '${namestationlast != null ? namestationlast : ""}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'custom_font',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),

                                //box3
                                SizedBox(height: 15),
                                Container(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 10),
                                        child: Text(
                                          'ทางออก',
                                          style: TextStyle(
                                            fontFamily: 'custom_font',
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      if (dropdownItems
                                          .isNotEmpty) // เช็คว่า dropdownItems ไม่ว่างเปล่า
                                        Container(
                                          width: 60,
                                          margin: EdgeInsets.only(left: 15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 238, 238, 238),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: DropdownButton<String>(
                                                value: dropdownValue,
                                                icon: Container(),
                                                iconSize: 24,
                                                elevation: 16,
                                                style: TextStyle(
                                                  fontFamily: 'custom_font',
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    dropdownValue = newValue!;
                                                    changeoutpathway = true;
                                                    print(dropdownValue);
                                                    Loadpublictransport(
                                                        dropdownValue,
                                                        mycategory);
                                                    LoadFacilities(mycategory);
                                                    getcomment(dropdownValue,
                                                        mycategory);
                                                  });
                                                },
                                                items: dropdownItems.map<
                                                    DropdownMenuItem<String>>(
                                                  (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical: 8,
                                                          horizontal: 16,
                                                        ),
                                                        child: Text(
                                                          value,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'custom_font',
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (dropdownItems
                                          .isEmpty) // เงื่อนไขเมื่อ dropdownItems ว่างเปล่า
                                        Container(
                                          width: 60,
                                          height: 50,
                                          margin: EdgeInsets.only(left: 15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 238, 238, 238),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20),
                                if (futureCompleted == true) showPayment(),

                                SizedBox(height: 10),
                                //box 4 sevice
                                showfac(),

                                SizedBox(
                                  height: 20,
                                ),

                                //box 5 sevice

                                showtranport(),
                                SizedBox(
                                  height: 10,
                                ),
                                //box 6 sevice
                                Divider(
                                  thickness: 2,
                                  color: Color.fromARGB(255, 238, 238, 238),
                                ),
                                showComment(user),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              isopenMap ? showmap() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSecondTabContent() {
    // String? _selectedStation;
    final List<String> stationNames = [
      'สถานีบางซื่อ',
      'สถานีจตุจักร',
      'สถานีวัดเสมียนนารี',
      'สถานีบางเขน',
      'สถานีทุ่งสองห้อง',
      'สถานีหลักสี่',
      'สถานีการเคหะ',
      'สถานีดอนเมือง',
      'สถานีหลักหก',
      'สถานีรังสิต',
      'สถานีบางซ่อน',
      'สถานีบางบำหรุ',
      'สถานีตลิ่งชัน'
    ];
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'ตารางเดินรถไฟ',
              style: TextStyle(
                fontFamily: 'custom_font',
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 250,
              child: DropdownButtonFormField<String>(
                value: _selectedStation,
                onChanged: (String? newValue) {
                  setState(() {
                    final index = stationNames.indexOf(newValue!);
                    _selectedStation = newValue;
                    _selecx = index.toString().padLeft(3, '0');
                  });
                },
                items: List.generate(stationNames.length, (index) {
                  String stationName = stationNames[index];
                  return DropdownMenuItem<String>(
                    value: stationName,
                    child: Text(
                      stationName,
                      style: TextStyle(
                        color: Colors.black, // สีข้อความ
                        fontSize: 26, // ขนาดตัวอักษร
                        fontWeight: FontWeight.bold, // ตัวหนา
                        fontFamily: 'custom_font', // ชื่อฟอนต์
                      ),
                    ),
                  );
                }),
                decoration: InputDecoration(
                  labelText: 'เลือกสถานี',
                  labelStyle: TextStyle(
                    color: Colors.grey, // สีข้อความ
                    fontSize: 22, // ขนาดตัวอักษร
                    fontWeight: FontWeight.bold, // ตัวหนา
                    fontFamily: 'custom_font', // ชื่อฟอนต์
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10, // ระยะห่างของข้อความจากขอบบนและล่าง
                    horizontal: 10, // ระยะห่างของข้อความจากขอบซ้ายและขวา
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red, // สีของเส้นขอบด้านล่างเมื่อไม่ได้เลือก
                      width: 2, // ความหนาของเส้นขอบ
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red, // สีของเส้นขอบด้านล่างเมื่อได้เลือก
                      width: 2, // ความหนาของเส้นขอบ
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
            // Text(_selectedStation == null
            //     ? "โปรดเลือกสถานี"
            //     : _selectedStation!),
            // Text(_selecx == null ? "โปรดเลือกสถานี" : _selecx!),
            _selecx == ""
                ? Container(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color.fromARGB(255, 197, 197, 197),
                          width: 1,
                        ),
                      ),
                      height: 500,
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        'โปรดเลือกสถานีก่อน',
                        style: TextStyle(
                          color: Colors.grey, // สีข้อความ
                          fontSize: 22, // ขนาดตัวอักษร
                          fontWeight: FontWeight.bold, // ตัวหนา
                          fontFamily: 'custom_font', // ชื่อฟอนต์
                        ),
                      )),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color.fromARGB(255, 197, 197, 197),
                          width: 1,
                        ),
                      ),
                      height: 500,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: timetableList.length,
                        itemBuilder: (context, index) {
                          Map<dynamic, dynamic> timetableData =
                              timetableList[index];
                          String stationID = timetableData['ID'];
                          if (stationID == _selecx) {
                            List<String> timeDetails =
                                timetableData['TimeDetail'].split(', ');
                            String formattedTimeDetails =
                                timeDetails.join(' | ');

                            // Check if the time is close to current time
                            bool isNearCurrentTime =
                                isTimeNearCurrentTime(timetableData['Time']);
                            // bool isNearCurrentTimedetail =
                            //     isTimeNearCurrentTimeDetail(
                            //         formattedTimeDetails);

                            return ListTile(
                              leading: Container(
                                width: 55,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: isNearCurrentTime
                                      ? Color.fromARGB(255, 182, 23, 17)
                                      : Color.fromARGB(255, 0, 0, 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Center(
                                  child: Text(
                                    '${timetableData['Time']}',
                                    style: TextStyle(
                                      fontFamily: 'custom_font',
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              title: buildTimeListWidget(timeDetails),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(
                thickness: 2,
                color: Color.fromARGB(255, 238, 238, 238),
              ),
            ),
            Text(
              'SOON!',
              style: TextStyle(
                fontFamily: 'custom_font',
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 214, 214, 214),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isTimeNearCurrentTime(String time) {
    final currentTime = DateTime.now();
    final timeParts = time.split(':');
    final timeHour = int.parse(timeParts[0]);
    final timeMinute = int.parse(timeParts[1]);
    final timeToCheck = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      timeHour,
      timeMinute,
    );
    if (timeHour == currentTime.hour) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildTimeListWidget(List<String> timeList) {
    final currentTime = DateTime.now();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // แนวนอนเพื่อให้สามารถเลื่อนได้
      child: Row(
        children: timeList.map((timeStr) {
          final timeParts = timeStr.trim().split(':');
          final timeHour = int.parse(timeParts[0]);
          final timeMinute = int.parse(timeParts[1]);
          final timeToCheck = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            timeHour,
            timeMinute,
          );

          final isNearCurrentTime = timeToCheck.isAfter(currentTime) &&
              (timeToCheck.difference(currentTime).inMinutes <= 15 ||
                  (timeToCheck.difference(currentTime).inMinutes <= 0 &&
                      timeList.indexOf(timeStr) < timeList.length - 1 &&
                      DateTime.parse(timeList[timeList.indexOf(timeStr) + 1])
                          .isAfter(currentTime)));

          return Container(
            padding: EdgeInsets.symmetric(
                vertical: 10, horizontal: 8), // ปรับเพิ่มเล็กน้อย
            margin: EdgeInsets.only(right: 8), // เพิ่มขอบด้านขวาของ Container
            decoration: isNearCurrentTime
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.red,
                      width: 1,
                    ),
                  )
                : BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
            child: Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'custom_font',
                fontSize: isNearCurrentTime ? 18 : 16,
                fontWeight:
                    isNearCurrentTime ? FontWeight.bold : FontWeight.normal,
                color: isNearCurrentTime ? Colors.red : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool isTimeNearCurrentTimeDetail(String timeDetails) {
    final currentTime = DateTime.now();
    final List<String> timeList =
        timeDetails.split(' | '); // แปลง formattedTimeDetails เป็นลิสต์ของเวลา

    for (var timeStr in timeList) {
      final timeParts = timeStr
          .trim()
          .split(':'); // ตัดช่องว่างด้านหน้าและด้านหลังแล้วแยกชั่วโมงและนาที
      final timeHour = int.parse(timeParts[0]);
      final timeMinute = int.parse(timeParts[1]);
      final timeToCheck = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        timeHour,
        timeMinute,
      );

      if (timeToCheck.isAfter(currentTime) &&
          timeToCheck.difference(currentTime).inMinutes <= 30) {
        return true; // หากพบเวลาใกล้เคียงที่สุดอยู่ภายใน 30 นาที ให้คืนค่า true
      }
    }

    return false; // หากไม่พบเวลาใกล้เคียง หรือเวลาใกล้เคียงไม่ถึง 30 นาที ให้คืนค่า false
  }
}
