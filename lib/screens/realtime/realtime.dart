// Dependencias de flutter
import 'dart:async';
import 'package:flutter/material.dart';

// Dependencias externas
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Otros archivo de codigo
// -- Modulos
import 'package:agrocablebot/modules/components/components.dart';
import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:agrocablebot/modules/constants/constants.dart';
import 'package:agrocablebot/modules/system/system.dart';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});

  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends State<RealtimeScreen> {
  Map<String, dynamic> sensorData = {};
  late Timer dataTimer;

  refresh(String topic, Map<String, dynamic> payload) {
    setState(() {
      sensorData = payload;
    });
  }

  @override
  void initState() {
    super.initState();
    MqttClient.linkSetState(refresh);
    MqttClient.publish('comandos', '{"interface":"send_aio"}');
    dataTimer =
        Timer.periodic(Duration(seconds: Configuration.realtimeDelay), (timer) {
      MqttClient.publish('comandos', '{"interface":"send_aio"}');
    });
  }

  @override
  void dispose() {
    dataTimer.cancel();
    MqttClient.linkSetState(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        preferredSize: Size(600.w, 160.h),
        child: Text(AppLocalizations.of(context)!.sensors),
      ),
      body: ListView.builder(
        itemCount: sensorData.length,
        itemBuilder: (context, index) {
          List<Widget> subtitles = List.generate(
              sensorData[sensorData.keys.elementAt(index)].keys.length,
              (index2) {
            var values = sensorData[sensorData.keys.elementAt(index)];
            String key = values.keys.elementAt(index2);
            return Text(
              '${key.capitalize()}: ${values[key]}',
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineLarge!.color,
                fontSize: 20.sp,
              ),
            );
          });
          return Container(
            decoration: BoxDecoration(
              color: azul.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30.dg),
            ),
            margin: EdgeInsets.only(
              top: 15.h,
              left: 25.w,
              right: 25.w,
            ),
            padding: EdgeInsets.only(left: 25.w),
            child: ListTile(
                title: Text(
                  sensorData.keys.elementAt(index).capitalize(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge!.color,
                    fontSize: 30.sp,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subtitles,
                )),
          );
        },
      ),
      drawer: const SideMenu(),
    );
  }
}
