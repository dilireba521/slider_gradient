import 'package:flutter/painting.dart';

class LabelStyle {
  const LabelStyle(
      {this.fillColor, this.color = const Color(0xffffffff), this.size = 10});

  ///背景填充色
  final Color fillColor;

  ///字体颜色
  final Color color;

  ///字体大小
  final double size;
}
