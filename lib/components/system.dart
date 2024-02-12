import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:developer';

void changeRotation(Orientation orientation) {
  bool landscape = orientation == Orientation.portrait ? false : true;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: !landscape ? SystemUiOverlay.values : []);
}

void displaySystemUI(Orientation orientation) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays:
          orientation == Orientation.portrait ? SystemUiOverlay.values : []);
}

double responsiveSize(Size size, double option1, double option2) {
  return size.width < size.height ? option1 : option2;
}

final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
final DateFormat formatterFiles = DateFormat('yyyyMMddhhmmss');

class FileStorage {
  static Future<File> get _logFile async {
    final path = await getExternalStorageDirectory();
    return File('${path!.path}/logs.log').create(recursive: true);
  }

  static Future<File> logToFileS(String log) async {
    final file = await _logFile;
    await checkPermission();
    return file.writeAsString('$log\n', mode: FileMode.append);
  }

  static Future<List<String>> listLogs() async {
    final file = await _logFile;
    return file.readAsLines();
  }

  static Future<File> clearLogs() async {
    final file = await _logFile;
    return file.writeAsString('');
  }

  static deleteLog(List<String> logs) async {
    await clearLogs();
    for (var element in logs) {
      logToFileS(element);
    }
  }

  static Future<String> _getExternalDocumentPath() async {
    Directory directory = Directory("");
    await checkPermission();
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/AgroCableBot");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final exPath = directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _imagePath async {
    final String directory = await _getExternalDocumentPath();
    return directory;
  }

  static Future<File> saveImage(var bytes, String name) async {
    final path = await _imagePath;
    File file = File('$path/$name');
    return file.writeAsBytes(bytes);
  }

  static Future<void> checkPermission() async {
    //var status = await Permission.storage.status;
    var status1 = await Permission.manageExternalStorage.status;
    //if (!status.isGranted) {
    //log(status.isGranted.toString());
    //await Permission.storage.request();
    //log('status');
    //}
    if (!status1.isGranted) {
      log(status1.isGranted.toString());
      await Permission.manageExternalStorage.request();
      log('status1');
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DoubleExtension on double {
  double roundDecimals(int n) => double.parse(toStringAsFixed(n));
}

List getIndex(List<List> matriz, int item, {int count = 0}) {
  int y = item ~/ 9;
  int x = matriz[y].indexOf(item);

  return [x - 4, (-y + 4)];
}

int getSelected(Map<dynamic, dynamic> pos) {
  int res = 0;

  int x = 0;
  int y = 0;

  x = pos['x'];
  y = pos['y'];

  res = (x + 400) + ((-y + 400) * 9);
  res = (res / 100).round();
  return res;
}
