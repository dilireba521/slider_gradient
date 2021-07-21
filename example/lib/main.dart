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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color color;
  int val1 = 40;
  int val2 = 40;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('slider_gradient'),
      ),
      body: Container(
          // padding: EdgeInsets.all(20),
          child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          SliderGradient(
            value: val1,
            onChange: (valData) {
              setState(() {
                val1 = valData.value;
              });
            },
            isGradientBg: false,
            isShowLabel: true,
          ),
          SizedBox(
            height: 40,
          ),
          SliderGradient(
            value: val2,
            isShowLabel: true,
            label: "${color ?? 0}",
            onChange: (valData) {
              setState(() {
                color = valData.thumbColor;
                val2 = valData.value;
              });
            },
            colors: [Colors.red, Colors.green, Colors.yellow],
          ),
        ],
      )),
    );
  }
}
