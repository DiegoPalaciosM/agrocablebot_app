import 'dart:async';

import 'package:flutter/material.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/constants.dart';
import 'package:acb/components/header.dart';
import 'package:acb/components/menu.dart';
import 'package:acb/components/system.dart';

class RealTimeScreen extends StatefulWidget {
  final MQTT mqtt;
  final Map<String, String> configuration;

  const RealTimeScreen(
      {super.key, required this.mqtt, required this.configuration});

  @override
  State<RealTimeScreen> createState() => _RealTimeScreenState();
}

class _RealTimeScreenState extends State<RealTimeScreen> {
  Map<dynamic, dynamic> sensorsData = {};
  late Timer dataTimer;

  refresh(String topic, Map<dynamic, dynamic> payload) {
    if (!(topic == 'sensores')) {
      return 0;
    }
    setState(() {
      sensorsData = payload;
    });
  }

  List<Widget> sensors(size) {
    List<Widget> list = [];
    sensorsData.forEach(
      (key, value) {
        List<Widget> subtitle = [];
        value.forEach(
          (key1, value1) {
            subtitle.add(
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: responsiveSize(
                          size, size.height * 0.005, size.width * 0.005),
                      bottom: responsiveSize(
                          size, size.height * 0.01, size.width * 0.01),
                    ),
                    child: Text(
                      '$key1:  $value1'.capitalize(),
                      style: TextStyle(
                          fontSize: responsiveSize(
                              size, size.height * 0.015, size.width * 0.02)),
                    ),
                  )
                ],
              ),
            );
          },
        );
        list.add(
          Container(
            decoration: BoxDecoration(
                color: azul.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(responsiveSize(
                    size, size.width * 0.05, size.height * 0.05)))),
            margin: EdgeInsets.only(
              bottom:
                  responsiveSize(size, size.height * 0.01, size.width * 0.005),
            ),
            padding: EdgeInsets.only(
              top: responsiveSize(
                  size, size.height * 0.005, size.width * 0.0025),
              left:
                  responsiveSize(size, size.width * 0.005, size.width * 0.0025),
            ),
            width: size.width * 0.9,
            child: ListTile(
              title: Text(
                '$key'.capitalize(),
                style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge!.color,
                    fontSize: responsiveSize(
                        size, size.height * 0.025, size.width * 0.025)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subtitle,
              ),
            ),
          ),
        );
      },
    );
    return list;
  }

  @override
  void initState() {
    super.initState();
    widget.mqtt.linkSetState(refresh);
    widget.mqtt.publish('comandos', '{"interface": "send_aio"}');
    dataTimer = Timer.periodic(
        Duration(
            seconds: int.parse(widget.configuration['realtimeDelay'] ?? '5')),
        (timer) {
      widget.mqtt.publish('comandos', '{"interface": "send_aio"}');
    });
  }

  @override
  void dispose() {
    dataTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Header(
              ip: widget.configuration["ip"],
              name: widget.configuration["name"],
              size: size,
              title: 'Sensores'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: sensors(size),
              ),
            ),
          )
        ],
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }
}
