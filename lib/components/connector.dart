import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:acb/components/constants.dart';
import 'package:acb/components/structure.dart';

class MQTT {
  String ip = '';
  bool connected = false;
  bool moving = false;
  late MqttServerClient client;
  late Function refresh;

  MQTT();

  update([String ip = '']) {
    if (ip != '') {
      this.ip = ip;
    }
  }

  connect() async {
    if (!connected) {
      try {
        client = MqttServerClient(ip, '1883');
        client.keepAlivePeriod = 60;
        client.onConnected = _onConnected;
        client.autoReconnect = true;
        client.onAutoReconnect = connect;
        final connMess = MqttConnectMessage()
            .withClientIdentifier('app_${Random().nextInt(100)}')
            .withWillTopic('willtopic')
            .withWillMessage('My Will message')
            .startClean()
            .withWillQos(MqttQos.atLeastOnce);
        client.connectionMessage = connMess;
        try {
          await client.connect(mqttUser, mqttPassword);
        } on NoConnectionException catch (_) {
          client.disconnect();
          connected = false;
          return 0;
        } on SocketException catch (_) {
          client.disconnect();
          connected = false;
          return 0;
        }
        if (client.connectionStatus!.state == MqttConnectionState.connected) {
        } else {
          client.disconnect();
          connected = false;
          return 0;
        }
        client.updates!.listen(_onMessage);
        return 0;
      } catch (_) {}
    }
  }

  linkSetState(Function refreshA) {
    refresh = refreshA;
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    Map<String, dynamic> aux = jsonDecode(pt);
   
    try {
      refresh(c[0].topic, aux);
    } catch (_) {}
  }

  _buildMessage(message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    return builder.payload!;
  }

  void publish(topic, message) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.publishMessage(topic, MqttQos.exactlyOnce, _buildMessage(message));
    }
  }

  _onConnected() {
    client.subscribe('sensores', MqttQos.exactlyOnce);
    client.subscribe('status', MqttQos.exactlyOnce);
    connected = true;
  }
}

class SqliteConn {
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'config.db'),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE configuration (id INTEGER PRIMARY KEY, title TEXT, value TEXT)",
      );
    }, version: 1);
  }

  static Future<void> add(Configuration configuration) async {
    Database database = await _openDB();
    database.execute(
        'insert or replace into configuration (title, value) values ("${configuration.title}", "${configuration.value}");');
  }

  static Future<String> get(String title) async {
    Database database = await _openDB();
    final value = await database.query('configuration',
        columns: ['value'], where: 'title = ?', whereArgs: [title]);

    if (value.isEmpty) {
      add(Configuration(title: title, value: '1'));
      return '1';
    }
    return '${value[0]["value"]}';
  }

  static Future<List<Configuration>> configuration() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> configurationMap =
        await database.query("configuration");

    return List.generate(
        configurationMap.length,
        (i) => Configuration(
            title: configurationMap[i]['title'],
            value: configurationMap[i]['value']));
  }
}
