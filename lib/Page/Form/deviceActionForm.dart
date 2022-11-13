import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/SystemBoardReply.dart';
import 'package:openwrt_manager/OpenWrt/OpenWrtClient.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/OpenWrt/Model/RebootReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'package:openwrt_manager/Page/Form/ServicesForm.dart';
import 'package:openwrt_manager/Page/Form/logViewerForm.dart';
import 'package:openwrt_manager/settingsUtil.dart';

class DeviceActionForm extends StatefulWidget {
  final Device device;

  const DeviceActionForm(this.device) : super();

  @override
  State<StatefulWidget> createState() {
    var s = DeviceActionFormState(device);
    return s;
  }
}

class DeviceActionFormState extends State<DeviceActionForm> {
  final Device device;

  Map _boardData;
  String _boardDataStatusText = "Loading Device Info";

  DeviceActionFormState(this.device) {
    var cli = OpenWrtClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
    cli.authenticate().then((res) {
      if (res.status == ReplyStatus.Ok) {
        cli.getData(res.authenticationCookie, [SystemBoardReply(ReplyStatus.Ok)]).then((boardInfoRes) {
          try {
            setState(() {
              _boardData = (boardInfoRes[0].data["result"] as List)[1] as Map;
            });
          } catch (e) {
            Dialogs.simpleAlert(context, "Error", "Bad response from device");
          }
        });
      } else
        setState(() {
          _boardDataStatusText = "Error getting device data - authentication failed";
        });
    });
  }

  Widget getBoardInfoWidget() {
    if (_boardData == null || _boardData.keys.length == 0)
      return Text(_boardDataStatusText);
    else {
      List<Widget> lst = [];
      for (var key in _boardData.keys) {
        if (_boardData[key] is String)
          addBoardInfoItem(lst, _boardData, key);
        else if (_boardData[key] is Map)
          for (var vv in (_boardData[key] as Map).keys) addBoardInfoItem(lst, _boardData[key], vv);
      }

      return Column(
        children: lst,
      );
    }
  }

  Future<void> doReboot() async {
    var res = await Dialogs.confirmDialog(context,
        title: 'Reboot ${device.displayName} ?', text: 'Please confirm device reboot');
    if (res == ConfirmAction.CANCEL) return;
    var cli = OpenWrtClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
    cli.authenticate().then((res) {
      if (res.status == ReplyStatus.Ok) {
        cli.getData(res.authenticationCookie, [RebootReply(ReplyStatus.Ok)]).then((rebootRes) {
          try {
            var responseCode = (rebootRes[0].data["result"] as List)[0];
            if (responseCode == 0) {
              Dialogs.simpleAlert(context, "Success", "Device should reboot");
            } else {
              Dialogs.simpleAlert(context, "Error", "Device returned unexpected result");
            }
          } catch (e) {
            Dialogs.simpleAlert(context, "Error", "Bad response from device");
          }
        });
      } else {
        Dialogs.simpleAlert(context, "Error", "Authentication failed");
      }
    });
  }

  Future<List<String>> getSystemLog() async {
    var cli = OpenWrtClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
    var lst = ["Authentication failed"];
    await cli.authenticate().then((res) async {
      if (res.status == ReplyStatus.Ok) {
        var responseText = await cli.executeCgiExec(res.authenticationCookie.value, "/sbin/logread -e ^");
        lst = new LineSplitter().convert(responseText).toList();
      }
    });
    return lst;
  }

  Future<List<String>> getKernelLog() async {
    var cli = OpenWrtClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
    var lst = ["Authentication failed"];
    await cli.authenticate().then((res) async {
      if (res.status == ReplyStatus.Ok) {
        var responseText = await cli.executeCgiExec(res.authenticationCookie.value, "/bin/dmesg -r");
        lst = new LineSplitter().convert(responseText).toList();
        for (int i = 0; i < lst.length; i++)
          if (lst[i].startsWith("<") && lst[i].contains(">")) lst[i] = lst[i].substring(lst[i].indexOf(">") + 1);
      }
    });
    return lst;
  }

  void addBoardInfoItem(List<Widget> lst, Map m, key) {
    lst.add(Row(
      children: [
        SizedBox(
          child: Text(key),
          width: 120,
        ),
        SizedBox(width: 10),
        Flexible(child: Text(m[key]))
      ],
    ));
  }

  void showLogPage(String title, LogViewerForm logView) {
    Dialogs.showPage(context, title, logView, actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        onPressed: () {
          logView.refresh();
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                var logView = LogViewerForm(() async {
                  return await getKernelLog();
                });
                showLogPage(device.displayName + " Kernel Log", logView);
              },
              child: Text("Kernel Log"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                var logView = LogViewerForm(() async {
                  return await getSystemLog();
                });
                showLogPage(device.displayName + " System Log", logView);
              },
              child: Text("System Log"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Dialogs.showPage(context, device.displayName + " Startup", ServicesForm(device));
              },
              child: Text("Startup"),
            )
          ]),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  doReboot();
                },
                child: Text("Reboot"),
              )
            ]),
          ),
          Container(padding: EdgeInsets.all(10), child: Text("Device Info", textScaleFactor: 1.5)),
          Column(
            children: [getBoardInfoWidget()],
          )
        ],
      ),
    );
  }
}
