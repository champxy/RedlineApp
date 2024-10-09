import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:math';
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
  Object? mark;
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

  Future<void> _displayDraggableScrollableSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0), // Adjust as needed
                  topRight: Radius.circular(20.0), // Adjust as needed
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: FocusNode(
                                canRequestFocus: true,
                                descendantsAreFocusable: true),
                            controller: boxsearch,
                            onChanged: (value) {
                              searchData(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'ค้นหา',
                              suffixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10, // ปรับตามต้องการ
                                horizontal: 10, // ปรับตามต้องการ
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: dataSearch.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              ListTile(
                                  leading: GestureDetector(
                                    onTap: () {
                                      set_location(dataSearch[index]['lat'],
                                          dataSearch[index]['lon']);
                                      print(
                                          "lat: ${dataSearch[index]['lat']} lon: ${dataSearch[index]['lon']}");
                                    },
                                    child: Icon(Icons.location_on,
                                        color: Colors.grey.shade300),
                                  ),
                                  title: Text(dataSearch[index]['name']),
                                  subtitle: Text(dataSearch[index]['address']),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      // setState(() {
                                      //   dataMark.add(dataSearch[index]);
                                      // });
                                      if (dataMark.length > 0) {
                                        var check = dataMark.where((element) =>
                                            element['name'] ==
                                            dataSearch[index]['name']);
                                        print(check.length);
                                        if (check.length == 0) {
                                          setState(() {
                                            dataMark.add(dataSearch[index]);
                                          });
                                          set_location(dataSearch[index]['lat'],
                                              dataSearch[index]['lon']);
                                          add_mark(dataSearch[index]['lat'],
                                              dataSearch[index]['lon']);
                                        } else {
                                          print("มีข้อมูลแล้ว");
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    Colors.grey[200],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                title: Text("แจ้งเตือน"),
                                                content: Text(
                                                    "มีข้อมูลนี้อยู่แล้ว",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15)),
                                                actions: [
                                                  TextButton(
                                                    child: Text("ปิด",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 20)),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        setState(() {
                                          dataMark.add(dataSearch[index]);
                                        });
                                        set_location(dataSearch[index]['lat'],
                                            dataSearch[index]['lon']);
                                        add_mark(dataSearch[index]['lat'],
                                            dataSearch[index]['lon']);
                                      }
                                    },
                                    child: Icon(Icons.add_box,
                                        color: Colors.pink.shade300),
                                  )),
                              Divider(
                                height: 1,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    )
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
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

  Future<void> rounting(flon, flat, tlon, tlat) async {
    try {
      const apikey = "804903bb8f1b3b154a6f11b156adaf62";
      final url = Uri.parse(
          'https://api.longdo.com/RouteService/json/route/guide?flon=${flon}&flat=${flat}&tlon=${tlon}&tlat=${tlat}&mode=t&type=25&locale=th&key=${apikey}');
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
  String getTurnDirection(int turnCode) {
  switch (turnCode) {
    case 0:
      return "Turn left";
    case 1:
      return "Turn right";
    case 2:
      return "Turn slight left";
    case 3:
      return "Turn slight right";
    case 4:
      return "Unknown direction";
    case 5:
      return "Go straight";
    case 6:
      return "Enter tollway";
    case 9:
      return "Arrive";
    case 11:
      return "Travel by ferry";
    default:
      return "Unknown";
  }
}
  var _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Object? marker;
    return MaterialApp(
      scaffoldMessengerKey: messenger,
      home: Scaffold(
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
                    // print(widget.mylo['start'][0]['lat']);
                    // print(widget.mylo['start'][0]['lon']);
                    // print(widget.mylo['end'][0]['lat']);
                    // print(widget.mylo['end'][0]['lon']);
                    // var startlat = widget.mylo['start'][0]['lat'];
                    // var startlon = widget.mylo['start'][0]['lon'];
                    // var endlat = widget.mylo['end'][0]['lat'];
                    // var endlon = widget.mylo['end'][0]['lon'];
                    // rounting(startlon, startlat, endlon, endlat); //ค้นหาเส้นทาง
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
                    // map.currentState?.call("Route.auto", args: [true]);

                    // map.currentState
                    //     ?.call("Ui.Geolocation.visible", args: [true]);
                    // map.currentState?.call("zoom", args: [20, true]);
                    // var zoom = await map.currentState?.call("location");
                    // print("get zoom ${zoom} xd}");
                    // print(zoom);
                    // print("get zoom ${zoom.cur} xd}");
                    // map.currentState?.call("Event.bind",
                    //     args: ["click", (e) => print("click")]);
                    var lay =
                        map.currentState?.LongdoStatic("Layers", 'RASTER_POI');
                    if (lay != null) {
                      print("ready");
                      map.currentState?.call('Layers.setBase', args: [lay]);
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
                    // print("click XD");
                    // print(jsonDecode(message.message)['data']);
                    var data = jsonDecode(message.message)['data'];
                    var lat = data['lat'];
                    var lon = data['lon'];
                    fetchData(lon, lat);
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
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(2.0),
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
                  padding: const EdgeInsets.only(top: 10, left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("เส้นทางของคุณ",
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'custom_font',
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 50),
                    itemCount: dataSearch[0]["guide"]
                        .length, // Use the number of routing steps
                    itemBuilder: (BuildContext context, int index) {
                      final step = dataSearch[0]["guide"][index];
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color.fromARGB(255, 196, 25, 13),
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  // Handle onTap action here if needed
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.purple,
                                    size: 30,
                                  ),
                                ),
                              ),
                              title: Text("Direction: ${getTurnDirection(step["turn"])}"),
                              subtitle: Text(
                                  "Name: ${step["name"]}\nDistance: ${step["distance"]} meters"),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
              ),

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
