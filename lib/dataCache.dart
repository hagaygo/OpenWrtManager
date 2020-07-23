import 'Model/dhcpLease.dart';

class DataCache {
  static Map<String, DHCPLease> _macAddressMap = Map<String, DHCPLease>();

  static Map<String, DHCPLease> get macAddressMap => _macAddressMap;

  static void updateData(List<DHCPLease> lst)
  {
    for (var d in lst)
      _macAddressMap[d.macAddress] = d;
  }
}
