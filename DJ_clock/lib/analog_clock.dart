import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:flukit/flukit.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:volume_watcher/volume_watcher.dart';

final radiansPerTick = radians(360 / 60);

final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';

  bool isiOS = null; //判斷 ios和安卓
  Timer _timer;
  double _turns = DateTime.now().second / 60;

  Size recordPlayerSize = Size(0, 0);
  GlobalKey _recordPlayerSizeKey = GlobalKey();

  _getContainerSize() {
    RenderBox _recordPlayerSizeBox =
        _recordPlayerSizeKey.currentContext.findRenderObject();
    recordPlayerSize = _recordPlayerSizeBox.size;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    _updateTime();
    _updateModel();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getContainerSize());
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1),
        _updateTime,
      );

      _turns += (1 / 60);
    });
  }

  var nowSpeed = 0;
  var kedovalue = 0;

  @override
  Widget build(BuildContext context) {
    if (isiOS == null) {
      isiOS = Theme.of(context).platform == TargetPlatform.iOS ? true : false;
      print(isiOS);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _getContainerSize());

    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_now);
    final minute = DateFormat('mm').format(_now);

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );
    final imageTheme =
        Theme.of(context).brightness == Brightness.light ? 'light' : 'dark';

    final time = DateFormat.Hms().format(DateTime.now());

    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );

    // if (_now.second + _now.millisecond / 1000 < 0.05) {
    //   nowSpeed = 0;
    // } else {
    //   nowSpeed = 500;
    // }
    nowSpeed = 5000;

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        key: _recordPlayerSizeKey,
        margin: EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/background_$imageTheme.png")),
        ),
        child: Stack(
          children: [
            Positioned(
              //唱片陰影
              left: recordPlayerSize.width * 0.07,
              top: recordPlayerSize.height * 0.1,
              height: recordPlayerSize.height * 0.8,
              child: Image(
                image: AssetImage("images/record_shadow.png"),
              ),
            ),
            Positioned(
              //唱片
              left: recordPlayerSize.width * 0.05,
              top: recordPlayerSize.height * 0.1,
              height: recordPlayerSize.height * 0.8,
              child: TurnBox(
                turns: _turns,
                speed: nowSpeed,
                child: Image(
                  image: AssetImage("images/record_$imageTheme.png"),
                ),
              ),
            ),
            Positioned(
              //時間
              left: recordPlayerSize.width * 0.15,
              top: recordPlayerSize.height * 0.36,
              child: Text(
                '$hour : $minute',
                style: TextStyle(
                  fontFamily: 'CuteFont',
                  color: Colors.red[400],
                  fontSize: recordPlayerSize.height * 0.2,
                  shadows: [
                    Shadow(
                      blurRadius: 0,
                      color: Colors.red[200],
                      offset: Offset(2, 0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              //指針
              left: recordPlayerSize.width * 0.4,
              top: recordPlayerSize.height * 0.05,
              height: recordPlayerSize.height * 0.75,
              child: Image.asset(
                "images/Tonearm.png",
              ),
            ),
            Positioned(
              //旋鈕陰影
              left: recordPlayerSize.width * 0.75,
              top: recordPlayerSize.height * 0.08,
              height: recordPlayerSize.height * 0.2,
              child: Image(
                image: AssetImage("images/knob_shadow_$imageTheme.png"),
              ),
            ),
            Positioned(
              //旋鈕
              left: recordPlayerSize.width * 0.74,
              top: recordPlayerSize.height * 0.08,
              height: recordPlayerSize.height * 0.2,
              child: Stack(
                children: <Widget>[
                  TurnBox(
                    turns: kedovalue / 100,
                    speed: 0,
                    child: Image.asset(
                      "images/knob_$imageTheme.png",
                    ),
                  ),
                  SleekCircularSlider(
                    initialValue: 0,
                    appearance: CircularSliderAppearance(
                      angleRange: 300,
                      startAngle: 270,
                      size: recordPlayerSize.height * 0.25,
                      infoProperties: InfoProperties(),
                      customColors: CustomSliderColors(
                        dotColor: Colors.transparent,
                        progressBarColor: Colors.transparent,
                        trackColor: Colors.transparent,
                        hideShadow: true,
                      ),
                    ),
                    onChange: (double value) {
                      kedovalue = value.toInt();
                      setState(() {});
                      VolumeWatcher.setVolume(isiOS == null
                          ? value / 100
                          : isiOS ? value / 100 : value / 10);
                      print(kedovalue);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              //拉桿
              left: recordPlayerSize.width * 0.7,
              top: recordPlayerSize.height * 0.35,
              width: recordPlayerSize.width * 0.2,
              height: recordPlayerSize.height * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: recordPlayerSize.width * 0.06,
                        height: recordPlayerSize.height * 0.08,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/print.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text("${_now.year % 100}"),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            width: recordPlayerSize.width * 0.06,
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              "images/track_$imageTheme.png",
                              height: recordPlayerSize.height * 0.5,
                            ),
                          ),
                          Positioned(
                            top: recordPlayerSize.height *
                                0.425 *
                                ((_now.year % 100 + 1) / 100),
                            child: Image.asset(
                              "images/fader_y_$imageTheme.png",
                              width: recordPlayerSize.width * 0.06,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: recordPlayerSize.width * 0.06,
                        height: recordPlayerSize.height * 0.08,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/print.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text(_now.month < 10
                            ? "0${_now.month}"
                            : "${_now.month}"),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            width: recordPlayerSize.width * 0.06,
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              "images/track_$imageTheme.png",
                              height: recordPlayerSize.height * 0.5,
                            ),
                          ),
                          Positioned(
                            top: recordPlayerSize.height *
                                0.4 *
                                (_now.month / 12),
                            child: Image.asset(
                              "images/fader_m_$imageTheme.png",
                              width: recordPlayerSize.width * 0.06,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: recordPlayerSize.width * 0.06,
                        height: recordPlayerSize.height * 0.08,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/print.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Text(
                            _now.day < 10 ? "0${_now.day}" : "${_now.day}"),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            width: recordPlayerSize.width * 0.06,
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              "images/track_$imageTheme.png",
                              height: recordPlayerSize.height * 0.5,
                            ),
                          ),
                          Positioned(
                            top: recordPlayerSize.height *
                                0.425 *
                                (_now.day / 31),
                            child: Image.asset(
                              "images/fader_d_$imageTheme.png",
                              width: recordPlayerSize.width * 0.06,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
