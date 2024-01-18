import 'package:flutter/material.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/header.dart';
import 'package:acb/components/menu.dart';

class CropScreen extends StatefulWidget {
  final MQTT mqtt;
  final Map<String, String> configuration;

  const CropScreen(
      {super.key, required this.mqtt, required this.configuration});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Header(
              ip: widget.configuration["ip"],
              name: widget.configuration["name"],
              size: size,
              title: 'Cultivo'),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [],
              ),
            ),
          )
        ],
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }
}
