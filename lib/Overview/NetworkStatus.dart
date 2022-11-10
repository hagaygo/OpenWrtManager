import 'package:flutter/cupertino.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Overview/OverviewWidgetBase.dart';
import 'package:openwrt_manager/Utils.dart';

class NetworkStatus extends OverviewWidgetBase {
  NetworkStatus(
      Device device,
      bool loading,
      AuthenticateReply authenticationStatus,
      List<CommandReplyBase> replies,
      OverviewItem item,
      String overviewItemGuid,
      Function doOverviewRefresh)
      : super(device, loading, authenticationStatus, replies, item,
            overviewItemGuid, doOverviewRefresh);

  @override
  State<StatefulWidget> createState() {
    return NetworkStatusState();
  }
}

class NetworkStatusState extends OverviewWidgetBaseState {
  @override
  Widget get myWidget {
    List<Widget> rows = [];
    var interfaces = data[0][1]["interface"];
    var ifCounter = 1;
    _interfaces = [];
    for (var iff in interfaces) {
      if (iff["up"] && iff["proto"] != "none" && iff["device"] != "lo") {
        var dataMap = Map<String, String>();
        var interface = iff["interface"];
        _interfaces.add(interface);
        if (configData != null && configData[interface] != true) continue;
        if (ifCounter > 1) rows.add(SizedBox(height: 5));
        dataMap.addAll({"Interface": "$interface (${iff["device"]})"});
        var ipAddress = iff["ipv4-address"] as List<dynamic>;
        for (var ip in ipAddress)
          dataMap.addAll({"Ip Address": "${ip["address"]}/${ip["mask"]}"});
        dataMap.addAll(
            {"Up": Utils.formatDuration(Duration(seconds: iff["uptime"]))});
        var dnsServer = iff["dns-server"] as List<dynamic>;
        if (dnsServer.length > 0)
          dataMap.addAll({"Dns Server": dnsServer.join("\n")});
        var interfaceData = getRows(dataMap);
        rows.addAll(interfaceData);
        ifCounter++;
      }
    }

    return Column(
      children: rows,
    );
  }

  List<String> _interfaces;

  @override
  List<Map<String, dynamic>> get configItems {
    if (_interfaces == null || _interfaces.length == 0) return null;
    return _interfaces
        .map((x) => {
              "name": "$x",
              "type": "bool",
              "category": "Select interfaces to show"
            })
        .toList();
  }

  @override
  bool get supportsConfig {
    return true;
  }
}
