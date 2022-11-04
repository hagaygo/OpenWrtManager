import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/SystemBoardReply.dart';
import 'package:openwrt_manager/OpenWRT/OpenWRTClient.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/OpenWRT/Model/RebootReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
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

  DeviceActionFormState(this.device) {
    var cli = OpenWRTClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
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
      }
    });
  }

  Widget getBoardInfoWidget() {
    if (_boardData == null || _boardData.keys.length == 0)
      return Text("No device data");
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
    var cli = OpenWRTClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Column(
            children: [getBoardInfoWidget()],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                
              },
              child: Text("Kernel Log"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                
              },
              child: Text("System Log"),
            ),
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
        ],
      ),
    );
  }
}
