import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goog/displayuserdb.dart';
import 'package:goog/profire_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'realtimedb.dart';

class Redlinehome extends StatefulWidget {
  const Redlinehome({super.key});

  @override
  State<Redlinehome> createState() => _RedlinehomeState();
}

class _RedlinehomeState extends State<Redlinehome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [backgound(), box1(), box2(), textexit(), data1()],
        ),
      ),
    );
  }

  Positioned data1() {
    return Positioned(
      top: 70, // Adjust the top position as needed
      left: 25,
      child: SingleChildScrollView(
        // Wrap data1 in a SingleChildScrollView
        scrollDirection: Axis.vertical,
        child: Row(
          children: [
            Text(
              'สิ่งอำนวยความสะดวก',
              style: TextStyle(
                fontFamily: 'custom_font',
                fontSize: 25, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust the text color as needed
              ),
            ),
            // Add more widgets here if needed
          ],
        ),
      ),
    );
  }

  Positioned textexit() {
    return Positioned(
      top: 650, // Adjust the top position as needed
      left: 25,

      child: Row(
        children: [
          Text(
            'ทางออก',
            style: TextStyle(
              fontFamily: 'custom_font',
              fontSize: 25, // Adjust the font size as needed
              fontWeight: FontWeight.bold,
              color: Colors.black, // Adjust the text color as needed
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15), // Adjust the margin as needed
            padding: EdgeInsets.symmetric(
              horizontal: 40,
            ), // Adjust padding as needed
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    10), // Adjust the border radius as needed
                color: Colors.white, // Adjust the background color as needed
                border: Border.all(
                  color: Color.fromARGB(
                      255, 238, 238, 238), // Adjust the border color as needed
                  width: 1.5, // Adjust the border width as needed
                )),
            child: Padding(
              padding: EdgeInsets.all(1),
              child: Text(
                '1',
                style: TextStyle(
                  fontFamily: 'custom_font',
                  fontSize: 30, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Adjust the text color as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned box2() {
    return Positioned(
      top: 500,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.fromARGB(255, 240, 240, 240),
            width: 1,
          ),
          color: Colors.white,
        ),
        height: 130,
        width: 350,
        child: Column(
          children: [
            SizedBox(height: 25),
            Row(
              children: [
                // Left Element
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Color.fromARGB(255, 37, 37, 37),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 7),
                    child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Center(
                        child: Text(
                          'บ้านนาบ้านเรา',
                          style: TextStyle(
                            fontFamily: 'custom_font',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                  margin: EdgeInsets.only(bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment
                            .topCenter, // Align the content to the top center
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ราคา ',
                              style: TextStyle(
                                fontFamily: 'custom_font',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '42',
                              style: TextStyle(
                                fontFamily: 'custom_font',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              ' บาท',
                              style: TextStyle(
                                fontFamily: 'custom_font',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 4,
                          ),
                          Text('- - - - - - - - - - - - - -'),
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 4,
                          ),
                        ],
                      ),
                      Text(
                        '20 นาทีโดยประมาณ',
                        style: TextStyle(
                          fontFamily: 'custom_font',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 5),

                // Right Element
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.red[800],
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 7),
                    child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Center(
                        child: Text(
                          'ยโสธร',
                          style: TextStyle(
                            fontFamily: 'custom_font',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Positioned box1() {
    return Positioned(
      top: 150,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.fromARGB(255, 245, 245, 245),
            width: 1,
          ),
          color: Colors.white,
        ),
        //ขนาดของกล่อง
        height: 330, // Increased height to accommodate additional content
        width: 350,
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 20)),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage('assets/dek.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'คุณสิไปไส ให้ข้อยพาไปบ่ ?',
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
              margin: EdgeInsets.symmetric(horizontal: 14),
              padding: EdgeInsets.symmetric(horizontal: 5),
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
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Color.fromARGB(255, 248, 248, 248),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'boxInput',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontFamily: 'custom_font',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 5), // Add spacing between the input and new content
            // New input with the same style as "เริ่มต้น :"
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(horizontal: 5),
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
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Color.fromARGB(255, 248, 248, 248),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'boxInput',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontFamily: 'custom_font',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 20), // Add spacing between the input and the button
            // Centered button at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 150, // Set the width of the button
                height: 40, // Set the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    // Add your button action here
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.all(0), // Remove padding to control size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Adjust the button's border radius
                    ),
                    backgroundColor: Color.fromARGB(255, 37, 37, 37),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0), // Add margin around the text
                    child: Text(
                      'เริ่ม',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'custom_font',
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

// ...
          ],
        ),
      ),
    );
  }

  Column backgound() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/deno1.jpg'), // Replace 'your_image.png' with your image asset path.
              fit: BoxFit.cover, // You can adjust the fit as needed.
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
