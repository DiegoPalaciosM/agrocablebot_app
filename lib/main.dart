import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/constants.dart';
import 'package:acb/components/system.dart';

import 'package:acb/screens/actions/actions.dart';
import 'package:acb/screens/charts/charts.dart';
import 'package:acb/screens/config/config.dart';
import 'package:acb/screens/connect/connect.dart';
import 'package:acb/screens/crop/crop.dart';
import 'package:acb/screens/dashboard/dashboard.dart';
import 'package:acb/screens/realtime/realtime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int testing = 1;

  Map<String, String> configs = {};
  bool loaded = false;

  late MQTT mqtt;

  ThemeData darkTheme({required Size size}) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: dPrimaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: dTextColor),
        titleTextStyle: TextStyle(
            fontSize: size.width < size.height
                ? size.height * 0.04
                : size.width * 0.06,
            color: dTextColor),
      ),
      brightness: Brightness.dark,
      primaryColor: dPrimaryColor,
      scaffoldBackgroundColor: dBackgroundColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: dTextColor),
      ),
    );
  }

  ThemeData lightTheme({required Size size}) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: lPrimaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: lTextColor),
        titleTextStyle: TextStyle(
            fontSize: size.width < size.height
                ? size.height * 0.04
                : size.width * 0.05,
            color: lTextColor),
        shadowColor: Colors.black,
      ),
      brightness: Brightness.light,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              const MaterialStatePropertyAll<Color>(lElevatedColor),
          minimumSize: MaterialStateProperty.all(
            Size(
              responsiveSize(size, size.width * 0.22, size.width * 0.1),
              responsiveSize(size, size.height * 0.035, size.height * 0.05),
            ),
          ),
          maximumSize: MaterialStateProperty.all(
            Size(
              responsiveSize(size, size.width * 0.22, size.width * 0.1),
              responsiveSize(size, size.height * 0.035, size.height * 0.05),
            ),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(), backgroundColor: lFLoatingColor),
      primaryColor: lPrimaryColor,
      scaffoldBackgroundColor: lBackgroundColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        bodyMedium: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        bodySmall: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        displayLarge: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        displayMedium: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        displaySmall: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        headlineLarge: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        headlineMedium: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        headlineSmall: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        labelLarge: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        labelMedium: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        labelSmall: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        titleLarge: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        titleMedium: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
        titleSmall: TextStyle(color: lTextColor, fontFamily: 'Montserrat'),
      ),
      //textTheme: TextTheme().apply(bodyColor: lTextColor)
    );
  }

  configInit([bool connect = false]) async {
    SqliteConn.configuration().then((value) {
      for (var config in value) {
        configs[config.title] = config.value;
      }
      setState(() {
        if (configs.containsKey("ip")) {
          mqtt.update(configs["ip"]!);
        }
        loaded = true;
      });
      mqtt.connect();
    });
  }

  @override
  void initState() {
    super.initState();
    mqtt = MQTT();
    configInit();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return OrientationBuilder(builder: (context, orientation) {
      changeRotation(orientation);
      return MaterialApp(
        initialRoute: '/charts',
        darkTheme: darkTheme(size: size),
        routes: {
          '/actions': (context) =>
              ActionsScreen(mqtt: mqtt, configuration: configs),
          '/config': (context) =>
              ConfigScreen(configuration: configs, configInit: configInit),
          '/charts': (context) => ChartsScreen(
                configuration: configs,
              ),
          '/connect': (context) =>
              ConnectScreen(mqtt: mqtt, configInit: configInit),
          '/crop': (context) => CropScreen(mqtt: mqtt, configuration: configs),
          '/dashboard': (context) =>
              DashboardScreen(configuration: configs, mqtt: mqtt),
          '/realtime': (context) =>
              RealTimeScreen(mqtt: mqtt, configuration: configs),
        },
        theme: lightTheme(size: size),
        themeMode: ThemeMode.light,
      );
    });
  }
}
