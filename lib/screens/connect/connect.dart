// Dependencias de flutter
import 'dart:async';
import 'dart:convert';
import 'dart:io';
// ignore: unused_import
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// Dependencias externas
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Otros archivo de codigo
// -- Modulos
import 'package:agrocablebot/modules/constants/constants.dart';
import 'package:agrocablebot/modules/connector/connector.dart';

class ConnectScreen extends StatefulWidget {
  final Function update;

  const ConnectScreen({super.key, required this.update});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Map<String, String> devicesFinded = {};

  late Timer findTimer;

  Future<void> getDevices() async {
    var interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      if (interface.name == "wlan0") {
        var wifiip = interface.addresses[0].address;

        for (var i = 0; i < 255; i++) {
          if (!mounted) {
            break;
          }
          String ip = (wifiip.split('.')
                ..removeLast()
                ..add(i.toString()))
              .join('.');
          await Socket.connect(
            ip,
            7001,
            timeout: const Duration(milliseconds: 100),
          ).then(
            (socket) {
              if (!devicesFinded.keys.contains(ip)) {
                http
                    .get(Uri.parse('http://$ip:7001/deviceInfo'))
                    .then((response) {
                  if (response.statusCode == 200) {
                    devicesFinded[ip] = response.body;
                  }
                });
              }
              if (mounted) {
                setState(() {
                  devicesFinded = Map.fromEntries(devicesFinded.entries.toList()
                    ..sort((e1, e2) => e1.key.compareTo(e2.key)));
                });
              }
            },
          ).catchError((error) {});
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    findTimer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      getDevices();
    });
  }

  @override
  void dispose() {
    findTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: devicesFinded.length,
        itemBuilder: (context, index) {
          var keys = devicesFinded.keys;
          var dict = jsonDecode(devicesFinded[keys.elementAt(index)]!);
          return ListTile(
            title: Text(
              dict['name'],
              style: TextStyle(
                fontSize: 45.sp,
                color: gris,
              ),
            ),
            subtitle: Text(
              keys.elementAt(index),
              style: TextStyle(
                fontSize: 30.sp,
                color: gris,
              ),
            ),
            onTap: () {
              findTimer.cancel();
              //Configuration.set('ip', keys.elementAt(index));
              //Configuration.set('name', dict["name"]);
              Configuration.set(
                  ['ip', 'name'], [keys.elementAt(index), dict["name"]]).then(
                (value) {
                  MqttClient.update();
                  widget.update();
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
