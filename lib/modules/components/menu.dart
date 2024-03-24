import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agrocablebot/modules/constants/colors.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<List<dynamic>> items = [
      [
        AppLocalizations.of(context)!.actions,
        Icons.gamepad_outlined,
        '/actions',
      ],
      [
        AppLocalizations.of(context)!.configuration,
        Icons.settings,
        '/configuration',
      ],
      [
        AppLocalizations.of(context)!.crop,
        Icons.local_florist,
        '/crop',
      ],
      [
        AppLocalizations.of(context)!.dashboard,
        Icons.dashboard,
        '/dashboard',
      ],
      [
        AppLocalizations.of(context)!.charts,
        Icons.show_chart_sharp,
        '/charts',
      ],
      [
        AppLocalizations.of(context)!.sensors,
        Icons.sensors,
        '/realtime',
      ]
    ];
    var current = ModalRoute.of(context)?.settings.name;
    return Drawer(
      backgroundColor: lPrimaryColor,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  alignment: Alignment.bottomCenter,
                ),
              ),
              child: SizedBox(),
            );
          }
          return ListTile(
            tileColor: current == items[index - 1][2] ? naranja : azul,
            leading: Icon(items[index - 1][1], color: lTextColor),
            title: Text(
              items[index - 1][0],
              style: const TextStyle(color: lTextColor),
            ),
            onTap: () {
              if (current != items[index - 1][2]) {
                Navigator.pushReplacementNamed(context, items[index - 1][2]);
                return;
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
