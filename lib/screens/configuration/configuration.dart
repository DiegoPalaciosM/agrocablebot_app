// Dependencias de flutter
import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'dart:developer' as dev;
// Dependencias externas
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

// Otros archivo de codigo
// -- Modulos
import 'package:agrocablebot/modules/constants/constants.dart';
import 'package:agrocablebot/modules/connector/connector.dart';
import 'package:agrocablebot/modules/components/components.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late BuildContext globalContext;

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
    globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 60.h,
          child: FittedBox(
            child: Text(AppLocalizations.of(context)!.configuration),
          ),
        ),
      ),
      body: Column(
        children: [
          configurationItem(context, 'realtimeDelay',
              AppLocalizations.of(context)!.realtimeDelay),
          configurationItem(
            context,
            'name',
            AppLocalizations.of(context)!.serverName,
            () {
              http.get(
                Uri.parse(
                    'http://${Configuration.ip}:7001/changeName/${Configuration.name}'),
              );
            },
          ),
          configurationItem(
            context,
            'ip',
            AppLocalizations.of(context)!.ip,
            () {
              MqttClient.update();
            },
          ),
          configurationItem(
              context, 'mqttUser', AppLocalizations.of(context)!.mqttUser),
          configurationItem(context, 'mqttPassword',
              AppLocalizations.of(context)!.mqttPassword),
          actionAssetConfig(context),
        ],
      ),
      drawer: const SideMenu(),
    );
  }

  ListTile configurationItem(
      BuildContext context, String configuration, String titleConfig,
      [Function? callback]) {
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            inputConfigController.text =
                '${Configuration.listConfiguration()[configuration]}';
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.newValue,
                style: const TextStyle(
                  color: gris,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Configuration.set([
                      configuration
                    ], [
                      Configuration.listConfiguration()[configuration]
                                  .runtimeType ==
                              String
                          ? inputConfigController.text
                          : int.parse(inputConfigController.text)
                    ]).then(
                      (value) {
                        if (callback != null) {
                          callback();
                        }
                        setState(() {});
                        Navigator.pop(context);
                      },
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.accept,
                    style: const TextStyle(
                      color: gris,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(
                      color: gris,
                    ),
                  ),
                )
              ],
              content: TextFormField(
                controller: inputConfigController,
                keyboardType: Configuration.listConfiguration()[configuration]
                            .runtimeType ==
                        String
                    ? TextInputType.text
                    : TextInputType.number,
                style: const TextStyle(fontFamily: "Roboto", color: gris),
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      },
      title: Text(
        titleConfig,
        style: const TextStyle(
          color: gris,
        ),
      ),
      subtitle: Text(
        '${Configuration.listConfiguration()[configuration]}',
        style: const TextStyle(
          color: gris,
        ),
      ),
      leading: const Icon(
        Icons.settings,
        color: gris,
      ),
    );
  }

  ListTile actionAssetConfig(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context1) {
            dev.log(Configuration.actionAsset);
            dropDownConfigValue.text = Configuration.actionAsset;
            return StatefulBuilder(
              builder: (context, StateSetter setState1) {
                return AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.newImage,
                    style: const TextStyle(
                      color: gris,
                    ),
                  ),
                  content: FittedBox(
                    child: Row(
                      children: List.generate(
                        listPNG.length,
                        (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                Configuration.actionAsset =
                                    listPNG[index].value;
                              });
                              Navigator.pop(context1);
                            },
                            child: listPNG[index],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      title: Text(
        AppLocalizations.of(context)!.actionsIcon,
        style: const TextStyle(
          color: gris,
        ),
      ),
      leading: Image.asset(
        Configuration.actionAsset,
        height: 30.h,
      ),
    );
  }
}
