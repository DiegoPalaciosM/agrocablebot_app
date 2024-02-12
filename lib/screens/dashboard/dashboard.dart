import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/constants.dart';
import 'package:acb/components/menu.dart';
import 'package:acb/components/system.dart';

import 'dart:developer';

class DashboardScreen extends StatefulWidget {
  final Map<String, String> configuration;
  final MQTT mqtt;

  const DashboardScreen(
      {super.key, required this.configuration, required this.mqtt});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  GlobalKey appBarKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  bool aCameraStatus = false;
  final GlobalKey aboveKey = GlobalKey();
  bool bCameraStatus = false;
  final GlobalKey belowKey = GlobalKey();

  double appBarSize = 0.0;

  TextEditingController commandField = TextEditingController();
  final List<String> availableGCode = ['G1', 'G10', 'G28', 'M6'];

  List<String> logs = [];

  sizes() {
    setState(() {
      appBarSize = appBarKey.currentContext?.size!.height ?? 0;
    });
  }

  void setUpLogs() async {
    FileStorage.listLogs().then((value) {
      setState(() {
        log(value.toString());
        logs = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setUpLogs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Orientation orientation = MediaQuery.of(context).orientation;
    WidgetsBinding.instance.addPostFrameCallback((_) => size);
    displaySystemUI(orientation);
    return orientation == Orientation.portrait
        ? portraitLayout(size)
        : landscapeLayout(size);
  }

  Scaffold landscapeLayout(Size size) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldState,
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
      body: SizedBox(
          child: Row(
        children: [
          deviceLogs(size, landscape: true),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Mover motores individualmente",
                    style: TextStyle(
                        color: gris, fontSize: size.longestSide * 0.025),
                  ),
                ),
                infoWidget(size, landscape: true),
                camerasWidget(size, landscape: true),
              ],
            ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.menu),
        onPressed: () {
          setState(
            () {
              _scaffoldState.currentState!.openDrawer();
            },
          );
        },
      ),
    );
  }

  Scaffold portraitLayout(Size size) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Dashboard'),
        key: appBarKey,
      ),
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: (size.height - appBarSize) * 0.6,
              child: Row(
                children: [
                  deviceLogs(size),
                  camerasWidget(size, landscape: false),
                ],
              ),
            ),
            Center(
              child: Text(
                "Mover motores individualmente",
                style:
                    TextStyle(color: gris, fontSize: size.longestSide * 0.025),
              ),
            ),
            infoWidget(size)
          ],
        ),
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }

  Container deviceLogs(Size size, {bool landscape = false}) {
    return Container(
      margin: EdgeInsets.only(
          top: size.height * 0.01,
          left: size.width * 0.01,
          right: size.width * 0.01),
      width: size.width * (landscape ? 0.2 : 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black),
                left: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      widget.configuration["name"] ?? "",
                      style: TextStyle(
                          color: gris,
                          fontWeight: FontWeight.bold,
                          fontSize: size.longestSide * 0.025),
                    ),
                    Text(
                      widget.configuration["ip"] ?? "",
                      style: TextStyle(
                          color: gris,
                          fontWeight: FontWeight.bold,
                          fontSize: size.longestSide * 0.015),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/connect');
                      //FileStorage.clearLogs();
                      //setUpLogs();
                    },
                    icon: const Icon(Icons.link))
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black),
                left: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(left: size.width * 0.01),
                    child: TextField(
                      controller: commandField,
                      textCapitalization: TextCapitalization.sentences,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus!.unfocus();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Comando',
                      ),
                      style: const TextStyle(color: gris),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      log(FileStorage.logToFileS(commandField.text).toString());
                      widget.mqtt.publish(
                          'comandos', '{"GCODE":"${commandField.text}"}');
                      setState(() {
                        logs.add(commandField.text);
                      });
                      //setUpLogs();
                      commandField.text = '';
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: size.height * 0.01),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: ListView.builder(
                dragStartBehavior: DragStartBehavior.down,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onLongPress: () {
                      logs.remove(logs[index]);
                      setState(() {
                        FileStorage.deleteLog(logs);
                      });
                    },
                    onTap: () {
                      //FileStorage.logToFileS(
                      //   '[${formatter.format(DateTime.now())}] ${logs[index].split('] ')[1]}');
                      //widget.mqtt.publish('comandos',
                      //    '{"GCODE":"${logs[index].split('] ')[1]}"}');
                      FileStorage.logToFileS(logs[index]);
                      widget.mqtt
                          .publish('comandos', '{"GCODE":"${logs[index]}"}');
                      setState(() {
                        logs.add(logs[index]);
                      });
                      //setUpLogs();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: size.width * 0.01, top: size.height * 0.005),
                      child: Text(
                        logs[index],
                        style: const TextStyle(
                          color: gris,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container camerasWidget(Size size, {bool landscape = false}) {
    List<Widget> cameras = [
      Column(
        children: [
          Text(
            'Camara Superior',
            style: TextStyle(
              fontSize: size.longestSide * 0.025,
              color: gris,
            ),
          ),
          Stack(alignment: AlignmentDirectional.center, children: [
            SizedBox(
              height: landscape ? size.width * 0.2 : size.height * 0.2,
              child: Mjpeg(
                stream:
                    'http://${widget.configuration["ip"] ?? ""}:7001/aboveCam',
                isLive: aCameraStatus,
                error: (context, error, stack) {
                  aCameraStatus = false;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        Timer(const Duration(seconds: 1), () {
                          aCameraStatus = true;
                        });
                      });
                    },
                    child: const Center(
                        child: Text(
                            'Error al conectarse con la camara\nToca para reintentar',
                            style: TextStyle(color: naranja))),
                  );
                },
              ),
            ),
            Center(
              child: Text(
                !aCameraStatus ? 'Pausado' : '',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: size.longestSide * 0.025,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(!aCameraStatus ? Icons.play_arrow : Icons.pause),
                onPressed: () {
                  setState(() {
                    aCameraStatus = !aCameraStatus;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Camara Inferior',
            style: TextStyle(
              fontSize: size.longestSide * 0.025,
              color: gris,
            ),
          ),
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SizedBox(
                height: landscape ? size.width * 0.2 : size.height * 0.2,
                child: Mjpeg(
                  stream:
                      'http://${widget.configuration["ip"] ?? ""}:7001/belowCam',
                  isLive: bCameraStatus,
                  error: (context, error, stack) {
                    bCameraStatus = false;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          Timer(const Duration(seconds: 1), () {
                            bCameraStatus = true;
                          });
                        });
                      },
                      child: const Center(
                          child: Text(
                              'Error al conectarse con la camara\nToca para reintentar',
                              style: TextStyle(color: Colors.red))),
                    );
                  },
                ),
              ),
              Center(
                child: Text(
                  !bCameraStatus ? 'Pausado' : '',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: size.longestSide * 0.025,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(!bCameraStatus ? Icons.play_arrow : Icons.pause),
                onPressed: () {
                  setState(() {
                    bCameraStatus = !bCameraStatus;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {},
              )
            ],
          ),
        ],
      )
    ];
    return Container(
        width: size.width * (landscape ? 0.77 : 0.57),
        margin: EdgeInsets.only(right: size.width * 0.01),
        child: landscape
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: cameras,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: cameras,
              ));
  }

  Widget infoWidget(Size size, {bool landscape = false}) {
    List<Widget> info = [
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Text(
              "Motor A",
              style: TextStyle(
                color: gris,
                fontSize: responsiveSize(
                    size, size.longestSide * 0.022, size.longestSide * 0.015),
              ),
            ),
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Text(
              "Motor B",
              style: TextStyle(
                color: gris,
                fontSize: responsiveSize(
                    size, size.longestSide * 0.022, size.longestSide * 0.015),
              ),
            ),
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Text(
              "Motor C",
              style: TextStyle(
                color: gris,
                fontSize: responsiveSize(
                    size, size.longestSide * 0.022, size.longestSide * 0.015),
              ),
            ),
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Text(
              "Motor D",
              style: TextStyle(
                color: gris,
                fontSize: responsiveSize(
                    size, size.longestSide * 0.022, size.longestSide * 0.015),
              ),
            ),
            IconButton(
              iconSize:
                  responsiveSize(size, size.width * 0.12, size.height * 0.1),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
      ),
    ];
    return landscape
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: info,
          )
        : GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: size.aspectRatio * 3.8,
            children: info,
          );
  }
}
