import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:goog/displayuserdb.dart';
import 'package:goog/profire_page.dart';
import 'package:goog/redline.dart';
import 'package:goog/redlineXd.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'realtimedb.dart';
import 'redline.dart';
import 'package:firebase_database/firebase_database.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> signInWithGoogle() async {
    // create an instance of the firebase auth and google signin
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    //Triger the authenication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    //Obtain the auth de tails from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    //Create a new credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //sign in the user with th crededentails
    final UserCredential userCredential =
        await auth.signInWithCredential(credential);
  }


Future<void> login(dynamic email, dynamic name) async {
  // Define the reference to the 'User' node in Firebase Realtime Database
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User');

  // Fetch the data from Firebase Realtime Database using once()
  userRef.once().then((DatabaseEvent event) {
    // Retrieve the data snapshot from the event
    DataSnapshot snapshot = event.snapshot;

    // Check if the snapshot's value is a list
    if (snapshot.value is List<dynamic>) {
      // Cast the snapshot's value to a list
      List<dynamic> users = snapshot.value as List<dynamic>;

      // Initialize a flag to check if the user is found
      bool userFound = false;

      // Iterate over the list to find the user
      for (var user in users) {
        if (user is Map<dynamic, dynamic> && user['email'] == email) {
          print('User email found: ${user['email']}');
          userFound = true;
          // Check if the user is blocked
          if (user['status'] == 'block') {
            print('ผู้ใช้ที่อีเมลล์ $email ถูกบล็อค');
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
                      "User คนนี้ถูก block โดยระบบ\nกรุณาติดต่อผู้ดูแลระบบ",
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
        logout();
          } else {
            print('พบผู้ใช้ที่อีเมลล์ $email');
            if (user['status'] == 'active') {
              updatedate(email);
            }else{
              print('User status is not active');
            }
          }
          break;
        }
      }

      // If the user wasn't found, print a message
      if (!userFound) {
        print('ไม่พบผู้ใช้ที่อีเมลล์ $email');
        addNewUser(email, name);
      }
    } else {
      // If the data is not in the expected format, print an error message
      print('Data format is not as expected. Please check the database structure.');
    }
  }).catchError((error) {
    // Handle any errors here
    print('An error occurred: $error');
  });
}

Future<void> logout() async {
    final GoogleSignIn googleSign = GoogleSignIn();
    await googleSign.signOut();
    await FirebaseAuth.instance.signOut();
  }
Future<void> updatedate(dynamic email) async {
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User');
  DateTime now = DateTime.now();
    String formattedDateTime = now.toString().substring(0, 19);
  userRef.once().then((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value is List<dynamic>) {
      List<dynamic> users = snapshot.value as List<dynamic>;
      for (var user in users) {
        if (user is Map<dynamic, dynamic> && user['email'] == email) {
          userRef.child(users.indexOf(user).toString()).update(<String, dynamic>{
            "update_date": formattedDateTime
          }).then((_) {
            print('User update date updated');
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => redliadXD()),
              );
            }
          }).catchError((error) {
            print('An error occurred: $error');
          });
        }
      }
    }
  }).catchError((error) {
    print('An error occurred: $error');
  });

}
Future<void> addNewUser(dynamic email, dynamic name) async {
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User');
  DatabaseReference counterRef = FirebaseDatabase.instance.ref().child('User');
  DateTime now = DateTime.now();
    String formattedDateTime = now.toString().substring(0, 19);
  int count = 0;

  counterRef.once().then((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value is List<dynamic>) {
      List<dynamic> users = snapshot.value as List<dynamic>;
      count = users.length;
    }
    print('User count: $count');
    userRef.child(count.toString()).set(<String, dynamic>{
  "Routes": "",
  "created_date": formattedDateTime,
  "email": email,
  "name": name,
  "status": "active",
  "update_date": formattedDateTime,
    }).then((_) {
      print('New user added to the database');
      if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => redliadXD()),
              );
            }
    }).catchError((error) {
      print('An error occurred: $error');
    });
  }).catchError((error) {
    print('An error occurred: $error');
  });
}








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bglogin.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/dek.png', // Replace with the actual path to your logo image
                  height: 100, // Set the desired height
                  width: 100, // Set the desired width
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Implement your sign-in logic here
                    await signInWithGoogle();
                    final User? user = FirebaseAuth.instance.currentUser;
                    print(user?.email!);
                    login(user?.email!,user?.displayName!);
                    // if (mounted) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (_) => redliadXD()),
                    //   );
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Change the button color to your preference
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4, // Add a subtle shadow
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/google.png',
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontFamily: 'custom_font',
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Implement the logic to navigate to another page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              redliadXD()), // Replace redliadXD with the actual destination page
                    );
                  },
                  child: Text(
                    'Use guest ID',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'custom_font',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
