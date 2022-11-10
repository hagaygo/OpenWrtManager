import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/OpenWrtClient.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Overview/OverviewWidgetBase.dart';
import 'package:openwrt_manager/Utils.dart';
import 'package:openwrt_manager/my_flutter_app_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NetworkTraffic extends OverviewWidgetBase {
  NetworkTraffic(
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
    return NetworkTrafficState();
  }
}

class NetworkTrafficState extends OverviewWidgetBaseState {
  List<String> _interfaces;
  var _trafficData = Map<String, Map<String, dynamic>>();

  @override
  Widget get myWidget {
    List<Widget> rows = [];
    var trafficInterfaces = data[0][1];
    var interfaces = data[1][1]["interface"] as List;
    var ifCounter = 1;
    _interfaces = [];
    for (var name in trafficInterfaces.keys) {
      var iff = trafficInterfaces[name];
      if (iff["up"] && !iff["flags"]["loopback"]) {
        _interfaces.add(name);
        if (configData != null && configData[name] != true) continue;
        if (ifCounter > 1) rows.add(SizedBox(height: 10));
        var incoming =
            double.parse(iff["stats"]["rx_bytes"].toString()).toInt();
        var outgoing =
            double.parse(iff["stats"]["tx_bytes"].toString()).toInt();

        if (_trafficData[name] != null) {
          var incomingDiff = incoming - _trafficData[name]["in"];
          var outgoingDiff = outgoing - _trafficData[name]["out"];
          if (gotNewData) {
            var currentTimeStamp = new DateTime.now().millisecondsSinceEpoch;
            var timeDiff =
                (currentTimeStamp - _trafficData[name]["timeStamp"]) / 1000;
            _trafficData[name]["timeStamp"] = currentTimeStamp;
            _trafficData[name]["inSpeed"] = Utils.formatBytes(
                (incomingDiff / timeDiff).round(),
                decimals: 1);
            _trafficData[name]["outSpeed"] = Utils.formatBytes(
                (outgoingDiff / timeDiff).round(),
                decimals: 1);
          }
        }

        String incomingSpeed = " " + Utils.NoSpeedCalculationText + " Kb/s";
        String outgoingSpeed = " " + Utils.NoSpeedCalculationText + " Kb/s";

        if (_trafficData[name] != null &&
            _trafficData[name]["inSpeed"] != null) {
          incomingSpeed = "${_trafficData[name]["inSpeed"]}/s";
          outgoingSpeed = "${_trafficData[name]["outSpeed"]}/s";
        }

        var interface = interfaces.firstWhere(
            (x) => x["l3_device"] == iff["name"],
            orElse: () => null); // first try by name

        if (interface == null) // then try to match by master device
          interface = interfaces.firstWhere(
              (x) => iff["master"] == x["l3_device"],
              orElse: () => null);

        String uptime = "";
        String interfaceAddress = "";
        if (interface != null) {
          if (interface["uptime"] != null)
            uptime =
                Utils.formatDuration(Duration(seconds: interface["uptime"]));
          if (interface["ipv4-address"] != null &&
              (interface["ipv4-address"] as List).length > 0)
            interfaceAddress =
                "${interface["ipv4-address"][0]["address"] ?? ""}";
        }

        var interfaceHeaderRow = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                width: 110,
                child: Text("${iff["name"]}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ))),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text("$interfaceAddress"),
              ),
            ),
            Container(
                width: 120,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      uptime,
                    )))
          ],
        );

        var trafficRow = Row(
          children: <Widget>[
            Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: getTrafficWidgetBytes(
                      incoming, MyFlutterApp.down_bold, incomingSpeed)),
            ),
            Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: getTrafficWidgetBytes(
                      outgoing, MyFlutterApp.up_bold, outgoingSpeed)),
            )
          ],
        );

        var interfaceBox = Container(
            padding: EdgeInsets.all(3),
            child: InkWell(
                onLongPress: () async =>
                    {await showRestartInterfaceOptionsDialog(interface)},
                child: Column(
                  children: <Widget>[
                    interfaceHeaderRow,
                    SizedBox(
                      height: 10,
                    ),
                    trafficRow,
                    SizedBox(
                      height: 5,
                    )
                  ],
                )));
        rows.add(interfaceBox);
        if (_trafficData[name] == null)
          _trafficData[name] = Map<String, dynamic>();
        _trafficData[name]["out"] = outgoing;
        _trafficData[name]["in"] = incoming;
        if (_trafficData[name]["timeStamp"] == null)
          _trafficData[name]["timeStamp"] =
              new DateTime.now().millisecondsSinceEpoch;
        ifCounter++;
      }
    }

    return Column(
      children: rows,
    );
  }

  static Widget getTrafficWidgetBytes(int bytes, IconData ico, String speed) {
    const int MoreDecimalThreshold = 1024 * 1024 * 1024 * 1024;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            width: 75,
            child: Align(
                alignment: Alignment.centerRight,
                child: Text("${Utils.formatBytes(bytes, decimals: bytes > MoreDecimalThreshold  ? 3 : 1)}"))),
        SizedBox(width: 2),
        Icon(ico, size: 12),
        SizedBox(width: 2),
        Expanded(
          child: Container(
            child: Text(speed),
          ),
        )
      ],
    );
  }

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

  Future showRestartInterfaceOptionsDialog(interface) async {
    Alert(
        context: context,
        title: "${interface["interface"]} (${interface["device"]})",
        desc: "",
        buttons: [
          DialogButton(
            color: Colors.red,
            child: Text(
              "Restart",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              var client = OpenWrtClient(widget.device, null);
              Dialogs.showLoadingDialog(context);
              var res = await client.restartInterface(
                  widget.authenticationStatus, interface["interface"]);
              if (res.status != ReplyStatus.Ok) {
                Dialogs.simpleAlert(context, "Error",
                    "Interface restart request returned error");
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]).show();
  }
}
