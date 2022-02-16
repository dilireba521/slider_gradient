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
  double val1 = 50;
  double val2 = 43;
  double valMin = 1;
  double valMax = 100;

  double rangeMin = 0;
  double rangeMax = 100;
  double rangeVal1 = 50;
  double rangeVal2 = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('slider_gradient'),
      ),
      body: Container(
          child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          SliderGradient(
            min: valMin,
            max: valMax,
            value: val1,
            onChangeEnd: (valData) {
              setState(() {
                val1 = valData.value;
              });
            },
            isGradientBg: false,
            isShowLabel: true,
            onChange: (SliderData data) {},
          ),
          SizedBox(
            height: 50,
          ),
          SliderGradient(
            value: val2,
            isShowLabel: true,
            label: "${color ?? 0}",
            onChangeEnd: (data) {
              setState(() {
                val2 = data.value;
                color = data.color;
              });
            },
            colors: [Colors.red, Colors.green, Colors.yellow],
            onChange: (SliderData data) {},
          ),
          SizedBox(
            height: 50,
          ),
          SliderGradient(
            isRange: true,
            min: rangeMin,
            max: rangeMax,
            values: [rangeVal1, rangeVal2],
            isShowLabel: true,
            onChangeEnd: (data) {
              setState(() {
                rangeVal1 = data.values.first;
                rangeVal2 = data.values.last;
              });
            },
            colors: [Colors.red, Colors.green],
            value: rangeVal1,
            onChange: (SliderData data) {},
          ),
        ],
      )),
    );
  }
}
