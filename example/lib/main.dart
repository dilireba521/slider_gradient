import 'package:flutter/material.dart';
import 'package:slider_gradient/slider_gradient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color color;
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
                  isShowLabel: true,
                  label: "${color}",
                  onChange: (val) {
                    setState(() {
                      color = val.thumbColor;
                    });
                  },
                  colors: [Colors.red, Colors.green, Colors.yellow],
                )
              ],
            )),
      ),
    );
  }
}
