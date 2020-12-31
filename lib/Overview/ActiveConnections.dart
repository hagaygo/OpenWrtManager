import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/OpenWRTClient.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Overview/OverviewWidgetBase.dart';
import 'package:openwrt_manager/Utils.dart';
import 'dart:math' as math;

class ActiveConnections extends OverviewWidgetBase {
  ActiveConnections(
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
    return ActiveConnectionsState();
  }
}

class ActiveConnectionsState extends OverviewWidgetBaseState {
  static const int MAX_ROWS = 5;
  static const int EXPANDED_MAX_ROWS = 15;

  Map<String, String> _ipLookup = Map<String, String>();
  Map<String, dynamic> _trafficMap = Map<String, dynamic>();
  int lastTrafficDataTimeStamp = 0;

  @override
  bool get supportsExpand => true;

  String getProtocolText(dynamic data, String ipPropName, String portPropName) {
    var ip = data[ipPropName];
    if (ip == null) return "";
    var str = _ipLookup[ip];
    if (data[portPropName] != null) str = str + ":" + data[portPropName];
    return str;
  }

  void checkIpForLookup(String ip, List<String> ipToResolve) {
    if (!_ipLookup.containsKey(ip)) {
      ipToResolve.add(ip);
      _ipLookup[ip] = ip;
    }
  }

  @override
  Widget get myWidget {
    var rows = List<Widget>();
    var connectionsList = data[0][1]["result"] as List;
    if (connectionsList.length == 0) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("No active connections")],
      ));
    } else {
      connectionsList.sort((a, b) =>
          int.parse(b["bytes"].toString()) - int.parse(a["bytes"].toString()));

      var ipToResolve = List<String>();
      var currentTimeStamp = new DateTime.now().millisecondsSinceEpoch;
      for (var con in connectionsList.take(expanded ? EXPANDED_MAX_ROWS : MAX_ROWS)) {
        checkIpForLookup(con["src"], ipToResolve);
        checkIpForLookup(con["dst"], ipToResolve);

        String speedText;

        var connectionKey = getProtocolText(con, "src", "sport") +
            "," +
            getProtocolText(con, "dst", "dport");

        if (_trafficMap.containsKey(connectionKey)) {
          var oldTrafficData = _trafficMap[connectionKey];
          var newTrafficDataBytes = con["bytes"];

          if (gotNewData) {
            var timeDiff = (currentTimeStamp - lastTrafficDataTimeStamp) / 1000;
            if (timeDiff > 0) {
              var byteDiff = newTrafficDataBytes - oldTrafficData["traffic"];
              var speed = (byteDiff / timeDiff).round();
              speedText = Utils.formatBytes(speed, decimals: 2) + "/s";
              oldTrafficData["speedText"] = speedText;
              oldTrafficData["traffic"] = newTrafficDataBytes;
            }
          } else {
            speedText = oldTrafficData["speedText"];
          }
        } else {
          _trafficMap[connectionKey] = Map();
          _trafficMap[connectionKey]["traffic"] = con["bytes"];
        }                

        rows.add(Container(                    
          margin: EdgeInsets.fromLTRB(10, 0, 10, 15),          
          child: Column(
            children: [
              Row(children: [
                Container(                    
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(con["layer3"].toString().toUpperCase()),
                        Text("/"),
                        Text(con["layer4"].toString().toUpperCase())
                      ],
                    )),
                Expanded(
                    child: Container(
                        width: 100,
                        child: Center(
                            child: Text(
                                speedText != null ? speedText : (Utils.NoSpeedCalculationText + " Kb/s"))))),
                Container(
                    width: 100,
                    child: Align(alignment: Alignment.centerRight,
                        child:
                            Text(Utils.formatBytes(con["bytes"], decimals: 2), style: TextStyle(fontWeight: FontWeight.bold),)))
              ]),
              SizedBox(
                height: 5,
              ),
              Row(children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: Icon(Icons.subdirectory_arrow_left, size: 12)),
                ),
                Expanded(child: Text(getProtocolText(con, "src", "sport"))),
              ]),
              SizedBox(
                height: 5,
              ),
              Row(children: [
                Icon(Icons.subdirectory_arrow_right, size: 12),
                Expanded(
                  child:
                      Text(getProtocolText(con, "dst", "dport"), maxLines: 2),
                ),
              ])
            ],
          ),
        ));
      }

      if (gotNewData) lastTrafficDataTimeStamp = currentTimeStamp;

      if (ipToResolve.length > 0) {
        var cli = OpenWRTClient(widget.device, null);
        cli.getRemoteDns(widget.authenticationStatus, ipToResolve).then((res) {
          if (res.status == ReplyStatus.Ok) {
            var data = (res.data["result"] as dynamic)[1];
            if (data != null && data is Map) {
              for (String ip in data.keys) {
                _ipLookup[ip] = data[ip];
              }
            }
          }
        });
      }
    }

    return Column(
      children: rows,
    );
  }
}
