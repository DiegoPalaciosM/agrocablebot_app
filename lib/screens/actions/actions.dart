import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/constants.dart';
import 'package:acb/components/header.dart';
import 'package:acb/components/menu.dart';
import 'package:acb/components/system.dart';

class ActionsScreen extends StatefulWidget {
  final MQTT mqtt;
  final Map<String, String> configuration;

  const ActionsScreen(
      {super.key, required this.mqtt, required this.configuration});

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  int seedersNumber = 81;
  int selected = 40;
  int Z = 0;
  late List<List> matriz;
  late Orientation orientation;

  refresh(String topic, Map<dynamic, dynamic> payload) {
    // if (!(topic == 'comandos')) {
    //   return 0;
    // }
    setState(() {
      selected = getSelected(payload);
      Z = payload['z'];
    });
  }

  sendG1() {
    final xy = getIndex(matriz, selected);
    widget.mqtt.publish(
        'comandos', '{"GCODE":"G1 X${xy[0] * 100} Y${xy[1] * 100} Z$Z"}');
  }

  @override
  void initState() {
    super.initState();
    matriz = List.generate(9, (i) {
      return List.generate(9, (j) {
        return j + (9 * i);
      });
    });
    widget.mqtt.connect();
    widget.mqtt.linkSetState(refresh);
    widget.mqtt.publish('comandos', '{"GCODE":"M5"}');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    displaySystemUI(orientation);
    return Scaffold(
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Header(
                ip: widget.configuration["ip"],
                name: widget.configuration["name"],
                size: size,
                title: 'Acciones'),
            (orientation == Orientation.landscape
                ? landscapeLayout
                : portraitLayout)(
              size,
              context,
            ),
          ],
        ),
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }

  Widget landscapeLayout(Size size, BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(left: size.height * 0.1),
            width: size.width * 0.55,
            child: GridView.count(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: size.aspectRatio * 0.95,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 9,
              children: List.generate(seedersNumber, (index) {
                return GestureDetector(
                  onLongPressDown: (details) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: gris.withOpacity(0.8),
                        dismissDirection: DismissDirection.none,
                        duration: const Duration(seconds: 1, milliseconds: 100),
                        //width: size.width * 0.1,
                        margin: EdgeInsets.only(
                            left: details.globalPosition.dx + size.width * 0.03,
                            right: size.width -
                                (details.globalPosition.dx + size.width * 0.13),
                            bottom:
                                size.height - (details.globalPosition.dy * 1)),
                        content: Center(
                          child: Text(
                              '${getIndex(matriz, index, count: seedersNumber)}'),
                        ),
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      selected = index;
                    });
                  },
                  child: SizedBox(
                    child: Center(
                      child: SimpleShadow(
                        opacity: selected == index ? 1 : 0.6,
                        color: selected == index ? amarillo : gris,
                        offset: const Offset(2, 2),
                        sigma: selected == index ? 8 : 4,
                        child: Image.asset(
                            widget.configuration['imagePlantasConfig'] ??
                                'assets/images/plantas/albahaca.png'),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            width: size.width * 0.35,
            margin: EdgeInsets.only(right: size.height * 0.1),
            child: Column(
              children: [
                prefixButtons(size, orientation),
                arrowButtons(size, orientation)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget portraitLayout(Size size, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          prefixButtons(size, orientation),
          Container(
            margin: EdgeInsets.only(top: size.height * 0.01),
            width: size.width * 0.95,
            child: GridView.count(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: size.aspectRatio * 2.05,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 9,
              children: List.generate(seedersNumber, (index) {
                return GestureDetector(
                  onLongPressDown: (details) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: gris.withOpacity(0.8),
                        dismissDirection: DismissDirection.none,
                        duration: const Duration(seconds: 1, milliseconds: 100),
                        //width: size.width * 0.1,
                        margin: EdgeInsets.only(
                            left: details.globalPosition.dx < size.width / 2
                                ? details.globalPosition.dx + size.width * 0.03
                                : details.globalPosition.dx - size.width * 0.23,
                            right: details.globalPosition.dx < size.width / 2
                                ? size.width -
                                    (details.globalPosition.dx +
                                        size.width * 0.23)
                                : size.width -
                                    (details.globalPosition.dx -
                                        size.width * 0.03),
                            bottom:
                                size.height - (details.globalPosition.dy * 1)),
                        content: Center(
                          child: Text(
                              '${getIndex(matriz, index, count: seedersNumber)}'),
                        ),
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      selected = index;
                    });
                  },
                  child: SizedBox(
                    child: Center(
                      // child: Text(
                      //   '${getIndex(matriz, index, count: seedersNumber)}',
                      //   style: TextStyle(color: selected == index ? verde : gris),
                      // ),
                      child: SimpleShadow(
                        opacity: selected == index ? 1 : 0.6,
                        color: selected == index ? amarillo : gris,
                        offset: const Offset(2, 2),
                        sigma: selected == index ? 8 : 4,
                        child: Image.asset(
                            widget.configuration['imagePlantasConfig'] ??
                                'assets/images/plantas/albahaca.png'),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          arrowButtons(size, orientation)
        ],
      ),
    );
  }

  SizedBox prefixButtons(Size size, Orientation orientation) {
    final buttons = [
      ElevatedButton(
        onPressed: () {
          sendG1();
        },
        child: Text(
          'Mover',
          style: TextStyle(
            fontSize:
                responsiveSize(size, size.height * 0.02, size.width * 0.02),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          widget.mqtt.publish('comandos', '{"interface" : "send_data"}');
        },
        child: Text(
          'Sensores',
          style: TextStyle(
            fontSize:
                responsiveSize(size, size.height * 0.02, size.width * 0.02),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text(
          'Arrado',
          style: TextStyle(
            fontSize:
                responsiveSize(size, size.height * 0.02, size.width * 0.02),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text(
          'Siembra',
          style: TextStyle(
            fontSize:
                responsiveSize(size, size.height * 0.02, size.width * 0.02),
          ),
        ),
      ),
    ];
    return SizedBox(
        width: orientation == Orientation.landscape
            ? size.width * 0.3
            : size.width * 0.9, //size.width * 0.35,
        height: orientation == Orientation.landscape
            ? size.height * 0.25
            : size.height * 0.1, // size.height * 0.25,
        child: Center(
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: EdgeInsets.zero,
            crossAxisCount: orientation == Orientation.landscape
                ? sqrt(buttons.length).ceil()
                : buttons.length < 4
                    ? buttons.length
                    : sqrt(buttons.length).ceil(),
            childAspectRatio: orientation == Orientation.landscape
                ? size.aspectRatio * sqrt(buttons.length - 1).ceil()
                : size.aspectRatio * 10,
            //sqrt(buttons.length - 1).ceil().toDouble() * (1 / size.aspectRatio) + buttons.length,
            //buttons.length / (size.aspectRatio / sqrt(buttons.length - 1).ceil()),
            children: buttons,
          ),
        ));
  }

  Widget arrowButtons(Size size, Orientation orientation) {
    return Expanded(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize:
                    responsiveSize(size, size.width * 0.12, size.height * 0.1),
                onPressed: () {
                  setState(() {
                    if (selected < 9) {
                      return;
                    }
                    selected -= 9;
                    sendG1();
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_up),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: responsiveSize(
                        size, size.width * 0.12, size.height * 0.1),
                    onPressed: () {
                      setState(() {
                        if (selected < 1) {
                          return;
                        }
                        selected -= 1;
                        sendG1();
                      });
                    },
                    icon: const Icon(Icons.keyboard_arrow_left),
                  ),
                  IconButton(
                    iconSize: responsiveSize(
                        size, size.width * 0.12, size.height * 0.1),
                    onPressed: () {
                      setState(() {
                        selected = 40;
                        //widget.mqtt.publish('comandos', '{"GCODE":"G28"}');
                        sendG1();
                      });
                    },
                    icon: const Icon(Icons.home),
                  ),
                  IconButton(
                    iconSize: responsiveSize(
                        size, size.width * 0.12, size.height * 0.1),
                    onPressed: () {
                      setState(() {
                        if (selected > seedersNumber - 2) {
                          return;
                        }
                        selected += 1;
                        sendG1();
                      });
                    },
                    icon: const Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
              IconButton(
                iconSize:
                    responsiveSize(size, size.width * 0.12, size.height * 0.1),
                onPressed: () {
                  setState(() {
                    if (selected > seedersNumber - 9) {
                      return;
                    }
                    selected += 9;
                    sendG1();
                  });
                },
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
          Align(
            widthFactor:
                responsiveSize(size, size.width * 0.02, size.width * 0.006),
            alignment: AlignmentDirectional.topEnd,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: responsiveSize(
                      size, size.width * 0.12, size.height * 0.1),
                  onPressed: () {
                    setState(() {
                      Z += 10;
                      sendG1();
                    });
                  },
                  icon: const Icon(Icons.arrow_upward),
                ),
                Text(
                  "$Z",
                  style: TextStyle(
                    fontSize: responsiveSize(
                        size, size.height * 0.025, size.width * 0.02),
                    color: gris,
                  ),
                ),
                IconButton(
                  iconSize: responsiveSize(
                      size, size.width * 0.12, size.height * 0.1),
                  onPressed: () {
                    setState(() {
                      Z -= 10;
                      sendG1();
                    });
                  },
                  icon: const Icon(Icons.arrow_downward),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
