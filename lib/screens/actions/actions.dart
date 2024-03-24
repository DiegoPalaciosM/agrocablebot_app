// Dependencias de flutter
import 'dart:math' as math;
// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:ui';
import 'package:flutter/material.dart';

// Dependencias externas
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Otros archivo de codigo
// -- Modulos
import 'package:agrocablebot/modules/constants/constants.dart';
import 'package:agrocablebot/modules/components/components.dart';
import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:agrocablebot/modules/system/system.dart';

class ActionsScreen extends StatefulWidget {
  const ActionsScreen({super.key});

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  late BuildContext globalContext;

  int seedersNumber = 81;
  int selected = 40;
  int z = 0;
  int seederRadius = 100;

  late Size size;

  refresh(String topic, Map<dynamic, dynamic> payload) {
    setState(() {
      if (topic == 'status' && payload.containsKey('x')) {
        selected = getSelected(payload, seedersNumber, seederRadius);
        z = payload['z'];
      }
    });
  }

  sendG1() {
    if (!MqttClient.moving) {
      final xy = getIndex(selected, seedersNumber);
      MqttClient.publish('comandos',
          '{"GCODE": "G1 X${xy[0] * seederRadius} Y${xy[1] * seederRadius} Z$z"}');
    }
  }

  @override
  void initState() {
    super.initState();
    Configuration.linkSetState(() {
      setState(() {
        selected = selected;
      });
    });
    MqttClient.linkSetState(refresh);
    MqttClient.publish('comandos', '{"GCODE":"M5"}');
  }

  @override
  void dispose() {
    MqttClient.linkSetState(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Header(
          preferredSize: Size(600.w, 160.h),
          child: Text(AppLocalizations.of(context)!.actions)),
      body: Center(
        child: portraitLayout(),
      ),
      drawer: const SideMenu(),
    );
  }

  portraitLayout() => Column(
        children: [prefixButtons(), gridButtons(), arrowButtons()],
      );

  prefixButtons() {
    final buttons = [
      actionButton(
        AppLocalizations.of(globalContext)!.move,
        () {
          sendG1();
        },
      ),
      actionButton(
        AppLocalizations.of(globalContext)!.sensors,
        () {
          MqttClient.publish('comandos', '{"interface" : "send_data"}');
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
      height: 115.h,
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

  gridButtons() {
    String asset = Configuration.actionAsset;
    return GridView.count(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: math.sqrt(seedersNumber).ceil(),
      childAspectRatio: size.aspectRatio < 0.5
          ? 0.45 / size.aspectRatio
          : 2 * size.aspectRatio,
      children: List.generate(
        seedersNumber,
        (index) => GestureDetector(
          onLongPressStart: (details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: gris.withOpacity(0.8),
                dismissDirection: DismissDirection.none,
                duration: const Duration(seconds: 1, milliseconds: 500),
                margin: EdgeInsets.only(
                    left: details.globalPosition.dx < 600.w / 2
                        ? details.globalPosition.dx + 600.w * 0.05
                        : details.globalPosition.dx - 600.w * 0.25,
                    right: details.globalPosition.dx < 600.w / 2
                        ? 600.w - (details.globalPosition.dx + 600.w * 0.25)
                        : 600.w - (details.globalPosition.dx - 600.w * 0.05),
                    bottom: 1024.h - (details.globalPosition.dy)),
                content: Center(
                  child: Text('${getIndex(index, seedersNumber)}'),
                ),
              ),
            );
          },
          onTap: () {
            setState(() {
              if (MqttClient.moving) {
                index = selected;
                ScaffoldMessenger.of(globalContext).showSnackBar(SnackBar(
                  content: FittedBox(
                    child: Center(
                        child:
                            Text(AppLocalizations.of(globalContext)!.espBusy)),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: const StadiumBorder(),
                  margin: EdgeInsets.all(50.sp),
                  padding: EdgeInsets.symmetric(horizontal: 100.w),
                  backgroundColor: naranja,
                ));

                return;
              }
              selected = index;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(3.sp),
            child: Stack(
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaY: index == selected ? 1 : 4,
                    sigmaX: index == selected ? 5 : 4,
                  ),
                  child: Opacity(
                    opacity: index == selected ? 1 : 0,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          index == selected ? amarillo : gris,
                          BlendMode.srcATop),
                      child: Image.asset(asset),
                    ),
                  ),
                ),
                Image.asset(asset),
              ],
            ),
          ),
        ),
      ),
    );
  }

  arrowButtons() {
    return Expanded(
      child: Row(
        //alignment: AlignmentDirectional.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 45.h,
              width: 140.w,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(globalContext)!.espStatus,
                    style: const TextStyle(color: gris),
                  ),
                  Text(
                    MqttClient.moving
                        ? AppLocalizations.of(context)!.busy
                        : AppLocalizations.of(context)!.ready,
                    style: TextStyle(
                      color: MqttClient.moving ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 195.h,
            width: 320.w,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 500.h,
                    onPressed: () {
                      setState(
                        () {
                          if (MqttClient.moving) {
                            return;
                          }
                          if (selected < 9) {
                            return;
                          }
                          selected -= 9;
                          sendG1();
                        },
                      );
                    },
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 500.h,
                        onPressed: () {
                          setState(
                            () {
                              if (MqttClient.moving) {
                                return;
                              }
                              if (selected < 1) {
                                return;
                              }
                              selected -= 1;
                              sendG1();
                            },
                          );
                        },
                        icon: const Icon(Icons.keyboard_arrow_left),
                      ),
                      IconButton(
                        iconSize: 500.h,
                        onPressed: () {
                          setState(
                            () {
                              if (MqttClient.moving) {
                                return;
                              }
                              selected = 40;
                              sendG1();
                            },
                          );
                        },
                        icon: const Icon(Icons.home),
                      ),
                      IconButton(
                        iconSize: 500.h,
                        onPressed: () {
                          setState(
                            () {
                              if (MqttClient.moving) {
                                return;
                              }
                              if (selected > seedersNumber - 2) {
                                return;
                              }
                              selected += 1;
                              sendG1();
                            },
                          );
                        },
                        icon: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ],
                  ),
                  IconButton(
                    iconSize: 500.h,
                    onPressed: () {
                      setState(
                        () {
                          if (MqttClient.moving) {
                            return;
                          }
                          if (selected > seedersNumber - 9) {
                            return;
                          }
                          selected += 9;
                          sendG1();
                        },
                      );
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 175.h,
            width: 140.w,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 500.h,
                    onPressed: () {
                      setState(
                        () {
                          if (MqttClient.moving) {
                            return;
                          }
                          z += 10;
                          sendG1();
                        },
                      );
                    },
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  Text(
                    '$z',
                    style: TextStyle(
                      fontSize: 500.h,
                      color: gris,
                    ),
                  ),
                  IconButton(
                    iconSize: 500.h,
                    onPressed: () {
                      setState(
                        () {
                          if (MqttClient.moving) {
                            return;
                          }
                          z -= 10;
                          sendG1();
                        },
                      );
                    },
                    icon: const Icon(Icons.arrow_downward),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
