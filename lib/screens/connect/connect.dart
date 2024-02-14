import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/constants.dart';
import 'package:acb/components/structure.dart';

import 'package:acb/screens/connect/components/functions.dart';

class ConnectScreen extends StatefulWidget {
  final Function configInit;
  final MQTT mqtt;

  const ConnectScreen(
      {super.key, required this.configInit, required this.mqtt});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  late Functions functions;
  Map<String, String> devicesFinded = {};

  Map<String, dynamic> tailscaleDevice = {};

  late Timer findTimer;
  late Timer tailscaleTimer;

  @override
  void initState() {
    super.initState();
    functions = Functions(refresh: refresh);
    findTimer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      functions.getDevices();
    });
    SqliteConn.get('tailscale').then((value){
      http.get(Uri.parse('http://$value:7001/deviceInfo')).then((response) {
          if (response.statusCode == 200) {
            setState(() {
              tailscaleDevice = jsonDecode(response.body);

            });
          }
        }).catchError((error) {
          setState(() {
            tailscaleDevice = {};
          });
        });
      tailscaleTimer = Timer.periodic(const Duration(seconds: 5), (Timer t){
        http.get(Uri.parse('http://$value:7001/deviceInfo')).then((response) {
          if (response.statusCode == 200) {
            setState(() {
              tailscaleDevice = jsonDecode(response.body);

            });
          }
        }).catchError((error) {
          setState(() {
            tailscaleDevice = {};
          });
        });
      });
    });

  }

  @override
  void dispose() {
    findTimer.cancel();
    tailscaleTimer.cancel();
    super.dispose();
  }

  refresh(String ip) {
    if (!devicesFinded.keys.contains(ip)) {
      http.get(Uri.parse('http://$ip:7001/deviceInfo')).then((response) {
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
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Text(
                  "Conexión mediante VPN TailScale",
                  style: TextStyle(color: gris, fontSize: size.height * 0.025),
                ),
                ListTile(
                  title: Text(
                    tailscaleDevice['name'] ?? 'Sin Conexión',
                    style: TextStyle(
                      fontSize: size.height * 0.025,
                      color: gris,
                    ),
                  ),
                  onTap: () {
                    findTimer.cancel();
                    tailscaleTimer.cancel();
                    SqliteConn.get('tailscale').then((value) {
                      SqliteConn.add(Configuration(
                          title: 'ip', value: value));
                          SqliteConn.add(Configuration(
                        title: 'name', value: tailscaleDevice["name"]));
                    SqliteConn.add(
                        Configuration(title: 'mac', value: tailscaleDevice["mac"]));
                    SqliteConn.add(Configuration(
                        title: 'ssid', value: tailscaleDevice["ssid"]));
                    widget.mqtt.connected = false;
                    widget.mqtt.client.disconnect();
                    widget.configInit(true);
                    Navigator.pop(context);
                    });
                    
                  },
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Conexión mediante red local",
                  style: TextStyle(color: gris, fontSize: size.height * 0.025),
                ),
                SizedBox(
                  height: size.height,
                  child: ListView.builder(
                    itemCount: devicesFinded.length,
                    itemBuilder: (context, index) {
                      var keys = devicesFinded.keys;
                      var dict =
                          jsonDecode(devicesFinded[keys.elementAt(index)]!);
                      return ListTile(
                        title: Text(
                          dict['name'],
                          style: TextStyle(
                            fontSize: size.height * 0.025,
                            color: gris,
                          ),
                        ),
                        subtitle: Text(
                          keys.elementAt(index),
                          style: TextStyle(
                            fontSize: size.height * 0.015,
                            color: gris,
                          ),
                        ),
                        onTap: () {
                          findTimer.cancel();
                          SqliteConn.add(Configuration(
                              title: 'ip', value: keys.elementAt(index)));
                          SqliteConn.add(Configuration(
                              title: 'name', value: dict["name"]));
                          SqliteConn.add(
                              Configuration(title: 'mac', value: dict["mac"]));
                          SqliteConn.add(Configuration(
                              title: 'ssid', value: dict["ssid"]));
                          widget.mqtt.connected = false;
                          widget.mqtt.client.disconnect();
                          widget.configInit(true);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
