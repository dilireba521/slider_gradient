import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';

import 'model/label_style.dart';
import 'model/track_style.dart';

typedef SliderChangeCallback(SliderData data);
enum SliderLocation { left, right }
enum ColorFromARGB { a, r, g, b }

class SliderData {
  SliderData({this.trackColor, this.value});
  int value;
  Color trackColor;
}

class SliderGradient extends StatefulWidget {
  SliderGradient(
      {Key key,
      this.label,
      this.trackStyle = const TrackStyle(),
      this.labelStyle = const LabelStyle(),
      this.sliderHeight,
      this.isGradientBg = true,
      this.colors,
      this.min = 0,
      this.max = 100,
      this.isShowLabel = false,
      this.initValue,
      this.onChange,
      this.onChangeBegin,
      this.onChangeEnd})
      : super(key: key);

  ///默认值
  int initValue;

  ///最小值
  int min;

  ///最大值
  int max;

  ///数据发生变化
  SliderChangeCallback onChange;

  ///数据变化结束
  SliderChangeCallback onChangeEnd;

  ///数据变化开始
  SliderChangeCallback onChangeBegin;

  ///label展示数据，只有isShowLabel为true时才有效。
  String label;

  ///是否展示label
  bool isShowLabel;

  ///渐变色数组
  List<Color> colors;

  /// label样式自定义;
  LabelStyle labelStyle;

  ///slider高度
  double sliderHeight;

  ///track样式
  TrackStyle trackStyle;

  ///背景slider背景色是否为渐变色，默认为true
  bool isGradientBg;

  @override
  _SliderGradientState createState() => _SliderGradientState();
}

class _SliderGradientState extends State<SliderGradient> {
  double trackHeight;
  double trackWidth;
  double sliderHeight;
  String label;
  Color labelFillColor;
  int initValue;
  Color _beginColor;
  Color _endColor;
  Color _trackColor;
  Color _trackBorderColor = Color(0xffE6E6E6);
  double _leftLocation;
  double _sliderWidth; //
  double _sliderMinWidth = 140; //
  double _sliderBorderRadius = 4;
  bool _isShowLabel; //手势控制时，label的状态
  Color _primaryColor;
  @override
  void initState() {
    super.initState();
    if (widget.initValue == null || widget.min > widget.initValue) {
      initValue = widget.min;
    } else if (widget.initValue > widget.max) {
      initValue = widget.max;
    } else {
      initValue = widget.initValue;
    }
  }

  ///初始化执行方法
  void initData() {
    _primaryColor = Theme.of(context).primaryColor;
    sliderHeight = widget.sliderHeight ?? 16;
    _beginColor = widget.colors?.first ?? _primaryColor;
    _endColor = widget.colors?.last ?? Color(0xffffffff);

    if (widget.colors == null) {
      widget.colors = [_beginColor, _endColor];
    }
    labelFillColor = widget.labelStyle.fillColor ?? _beginColor;
    trackHeight = widget.trackStyle.height;
    trackWidth = widget.trackStyle.width;
    if (widget.isShowLabel)
      _isShowLabel = true;
    else
      _isShowLabel = false;
    if (_leftLocation == null) {
      Future.delayed(Duration(milliseconds: 100), () {
        //初始化位置
        _leftLocation = ((initValue - widget.min) / (widget.max - widget.min)) *
                _sliderWidth -
            trackWidth / 2;
        _getTrackColor();
      });
    }
  }

  ///水平移动track
  void moveHrizontal(DragUpdateDetails val) {
    double _dx = val.localPosition.dx;
    changeTrackLocation(_dx);
    getTrackVal(_leftLocation);
  }

  ///点击track
  void handleClick(TapDownDetails val) {
    double _dx = val.localPosition.dx;
    changeTrackLocation(_dx);
    getTrackVal(_leftLocation);
  }

  ///根据点击位置，对track位置做变换
  void changeTrackLocation(double val) {
    if (val < -trackWidth / 2) {
      _leftLocation = -trackWidth / 2;
    } else if (val >= _sliderWidth - trackWidth / 2) {
      _leftLocation = _sliderWidth - trackWidth / 2;
    } else {
      _leftLocation = val;
    }
  }

  ///根据track当前位置返回对应数值
  void getTrackVal(double val) {
    int _currentVal = (((_leftLocation + trackWidth / 2) / _sliderWidth) *
            (widget.max - widget.min))
        .ceil();
    if (_currentVal <= widget.min / 100) {
      initValue = widget.min;
    } else if (_currentVal >= widget.max - widget.min * 101 / 100) {
      initValue = widget.max;
    } else {
      initValue = _currentVal + widget.min;
    }
    _getTrackColor();
  }

  ///track颜色获取
  void _getTrackColor() {
    if (!widget.isGradientBg ||
        widget.colors == null ||
        widget.colors.length < 2) {
      _trackColor = _beginColor;
      setState(() {});
      return;
    }
    double _percent = ((_leftLocation + trackWidth / 2) / _sliderWidth);
    int _len = widget.colors?.length ?? 2;
    _trackColor = _lerp(_len, _percent);
    setState(() {});
  }

  ///根据百分比求出前后颜色
  Color _lerp(int len, double percent) {
    int _denominator = len - 1;
    int _num = 1;
    while (_num / _denominator < percent) {
      _num++;
    }
    return Color.lerp(widget.colors[_num - 1], widget.colors[_num],
        ((percent - (_num - 1) / _denominator) * _denominator).toDouble());
  }

  ///label样式
  TextStyle labelStyle() {
    return TextStyle(
        fontSize: widget.labelStyle.size, color: widget.labelStyle.color);
  }

  ///slider 纯色背景
  Widget sliderItem(SliderLocation location) {
    if (_sliderWidth == null || _leftLocation == null) return Container();
    double _width = _leftLocation + trackWidth / 2;
    Color _color;

    if (location == SliderLocation.left) {
      _color = _beginColor;
      _width = _width > _sliderWidth ? _sliderWidth : _width;
    } else if (location == SliderLocation.right) {
      _color = _endColor;
      _width = _sliderWidth - _width;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(_sliderBorderRadius),
      child: AnimatedContainer(
        width: _width,
        duration: Duration(milliseconds: 100),
        color: _color,
      ),
    );
  }

  ///获取当前参数添加到回调函数内
  SliderData dataCallback() {
    return SliderData(trackColor: _trackColor, value: initValue);
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth == double.infinity)
        _sliderWidth = _sliderMinWidth;
      else
        _sliderWidth = constraints.maxWidth;
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: _sliderMinWidth),
        child: GestureDetector(
          onTapDown: (val) {
            handleClick(val);
          },
          onTapUp: (val) {
            if (widget.onChangeEnd != null) widget.onChangeEnd(dataCallback());
          },
          onHorizontalDragStart: (val) {
            if (widget.onChangeBegin != null)
              widget.onChangeBegin(dataCallback());
          },
          onHorizontalDragUpdate: (val) {
            moveHrizontal(val);
            if (widget.onChange != null) widget.onChange(dataCallback());
          },
          onHorizontalDragEnd: (val) {
            if (widget.onChangeEnd != null) widget.onChangeEnd(dataCallback());
          },
          child: Container(
            // duration: Duration(milliseconds: 100),
            height: trackHeight,
            width: _sliderWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                //background
                backgroundWidget(),
                //label
                _leftLocation != null
                    ? _isShowLabel
                        ? labelWidget()
                        : Container()
                    : Container(),
                //track
                trackWidget()
              ],
            ),
          ),
        ),
      );
    });
  }

  ///background
  Widget backgroundWidget() {
    return Container(
      margin: EdgeInsets.only(top: trackHeight / 4),
      width: double.infinity,
      height: sliderHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(_sliderBorderRadius)),
          gradient: widget.isGradientBg
              ? LinearGradient(
                  colors: widget.colors == null || widget.colors.length < 2
                      ? [_beginColor, _endColor]
                      : widget.colors)
              : null,
          color: widget.isGradientBg ? null : _endColor),
      child: !widget.isGradientBg
          ? Row(
              children: [
                sliderItem(SliderLocation.left),
              ],
            )
          : null,
    );
  }

  ///track
  Widget trackWidget() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      left: _leftLocation,
      child: Column(
        children: [
          _leftLocation != null
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: _trackColor ?? _beginColor,
                    border: Border.all(color: _trackBorderColor, width: 2),
                  ),
                  width: trackWidth,
                  height: trackHeight,
                )
              : Container(),
        ],
      ),
    );
  }

  ///label
  Widget labelWidget() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      left: _leftLocation - 50 + trackWidth / 2,
      top: -26 - (widget.labelStyle.size - 10),
      child: Container(
        width: 100,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: labelFillColor,
              ),
              child: Text("${widget.label ?? initValue}", style: labelStyle()),
            ),
            Transform.translate(
              offset: Offset(0, -5),
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                      color: labelFillColor,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
