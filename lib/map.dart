import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:goog/displayuserdb.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Mymap extends StatefulWidget {
  const Mymap({super.key, required this.title, required this.mylo});
  final String title;
  final Map mylo;
  @override
  State<Mymap> createState() => MapState();
}

class MapState extends State<Mymap> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  List<bool> ischeckbtnAdd = List.generate(20, (index) => false);
  var boxsearch = TextEditingController();
  var dataSearch = [];
  var dataMark = [];
  var dataRoute = [];
  var ttimetext = '';
  Object? mark;
  List<Map<String, double>> pointmarkpolyline1 = [];
  List<Map<String, double>> pointmarkpolyline2 = [];
  List<Map<String, double>> pathways1 = [];
  List<Map<String, double>> pathways2 = [];
  List<Map<String, double>> station = [];

  Future<void> routing(
      double flon, double flat, double tlon, double tlat) async {
    int totalDistance = 0; // Initialize totalDistance
    int totalTime = 0; // Initialize totalTime

    try {
      const apikey = "804903bb8f1b3b154a6f11b156adaf62";
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
          totalTimeText = '$hours ชั่วโมง $minutes นาที';
          ttimetext = totalTimeText;
        } else {
          totalTimeText = '$minutes นาที';
          ttimetext = totalTimeText;
        }
        print(totalTimeText);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }
  Future<void> fetchData(lon, lat) async {
    var apiKey = "804903bb8f1b3b154a6f11b156adaf62";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=20');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      var lotlat = jsonData['data'].map((e) => {
            "lat": e['lat'].toStringAsFixed(4),
            "lon": e['lon'].toStringAsFixed(4),
          });
      var lotlats = jsonData['data'].map((e) => {
            "lat": e['lat'].toStringAsFixed(4),
            "lon": e['lon'].toStringAsFixed(5),
          });
      print(lat.toStringAsFixed(4) + ' ' + lon.toStringAsFixed(4));
      print(lat.toStringAsFixed(4) + ' ' + lon.toStringAsFixed(6));
      print(lotlat);
      print(lotlats);
      dynamic datax = [];
      jsonData['data'].forEach((element) {
        if (element['lat'].toStringAsFixed(4) == lat.toStringAsFixed(4) &&
            element['lon'].toStringAsFixed(4) == lon.toStringAsFixed(4)) {
          datax.add(element);
        }
      });
      // print( is List ? true : false);
      print(datax.length);
      if (datax.length > 0) {
        if (dataMark.length == 0) {
          dataMark.add(datax[0]);
          setState(() {
            messenger.currentState?.showSnackBar(
              SnackBar(
                content: Text(datax[0]['name'] + " ถูกเพิ่มแล้ว"),
              ),
            );
            dataMark = dataMark;
          });
          add_mark(datax[0]['lat'], datax[0]['lon']);
        } else {
          var check =
              dataMark.where((element) => element['name'] == datax[0]['name']);
          print(check.length);
          if (check.length == 0) {
            setState(() {
              messenger.currentState?.showSnackBar(
                SnackBar(
                  content: Text(datax[0]['name'] + " ถูกเพิ่มแล้ว"),
                ),
              );
              dataMark.add(datax[0]);
            });
            // set_location(datax[0]['lat'], datax[0]['lon']);
            add_mark(datax[0]['lat'], datax[0]['lon']);
          } else {
            print("มีข้อมูลแล้ว");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  title: Text("แจ้งเตือน"),
                  content: Text("มีข้อมูลนี้อยู่แล้ว",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  actions: [
                    TextButton(
                      child: Text("ปิด",
                          style: TextStyle(color: Colors.red, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        setState(() {
          messenger.currentState?.showSnackBar(
            SnackBar(
              content: Text("ไม่พบข้อมูล"),
            ),
          );
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
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
    print("lat: ${localtion.latitude} lon: ${localtion.longitude}");
    return await Geolocator.getCurrentPosition();
  }

  Future _displayBottomSheet(BuildContext context) {
    TextEditingController _searchController = TextEditingController();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.0),
        ),
      ),
      builder: (context) => Container(
        height: 400,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ค้นหา',
                          suffixIcon: Icon(Icons.search),
                          // labelText: 'ค้นหา',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          print("XD");
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.search, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> searchData(value) async {
    try {
      const apikey = "804903bb8f1b3b154a6f11b156adaf62";
      final url = Uri.parse(
          'https://search.longdo.com/mapsearch/json/search?keyword=${value}&limit=40&key=${apikey}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        dataSearch = jsonData['data'];
        setState(() {
          dataSearch = dataSearch;
        });
        print(dataSearch);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  void add_mark(lat, lon) {
    mark = map.currentState?.LongdoObject(
      "Marker",
      args: [
        {
          "lon": lon,
          "lat": lat,
        },
      ],
    );
    if (mark != null) {
      map.currentState?.call("Overlays.add", args: [mark!]);
    }
  }

  void set_location(lat, lon) {
    map.currentState?.call("location", args: [
      {
        "lon": lon,
        "lat": lat,
      }
    ]);
  }

  void remove_mark(index) async {
    print("remove ${index}");
    var x = await map.currentState?.call("Overlays.list");
    var xd = jsonDecode(x.toString());
    print(xd[index]);
    map.currentState?.call("Overlays.remove", args: [xd[index]]);
    setState(() {
      dataMark.removeAt(index);
    });
  }

  var _currentIndex = 1;

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

  void checkstation() async {
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
              [widget.mylo['start'][0]['lat'], widget.mylo['start'][0]['lon']],
              [station['lat'], station['lon']]);
          firstdistances.add(distance); // เก็บระยะทางลงในรายการ
          print("Distance to station: $distance km");
        });

        print("Distances to stations first: $firstdistances");

        station.forEach((station) {
          double distance = calculateDistance(
              [widget.mylo['end'][0]['lat'], widget.mylo['end'][0]['lon']],
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
        var namestationfirst = await namestation(minIndex1);
        var namestationlast = await namestation(minIndex2);
        print("Name station first: $namestationfirst");
        print("Name station last: $namestationlast");
        if (minIndex1 != -1) {
          print("Minimum distance first: $minDistance1 km");
          print("Index of minimum distance: $minIndex1");

          // นำข้อมูลสถานีที่ใกล้ที่สุดไปเก็บไว้ใน nearstation
          Map<String, double> nearfirststation = {
            "lat": station[minIndex1]['lat']!,
            "lon": station[minIndex1]['lon']!
          };
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
          Map<String, double> nearlaststation = {
            "lat": station[minIndex2]['lat']!,
            "lon": station[minIndex2]['lon']!
          };
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
            getPathwayData(minIndex1, minIndex2);
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

  Future<void> getPathwayData(int index1, int index2) async {
    DatabaseReference pathway = FirebaseDatabase.instance.ref('MapMarking');
    List<Map<String, double>> pathways1 =
        []; // For storing pathways corresponding to index1
    List<Map<String, double>> pathways2 =
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
                if (element is List && element.length >= 2) {
                  var latitude = element[0];
                  var longitude = element[1];
                  print(
                      "Pathway $loopIndex: Latitude: $latitude, Longitude: $longitude");
                  Map<String, double> pathway = {
                    "lon": longitude,
                    "lat": latitude,
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
        if (pathways1.isNotEmpty && pathways2.isNotEmpty) {
          addpathwayline(pathways1, 'rgba(32, 0, 255, 1)');
          addpathwayline(pathways2, 'rgba(32, 0, 255, 1)');
        } else {
          print("Pathways list is empty.");
        }
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> addpathwayline(
      List<Map<String, double>> pathwayline, color) async {
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
     var marklist = await map.currentState?.call("Overlays.list");
    print(marklist);
    var ListMark = jsonDecode(marklist!.toString());
    print(ListMark);
    print('ความยาวของ ListMark คือ ${ListMark.length}');
  }

  void getPolylineData() async {
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
      List<Map<String, double>> pointmarkpolyline, color) async {
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

  @override
  Widget build(BuildContext context) {
    // Object? marker;
    return MaterialApp(
      scaffoldMessengerKey: messenger,
      home: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: LongdoMapWidget(
                  apiKey: "804903bb8f1b3b154a6f11b156adaf62",
                  key: map,
                  eventName: [
                    JavascriptChannel(
                      name: "ready",
                      onMessageReceived: (JavascriptMessage message) async {
                        print("ready click");
                        print(widget.mylo['start'][0]['lat']);
                        print(widget.mylo['start'][0]['lon']);
                        var startlat = widget.mylo['start'][0]['lat'];
                        var startlon = widget.mylo['start'][0]['lon'];
                        var endlat = widget.mylo['end'][0]['lat'];
                        var endlon = widget.mylo['end'][0]['lon'];

                        // map.currentState?.call("Route.add", args: [
                        //   {
                        //     "lat": startlat,
                        //     "lon": startlon,
                        //   }
                        // ]);
                        // map.currentState?.call("Route.add", args: [
                        //   {
                        //     "lat": endlat,
                        //     "lon": endlon,
                        //   }
                        // ]);
                        // map.currentState?.call("Route.search");
                        getPolylineData();

                        var lay = map.currentState
                            ?.LongdoStatic("Layers", 'RASTER_POI');
                        if (lay != null) {
                          print("ready");
                          map.currentState?.call('Layers.setBase', args: [lay]);
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
                      onMessageReceived: (message) {},
                    ),
                  ],
                  options: {
                    // "ui": Longdo.LongdoStatic(
                    //   "UiComponent",
                    //   "None",
                    // )
                  },
                ),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Column(children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: const Color.fromARGB(255, 196, 25, 13),
                              width: 2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("เส้นทางของคุณ",
                              style: TextStyle(
                                  fontSize: 25, fontFamily: 'custom_font')),
                          Row(
                            children: [
                              Text("${ttimetext}", //here
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: 'custom_font')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // FloatingActionButton(
                  //   onPressed: () => print("zs"),
                  //   child: Icon(Icons.add),

                  // )
                ]),
              ))
            ],
          )),
    );
  }
}
