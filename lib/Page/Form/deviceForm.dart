import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/Identity.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/OpenWRTClient.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:uuid/uuid.dart';

class DeviceForm extends StatefulWidget {
  final Device device;
  final String title;

  const DeviceForm({Key key, this.device, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var s = DeviceFormState();
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

class DeviceFormState extends State<DeviceForm> {
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
                          Text("Display Name"),
                        ],
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                top: InputMargin, bottom: InputMargin)),
                        controller: _displayName,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Display name is missing';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Text("Identity"),
                        ],
                      ),
                      DropdownButtonFormField<Identity>(
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 0, bottom: 0)),
                        value: selectedIdentity,
                        validator: (value) {
                          if (value == null) {
                            return 'Identity is missing';
                          }
                          return null;
                        },
                        items: SettingsUtil.identities
                            .map((i) => DropdownMenuItem(
                                  child: Text(i.name),
                                  value: i,
                                ))
                            .toList(),
                        onChanged: (i) {
                          setState(() => selectedIdentity = i);
                        },
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text("Address")),
                          Container(width: 130, child: Text("Port"))
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      top: InputMargin, bottom: InputMargin)),
                              controller: _address,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Address is missing';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            width: 130,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  isDense: true,
                                  hintText: Device.defaultPort,
                                  contentPadding: EdgeInsets.only(
                                      top: InputMargin, bottom: InputMargin)),
                              controller: _port,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 150,
                            child: CheckboxListTile(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Use https"),
                              onChanged: (bool value) {
                                setState(() {
                                  _secureConnection = value;
                                });
                              },
                              value: _secureConnection,
                            ),
                          ),
                          Visibility(
                            visible: _secureConnection,
                            child: Container(
                              width: 210,
                              child: CheckboxListTile(
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text("Ignore certificate errors"),
                                onChanged: (bool value) {
                                  setState(() {
                                    _ignoreBadCertificate = value;
                                  });
                                },
                                value: _ignoreBadCertificate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: <
                      Widget>[
                    Visibility(
                        visible: _editedGuid != null,
                        child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            height: 40,
                            child: SizedBox.expand(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    var res = await Dialogs.confirmDialog(
                                        context,
                                        title: 'Delete Device ?',
                                        text: 'Please confirm device deletion');
                                    if (res == ConfirmAction.CANCEL) return;
                                    var i = SettingsUtil.devices.firstWhere(
                                        (x) => x.guid == _editedGuid);
                                    var o = SettingsUtil.overviews.firstWhere(
                                        (x) => x.deviceGuid == _editedGuid,
                                        orElse: () => null);
                                    if (o == null) {
                                      SettingsUtil.devices.remove(i);
                                      SettingsUtil.saveDevices();
                                      Navigator.pop(context);
                                    } else {
                                      Dialogs.simpleAlert(
                                          context,
                                          "Can not delete",
                                          "Device in use on main page");
                                    }
                                  },
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      )),
                            ))),
                    Container(
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
                                    Dialogs.simpleAlert(context, "Test Result",
                                        res.status.toString().split('.').last);
                                  });
                                  Dialogs.showLoadingDialog(context);
                                }
                              },
                              child: Text(
                                "Test",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      )),
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        height: 40,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  var d = Device();
                                  if (_editedGuid != null)
                                    d = SettingsUtil.devices.firstWhere(
                                        (x) => x.guid == _editedGuid);
                                  getDevice(d);
                                  if (_editedGuid == null) {
                                    d.guid = Uuid().v4().toString();
                                    SettingsUtil.devices.add(d);
                                  }
                                  SettingsUtil.saveDevices();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      )),
                        ))
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
