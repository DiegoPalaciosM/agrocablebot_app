import 'dart:io';
import 'dart:developer' as dev;

import 'package:network_info_plus/network_info_plus.dart';

class Functions {
  final Function refresh;

  Functions({required this.refresh});

  Future<List<String>> getDevices() async {
    List<String> data = [];
    var interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      if (interface.name == "wlan0") {
        var wifiip = interface.addresses[0].address;
        for (var i = 0; i < 255; i++) {
          String ip = (wifiip.split('.')
                  ..removeLast()
                  ..add(i.toString()))
                .join('.');
                await Socket.connect(ip, 7001,
                    timeout: const Duration(milliseconds: 50))
                .then((socket) {
              data.add(ip);
              refresh(ip);
            }).catchError((error) {});
        }

      }
    }
    return data;
  }

  Future<List<String>> getDevices_bk() async {
    List<String> data = [];
    await NetworkInfo().getWifiIP().then((wifiip) async {
      if (wifiip == null) {
        return;
      }
      dev.log(wifiip);
      await NetworkInfo().getWifiGatewayIP().then((gatewayip) async {
        if (gatewayip == null) {
          return;
        }
        await NetworkInfo().getWifiBroadcast().then((broadcastip) async {
          if (broadcastip == null) {
            return;
          }
          for (var i = int.parse(gatewayip.split('.')[3]);
              i < int.parse(broadcastip.split('.')[3]);
              i++) {
            String ip = (wifiip.split('.')
                  ..removeLast()
                  ..add(i.toString()))
                .join('.');
            await Socket.connect(ip, 7001,
                    timeout: const Duration(milliseconds: 50))
                .then((socket) {
              data.add(ip);
              refresh(ip);
            }).catchError((error) {});
          }
        });
      });
    });
    return data;
  }
}
