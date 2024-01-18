import 'dart:developer';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

class Functions {
  final Function refresh;

  Functions({required this.refresh});

  Future<List<String>> getDevices() async {
    List<String> data = [];
    await NetworkInfo().getWifiIP().then((wifiip) async {
      if (wifiip == null) {
        return;
      }
      log(wifiip);
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
