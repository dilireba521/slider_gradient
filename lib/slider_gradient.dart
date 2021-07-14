import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';

typedef SliderChangeCallback(SliderData data);

class SliderGradient extends StatefulWidget {
  SliderGradient(
      {Key key,
      this.label,
      this.thumbStyle = const ThumbStyle(),
      this.labelStyle = const LabelStyle(),
      this.sliderStyle = const SliderStyle(),
      this.isGradientBg = true,
      this.colors,
      this.min = 0,
      this.max = 100,
      this.isShowLabel = false,
      @required this.value,
      @required this.onChange,
      this.onChangeBegin,
      this.onChangeEnd})
      : assert(value != null),
        assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key);

  ///默认值
  int value;

  ///最小值
  final int min;

  ///最大值
  final int max;

  ///数据发生变化
  final SliderChangeCallback onChange;

  ///数据变化结束
  final SliderChangeCallback onChangeEnd;

  ///数据变化开始
  final SliderChangeCallback onChangeBegin;

  ///label展示数据，只有isShowLabel为true时才有效。
  final String label;

  ///是否展示label
  final bool isShowLabel;

  ///渐变色数组
  List<Color> colors;

  /// label样式自定义;
  final LabelStyle labelStyle;

  ///slider样式
  final SliderStyle sliderStyle;

  ///thumb样式
  final ThumbStyle thumbStyle;

  ///背景slider背景色是否为渐变色，默认为true
  final bool isGradientBg;

  @override
  _SliderGradientState createState() => _SliderGradientState();
}

class _SliderGradientState extends State<SliderGradient> {
  double _thumbHeight;
  double _thumbWidth;
  double _sliderHeight;
  Color _labelFillColor;
  double _labelHeight;
  Color _beginColor;
  Color _endColor;
  Color _thumbColor;
  double _leftLocation;
  double _sliderWidth; //
  double _sliderMinWidth = 140; //slider最小宽度
  double _sliderBorderRadius;
  bool _isShowLabel = false; //手势控制时，label的状态
  Color _primaryColor;
  Duration _duration = Duration(milliseconds: 100); //动画时长

  ///初始化执行方法
  void initData(BoxConstraints constraints) {
    _primaryColor = Theme.of(context).primaryColor;
    _sliderHeight = widget.sliderStyle.height;
    _sliderBorderRadius = widget.sliderStyle.radius;
    _beginColor = widget.colors?.first ?? _primaryColor;
    _endColor = widget.colors?.last ?? Color(0xffffffff);

    if (widget.colors == null) {
      widget.colors = [_beginColor, _endColor];
    }
    _labelFillColor = widget.labelStyle.fillColor ?? _beginColor;
    _labelHeight = labelTextHeight(
        "${widget.label ?? widget.value}", widget.labelStyle.size);
    _thumbHeight = widget.thumbStyle.height;
    _thumbWidth = widget.thumbStyle.width;
    if (constraints.maxWidth == double.infinity)
      _sliderWidth = _sliderMinWidth - _thumbWidth;
    else
      _sliderWidth = constraints.maxWidth - _thumbWidth;
    _leftLocation = ((widget.value - widget.min) / (widget.max - widget.min)) *
            _sliderWidth -
        _thumbWidth / 2;
    _getthumbColor();
  }

  ///水平移动thumb
  void _moveHrizontal(DragUpdateDetails val) {
    double _dx = val.localPosition.dx;
    _changethumbLocation(_dx);
    _getThumbVal(_leftLocation);
  }

  ///点击thumb
  void handleClick(TapDownDetails val) {
    double _dx = val.localPosition.dx;
    _changethumbLocation(_dx);
    _getThumbVal(_leftLocation);
  }

  ///根据点击位置，对thumb位置做变换
  void _changethumbLocation(double val) {
    if (val < -_thumbWidth / 2) {
      _leftLocation = -_thumbWidth / 2;
    } else if (val >= _sliderWidth - _thumbWidth / 2) {
      _leftLocation = _sliderWidth - _thumbWidth / 2;
    } else {
      _leftLocation = val;
    }
  }

  ///根据thumb当前位置返回对应数值
  void _getThumbVal(double val) {
    int _currentVal = (((_leftLocation + _thumbWidth / 2) / _sliderWidth) *
            (widget.max - widget.min))
        .ceil();
    if (_currentVal <= widget.min / 100) {
      widget.value = widget.min;
    } else if (_currentVal >= widget.max - widget.min * 101 / 100) {
      widget.value = widget.max;
    } else {
      widget.value = _currentVal + widget.min;
    }
    _getthumbColor();
  }

  ///thumb颜色获取
  void _getthumbColor() {
    if (!widget.isGradientBg ||
        widget.colors == null ||
        widget.colors.length < 2) {
      _thumbColor = _beginColor;
      return;
    }
    double _percent = ((_leftLocation + _thumbWidth / 2) / _sliderWidth);
    int _len = widget.colors?.length ?? 2;
    _thumbColor = _lerp(_len, _percent);
  }

  ///判断数据变化时是否显示label
  void _isShowLabelClick(bool val) {
    if (widget.isShowLabel) _isShowLabel = val;
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

  ///计算label文本高度
  double labelTextHeight(String value, double fontSize) {
    if (value == null || value.length == 0) return 0;
    TextPainter painter = TextPainter(
        //AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
        locale: Localizations.localeOf(context),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: value,
            style: TextStyle(
              fontSize: fontSize,
            )));
    painter.layout(maxWidth: 100);
    //文字的宽度:painter.width
    return painter.height;
  }

  ///slider 纯色背景
  Widget sliderItem() {
    if (_sliderWidth == null || _leftLocation == null) return Container();
    double _width = _leftLocation + _thumbWidth / 2;
    Color _color;
    _color = _beginColor;
    _width = _width > _sliderWidth ? _sliderWidth : _width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_sliderBorderRadius),
      child: AnimatedContainer(
        width: _width,
        duration: _duration,
        color: _color,
      ),
    );
  }

  ///获取当前参数添加到回调函数内
  SliderData dataCallback() {
    return SliderData(thumbColor: _thumbColor, value: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      initData(constraints);
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: _sliderMinWidth),
        child: GestureDetector(
          onTapDown: (val) {
            handleClick(val);
            _isShowLabelClick(true);
            if (widget.onChange != null) widget.onChange(dataCallback());
          },
          onTapUp: (val) {
            if (widget.onChangeEnd != null) widget.onChangeEnd(dataCallback());
            if (widget.onChange != null) widget.onChange(dataCallback());
            _isShowLabelClick(false);
          },
          onHorizontalDragStart: (val) {
            if (widget.onChangeBegin != null)
              widget.onChangeBegin(dataCallback());
          },
          onHorizontalDragUpdate: (val) {
            _moveHrizontal(val);
            if (widget.onChange != null) widget.onChange(dataCallback());
          },
          onHorizontalDragEnd: (val) {
            if (widget.onChangeEnd != null) widget.onChangeEnd(dataCallback());
            if (widget.onChange != null) widget.onChange(dataCallback());
            _isShowLabelClick(false);
          },
          child: Container(
            padding:
                EdgeInsets.only(left: _thumbWidth / 2, right: _thumbWidth / 2),
            height: _sliderHeight > _thumbHeight ? _sliderHeight : _thumbHeight,
            width: _sliderWidth + _thumbWidth,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.center,
              children: [
                //background
                backgroundWidget(),
                //label
                _leftLocation != null
                    ? _isShowLabel
                        ? labelWidget()
                        : Container()
                    : Container(),
                //thumb
                thumbWidget()
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
      width: double.infinity,
      height: _sliderHeight,
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
                sliderItem(),
              ],
            )
          : null,
    );
  }

  ///thumb
  Widget thumbWidget() {
    return AnimatedPositioned(
      duration: _duration,
      left: _leftLocation,
      child: Column(
        children: [
          _leftLocation != null
              ? AnimatedContainer(
                  duration: _duration,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.thumbStyle.radius)),
                    color: _thumbColor ?? _beginColor,
                    border: Border.all(
                        color: widget.thumbStyle.borderColor, width: 2),
                  ),
                  width: _thumbWidth,
                  height: _thumbHeight,
                )
              : Container(),
        ],
      ),
    );
  }

  ///label
  Widget labelWidget() {
    return AnimatedPositioned(
      duration: _duration,
      left: _leftLocation - 50 + _thumbWidth / 2,
      top: -_labelHeight - 15,
      child: Container(
        width: 100,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: _labelFillColor,
              ),
              child:
                  Text("${widget.label ?? widget.value}", style: labelStyle()),
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
                      color: _labelFillColor,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderData {
  SliderData({this.thumbColor, this.value});
  int value; //选中数值
  Color thumbColor; //选中颜色
}

class SliderStyle {
  const SliderStyle({this.height = 16, this.radius = 4});

  ///slider高度
  final double height;

  ///slider 圆角
  final double radius;
}

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

class ThumbStyle {
  const ThumbStyle(
      {this.borderColor = const Color(0xffE6E6E6),
      this.width = 16,
      this.height = 32,
      this.radius = 4});

  ///thumb高度
  final double height;

  ///thumb宽度
  final double width;

  ///thumb 圆角
  final double radius;

  ///thumb 边框颜色
  final Color borderColor;
}
