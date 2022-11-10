import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/Overview/DHCPLeaseStatus.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Overview/OverviewWidgetBase.dart';
import 'package:openwrt_manager/Utils.dart';
import 'package:openwrt_manager/dataCache.dart';

class SystemInfo extends OverviewWidgetBase {
  SystemInfo(
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
  SystemInfoState createState() => SystemInfoState();
}

class SystemInfoState extends OverviewWidgetBaseState
    with TickerProviderStateMixin {
  @override
  bool get supportsExpand => true;

  @override
  Widget get myWidget {
    var infoData =  data[0][1];
    var uptime = infoData["uptime"];
    var load = infoData["load"] as List<dynamic>;
    var memoryTotal = infoData["memory"]["total"];
    var memoryUsed = memoryTotal -
        infoData["memory"]["free"] -
        infoData["memory"]["cached"] -
        infoData["memory"]["buffered"];

    var boardData = data[1][1];
    var hostName = boardData["hostname"];
    var releaseData = boardData["release"];

    var dhcpLeaseData = data[2][1];
    var dhcpLeaseList  = DHCPLeaseStatusState.getDHCPLeaseListFromJSON(dhcpLeaseData["dhcp_leases"]);    
    DataCache.updateData(dhcpLeaseList);
    
    var alwaysVisibleRows = getRows({
      "Hostname": hostName,
      "Up": Utils.formatDuration(Duration(seconds: uptime)),
      "Load": load.map((x) => (x / 65536).toStringAsFixed(2)).join(" , "),
      "Memory Usage": (memoryUsed / 1024 / 1024).toStringAsFixed(2) +
          "Mb/" +
          (memoryTotal / 1024 / 1024).toStringAsFixed(2) +
          "Mb"
    });

    List<Widget> rows = [];
    rows.addAll(alwaysVisibleRows);
    rows.add(AnimatedSize(
      curve: Curves.fastOutSlowIn,
      child: Visibility(
        visible: expanded,
        child: Column(
            children: getRows({
          "Release": releaseData["description"],
          "Model": boardData["model"],
          "Kernel": boardData["kernel"],
          "System": boardData["system"],
          "Target": releaseData["target"]
        })),
      ),
      duration: Duration(milliseconds: 200),      
    ));
    return Column(
      children: rows,
    );
  }
}
