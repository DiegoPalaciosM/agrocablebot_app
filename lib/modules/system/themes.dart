import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agrocablebot/modules/constants/constants.dart';

ThemeData lightTheme() {
  return ThemeData(
    appBarTheme: AppBarTheme(
      color: lPrimaryColor,
      centerTitle: true,
      iconTheme: const IconThemeData(color: lTextColor),
      titleTextStyle: TextStyle(
          fontSize: 90.sp, color: lTextColor, fontFamily: 'Montserrat'),
      shadowColor: Colors.black,
    ),
    brightness: Brightness.light,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const MaterialStatePropertyAll<Color>(lElevatedColor),
        minimumSize: MaterialStateProperty.all(
          Size(
            15.sp,
            15.sp,
          ),
        ),
        maximumSize: MaterialStateProperty.all(
          Size(
            40.sp,
            500.sp,
          ),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(), backgroundColor: lFLoatingColor),
    fontFamily: 'Montserrat',
    primaryColor: lPrimaryColor,
    scaffoldBackgroundColor: lBackgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lTextColor),
      bodyMedium: TextStyle(color: lTextColor),
      bodySmall: TextStyle(color: lTextColor),
      displayLarge: TextStyle(color: lTextColor),
      displayMedium: TextStyle(color: lTextColor),
      displaySmall: TextStyle(color: lTextColor),
      headlineLarge: TextStyle(color: lTextColor),
      headlineMedium: TextStyle(color: lTextColor),
      headlineSmall: TextStyle(color: lTextColor),
      labelLarge: TextStyle(color: lTextColor),
      labelMedium: TextStyle(color: lTextColor),
      labelSmall: TextStyle(color: lTextColor),
      titleLarge: TextStyle(color: lTextColor),
      titleMedium: TextStyle(color: lTextColor),
      titleSmall: TextStyle(color: lTextColor),
    ),
  );
}
