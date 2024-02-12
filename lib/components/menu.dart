import 'package:flutter/material.dart';

import 'package:acb/components/constants.dart';

class SideMenu extends StatelessWidget {
  final String? current;
  const SideMenu({super.key, required this.current});

  List<Widget> buttons(BuildContext context, {bool onlyLinks = false}) {
    List<Widget> list = [];
    if (!onlyLinks) {
      list.add(
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SizedBox(),
        ),
      );
    }
    items.forEach((key, value) {
      list.add(ListTile(
        tileColor: current == value[1] ? naranja : azul,
        leading: Icon(value[0], color: lTextColor),
        title: Text(
          key,
          style: const TextStyle(color: lTextColor),
        ),
        onTap: () {
          Navigator.pushReplacementNamed(context, value[1]);
        },
      ));
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: lPrimaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: buttons(context),
        ));
  }
}
