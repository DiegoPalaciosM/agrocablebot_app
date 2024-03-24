import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// Formato de fecha y hora para nombres de archivos.
final DateFormat formatterFiles = DateFormat('yyyyMMddhhmmss');

/// Función asíncrona para guardar una imagen en el dispositivo.
///
/// [bytes]: Los bytes de la imagen a guardar.
/// [name]: El nombre del archivo de la imagen.
Future<File> saveImage(var bytes, String name) async {
  Directory directory = Directory("");
  if (Platform.isAndroid) {
    directory = Directory("/storage/emulated/0/AgroCableBot");
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  final exPath = directory.path;
  await Directory(exPath).create(recursive: true);
  return File('$exPath/$name').writeAsBytes(bytes);
}

/// Clase para manejar archivos de registro (logs).
class Logs {
  /// Método estático para obtener el archivo de registro (log) correspondiente.
  static Future<File> get _logFile async {
    final path = await getApplicationDocumentsDirectory();
    return File('${path.path}/logs.log').create(recursive: true);
  }

  /// Método estático para crear un nuevo registro (log).
  ///
  /// [log]: El mensaje de registro a añadir.
  static createLog(String log) async {
    final file = await _logFile;
    return file.writeAsString('$log\n', mode: FileMode.append);
  }

  /// Método estático para listar todos los registros (logs) existentes.
  static Future<List<String>> listLogs() async {
    final file = await _logFile;
    return file.readAsLines();
  }

  /// Método estático para borrar todos los registros (logs) existentes.
  static clearLogs() async {
    final file = await _logFile;
    return file.writeAsString('');
  }

  /// Método estático para eliminar un registro (log) específico.
  ///
  /// [logs]: La lista de registros (logs) a mantener después de la eliminación.
  static deleteLog(List<String> logs) async {
    await clearLogs();
    for (var element in logs) {
      createLog(element);
    }
  }
}
