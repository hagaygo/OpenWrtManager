import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/OpenWrtClient.dart';
import 'package:openwrt_manager/Overview/NetworkTraffic.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Utils.dart';
import 'package:openwrt_manager/dataCache.dart';
import 'package:openwrt_manager/my_flutter_app_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'OverviewWidgetBase.dart';

class WIFIStatus extends OverviewWidgetBase {
  WIFIStatus(
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
  WIFIStatusState createState() => WIFIStatusState();
}

class HostHintData {
  HostHintData(this.host, this.ipV4);
  final String host;
  final String ipV4;
}

class WIFIStatusState extends OverviewWidgetBaseState {
  String getIpAddressStringFromList(dynamic lst) {
    for (var ip in lst) if (ip != null) return ip;
    return null;
  }

  @override
  Widget get myWidget {
    const String infoText =
        "\nUse \"Update Devices\" option on the drawer if you expect to have any WIFI interfaces on this device";

    var wifiData = [];
    var ifnameToApData = Map<String, Map<String, dynamic>>();
    List<String> wifiInterfaces = [];

    if (data != null) {
      var hostHintData = data[0];

      var macToHostHintMap = Map<String, HostHintData>();
      for (var mac in (hostHintData[1] as Map).keys)
        try {
          if (hostHintData[1][mac] != null &&
              hostHintData[1][mac]["name"] != null)
            macToHostHintMap[mac] = HostHintData(hostHintData[1][mac]["name"],
                getIpAddressStringFromList(hostHintData[1][mac]["ipaddrs"]));
        } catch (e) {}

      var wirelessDeviceData = data[1];

      for (var radio in (wirelessDeviceData[1] as Map).keys) {
        var interfaces = wirelessDeviceData[1][radio]["interfaces"];
        for (var interface in interfaces.where((x) => x["ifname"] != null)) {
          ifnameToApData[interface["ifname"]] = {
            "ssid": interface["iwinfo"]["ssid"],
            "noise": interface["iwinfo"]["noise"],
            "signal": interface["iwinfo"]["signal"],
            "channel": interface["iwinfo"]["channel"],
            "bitrate": interface["iwinfo"]["bitrate"],
            "frequency": interface["iwinfo"]["frequency"],
            "encryption": interface["config"]["encryption"],
            "mode": interface["config"]["mode"],
          };
        }
      }

      try {
        var wifiDeviceCounter = 0;
        for (var interface in data.skip(2)) {
          var wifiInterface = widget.device.wifiDevices[wifiDeviceCounter];
          wifiDeviceCounter++;
          wifiInterfaces.add(wifiInterface);
          var results = interface[1]["results"];
          for (var cli in results) {
            var i = cli;
            var hostHint = macToHostHintMap[i["mac"]] ?? null;
            if (hostHint != null) i["hostname"] = hostHint.host;
            i["ip"] = "";
            if (DataCache.macAddressMap.containsKey(i["mac"])) {
              var d = DataCache.macAddressMap[i["mac"]];
              i["ip"] = d.ipAddress;
            } else if (hostHint != null) i["ip"] = hostHint.ipV4;
            i["ifname"] = wifiInterface;
            wifiData.add(i);
          }
        }
      } catch (e, stackTrace) {
        return generateErrorText(
            e, stackTrace, "Error with WIFI data" + infoText);
      }
    }
    if (wifiInterfaces.length == 0)
      return Text("No WIFI interfaces found" + infoText);

    List<Widget> rows = [];

    String currentInterface = "";
    int ifCounter = 1;
    List<String> apWithDevicesList = [];
    bool firstClientInAP = true;
    for (var cli in wifiData) {
      if (cli["ifname"] != currentInterface) {
        var apData = ifnameToApData[cli["ifname"]];
        if (apData != null) {
          if (ifCounter++ > 1) rows.add(SizedBox(height: 5));
          rows.add(getApRow(apData));
          rows.add(SizedBox(height: 5));
          currentInterface = cli["ifname"];
          apWithDevicesList.add(currentInterface);
          firstClientInAP = true;
        }
      }

      if (firstClientInAP)
        firstClientInAP = false;
      else
        rows.add(SizedBox(height: 15));
      var clientContainer = Container(
        child: InkWell(
          onLongPress: () async {
            await setWifiClientDeviceDialog(cli);
          },
          child: wifiClientRows(cli),
        ),
      );
      rows.add(clientContainer);
    }
    for (var ifname in ifnameToApData.keys)
      if (!apWithDevicesList.contains(ifname)) {
        rows.add(SizedBox(height: 5));
        rows.add(getApRow(ifnameToApData[ifname]));
        rows.add(SizedBox(height: 5));
        rows.add(Text("No connected devices"));
      }
    return Column(
      children: rows,
    );
  }

  var _trafficData = Map<String, Map<String, dynamic>>();

  Widget wifiClientRows(cli) {
    var incoming = cli["rx"]["bytes"];
    var outgoing = cli["tx"]["bytes"];
    var name = cli["mac"] + "_" + cli["ifname"];

    if (_trafficData[name] != null) {
      var incomingDiff = incoming - _trafficData[name]["in"];
      var outgoingDiff = outgoing - _trafficData[name]["out"];
      if (gotNewData) {
        var currentTimeStamp = new DateTime.now().millisecondsSinceEpoch;
        var timeDiff = (currentTimeStamp - _trafficData[name]["timeStamp"]) /
            1000; // miliseconds to seconds
        _trafficData[name]["timeStamp"] = currentTimeStamp;
        _trafficData[name]["inSpeed"] =
            Utils.formatBytes((incomingDiff / timeDiff).round(), decimals: 1);
        _trafficData[name]["outSpeed"] =
            Utils.formatBytes((outgoingDiff / timeDiff).round(), decimals: 1);
      }
    }

    String incomingSpeed = " " + Utils.NoSpeedCalculationText + " Kb/s";
    String outgoingSpeed = " " + Utils.NoSpeedCalculationText + " Kb/s";

    if (_trafficData[name] != null && _trafficData[name]["inSpeed"] != null) {
      incomingSpeed = "${_trafficData[name]["inSpeed"]}/s";
      outgoingSpeed = "${_trafficData[name]["outSpeed"]}/s";
    }

    if (_trafficData[name] == null) _trafficData[name] = Map<String, dynamic>();
    _trafficData[name]["out"] = outgoing;
    _trafficData[name]["in"] = incoming;
    if (_trafficData[name]["timeStamp"] == null)
      _trafficData[name]["timeStamp"] =
          new DateTime.now().millisecondsSinceEpoch;

    return Container(
      padding: EdgeInsets.all(2),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              getSignalWidget(cli["signal"]),
              SizedBox(width: 5),
              Expanded(
                  child: Center(
                child:
                    Text(cli["hostname"] != null ? "${cli["hostname"]}" : ""),
              )),
              SizedBox(width: 5),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(cli["mac"].toString())),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              Container(
                width: 110,
                child: Text(Utils.formatDuration(
                    Duration(seconds: cli["connected_time"]))),
              ),
              Expanded(
                  child: Center(
                      child: Text(
                          "${cli["rx"]["rate"] / 1000}/${cli["tx"]["rate"] / 1000} Mbit/s"))),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Text(cli["ip"] ?? ""),
              )),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: NetworkTrafficState.getTrafficWidgetBytes(
                        incoming, MyFlutterApp.down_bold, incomingSpeed)),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: NetworkTrafficState.getTrafficWidgetBytes(
                        outgoing, MyFlutterApp.up_bold, outgoingSpeed)),
              )
            ],
          )
        ],
      ),
    );
  }

  Future setWifiClientDeviceDialog(cli) async {
    Alert(
        context: context,
        title: "Wifi Client Info",
        desc: "${cli["mac"]}\n\n${cli["hostname"]}",
        buttons: [
          DialogButton(
            color: Colors.red,
            child: Text(
              "Disconnect",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              var client = OpenWrtClient(widget.device, null);
              Dialogs.showLoadingDialog(context);
              var res = await client.deleteClient(
                  widget.authenticationStatus, cli["ifname"], cli["mac"]);
              if (res.status != ReplyStatus.Ok) {
                Dialogs.simpleAlert(
                    context, "Error", "Disconnect request returned error");
              } else {
                await new Future.delayed(const Duration(
                    seconds:
                        1)); // wait a little so refresh command will get updated data from ap
                widget.doOverviewRefresh?.call();
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

Widget getSignalWidget(int signal) {
  return Row(
    children: <Widget>[
      Container(
          child: Row(
            children: getSignalWidgets(signal, 40),
          ),
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.only(left: 2, right: 2),
          width: 42,
          height: 15,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Colors.grey))),
      SizedBox(width: 2),
      Text("$signal dBm"),
    ],
  );
}

List<Widget> getSignalWidgets(int signal, double width) {
  /*
    bigger than -60 - max
    between -60 to -80 - 3 bars
    between -80 to -95 - 2 bars
    lower than -95 1 bar

    average of few sites i checked
  */

  const marginBetweenBars = 1.0;
  int barCount = 4;
  double barWidth = width / barCount;

  List<Widget> lst = [];
  if (signal <= -60 && -80 < signal) barCount = 3;
  if (signal <= -80 && -95 < signal) barCount = 2;
  if (signal <= -95) barCount = 1;
  for (int i = 0; i < barCount; i++)
    lst.add(Container(
        color: Colors.blue,
        width: barWidth - (marginBetweenBars * 2),
        margin: EdgeInsets.only(right: marginBetweenBars, top: 1, bottom: 1)));
  return lst;
}

Widget getApRow(Map<String, dynamic> apData) {
  var freq = "";
  if (apData["frequency"] != null) freq = " ${apData["frequency"] / 1000} Ghz ";
  var channel = "";
  if (apData["channel"] != null) channel = " (${apData["channel"]})";
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        '${apData["ssid"]}$freq$channel (${apData["mode"]}/${apData["encryption"]})',
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ],
  );
}
