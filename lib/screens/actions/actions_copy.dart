// ignore_for_file: file_names

import 'dart:math';

import 'package:flutter/material.dart';

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
  int seedersNumber = 1;
  List colors = [];
  int selected = 40;
  double Z = 0;
  late List<List> matriz;

  getConfig() {
    widget.configuration.forEach((key, value) {
      if (key == 'seedersNumber') {
        seedersNumber = int.parse(value);
        colors = [];
      }
    });
    for (var i = 0; i < seedersNumber; i++) {
      colors.add(dPrimaryColor);
    }
  }

  refresh(String topic, Map<dynamic, dynamic> payload) {
    if (!(topic == 'comandos')) {
      return 0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    matriz = List.generate(9, (i) {
      return List.generate(9, (j) {
        return j + (9 * i);
      });
    });
    getConfig();
    widget.mqtt.connect();
    widget.mqtt.linkSetState(refresh);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    displaySystemUI(MediaQuery.of(context).orientation);
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  prefixButtons(size),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: GridView.count(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            childAspectRatio: size.aspectRatio *
                                responsiveSize(size, 2.5, 0.8),
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            crossAxisCount: 9,
                            children: List.generate(seedersNumber, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected = index;
                                  });
                                },
                                child: SizedBox(
                                    child: Center(
                                  child: Text(
                                    '${getIndex(matriz, index, count: seedersNumber)}',
                                    style: TextStyle(
                                        color: selected == index
                                            ? colors[index]
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color),
                                  ),
                                )),
                              );
                            }),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.4,
                          child: Column(
                            children: [
                              Expanded(child: prefixButtons(size, true)),
                              arrowButtons(size)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  arrowButtons(size, true)
                ],
              ),
            )
          ],
        ),
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }

  SizedBox prefixButtons(Size size, [bool landscape = false]) {
    final buttons = [
      ElevatedButton(
        onPressed: () {
          final xy = getIndex(matriz, selected);
          widget.mqtt.publish('comandos',
              '{"G1": "X${xy[0] * 100} Y${xy[1] * 100} Z${Z.roundDecimals(2)}"}');
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
      )
    ];
    return (landscape ? size.height : size.width) <
            (landscape ? size.width : size.height)
        ? SizedBox(
            width: responsiveSize(size, size.width, size.width * 0.35),
            height:
                responsiveSize(size, size.height * 0.08, size.width * 0.045),
            child: landscape
                ? Center(
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      crossAxisCount: landscape
                          ? sqrt(buttons.length).ceil()
                          : buttons.length,
                      childAspectRatio: buttons.length.toDouble(),
                      children: buttons,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: buttons,
                  ))
        : const SizedBox(
            height: 0,
            width: 0,
          );
  }

  Widget arrowButtons(Size size, [bool landscape = false]) {
    return (!landscape ? size.height : size.width) <
            (!landscape ? size.width : size.height)
        ? SizedBox(
            height: responsiveSize(size, size.height * 0.32, size.width * 0.3),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: responsiveSize(
                          size, size.width * 0.15, size.height * 0.1),
                      onPressed: () {
                        setState(() {
                          if (selected < 9) {
                            return;
                          }
                          selected -= 9;
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_up),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: responsiveSize(
                              size, size.width * 0.15, size.height * 0.1),
                          onPressed: () {
                            setState(() {
                              if (selected < 1) {
                                return;
                              }
                              selected -= 1;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_left),
                        ),
                        IconButton(
                          iconSize: responsiveSize(
                              size, size.width * 0.15, size.height * 0.1),
                          onPressed: () {
                            setState(() {
                              selected = 40;
                            });
                          },
                          icon: const Icon(Icons.home),
                        ),
                        IconButton(
                          iconSize: responsiveSize(
                              size, size.width * 0.15, size.height * 0.1),
                          onPressed: () {
                            setState(() {
                              if (selected > seedersNumber - 2) {
                                return;
                              }
                              selected += 1;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_right),
                        ),
                      ],
                    ),
                    IconButton(
                      iconSize: responsiveSize(
                          size, size.width * 0.15, size.height * 0.1),
                      onPressed: () {
                        setState(() {
                          if (selected > seedersNumber - 9) {
                            return;
                          }
                          selected += 9;
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                Align(
                  widthFactor: responsiveSize(
                      size, size.width * 0.02, size.width * 0.006),
                  alignment: AlignmentDirectional.topEnd,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: responsiveSize(
                            size, size.width * 0.15, size.height * 0.1),
                        onPressed: () {
                          Z += 0.1;
                        },
                        icon: const Icon(Icons.arrow_upward),
                      ),
                      Text("Z",
                          style: TextStyle(
                              fontSize: responsiveSize(size,
                                  size.height * 0.025, size.width * 0.02))),
                      IconButton(
                        iconSize: responsiveSize(
                            size, size.width * 0.15, size.height * 0.1),
                        onPressed: () {
                          Z -= 0.1;
                        },
                        icon: const Icon(Icons.arrow_downward),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        : const Stack();
  }
}
