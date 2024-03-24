import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agrocablebot/modules/constants/constants.dart';

ElevatedButton actionButton(String text, Function function) {
  return ElevatedButton(
    onPressed: () => function(),
    child: FittedBox(
      child: Text(
        text,
        style: TextStyle(fontSize: 35.sp),
      ),
    ),
  );
}

Center motorWidget(String text) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 50.sp,
          onPressed: () {
            MqttClient.publish('comandos', '{"GCODE":"G10 $text-1"}');
          },
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          height: 35.h,
          child: FittedBox(
            child: Text(
              "Motor $text",
              style: TextStyle(
                color: gris,
                fontSize: 100.sp,
              ),
            ),
          ),
        ),
        IconButton(
          iconSize: 50.sp,
          onPressed: () {
            MqttClient.publish('comandos', '{"GCODE":"G10 ${text}1"}');
          },
          icon: const Icon(Icons.add),
        ),
      ],
    ),
  );
}
