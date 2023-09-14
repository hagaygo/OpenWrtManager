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
  Map? _startupData;

  void refreshList() {
    var cli = OpenWrtClient(device, SettingsUtil.identities!.firstWhere((x) => x.guid == device.identityGuid));
    cli.authenticate().then((res) {
      if (res.status == ReplyStatus.Ok) {
        cli
            .getData(res.authenticationCookie, [StartupServiceReply(ReplyStatus.Ok)], pTimeout: 8)
            .then((startupReplyRes) {
          try {
            setState(() {
              _startupData = (startupReplyRes[0].data!["result"] as List)[1] as Map;
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

  ServicesFormState(this.device) {
    refreshList();
  }

  @override
  Widget build(BuildContext context) {
    if (_startupData == null || _startupData!.keys.length == 0)
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(_boardDataStatusText),
      ));
    else {
      return Column(
        children: getServicesRows(_startupData!),
      );
    }
  }

  Future<void> setInitAction(String serviceName, String action) async {
    var cli = OpenWrtClient(device, SettingsUtil.identities!.firstWhere((x) => x.guid == device.identityGuid));
    cli.authenticate().then((res) {
      if (res.status == ReplyStatus.Ok) {
        cli.getData(res.authenticationCookie, [StartupServiceCommandReply(ReplyStatus.Ok, serviceName, action)]).then(
            (commnadRes) {
          try {
            var responseCode = (commnadRes[0].data!["result"] as List)[0];
            if (responseCode == 0) {
              Dialogs.simpleAlert(context, "Success", "Action was successful");
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

  Map<String, bool> _expandedList = Map<String, bool>();

  List<Widget> getServicesRows(Map startupData) {
    List<Widget> lst = [];
    var orderdList = startupData.keys.toList();
    orderdList.sort((a, b) => (startupData[a]["index"] ?? 0) - (startupData[b]["index"] ?? 0));
    for (var key in orderdList) {
      lst.add(Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.5, color: Colors.grey[300]!),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedList[key] = !(_expandedList[key] ?? false);
                  });
                },
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
                    Container(
                        padding: EdgeInsets.only(left: 40),
                        child: (_expandedList[key] ?? false) ? Icon(Icons.expand_less) : Icon(Icons.expand_more))
                  ]))
                ]),
              ),
              Visibility(
                visible: _expandedList[key] ?? false,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: startupData[key]["enabled"] ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (startupData[key]["enabled"])
                          setInitAction(key, "disable");
                        else
                          setInitAction(key, "enable");
                        refreshList();
                      },
                      child: Text(startupData[key]["enabled"] ? "Disable" : "Enable"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        setInitAction(key, "start");
                        refreshList();
                      },
                      child: Text("Start"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        setInitAction(key, "restart");
                        refreshList();
                      },
                      child: Text("Restart"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        setInitAction(key, "stop");
                        refreshList();
                      },
                      child: Text("Stop"),
                    )
                  ]),
                ),
              )
            ],
          )));
    }
    return lst;
  }
}
