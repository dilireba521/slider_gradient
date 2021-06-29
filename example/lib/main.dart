import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:slider_gradient/slider_gradient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                SliderGradient(
                  isShowLabel: true,
                ),
                SizedBox(
                  height: 40,
                ),
                SliderGradient(
                  beginColor: Colors.red,
                  endColor: Colors.green,
                ),
                SizedBox(
                  height: 40,
                ),
                SliderGradient(
                  isGradientBg: false,
                  endColor: Colors.grey[300],
                  isShowLabel: true,
                )
              ],
            )),
      ),
    );
  }
}
