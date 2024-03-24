// Dependencias de flutter
// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Dependencias externas
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

// Otros archivo de codigo
// -- Modulos
import 'package:agrocablebot/modules/constants/constants.dart';
import 'package:agrocablebot/modules/components/components.dart';
import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:agrocablebot/modules/system/system.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Size size;

  TextEditingController commandField = TextEditingController();
  final List<String> availableGCode = ['G1', 'G10', 'G28', 'M6'];

  bool aboveStatus = true;
  bool belowStatus = true;

  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    Logs.listLogs().then((value) {
      setState(() {
        logs = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Header(
          preferredSize: Size(600.w, 160.h),
          child: Text(AppLocalizations.of(context)!.dashboard)),
      body: Center(
        child: portraitLayout(),
      ),
      drawer: const SideMenu(),
    );
  }

  portraitLayout() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              deviceLogs(),
              cameras(),
            ],
          ),
          motorsWidgets(),
        ],
      );

  deviceLogs() => Container(
        margin: EdgeInsets.only(right: 10.w, top: 15.h),
        width: 240.w,
        height: 500.h,
        child: Column(
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
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 10.w),
                      child: TextField(
                        controller: commandField,
                        textCapitalization: TextCapitalization.sentences,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.command,
                        ),
                        style: const TextStyle(color: gris),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (commandField.text.isNotEmpty) {
                        dev.log(Logs.createLog(commandField.text).toString());
                        MqttClient.publish(
                            'comandos', '{"GCODE":"${commandField.text}"}');
                        setState(() {
                          logs.add(commandField.text);
                        });
                        commandField.text = '';
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: ListView.builder(
                  dragStartBehavior: DragStartBehavior.down,
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onLongPress: () {
                        logs.remove(logs[index]);
                        setState(() {
                          Logs.deleteLog(logs);
                        });
                      },
                      onTap: () {
                        Logs.createLog(logs[index]);
                        MqttClient.publish(
                            'comandos', '{"GCODE":"${logs[index]}"}');
                        setState(() {
                          logs.add(logs[index]);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 5.h, left: 10.w),
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
            )
          ],
        ),
      );

  cameras() => Container(
        width: 330.w,
        height: 500.h,
        margin: EdgeInsets.only(top: 15.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  AppLocalizations.of(context)!.aboveCamera,
                  style: const TextStyle(
                    color: gris,
                  ),
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SizedBox(
                      child: Mjpeg(
                        stream: 'http://${Configuration.ip}:7001/aboveCam',
                        isLive: aboveStatus,
                        error: (context, error, stack) {
                          aboveStatus = false;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                Timer(const Duration(seconds: 1), () {
                                  aboveStatus = true;
                                });
                              });
                            },
                            child: Center(
                                child: Text(
                                    AppLocalizations.of(context)!.errorCamera,
                                    style: const TextStyle(color: naranja))),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        !aboveStatus
                            ? AppLocalizations.of(context)!.paused
                            : '',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(!aboveStatus ? Icons.play_arrow : Icons.pause),
                      onPressed: () {
                        setState(() {
                          aboveStatus = !aboveStatus;
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  AppLocalizations.of(context)!.belowCamera,
                  style: const TextStyle(
                    color: gris,
                  ),
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SizedBox(
                      //height: 200.h,
                      child: Mjpeg(
                        stream: 'http://${Configuration.ip}:7001/belowCam',
                        isLive: belowStatus,
                        error: (context, error, stack) {
                          belowStatus = false;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                Timer(const Duration(seconds: 1), () {
                                  belowStatus = true;
                                });
                              });
                            },
                            child: Center(
                                child: Text(
                                    AppLocalizations.of(context)!.errorCamera,
                                    style: const TextStyle(color: Colors.red))),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        !belowStatus
                            ? AppLocalizations.of(context)!.paused
                            : '',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(!belowStatus ? Icons.play_arrow : Icons.pause),
                      onPressed: () {
                        setState(() {
                          belowStatus = !belowStatus;
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
          ],
        ),
      );

  motorsWidgets() => GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: size.aspectRatio < 0.5
            ? 0.7 / size.aspectRatio
            : 3 * size.aspectRatio,
        children: [
          motorWidget('A'),
          motorWidget('B'),
          motorWidget('C'),
          motorWidget('D'),
        ],
      );
}
