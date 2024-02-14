import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import 'package:acb/components/constants.dart';
import 'package:acb/components/header.dart';
import 'package:acb/components/menu.dart';
import 'package:acb/components/system.dart';

import 'package:acb/screens/charts/components/functions.dart';

import 'dart:developer' as dev;

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, required this.configuration});

  final Map<String, String> configuration;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Functions functions;

  final GlobalKey chartKey = GlobalKey();
  late List<dynamic> chartData;
  String dateInit = DateTime.now().toString().substring(0, 19);
  String dateEnd = DateTime.now().toString().substring(0, 19);

  List<String> keys = [];
  List<String> displayKeys = ['pitch', 'roll', 'yaw', 'x', 'y', 'z', 'value'];
  List<String> currentLines = [];
  List<Color> colores = [gris, amarillo, naranja];
  List<String> sensores = [
    'Acelerometro',
    'Magnetometro',
    'Giroscopio',
    'Humedad',
    'Presion',
    'Temperatura'
  ];
  late String dropDownValue;

  double minY = 0;
  double maxY = 0;

  Future<void> takePicture(key) async {
    RenderRepaintBoundary? boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image? image = await boundary.toImage(pixelRatio: 1);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    FileStorage.saveImage(pngBytes,
        '$dropDownValue-${formatterFiles.format(DateTime.now())}.png');
  }

  void refresh(dynamic data) {
    setState(() {
      chartData = data;
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

  @override
  void initState() {
    super.initState();
    chartData = [];
    sensores.sort();
    dropDownValue = sensores[0].toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(
              ip: widget.configuration["ip"],
              name: widget.configuration["name"],
              size: size,
              title: 'Graficos'),
          orientation == Orientation.landscape
              ? landscapeLayout(size)
              : portraitLayout(size),
          buttons()
        ],
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }

  Column portraitLayout(Size size) {
    List<Widget> wList = [
      inputData(size),
      chart(size, 0.35),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: wList,
    );
  }

  Column landscapeLayout(Size size) {
    List<Widget> wList = [
      inputData(size),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: wList,
    );
  }

  RepaintBoundary chart(Size size, double percent) {
    List<Widget> wList = [
      SizedBox(
          height: size.height * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(currentLines.length, (index) {
              return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    currentLines.elementAt(index),
                    style: TextStyle(
                        color: colores[index], fontSize: size.height * 0.04),
                  ));
            }),
          )),
      Container(
        height: size.height * percent,
        padding: const EdgeInsets.only(right: 20),
        child: LineChart(
          lineChartData(size),
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

  Column inputData(Size size) {
    List<Widget> wList = [
      Container(
        margin: EdgeInsets.only(
            top: size.longestSide * 0.015, left: size.longestSide * 0.01),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: size.longestSide * 0.0025,
              color: naranja,
            ),
          ),
        ),
        child: Text(
          'Sensor',
          style: TextStyle(
            fontSize: size.longestSide * 0.03,
            color: gris,
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(
            top: size.longestSide * 0.005, left: size.longestSide * 0.015),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: dropDownValue,
            items: sensores.map((String sensor) {
              return DropdownMenuItem(
                  value: sensor.toLowerCase(),
                  child: Text(
                    sensor,
                    style: TextStyle(
                      fontSize: size.longestSide * 0.02,
                      color: gris,
                    ),
                  ));
            }).toList(),
            onChanged: (selected) {
              setState(() {
                dropDownValue = selected!;
              });
            },
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(
            top: size.longestSide * 0.005, left: size.longestSide * 0.01),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: size.longestSide * 0.0025,
              color: naranja,
            ),
          ),
        ),
        child: Text(
          'Rango',
          style: TextStyle(
            fontSize: size.longestSide * 0.03,
            color: gris,
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: size.longestSide * 0.005),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: size.longestSide * 0.001, color: naranja),
                  ),
                ),
                child: Text(
                  'Inicio',
                  style: TextStyle(
                    fontSize: size.longestSide * 0.025,
                    color: gris,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      DateTime? date = await showOmniDateTimePicker(
                        theme: ThemeData.light(),
                          context: context,
                          isShowSeconds: true,
                          initialDate: DateTime.parse(dateInit));
                      setState(() {
                        dateInit =
                            date?.toString().substring(0, 19) ?? dateInit;
                      });
                    },
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.change_circle),
                  ),
                  Text(
                    dateInit,
                    style: TextStyle(
                      fontSize: size.longestSide * 0.02,
                      color: gris,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: size.longestSide * 0.05,
                    top: size.longestSide * 0.005),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: size.longestSide * 0.001, color: naranja),
                  ),
                ),
                child: Text(
                  'Final',
                  style: TextStyle(
                    fontSize: size.longestSide * 0.025,
                    color: gris,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      DateTime? date = await showOmniDateTimePicker(
                        theme: ThemeData.light(),
                          context: context,
                          isShowSeconds: true,
                          initialDate: DateTime.parse(dateInit));
                      setState(() {
                        dateEnd = date?.toString().substring(0, 19) ?? dateEnd;
                      });
                    },
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.change_circle),
                  ),
                  Text(
                    dateEnd,
                    style: TextStyle(
                      fontSize: size.longestSide * 0.02,
                      color: gris,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: wList,
    );
  }

  Row buttons() {
    List<Widget> buttonList = [];
    buttonList.add(ElevatedButton(
      onPressed: () {
        dev.log('compelto');
        Functions.getData(
            refresh, widget.configuration["ip"] ?? '', dropDownValue);
      },
      child: const Text("Historial completo"),
    ));
    buttonList.add(
      ElevatedButton(
        onPressed: () {
          Functions.getData(
              refresh, widget.configuration["ip"] ?? '', dropDownValue,
              dateInit: dateInit, dateEnd: dateEnd);
        },
        child: const Text("Historial rango"),
      ),
    );
    buttonList.add(ElevatedButton(
        onPressed: () {
          takePicture(chartKey);
        },
        child: const Text("Guardar Captura")));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttonList,
    );
  }

  LineChartData lineChartData(Size size) {
    List<LineChartBarData> data = [];
    for (var line in currentLines) {
      List<dynamic> temp = [];
      for (var d in chartData) {
        temp.add(d[line]);
      }
      data.add(puntos(temp, colores[data.length]));
    }
    return LineChartData(
        lineTouchData: lineTouchData(size),
        gridData: const FlGridData(show: false),
        borderData: borderData,
        titlesData: titlesData1(size),
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

  LineTouchData lineTouchData(Size size) => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            tooltipMargin: size.height * 0.1,
            maxContentWidth: size.width * 0.4,
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

  FlTitlesData titlesData1(Size size) => FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(size),
        ),
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles(size),
        ),
      );

  SideTitles leftTitles(Size size) => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        reservedSize: size.width * 0.1,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
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

  SideTitles bottomTitles(Size size) => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        reservedSize: size.width * 0.1,
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
