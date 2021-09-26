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
      this.onChangeEnd,
      this.disabled = false})
      : assert(value != null),
        assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key);

  ///默认值
  double value;

  ///最小值
  final double min;

  ///最大值
  final double max;

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

  ///当isGradientBg=true时为渐变色数组，
  ///当isGradientBg=false时，不设置时slider主色调为系统当前主题色，辅助色为白色，
  ///对colors进行设置时主色调取数组第一个，辅助色取最后一个
  List<Color> colors;

  ///背景slider背景色是否为渐变色，默认为true
  final bool isGradientBg;

  /// label样式自定义;
  final LabelStyle labelStyle;

  ///slider样式
  final SliderStyle sliderStyle;

  ///thumb样式
  final ThumbStyle thumbStyle;

  ///空件为禁用状态
  bool disabled;

  @override
  _SliderGradientState createState() => _SliderGradientState();
}

class _SliderGradientState extends State<SliderGradient>
    with SingleTickerProviderStateMixin {
  Duration _duration = Duration(milliseconds: 100); //动画时长
  AnimationController controller;
  double _sliderDefaultWidth = 150;
  double _defaultWidth = 150;
  double _sliderDefaultPadding = 20;
  Color _thumbColor;
  Color _beginColor;
  Color _endColor;
  double _percent = 0;
  double _labelHeight;
  double _labelWidth = 100;
  double _value;
  bool _isShowLabel = false; //手势控制时，label的状态

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: _duration,
      vsync: this,
    );
    controller.value = 0;
  }

  ///初始化执行方法
  void initData(BoxConstraints constraints) {
    if (constraints.maxWidth != double.infinity)
      _sliderDefaultWidth = constraints.maxWidth;
    _beginColor = widget.colors?.first ?? Theme.of(context).primaryColor;
    _endColor = widget.colors?.last ?? Color(0xffffffff);
    _thumbColor = _beginColor;
    if (widget.colors == null) {
      widget.colors = [_beginColor, _endColor];
    }
    _defaultWidth = _sliderDefaultWidth - 2 * _sliderDefaultPadding;
    _labelHeight = labelTextHeight(
        "${widget.label ?? widget.value}", widget.labelStyle.size);
    if (widget.max == widget.min) {
      widget.disabled = true;
      return;
    }
    _location(widget.value);
  }

  void _tapDown(TapDownDetails details) {
    double _dx = details.localPosition.dx;
    _thumbLocation(_dx);
    _isShowLabelClick(true);
    if (widget.onChange != null) widget.onChange(dataCallback());
  }

  void _tapUp(TapUpDetails details) {
    if (widget.onChangeEnd != null) widget.onChangeEnd(dataCallback());
    // if (widget.onChange != null) widget.onChange(dataCallback());
    _isShowLabelClick(false);
  }

  void _horizontalDragStart(DragStartDetails details) {
    if (widget.onChangeBegin != null) widget.onChangeBegin(dataCallback());
  }

  void _horizontalDragUpdate(DragUpdateDetails details) {
    double _dx = details.localPosition.dx;
    _thumbLocation(_dx);
    controller.value += details.primaryDelta / _defaultWidth;
    if (widget.onChange != null) widget.onChange(dataCallback());
  }

  void _horizontalDragEnd(DragEndDetails details) {
    if (widget.onChangeEnd != null) widget.onChangeEnd(dataCallback());
    if (widget.onChange != null) widget.onChange(dataCallback());
    _isShowLabelClick(false);
  }

  void _thumbLocation(double val) {
    if (val <= _sliderDefaultPadding) {
      controller.value = 0;
      _percent = 0;
    } else if (val >= _sliderDefaultPadding + _defaultWidth) {
      controller.value = 1;
      _percent = 1;
    } else {
      _percent = _toAsFixed((val - _sliderDefaultPadding) / _defaultWidth, 4);
      controller.animateTo(_percent);
    }
    _value = _valueTransform(_percent);
    _getThumbColor();
  }

  ///根据传入值确定thumb位置
  void _location(double val) {
    _percent = _toAsFixed((val - widget.min) / (widget.max - widget.min), 2);
    controller.value = _percent;
    _value = _valueTransform(_percent);
    _getThumbColor();
  }

  ///thumb颜色获取
  void _getThumbColor() {
    if (!widget.isGradientBg ||
        widget.colors == null ||
        widget.colors.length < 2) {
      _thumbColor = _beginColor;
      return;
    }
    int _len = widget.colors?.length ?? 2;
    _thumbColor = _lerp(_len, _percent);
  }

  double _valueTransform(double val) {
    double _res = val * (widget.max - widget.min) + widget.min;
    return _toAsFixed(_res, 2);
  }

  double _toAsFixed(double val, int digit) {
    return double.parse(val.toStringAsFixed(digit));
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

  SliderData dataCallback() {
    return SliderData(color: _thumbColor, value: _value);
  }

  ///判断数据变化时是否显示label
  void _isShowLabelClick(bool val) {
    if (widget.isShowLabel) _isShowLabel = val;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        initData(constraints);
        return Opacity(
          opacity: widget.disabled ? .6 : 1,
          child: AbsorbPointer(
            absorbing: widget.disabled,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: _sliderDefaultWidth,
                  maxHeight:
                      widget.sliderStyle.height > widget.thumbStyle.height
                          ? widget.sliderStyle.height
                          : widget.thumbStyle.height),
              child: GestureDetector(
                  onTapDown: _tapDown,
                  onTapUp: _tapUp,
                  onHorizontalDragStart: _horizontalDragStart,
                  onHorizontalDragUpdate: _horizontalDragUpdate,
                  onHorizontalDragEnd: _horizontalDragEnd,
                  child: Container(
                      child: AnimatedBuilder(
                    animation: controller,
                    builder: (BuildContext context, Widget child) {
                      return Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.only(
                              left: _sliderDefaultPadding,
                              right: _sliderDefaultPadding),
                          child: Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              //background
                              backgroundWidget(),
                              thumbWidget(),
                            ],
                          ));
                    },
                    child: Container(
                      width: widget.thumbStyle.width,
                      height: widget.thumbStyle.height,
                      color: Colors.black26,
                    ),
                  ))),
            ),
          ),
        );
      },
    );
  }

  //thumb
  Widget thumbWidget() {
    return CustomSingleChildLayout(
        delegate: _ModalSliderLayout(_percent, true, widget.thumbStyle.width),
        child: Stack(
            alignment: AlignmentDirectional.centerStart,
            clipBehavior: Clip.none,
            children: [
              labelWidget(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(widget.thumbStyle.radius)),
                  color: _thumbColor,
                  border: Border.all(
                      color: widget.thumbStyle.borderColor, width: 2),
                ),
                width: widget.thumbStyle.width,
                height: widget.thumbStyle.height,
              ),
            ]));
  }

  ///label
  Widget labelWidget() {
    return Positioned(
      left: -_labelWidth / 2 + widget.thumbStyle.width / 2,
      top: -_labelHeight - 15,
      child: Offstage(
        offstage: !_isShowLabel,
        child: Container(
          alignment: Alignment.center,
          width: _labelWidth,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: widget.labelStyle.fillColor ?? _beginColor,
                ),
                child: Text("${widget.label ?? _value}",
                    overflow: TextOverflow.ellipsis, style: labelStyle()),
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
                        color: widget.labelStyle.fillColor ?? _beginColor,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///background
  Widget backgroundWidget() {
    return Container(
      width: double.infinity,
      height: widget.sliderStyle.height,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(widget.sliderStyle.radius)),
          gradient: widget.isGradientBg
              ? LinearGradient(colors: widget.colors)
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

  ///slider 纯色背景
  Widget sliderItem() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.sliderStyle.radius),
      child: Container(
        width: _defaultWidth * _percent,
        color: _beginColor,
      ),
    );
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
}

class SliderData {
  SliderData({this.color, this.value});
  double value; //选中数值
  Color color; //选中颜色
}

class SliderStyle {
  const SliderStyle({this.height = 16, this.radius = 4}) : assert(height >= 1);

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
      this.radius = 4})
      : assert(width >= 6),
        assert(height >= 6);

  ///thumb高度
  final double height;

  ///thumb宽度
  final double width;

  ///thumb 圆角
  final double radius;

  ///thumb 边框颜色
  final Color borderColor;
}

class _ModalSliderLayout extends SingleChildLayoutDelegate {
  _ModalSliderLayout(this.progress, this.isScrollControlled, this.thumbWidth);

  final double progress;
  final bool isScrollControlled;
  final double thumbWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: 0,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.maxHeight,
      // maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(size.width * progress - thumbWidth / 2, 0);
  }

  // @override
  bool shouldRelayout(_ModalSliderLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
