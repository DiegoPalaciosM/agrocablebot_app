// Dependencias de flutter
// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dependencias externas
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Otros archivo de codigo
// -- Diversas funciones
import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:agrocablebot/modules/system/system.dart';

// -- Pantallas
import 'package:agrocablebot/screens/actions/actions.dart';
import 'package:agrocablebot/screens/charts/charts.dart';
import 'package:agrocablebot/screens/configuration/configuration.dart';
import 'package:agrocablebot/screens/connect/connect.dart';
import 'package:agrocablebot/screens/dashboard/dashboard.dart';
import 'package:agrocablebot/screens/realtime/realtime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  runApp(const Entrypoint());
}

class Entrypoint extends StatefulWidget {
  const Entrypoint({super.key});

  @override
  State<Entrypoint> createState() => _EntrypointState();
}

class _EntrypointState extends State<Entrypoint> {
  bool loading = true;

  Future<bool> initConfig() async {
    return await Configuration.init();
  }

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initConfig(),
      builder: (context, snapshot) {
        if (!(snapshot.hasData)) {
          return const CircularProgressIndicator();
        }
        return ScreenUtilInit(
          designSize: const Size(600, 1024),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            builder: (context, screen) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: screen!),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/actions',
            routes: {
              '/actions': (context) => const ActionsScreen(),
              '/charts': (context) => const ChartScreen(),
              '/configuration': (context) => const ConfigurationScreen(),
              '/connect': (context) => ConnectScreen(update: refresh),
              '/dashboard': (context) => const DashboardScreen(),
              '/realtime': (context) => const RealtimeScreen(),
            },
            theme: lightTheme(),
            themeMode: ThemeMode.light,
          ),
        );
      },
    );
  }
}
