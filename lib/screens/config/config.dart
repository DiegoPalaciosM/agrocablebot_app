import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:acb/components/connector.dart';
import 'package:acb/components/constants.dart';
import 'package:acb/components/menu.dart';
import 'package:acb/components/structure.dart';
import 'package:acb/components/system.dart';

class ConfigScreen extends StatefulWidget {
  final Function configInit;
  final Map<String, String> configuration;

  const ConfigScreen(
      {super.key, required this.configuration, required this.configInit});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TextEditingController inputConfigController = TextEditingController();
  TextEditingController dropDownConfigValue = TextEditingController();
  List<DropdownMenuItem> listPNG = [];

  Future _initImages() async {
    var assetsFile =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(assetsFile);
    List<String> lista = manifestMap.keys
        .where((String key) => key.contains('plantas'))
        .toList();
    for (var element in lista) {
      listPNG.add(
        DropdownMenuItem(
          value: element.toLowerCase(),
          alignment: Alignment.center,
          child: Image.asset(element),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initImages();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuacion')),
      body: Center(
        child: SizedBox(
          child: Column(
            children: [
              configItem(
                  context, size, 'Actualizar sensores', '5', 'realtimeDelay'),
              configItem(
                  context, size, 'Nombre del servidor de Tailscale', '', 'tailscale'),
              imagePlantasConfig(
                  context,
                  size,
                  'Imagen de los semilleros en la pantalla de "Acciones"',
                  'assets/images/plantas/albahaca.png',
                  'imagePlantasConfig'),
            ],
          ),
        ),
      ),
      drawer: SideMenu(current: ModalRoute.of(context)!.settings.name),
    );
  }

  GestureDetector imagePlantasConfig(BuildContext context, Size size,
      String title, String data, String mapName) {
    return GestureDetector(
      onTap: () {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context1) {
              dropDownConfigValue.text = widget.configuration[mapName] ?? data;
              return StatefulBuilder(builder: (context, StateSetter setState) {
                return AlertDialog(
                  title: const Text(
                    'Nuevo imagen',
                    style: TextStyle(
                      color: gris,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        SqliteConn.add(
                          Configuration(
                              title: mapName, value: dropDownConfigValue.text),
                        );
                        widget.configInit();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Aceptar",
                        style: TextStyle(
                          color: gris,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                          color: gris,
                        ),
                      ),
                    )
                  ],
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: dropDownConfigValue.text,
                            items: listPNG,
                            onChanged: (selected) {
                              setState(() {
                                dropDownConfigValue.text = selected;
                              });
                            },
                          ),
                        ),
                      ]),
                );
              });
            });
      },
      child: ListTile(
          title: Text(
            title,
            style: TextStyle(
                color: gris,
                fontSize: responsiveSize(
                    size, size.height * 0.025, size.width * 0.025)),
          ),
          subtitle: Text(
            widget.configuration[mapName] ?? data,
            style: const TextStyle(
              color: gris,
            ),
          )),
    );
  }

  GestureDetector configItem(BuildContext context, Size size, String title,
      String data, String mapName) {
    return GestureDetector(
      onTap: () {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              inputConfigController.text =
                  widget.configuration[mapName] ?? data;
              return AlertDialog(
                title: const Text(
                  'Nuevo valor',
                  style: TextStyle(
                    color: gris,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      SqliteConn.add(
                        Configuration(
                            title: mapName, value: inputConfigController.text),
                      );
                      widget.configInit();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Aceptar",
                      style: TextStyle(
                        color: gris,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(
                        color: gris,
                      ),
                    ),
                  )
                ],
                content: TextFormField(
                  controller: inputConfigController,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: responsiveSize(
                          size, size.height * 0.02, size.width * 0.02), color: gris),
                  textAlign: TextAlign.center,
                ),
              );
            });
      },
      child: ListTile(
          title: Text(
            title,
            style: TextStyle(
                color: gris,
                fontSize: responsiveSize(
                    size, size.height * 0.025, size.width * 0.025)),
          ),
          subtitle: Text(
            widget.configuration[mapName] ?? data,
            style: const TextStyle(
              color: gris,
            ),
          )),
    );
  }
}
