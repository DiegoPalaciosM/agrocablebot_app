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

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, required this.configuration});

  final Map<String, String> configuration;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Functions functions;

  final GlobalKey chartKey = GlobalKey();
  late Map<String, dynamic> chartData;
  late List<dynamic> createdAt;
  List<String> keys = [];
  String dateInit = DateTime.now().toString().substring(0, 19);
  String dateEnd = DateTime.now().toString().substring(0, 19);

  List<Color> colores = [gris, amarillo, naranja];
  List<String> sensores = [
    'Acelerometro',
    'Compass',
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
      createdAt = chartData['createdAt'];
      keys = chartData.keys.toList();
      keys.removeWhere((element) => element == 'id' || element == 'createdAt');
    });
  }

  @override
  void initState() {
    super.initState();
    chartData = {};
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
      chart(size, 0.28),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: wList,
    );
  }

  bool checkElement(index, value, def) {
    try {
      return keys.elementAt(index) == value;
    } catch (_) {
      return def;
    }
  }

  RepaintBoundary chart(Size size, double percent) {
    List<Widget> wList = [
      SizedBox(
          height: size.height * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              keys.length,
              (index) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: chartData[keys.elementAt(0)].length > 1
                    ? Text(
                        keys.elementAt(index) == 'value'
                            ? ''
                            : keys.elementAt(index),
                        style: TextStyle(
                            color: colores[index],
                            fontSize: size.height * 0.04),
                      )
                    : null,
              ),
            ),
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
    checkElement(0, 'pitch', false)
        ? buttonList.add(ElevatedButton(
            onPressed: () {},
            child: const Text("Cambiar Tipo de grafico"),
          ))
        : null;
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
    for (var key in keys) {
      data.add(puntos(chartData[key], colores[data.length]));
    }
    return LineChartData(
        lineTouchData: lineTouchData,
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

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: gris.withOpacity(0.3),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem('', const TextStyle(), children: [
                  TextSpan(
                    text:
                        '${keys.elementAt(barSpot.barIndex)}: ${barSpot.y.roundDecimals(3)}\n',
                    style: TextStyle(color: colores[barSpot.barIndex]),
                  ),
                  TextSpan(
                    text: '${createdAt[barSpot.spotIndex]}\n',
                    style: TextStyle(color: colores[barSpot.barIndex]),
                  ),
                  TextSpan(
                    text: '${barSpot.barIndex}',
                    style: TextStyle(color: colores[barSpot.barIndex]),
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
