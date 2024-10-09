import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:goog/map.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'realtimedb.dart';
import 'updatepage.dart';

class Displaydb extends StatefulWidget {
  const Displaydb({Key? key});

  @override
  State<Displaydb> createState() => _DisplaydbState();
}

class _DisplaydbState extends State<Displaydb> {
  Query refquery = FirebaseDatabase.instance.ref().child("MapMarking");
  DatabaseReference refdelete =
      FirebaseDatabase.instance.ref().child("contact");

  Future<void> logout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  int _currentIndex = 0; // Track the selected tab index

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'The Redline',
          style: TextStyle(color: Colors.red[700]),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await logout();
                Navigator.pop(context);
              },
            ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (user != null && user.photoURL != null)
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL!),
                      radius: 48.0,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      user.displayName ?? '', // Display the name if available
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? '', // Display the email if available
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: Expanded(
  child: StreamBuilder(
    stream: FirebaseDatabase.instance
        .reference()
        .child('MapMarking')
        .onValue,
    builder: (context, snapshot) {
      if (snapshot.hasData &&
          !snapshot.hasError &&
          snapshot.data != null && // Check if snapshot.data is not null
          snapshot.data?.snapshot.value != null) {
        // Map to store the data
        Map<dynamic, dynamic>? mapMarkings = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
        print('Map Markings: ');
        print(mapMarkings);
        // Use the mapMarkings to build a list or any other type of widget
        return ListView.builder(
          itemCount: mapMarkings!.length,
          itemBuilder: (context, index) {
            String key = mapMarkings.keys.elementAt(index);
            dynamic value = mapMarkings[key];
            return ListTile(
              title: Text('Mark Point: ${value['markpoint']}'),
              subtitle: Text('Station ID: ${value['station_id']}'),
            );
          },
        );
      } else {
        // If the snapshot doesn't contain data or is null, display a loading indicator
        return CircularProgressIndicator();
      }
    },
  ),
),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.red[700], // Set your desired background color here
          borderRadius:
              BorderRadius.circular(25), // Optional: Add rounded corners
        ),
        child: IconButton(
          iconSize: 30,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => realtimedb()),
            );
          },
          icon: Icon(Icons.add),
          color: Colors.white, // Set icon color
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation based on the selected tab index
          switch (index) {
            case 0:
              // Do nothing or navigate to the current page (Displaydb)
              break;
            case 1:
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => Mymap(title: "mymap")),
              // );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.red[700],
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.directions_subway_filled_outlined,
              color: Colors.red[700],
            ),
            label: 'Map',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor:
            const Color.fromARGB(255, 0, 0, 0), // Set the unselected item color
        mouseCursor: SystemMouseCursors.click, // Set cursor on hover
      ),
    );
  }

  Widget showdisplay({required Map con}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${con['fname']} ${con['lname']}',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Email:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                con['email'],
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => editpage(
                            data: con,
                          )));
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  refdelete.child(con['key']).remove();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
