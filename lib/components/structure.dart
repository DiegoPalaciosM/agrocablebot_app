class Configuration {
  final String title;
  final String value;

  Configuration({required this.title, required this.value});

  Configuration.fromMap(Map<String, dynamic> item)
      : title = item['title'],
        value = item["value"];

  Map<String, Object> toMap() {
    return {'title': title, 'value': value};
  }
}

class DeviceInfo {
  final String ssid;
  final String mac;
  final String name;
  final String ip;

  DeviceInfo(
      {required this.ssid,
      required this.mac,
      required this.name,
      required this.ip});

  DeviceInfo.fromMap(Map<String, dynamic> item)
      : ssid = item["ssid"],
        mac = item["mac"],
        name = item["name"],
        ip = item["ip"];
}

class AcelerometroData {
  final String createdAt;
  final double x;
  final double y;
  final double z;

  AcelerometroData(
      {required this.createdAt,
      required this.x,
      required this.y,
      required this.z});

  AcelerometroData.fromMap(Map<String, dynamic> item)
      : createdAt = item["createdAt"],
        x = item["x"],
        y = item["y"],
        z = item["z"];
}

class GiroscopioData {
  final String createdAt;
  final double pith;
  final double roll;
  final double yaw;

  GiroscopioData(
      {required this.createdAt,
      required this.pith,
      required this.roll,
      required this.yaw});

  GiroscopioData.fromMap(Map<String, dynamic> item)
      : createdAt = item["createdAt"],
        pith = item["pith"],
        roll = item["roll"],
        yaw = item["yaw"];
}

class CompassData {
  final String createdAt;
  final double x;
  final double y;
  final double z;

  CompassData(
      {required this.createdAt,
      required this.x,
      required this.y,
      required this.z});

  CompassData.fromMap(Map<String, dynamic> item)
      : createdAt = item["createdAt"],
        x = item["x"],
        y = item["y"],
        z = item["z"];
}

class HumedadData {
  final String createdAt;
  final double value;

  HumedadData({required this.createdAt, required this.value});

  HumedadData.fromMap(Map<String, dynamic> item)
      : createdAt = item["createdAt"],
        value = item["value"];

  Map toJson() {
    return {'createdAt': createdAt, 'value': value};
  }
}

class TemperaturaData {
  final String createdAt;
  final double value;

  TemperaturaData({required this.createdAt, required this.value});

  TemperaturaData.fromMap(Map<String, dynamic> item)
      : createdAt = item["createdAt"],
        value = item["value"];
}

class PresionData {
  final String createdAt;
  final double value;

  PresionData({required this.createdAt, required this.value});

  PresionData.fromMap(Map<String, dynamic> item)
      : createdAt = item["createdAt"],
        value = item["value"];
}
