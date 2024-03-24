import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void displaySystemUI(Orientation orientation) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays:
          orientation == Orientation.portrait ? SystemUiOverlay.values : []);
}
