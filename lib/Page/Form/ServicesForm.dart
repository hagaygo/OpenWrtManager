import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/StartupServiceReply.dart';
import 'package:openwrt_manager/OpenWrt/OpenWrtClient.dart';
import 'package:openwrt_manager/settingsUtil.dart';

class ServicesForm extends StatefulWidget {
  final Device device;

  const ServicesForm(this.device) : super();

  @override
  State<StatefulWidget> createState() {
    var s = ServicesFormState(device);
    return s;
  }
}

class ServicesFormState extends State<ServicesForm> {
  final Device device;

  String _boardDataStatusText = "Loading Device Startup Info";
  Map _startupData;

  ServicesFormState(this.device) {
    var cli = OpenWrtClient(device, SettingsUtil.identities.firstWhere((x) => x.guid == device.identityGuid));
    cli.authenticate().then((res) {
      if (res.status == ReplyStatus.Ok) {
        cli.getData(res.authenticationCookie, [StartupServiceReply(ReplyStatus.Ok)]).then((startupReplyRes) {
          try {
            setState(() {
              _startupData = (startupReplyRes[0].data["result"] as List)[1] as Map;
            });
          } catch (e) {
            Dialogs.simpleAlert(context, "Error", "Bad response from device");
          }
        });
      } else
        setState(() {
          _boardDataStatusText = "Error getting device startup data - authentication failed";
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_startupData == null || _startupData.keys.length == 0)
      return Text(_boardDataStatusText);
    else {
      return Column(
        children: getServicesRows(_startupData),
      );
    }
  }
}

List<Widget> getServicesRows(Map startupData) {
  List<Widget> lst = [];
  var orderdList = startupData.keys.toList();
  orderdList.sort((a, b) => startupData[a]["index"] - startupData[b]["index"]);
  for (var key in orderdList) {
    lst.add(Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.5, color: Colors.grey[300]),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
        child: Row(children: [
          Container(width: 60, child: Text(startupData[key]["index"].toString())),
          Text(key),
          Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            startupData[key]["enabled"]
                ? Text(
                    "Enabled",
                    style: TextStyle(color: Colors.green),
                  )
                : Text("Disabled", style: TextStyle(color: Colors.red)),
            Container(padding: EdgeInsets.only(left: 40), child: Icon(Icons.expand_more))
          ]))
        ])));
  }
  return lst;
}
