class Device {
  String guid;
  String displayName;
  String address;
  String port;
  String identityGuid;
  bool useSecureConnection;
  bool ignoreBadCertificate;
  List<String> wifiDevices = [];

  static const String defaultPort = "80/443";

  Map toJson() => {
        'displayName': displayName,
        'guid': guid,
        'address': address,
        'identityGuid': identityGuid,
        'port': port,
        'wifiDevices': wifiDevices,
        'useSecureConnection': useSecureConnection,
        'ignoreBadCertificate': ignoreBadCertificate,
      };

  static Device fromJson(Map<String, dynamic> json) {
    var i = Device();
    i.guid = json['guid'].toString();
    i.address = json['address'].toString();
    i.displayName = json['displayName'].toString();
    i.identityGuid = json['identityGuid'].toString();
    i.port = json['port'].toString();
    i.useSecureConnection = json['useSecureConnection'] ?? false;
    i.ignoreBadCertificate = json['ignoreBadCertificate'] ?? false;
    if (json['wifiDevices'] != null && (json['wifiDevices'] as List).length > 0)
      i.wifiDevices.addAll((json['wifiDevices'] as List<dynamic>).map((x) => x.toString()));
    return i;
  }
}
