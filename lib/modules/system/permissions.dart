import 'dart:developer' as dev;

import 'package:permission_handler/permission_handler.dart';

/// Función asíncrona para verificar y solicitar permiso para administrar el almacenamiento externo.
///
/// Esta función verifica si la aplicación tiene permiso para administrar el almacenamiento externo.
/// Si el permiso no está concedido, solicita al usuario que lo conceda.
Future<void> checkPermission() async {
  var statusManageExternalStorage =
      await Permission.manageExternalStorage.status;
  if (!statusManageExternalStorage.isGranted) {
    dev.log(statusManageExternalStorage.isGranted.toString());
    await Permission.manageExternalStorage.request();
  }
}
