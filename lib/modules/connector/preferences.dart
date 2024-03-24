// ignore: unused_import
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';
import 'mqtt.dart';

/// Clase para manejar la configuración de la aplicación.
class Configuration {
  /// Instancia única de la clase [Configuration].
  static final Configuration _instance = Configuration._internal();

  /// Constructor de fábrica que devuelve la instancia única de [Configuration].
  factory Configuration() => _instance;

  /// Función de estado que se llama cuando se produce un cambio en la configuración.
  static Function setState = () {};

  /// Ruta al recurso de imagen de acción por defecto.
  static String actionAsset = 'assets/images/plantas/albahaca.png';

  /// Dirección IP del servidor MQTT por defecto.
  static String ip = '127.0.0.1';

  /// Nombre del servidor MQTT por defecto.
  static String name = 'localhost';

  /// Retraso en tiempo real por defecto para la actualización de datos.
  static int realtimeDelay = 5;

  // Usuario por defecto para conexión al servidor MQTT.
  static String mqttUser = '';

  // Contraseña por defecto para conexión al servidor MQTT.
  static String mqttPassword = '';

  /// Constructor privado para la clase [Configuration].
  Configuration._internal() {
    try {} catch (_) {}
  }

  /// Método para obtener las preferencias compartidas.
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// Método estático para inicializar la configuración desde las preferencias compartidas.
  static init() async {
    SharedPreferences prefs = await _instance._prefs;
    actionAsset = prefs.getString('actionAsset') ?? actionAsset;
    ip = prefs.getString('ip') ?? ip;
    name = prefs.getString('name') ?? name;
    realtimeDelay = prefs.getInt('realtimeDelay') ?? realtimeDelay;
    mqttUser = prefs.getString('mqttUser') ?? mqttUser;
    mqttPassword = prefs.getString('mqttPassword') ?? mqttPassword;
    return true;
  }

  /// Método estático para establecer un valor en las preferencias compartidas.
  static set(List<String> key, List<dynamic> value) async {
    for (var i = 0; i < key.length; i++) {
      switch (value[i].runtimeType) {
        case String:
          SharedPreferences prefs = await _instance._prefs;
          await prefs.setString(key[i], value[i]);
          break;
        case int:
          SharedPreferences prefs = await _instance._prefs;
          await prefs.setInt(key[i], value[i]);
          break;
        case double:
          SharedPreferences prefs = await _instance._prefs;
          await prefs.setDouble(key[i], value[i]);
          break;
        case bool:
          SharedPreferences prefs = await _instance._prefs;
          await prefs.setBool(key[i], value[i]);
          break;
      }
    }

    await init();
  }

  /// Método estático para vincular una función de estado para actualizaciones de configuración.
  static linkSetState(Function function) {
    setState = function;
  }

  /// Método estático para obtener la configuración actual.
  static listConfiguration() {
    return {
      'actionAsset': actionAsset,
      'ip': ip,
      'name': name,
      'realtimeDelay': realtimeDelay,
      'mqttUser': mqttUser,
      'mqttPassword': mqttPassword
    };
  }
}
