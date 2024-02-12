import 'dart:convert';

import 'package:http/http.dart' as http;

class Functions {
  static void getData(Function refresh, String ip, String sensor,
      {String dateInit = '0001-01-01 00:00:00',
      String dateEnd = '9999-12-31 23:59:59'}) {
    List<dynamic> returnData = [];
    http
        .post(Uri.parse('http://$ip:7001/data/$sensor'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'dateInit': dateInit, 'dateEnd': dateEnd}))
        .then((response) {
      if (response.statusCode == 200) {
        returnData = jsonDecode(response.body);
        refresh(returnData);
      }
    });
  }
}
