import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'model/mapmodel.dart';

class Mymap_search extends StatefulWidget {
  const Mymap_search(
      {super.key,
      required this.title,
      required this.mylo,
      required this.startname,
      required this.onLocationSelected});
  final String title;
  final Map mylo;
  final Map startname;

  final Function(Map) onLocationSelected;
  @override
  State<Mymap_search> createState() => MapState();
}

class MapState extends State<Mymap_search> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  List<bool> ischeckbtnAdd = List.generate(20, (index) => false);
  var boxsearch = TextEditingController();
  var dataSearch = [];
  var dataMark = [];
  Object? mark;
  var maplist = [];
  var apikey = "804903bb8f1b3b154a6f11b156adaf62";
  var mlat, mlon;
  Object? markuser;
  Future<void> fetchData(value) async {
    final url = Uri.parse(
        'https://search.longdo.com/mapsearch/json/search?keyword=${value}&limit=100&key=${apikey}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      maplist = jsonData['data'];
      var name = ['ตำแหน่งปัจจุบันของคุณ'];
      for (var i = 0; i < maplist.length; i++) {
        name.add(maplist[i]['name']);
      }
      // print(name is List ? true : false);
      // print(name);
      setState(() {
        province = name;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchlocation(lat, lon) async {
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apikey}&lon=${lon}&lat=${lat}&limit=20');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      maplist = jsonData['data'];
      print(maplist);
      // var name = ['ตำแหน่งปัจจุบันของคุณ'];
      // for (var i = 0; i < maplist.length; i++) {
      //   name.add(maplist[i]['name']);
      // }
      // print(name is List ? true : false);
      // print(name);
      // setState(() {
      //   province = name;
      // });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<bool> isCheckedList = List.generate(20, (index) => false);
  var province = [];
  List<String> bpro = [];
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
    // print("lat: ${localtion.latitude} lon: ${localtion.longitude}");
    return await Geolocator.getCurrentPosition();
  }

  void add_mark(lat, lon) {
    if (mark != null) {
      map.currentState?.call("Overlays.remove", args: [mark!]);
    }
    mark = map.currentState?.LongdoObject(
      "Marker",
      args: [
        {
          "lon": lon,
          "lat": lat,
        },
        {
          "title": "Marker",
          // "url": 'assets/pin_mark.png',
          // "offset": {"x": 12, "y": 45},
        }
      ],
    );
    print(mark);
    if (mark != null) {
      map.currentState?.call("Overlays.add", args: [mark!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // set_pro();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 10), // เพิ่ม padding เพื่อไม่ให้ข้อความชิดขอบ
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // สีของเงา
                        spreadRadius: 2, // การกระจายของเงา
                        blurRadius: 3, // ความคมของเงา
                        offset: Offset(0, 2), // การเยื้องของเงา
                      ),
                    ],
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      fetchData(value);
                    },
                    style: TextStyle(color: Colors.black), // สีของข้อความ
                    decoration: InputDecoration(
                      hintStyle:
                          TextStyle(color: Colors.grey), // สีของข้อความในฮินท์
                      suffixIcon: Icon(Icons.search,
                          color: Colors.grey), // สีของไอคอน search
                      labelText: 'ค้นหาที่คุณต้องการ',
                      labelStyle:
                          TextStyle(color: Colors.grey), // สีของข้อความ label
                      border: InputBorder.none, // ลบเส้นขอบ
                      focusedBorder: InputBorder.none, // ลบเส้นขอบเมื่อโฟกัส
                      enabledBorder: InputBorder.none, // ลบเส้นขอบเมื่อ enable
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height /
                      4, // Half of the screen height
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: province.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Column(
                        
                        children: [
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: const Color.fromARGB(255, 180, 19, 8)),
                            ),
                            
                            elevation: 0,
                            child: ListTile(
                              onTap: () async {
                                var loc = _determinePosition();
                                dynamic lat =
                                    await loc.then((value) => value.latitude);
                                dynamic lon =
                                    await loc.then((value) => value.longitude);
                                print("your location ${lat} ${lon}");
                                if (widget.title == "start") {
                                  print(widget.title);
                                  print(i);
                                  if (i == 0) {
                                    if (lat != null && lon != null) {
                                      print({
                                        "name": "ตำแหน่งปัจจุบันของคุณ",
                                        "lat": lat,
                                        "lon": lon
                                      });
                                      setState(() {
                                        widget.startname["start"] =
                                            "ตำแหน่งปัจจุบันของคุณ";
                                        widget.mylo["start"].clear();
                                        widget.mylo["start"].add({
                                          "name": "ตำแหน่งปัจจุบันของคุณ",
                                          "lat": lat,
                                          "lon": lon
                                        });
                                        add_mark(lat, lon);
                                        map.currentState
                                            ?.call("location", args: [
                                          {
                                            "lon": lon,
                                            "lat": lat,
                                          }
                                        ]);
                                        widget.onLocationSelected(widget.mylo);
                                      });
                                    }
                                  } else {
                                    print(
                                        "lat ${maplist[i - 1]["lat"]} lon ${maplist[i - 1]["lon"]}");
                                    print(maplist[i - 1]["name"]);
                                    setState(() {
                                      widget.startname["start"] =
                                          maplist[i - 1]["name"];
                                      widget.mylo["start"].clear();
                                      widget.mylo["start"].add(maplist[i - 1]);
                                      print(maplist[i - 1]);
                                      widget.onLocationSelected(widget.mylo);
                                    });
                                    add_mark(maplist[i - 1]["lat"],
                                        maplist[i - 1]["lon"]);
                                    map.currentState?.call("location", args: [
                                      {
                                        "lon": maplist[i - 1]["lon"],
                                        "lat": maplist[i - 1]["lat"],
                                      }
                                    ]);
                                  }
                                } else {
                                  print(widget.title);
                                  if (i == 0) {
                                    if (lat != null && lon != null) {
                                      setState(() {
                                        widget.startname["end"] =
                                            "ตำแหน่งปัจจุบันของคุณ";
                                        widget.mylo["end"].clear();
                                        widget.mylo["end"].add({
                                          "name": "ตำแหน่งปัจจุบันของคุณ",
                                          "lat": lat,
                                          "lon": lon
                                        });
                                        widget.onLocationSelected(widget.mylo);
                                      });
                                      add_mark(lat, lon);
                                      map.currentState?.call("location", args: [
                                        {
                                          "lon": lon,
                                          "lat": lat,
                                        }
                                      ]);
                                    }
                                  } else {
                                    print("check else");
                                    print(maplist[i - 1]);
                                    setState(() {
                                      widget.startname["end"] =
                                          maplist[i - 1]["name"];
                                      widget.mylo["end"].clear();
                                      widget.mylo["end"].add(maplist[i - 1]);
                                      print(maplist[i - 1]);
                                      widget.onLocationSelected(widget.mylo);
                                    });
                                    add_mark(maplist[i - 1]["lat"],
                                        maplist[i - 1]["lon"]);
                                    map.currentState?.call("location", args: [
                                      {
                                        "lon": maplist[i - 1]["lon"],
                                        "lat": maplist[i - 1]["lat"],
                                      }
                                    ]);
                                  }
                                }
                              },
                              leading: GestureDetector(
                                onTap: () {
                                  print(isCheckedList);
                                  setState(() {
                                    isCheckedList[i] = !isCheckedList[i];
                                  });
                                },
                                child: Container(
                                  width: 6,
                                  height: 50,
                                  child: Icon(Icons.location_on,color: const Color.fromARGB(255, 185, 14, 2),),
                                ),
                              ),
                              title: Text('${province[i]}',style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: 'custom_font'),),
                              
                            ),
                          ),
                          SizedBox(height: 10), // Add spacing between items
                        ],
                      );
                    },
                  ),
                ),

                // Add your content for the remaining half of the screen here
                Expanded(
                  flex: 2,
                  child: LongdoMapWidget(
                    apiKey: "804903bb8f1b3b154a6f11b156adaf62",
                    key: map,
                    eventName: [
                      JavascriptChannel(
                        name: "ready",
                        onMessageReceived: (JavascriptMessage message) async {
                          // print("ready click");
                          print(widget.mylo);
                          // print(widget.mylo['start'][0]['lat']);
                          // print(widget.mylo['start'][0]['lon']);
                          // var startlat = widget.mylo['start'][0]['lat'];
                          // var startlon = widget.mylo['start'][0]['lon'];
                          // var endlat = widget.mylo['end'][0]['lat'];
                          // var endlon = widget.mylo['end'][0]['lon'];

                          //  map.currentState?.call("Route.add", args: [{
                          //       "lat": startlat,
                          //       "lon": startlon,
                          //     }]);
                          //     map.currentState?.call("Route.add", args: [{
                          //       "lat": endlat,
                          //       "lon": endlon,
                          //     }]);
                          //     map.currentState?.call("Route.search");
                          //     map.currentState?.call("Route.auto", args: [true]);

                          // map.currentState
                          //     ?.call("Ui.Geolocation.visible", args: [true]);
                          // map.currentState?.call("zoom", args: [20, true]);
                          // var zoom = await map.currentState?.call("location");
                          // print("get zoom ${zoom} xd}");
                          // print(zoom);
                          // print("get zoom ${zoom.cur} xd}");
                          // map.currentState?.call("Event.bind",
                          //     args: ["click", (e) => print("click")]);
                          var lay = map.currentState
                              ?.LongdoStatic("Layers", 'RASTER_POI');
                          if (lay != null) {
                            print("ready");
                            map.currentState
                                ?.call('Layers.setBase', args: [lay]);
                          }
                          var latlon = _determinePosition();
                          print(latlon);
                          latlon.then((value) => {
                                setState(() {
                                  map.currentState?.call("location", args: [
                                    {
                                      "lon": value.longitude,
                                      "lat": value.latitude,
                                    }
                                  ]);
                                })
                              });
                        },
                      ),
                      JavascriptChannel(
                        name: "click",
                        onMessageReceived: (message) {
                          print("clicked");
                          print(jsonDecode(message.message)['data']);
                          var data = jsonDecode(message.message)['data'];
                          var lat = data['lat'];
                          var lon = data['lon'];
                          // fetchlocation(lat, lon);

                          // fetchData(lon, lat);
                          setState(() {
                            mlat = lat;
                            mlon = lon;
                            print("mlat ${mlat} mlon ${mlon}");
                            // print(mlon);
                          });
                          add_mark(lat, lon);
                        },
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
                ElevatedButton(
                  onPressed: () {
                    // ทำงานเมื่อปุ่มถูกคลิก

                    if (mark != null) {
                      print("mark not null");
                      print(widget.mylo['start']);
                      if (widget.title == "start") {
                        if (widget.mylo['start'].length != 0) {
                          print("start not null");
                          Navigator.pop(context);
                        } else {
                          print("start null");
                          setState(() {
                            widget.mylo['start'].clear();
                            widget.mylo['start'].add({
                              "name": "ตำแหน่งที่คุณเลือก",
                              "lat": mlat,
                              "lon": mlon
                            });
                          });
                          print(widget.mylo['start']);
                          widget.onLocationSelected(widget.mylo);
                          Navigator.pop(context);
                        }
                      } else {
                        if (widget.mylo['end'].length != 0) {
                          print("start not null");
                          Navigator.pop(context);
                        } else {
                          print("start null");
                          setState(() {
                            widget.mylo['end'].clear();
                            widget.mylo['end'].add({
                              "name": "ตำแหน่งที่คุณเลือก",
                              "lat": mlat,
                              "lon": mlon
                            });
                          });
                          print(widget.mylo['end']);
                          widget.onLocationSelected(widget.mylo);
                          Navigator.pop(context);
                        }
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
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                          child: Text(
                            "คุณยังไม่ได้เลือกจุด Mark!",
                            style: TextStyle(fontSize: 25,fontFamily: 'custom_font'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: -100,
                          child: Image.network(
                            "https://i.imgur.com/ov3SJS0.png",
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
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 183, 28, 28)),
                    minimumSize: MaterialStateProperty.all(Size(100, 50)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            0), // ปรับเส้นรอบขอบตามความเหมาะสม
                        side: BorderSide(
                            color: const Color.fromARGB(255, 183, 28, 28),
                            width:
                                2.0), // เพิ่มเส้นขอบด้วยสีดำ ความกว้าง 2.0 พิกเซล
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'ตกลง',
                      style: TextStyle(
                        fontFamily: 'custom_font',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
