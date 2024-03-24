// Dependencias de flutter
import 'dart:convert';
// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

// Dependencias externas
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

// Otros archivo de codigo
// -- Modulos
import 'package:agrocablebot/modules/constants/constants.dart';
import 'package:agrocablebot/modules/components/components.dart';
import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:agrocablebot/modules/system/system.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late BuildContext globalContext;
  late Size size;

  bool initDateState = false;
  String initDatetime = DateTime.now().toString().substring(0, 19);
  String dateInit = '0001-01-01 00:00:00';
  bool endDateState = false;
  String endDatetime =
      DateTime.now().add(const Duration(hours: 1)).toString().substring(0, 19);
  String dateEnd = '9999-12-31 23:59:59';

  final GlobalKey chartKey = GlobalKey();
  late List<dynamic> chartData;
  List<String> keys = [];
  List<String> displayKeys = ['pitch', 'roll', 'yaw', 'x', 'y', 'z', 'value'];
  List<String> currentLines = [];
  List<Color> colores = [gris, amarillo, naranja];

  List<String> sensores = [
    "Acelerometro",
    "Giroscopio",
    "Magnetometro",
    "Orientacion",
    "Humedad",
    "Presion",
    "Temperatura"
  ];
  late String sensorValue;

  exportImage() async {
    RenderRepaintBoundary? boundary =
        chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image? image = await boundary.toImage(pixelRatio: 10);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    saveImage(
        pngBytes, '$sensorValue-${formatterFiles.format(DateTime.now())}.png');
  }

  getData() {
    http
        .post(Uri.parse('http://${Configuration.ip}:7001/data/$sensorValue'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'dateInit': initDateState ? initDatetime : dateInit,
              'dateEnd': endDateState ? endDatetime : dateEnd
            }))
        .then(
      (response) {
        if (response.statusCode == 200) {
          setState(() {
            chartData = jsonDecode(response.body);
            if (chartData.isNotEmpty) {
              keys = chartData[0].keys.toList();
              List<String> temp = [];

              for (var key in keys) {
                if (displayKeys.contains(key)) {
                  temp.add(key);
                }
              }
              currentLines = temp;
            }
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    sensorValue = sensores[0].toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Header(
          preferredSize: Size(600.w, 160.h),
          child: Text(AppLocalizations.of(context)!.charts)),
      body: Center(
        child: portraitLayout(),
      ),
      drawer: const SideMenu(),
    );
  }

  portraitLayout() => Column(
        children: [inputData(), chart(), actionButtons()],
      );

  inputData() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45.h,
            margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: naranja, width: 2.h),
              ),
            ),
            child: FittedBox(
              child: Text(
                AppLocalizations.of(globalContext)!.sensor,
                style: TextStyle(
                  color: gris,
                  fontSize: 100.sp,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: sensorValue,
                items: sensores.map(
                  (String sensor) {
                    return DropdownMenuItem(
                      value: sensor.toLowerCase(),
                      child: SizedBox(
                        height: 33.h,
                        child: FittedBox(
                          child: Text(
                            sensor,
                            style: TextStyle(color: gris, fontSize: 250.sp),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    sensorValue = value ?? sensorValue;
                  });
                },
              ),
            ),
          ),
          Container(
            height: 45.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: naranja, width: 2.h),
              ),
            ),
            child: FittedBox(
              child: Text(
                AppLocalizations.of(globalContext)!.range,
                style: TextStyle(
                  color: gris,
                  fontSize: 100.sp,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: initDateState,
                    onChanged: (bool? value) {
                      showOmniDateTimePicker(
                              context: context,
                              theme: ThemeData.light(),
                              isShowSeconds: true)
                          .then((datetime) {
                        setState(() {
                          initDateState = value!;
                          initDatetime = datetime.toString().substring(0, 19);
                        });
                      });
                    },
                  ),
                  SizedBox(
                    height: 35.h,
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(globalContext)!.start,
                        style: TextStyle(color: gris, fontSize: 100.sp),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      DateTime? date = await showOmniDateTimePicker(
                          context: context,
                          theme: ThemeData.light(),
                          isShowSeconds: true,
                          initialDate: DateTime.parse(initDatetime));
                      setState(() {
                        initDatetime =
                            date?.toString().substring(0, 19) ?? initDatetime;
                      });
                    },
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.change_circle),
                  ),
                  SizedBox(
                    height: 35.h,
                    child: FittedBox(
                      child: Text(initDatetime,
                          style: const TextStyle(color: gris)),
                    ),
                  ),
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: endDateState,
                    onChanged: (bool? value) {
                      showOmniDateTimePicker(
                              context: context,
                              theme: ThemeData.light(),
                              isShowSeconds: true)
                          .then((datetime) {
                        setState(() {
                          endDateState = value!;
                        });
                      });
                    },
                  ),
                  SizedBox(
                    height: 35.h,
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(globalContext)!.end,
                        style: TextStyle(color: gris, fontSize: 100.sp),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      DateTime? date = await showOmniDateTimePicker(
                          context: context,
                          theme: ThemeData.light(),
                          isShowSeconds: true,
                          initialDate: DateTime.parse(endDatetime));
                      setState(() {
                        endDatetime =
                            date?.toString().substring(0, 19) ?? endDatetime;
                      });
                    },
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.change_circle),
                  ),
                  SizedBox(
                    height: 35.h,
                    child: FittedBox(
                      child: Text(endDatetime,
                          style: const TextStyle(color: gris)),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      );

  actionButtons() {
    final buttons = [
      actionButton(
        AppLocalizations.of(globalContext)!.draw,
        () {
          getData();
        },
      ),
      actionButton(
        AppLocalizations.of(globalContext)!.save,
        () {
          exportImage();
        },
      ),
    ];
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
      ),
      margin: EdgeInsets.only(
        top: 5.h,
        bottom: 5.h,
      ),
      height: 110.h,
      child: Center(
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: EdgeInsets.zero,
          crossAxisCount: math.sqrt(buttons.length).ceil(),
          childAspectRatio: 7.sp,
          children: buttons,
        ),
      ),
    );
  }

  RepaintBoundary chart() {
    List<Widget> wList = [
      SizedBox(
        height: 100.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            currentLines.length,
            (index) {
              return Container(
                height: 50.h,
                margin: const EdgeInsets.only(right: 10),
                child: FittedBox(
                  child: Text(
                    currentLines.elementAt(index),
                    style: TextStyle(
                      color: colores[index],
                      fontSize: 100.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      Container(
        height: size.aspectRatio < 0.5 ? 320.h : 390.h,
        margin: EdgeInsets.only(right: 10.w, left: 10.w),
        child: LineChart(
          lineChartData(),
        ),
      )
    ];
    return RepaintBoundary(
      key: chartKey,
      child: Column(
        children: wList,
      ),
    );
  }

  LineChartData lineChartData() {
    List<LineChartBarData> data = [];
    for (var line in currentLines) {
      List<dynamic> temp = [];
      for (var d in chartData) {
        temp.add(d[line]);
      }
      data.add(puntos(temp, colores[data.length]));
    }
    return LineChartData(
        lineTouchData: lineTouchData(),
        gridData: const FlGridData(show: false),
        borderData: borderData,
        titlesData: titlesData1(),
        lineBarsData: data);
  }

  LineChartBarData puntos(List<dynamic> data, Color colorBar) {
    return LineChartBarData(
        color: colorBar,
        isCurved: false,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: List.generate(data.length, (index) {
          return FlSpot(index.toDouble(), data[index]);
        }));
  }

  LineTouchData lineTouchData() => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            tooltipMargin: 15.h,
            maxContentWidth: 300.w,
            tooltipBgColor: azul.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem('', const TextStyle(), children: [
                  TextSpan(
                    text:
                        '${currentLines.elementAt(barSpot.barIndex)}: ${barSpot.y.roundDecimals(3)}\n',
                    style: TextStyle(
                      color: colores[barSpot.barIndex],
                      shadows: const [
                        Shadow(
                          blurRadius: 1.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: '${chartData[barSpot.spotIndex]['fecha_creacion']}\n',
                    style: TextStyle(
                      color: colores[barSpot.barIndex],
                      shadows: const [
                        Shadow(
                          blurRadius: 1.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: '${barSpot.spotIndex}',
                    style: TextStyle(
                      color: colores[barSpot.barIndex],
                      shadows: const [
                        Shadow(
                          blurRadius: 1.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  )
                ]);
              }).toList();
            }),
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black),
          left: BorderSide(color: Colors.black),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  FlTitlesData titlesData1() => FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles(),
        ),
      );

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        reservedSize: 50.w,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    Widget axisTitle = FittedBox(
      child: Text('${value.roundDecimals(4)}',
          style: const TextStyle(
            color: gris,
          ),
          textAlign: TextAlign.center),
    );
    if ((value == meta.max) || (value == meta.min)) {
      final remainder = value % meta.appliedInterval;
      if (remainder != 0.0 && remainder / meta.appliedInterval < 0.9) {
        axisTitle = const SizedBox.shrink();
      }
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: axisTitle);
  }

  SideTitles bottomTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        reservedSize: 0.h,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget axisTitle = Text('${value.roundDecimals(4)}',
        style: const TextStyle(
          color: gris,
        ),
        textAlign: TextAlign.center);
    if ((value == meta.max) || (value == meta.min)) {
      final remainder = value % meta.appliedInterval;
      if (remainder != 0.0 && remainder / meta.appliedInterval < 0.9) {
        axisTitle = const SizedBox.shrink();
      }
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: axisTitle);
  }
}
