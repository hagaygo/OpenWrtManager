import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/SelectedOverviewItem.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:uuid/uuid.dart';

class OverviewItemSelectionForm extends StatefulWidget {
  final SelectedOverviewItem overviewItem;
  final String title;

  const OverviewItemSelectionForm({Key key, this.overviewItem, this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var s = OverviewItemSelectionFormState();
    if (overviewItem != null) {
      s._selectedOverview = overviewItem.overiviewItemGuid;
      s._selectedDevice = SettingsUtil.devices
          .firstWhere((d) => overviewItem.deviceGuid == d.guid);
      s._editedGuid = overviewItem.guid;
    }
    return s;
  }
}

class OverviewItemSelectionFormState extends State<OverviewItemSelectionForm> {
  final _formKey = GlobalKey<FormState>();
  Device _selectedDevice;
  String _selectedOverview;
  String _editedGuid;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Text(
                            widget.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                  Text("Device"),
                  DropdownButtonFormField<Device>(
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0)),
                    value: _selectedDevice,
                    validator: (value) {
                      if (value == null) {
                        return 'Device is missing';
                      }
                      return null;
                    },
                    items: SettingsUtil.devices
                        .map((d) => DropdownMenuItem(
                              child: Text(d.displayName),
                              value: d,
                            ))
                        .toList(),
                    onChanged: (d) {
                      setState(() => _selectedDevice = d);
                    },
                  ),
                  SizedBox(height: 15),
                  Text("Overview Item"),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0)),
                    value: _selectedOverview,
                    validator: (value) {
                      if (value == null) {
                        return 'Overview item is missing';
                      }
                      return null;
                    },
                    items: OverviewItemManager.items.keys
                        .map((k) => DropdownMenuItem(
                              child: Text(
                                  OverviewItemManager.items[k].displayName),
                              value: k,
                            ))
                        .toList(),
                    onChanged: (o) {
                      setState(() => _selectedOverview = o);
                    },
                  ),
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: <
                      Widget>[
                    Visibility(
                        visible: _editedGuid != null,
                        child: Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 5, 0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      var soi = SettingsUtil.overviews
                                          .firstWhere(
                                              (o) => o.guid == _editedGuid);
                                      var idx =
                                          SettingsUtil.overviews.indexOf(soi);
                                      if (idx > 0) {
                                        SettingsUtil.overviews.removeAt(idx);
                                        SettingsUtil.overviews
                                            .insert(idx - 1, soi);
                                      }
                                      SettingsUtil.saveOverviews();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Move Up",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                  )),
                            ),
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        var soi = SettingsUtil.overviews
                                            .firstWhere(
                                                (o) => o.guid == _editedGuid);
                                        var idx =
                                            SettingsUtil.overviews.indexOf(soi);
                                        if (idx <
                                            SettingsUtil.overviews.length - 1) {
                                          SettingsUtil.overviews.removeAt(idx);
                                          SettingsUtil.overviews
                                              .insert(idx + 1, soi);
                                        }
                                        SettingsUtil.saveOverviews();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Move Down",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green))),
                            )
                          ],
                        ))),
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
                                        title: "Remove overview ?",
                                        text:
                                            'Please confirm overview removal');
                                    if (res == ConfirmAction.CANCEL) return;
                                    var soi = SettingsUtil.overviews.firstWhere(
                                        (o) => o.guid == _editedGuid);
                                    SettingsUtil.overviews.remove(soi);
                                    SettingsUtil.saveOverviews();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red)),
                            ))),
                    Container(
                        height: 40,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (_editedGuid == null) {
                                    var soi = SelectedOverviewItem();
                                    soi.deviceGuid = _selectedDevice.guid;
                                    soi.overiviewItemGuid = _selectedOverview;
                                    soi.guid = Uuid().v4().toString();
                                    SettingsUtil.overviews.add(soi);
                                  } else {
                                    var soi = SettingsUtil.overviews.firstWhere(
                                        (o) => o.guid == _editedGuid);
                                    soi.deviceGuid = _selectedDevice.guid;
                                    soi.overiviewItemGuid = _selectedOverview;
                                  }
                                  SettingsUtil.saveOverviews();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                _editedGuid != null ? "Update" : "Add",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue)),
                        ))
                  ])
                ],
              ),
            ),
          ),
        ));
  }
}
