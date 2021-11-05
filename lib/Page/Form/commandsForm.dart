import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/Identity.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/FirstbootResetReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/RebootReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/OpenWRTClient.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:uuid/uuid.dart';

class CommandsForm extends StatefulWidget {
  final Device device;
  final String title;

  const CommandsForm({Key key, this.device, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var s = CommandsFormState();
    if (device != null) {
      s._address.text = device.address;
      s._port.text = device.port;
      s._displayName.text = device.displayName;
      s._editedGuid = device.guid;
      s._secureConnection = device.useSecureConnection;
      s._ignoreBadCertificate = device.ignoreBadCertificate;
      s.selectedIdentity = SettingsUtil.identities
          .firstWhere((i) => i.guid == device.identityGuid, orElse: () => null);
    }
    if (SettingsUtil.identities.length == 1)
      s.selectedIdentity = SettingsUtil.identities[0];
    return s;
  }
}

class CommandsFormState extends State<CommandsForm> {
  final _formKey = GlobalKey<FormState>();

  final _address = TextEditingController();
  final _port = TextEditingController();
  final _displayName = TextEditingController();

  bool _secureConnection = false;
  bool _ignoreBadCertificate = false;
  String _editedGuid;

  Identity selectedIdentity;

  static const double InputMargin = 7;
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          reverse: true,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Device Name"),
                        ],
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                top: InputMargin, bottom: InputMargin)),
                        controller: _displayName,
                      ),
                      SizedBox(height: 15),
                      SizedBox(height: 15),
                    ],
                  ),
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: <
                      Widget>[
                    Visibility(
                      visible: _editedGuid != null,
                      child: Container(
                          height: 40,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: SizedBox.expand(
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    var d = Device();
                                    getDevice(d);
                                    var oc = OpenWRTClient(d, selectedIdentity);
                                    oc.authenticate().then((res) {
                                      Navigator.pop(context);
                                      Dialogs.simpleAlert(
                                          context,
                                          "Test Result",
                                          res.status
                                              .toString()
                                              .split('.')
                                              .last);
                                    });
                                    Dialogs.showLoadingDialog(context);
                                  }
                                },
                                child: Text(
                                  "Test Connection",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                )),
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      height: 40,
                    ),
                    SizedBox(height: 15),
                    SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        Text("Actions"),
                      ],
                    ),
                    Container(
                        height: 40,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () async {
                                var res = await Dialogs.confirmDialog(context,
                                    title: 'Factory Reset Device?',
                                    text:
                                        'Do you really want to factory reset this device? Once started, this action cannot be undone.');
                                if (res == ConfirmAction.CANCEL) return;
                                if (_formKey.currentState.validate()) {
                                  var d = Device();
                                  getDevice(d);
                                  var oc = OpenWRTClient(d, selectedIdentity);
                                  oc.authenticate().then((res) {
                                    oc.getData(res.authenticationCookie,
                                        [FirstbootResetReply(ReplyStatus.Ok)]);
                                    Navigator.pop(context);
                                    Dialogs.simpleAlert(
                                        context,
                                        "Factory Reset Device",
                                        res.status.toString().split('.').last);
                                  });
                                  Dialogs.showLoadingDialog(context);
                                }
                              },
                              child: Text(
                                "Factory Reset Device",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              )),
                        )),
                    Container(
                        height: 40,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () async {
                                var res = await Dialogs.confirmDialog(context,
                                    title: 'Reboot Device?',
                                    text:
                                        'Do you really want to reboot this device?');
                                if (res == ConfirmAction.CANCEL) return;
                                if (_formKey.currentState.validate()) {
                                  var d = Device();
                                  getDevice(d);
                                  var oc = OpenWRTClient(d, selectedIdentity);
                                  oc.authenticate().then((res) {
                                    oc.getData(res.authenticationCookie,
                                        [RebootReply(ReplyStatus.Ok)]);
                                    Navigator.pop(context);
                                    Dialogs.simpleAlert(
                                        context,
                                        "Reboot Device",
                                        res.status.toString().split('.').last);
                                  });
                                  Dialogs.showLoadingDialog(context);
                                }
                              },
                              child: Text(
                                "Reboot Device",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              )),
                        )),
                  ])
                ],
              ),
            ),
          ),
        ));
  }

  void getDevice(Device d) {
    d.displayName = _displayName.text;
    d.address = _address.text;
    d.port = _port.text;
    d.identityGuid = selectedIdentity.guid;
    d.useSecureConnection = _secureConnection;
    d.ignoreBadCertificate = _ignoreBadCertificate;
  }
}
