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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('slider_gradient'),
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
                SliderGradient(),
                SizedBox(
                  height: 40,
                ),
                SliderGradient(
                  isGradientBg: false,
                  isShowLabel: true,
                ),
                SizedBox(
                  height: 40,
                ),
                SliderGradient(
                  onChangeEnd: (val) {
                    print("object:${val.value}");
                  },
                  // isGradientBg: false,
                  isShowLabel: true,
                  colors: [
                    // Theme.of(context).primaryColor,
                    // Colors.red,
                    // Colors.green,
                    Colors.yellow
                  ],
                )
              ],
            )),
      ),
    );
  }
}
