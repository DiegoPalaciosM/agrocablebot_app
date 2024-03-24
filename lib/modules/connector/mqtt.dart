import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Clase para manejar la conexión MQTT.
class MqttClient {
  /// Instancia única de la clase [MqttClient].
  static final MqttClient _instance = MqttClient._internal();

  /// Constructor de fábrica que devuelve la instancia única de [MqttClient].
  factory MqttClient() => _instance;

  /// Cliente MQTT para la conexión con el servidor MQTT.
  late MqttServerClient client;

  /// Función de actualización que se llama cuando se recibe un mensaje MQTT.
  late Function refresh;

  List<String> topics = ['status', 'sensores'];

  static bool moving = false;

  /// Constructor privado para la clase [MqttClient].
  MqttClient._internal() {
    try {
      // Configuración del cliente MQTT
      client = MqttServerClient(Configuration.ip, '1883');
      client.keepAlivePeriod = 60;
      client.onConnected = _onConnected;
      client.onDisconnected = _onDisconnected;

      // Generación del identificador del cliente
      var name = 'app${Random().nextInt(99)}';

      // Configuración del mensaje de conexión
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(name)
          .withWillTopic('willTopic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client.connectionMessage = connMess;
    } catch (_) {
      dev.log(_.toString());
    }
  }

  /// Método estático para establecer la conexión con el servidor MQTT.
  static connect() async {
    if (_instance.client.connectionStatus?.state !=
        MqttConnectionState.connected) {
      try {
        await _instance.client
            .connect(Configuration.mqttUser, Configuration.mqttPassword);
      } on Exception catch (_) {
        _instance.client.disconnect();
        _instance.client.connectionStatus?.state =
            MqttConnectionState.disconnected;
        dev.log(_.toString());
        return false;
      }
      _instance.client.updates!.listen(_instance._onMessage);
      return true;
    }
    return true;
  }

  /// Método para manejar el evento de desconexión MQTT.
  _onDisconnected() {
    _instance.client.connectionStatus?.state = MqttConnectionState.disconnected;
    Configuration.setState();
  }

  /// Método para manejar el evento de conexión MQTT.
  _onConnected() {
    _instance.client.subscribe('testingimacuna', MqttQos.exactlyOnce);
    _instance.client.subscribe('status', MqttQos.exactlyOnce);
    _instance.client.subscribe('sensores', MqttQos.exactlyOnce);
    Configuration.setState();
  }

  /// Método para manejar los mensajes MQTT recibidos.
  _onMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt = jsonDecode(
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message));

    if (pt.containsKey('esp')) {
      moving = pt['esp'] == 'OK' ? false : true;
    }
    if (topics.contains(c[0].topic)) {
      try {
        refresh(c[0].topic, pt);
      } catch (_) {
        dev.log(_.toString());
        return;
      }
    }
  }

  /// Método estático para actualizar la dirección IP del servidor MQTT.
  static Future<bool> update() async {
    String ip = Configuration.ip;
    if (ip.isNotEmpty && _instance.client.server != ip || !status()) {
      dev.log(ip);
      _instance.client.server = ip;
      _instance.client.disconnect();
      return await connect();
    }
    return true;
  }

  /// Método estático para establecer la función de actualización del estado de la aplicación.
  static void linkSetState(Function function) {
    _instance.refresh = function;
  }

  /// Método estático para publicar un mensaje en un tema MQTT.
  static void publish(topic, message) {
    connect().then(
      (value) {
        if (value) {
          final builder = MqttClientPayloadBuilder();
          builder.addString(message);
          _instance.client
              .publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
        }
      },
    );
  }

  /// Método estático para verificar el estado de la conexión MQTT.
  static bool status() {
    return _instance.client.connectionStatus!.state ==
        MqttConnectionState.connected;
  }
}
