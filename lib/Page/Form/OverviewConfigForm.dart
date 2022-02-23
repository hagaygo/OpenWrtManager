import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/settingsUtil.dart';

class OverviewConfigForm extends StatefulWidget {
  final List<Map<String, dynamic>> configItems;
  final Device device;
  final OverviewItem item;
  final String overviewItemGuid;

  OverviewConfigForm(
      this.configItems, this.device, this.item, this.overviewItemGuid);

  @override
  State<StatefulWidget> createState() {
    return OverviewConfigFormState();
  }
}

class OverviewConfigFormState extends State<OverviewConfigForm> {
  Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>();
    var config = SettingsUtil.overviewConfig.data[widget.overviewItemGuid];
    for (var ci in widget.configItems) {
      _data[ci["name"]] = config == null ? true : config[ci["name"]] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text(
              "${widget.device.displayName} - ${widget.item.displayName} Config",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 30,
            ),
            Column(children: getConfigItems()),
            SizedBox(
              height: 15,
            ),
            Container(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      )                ,
                child: Text("Save"),                
                onPressed: () {
                  saveConfig();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  getConfigItems() {
    List<Widget> lst = [];
    String lastCategory;
    for (var ci in widget.configItems) {
      var category = ci["category"];
      if (category != lastCategory) {
        lst.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              category,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
      }
      lastCategory = category;
      var row = Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(child: Text(ci["name"])),
              ),
              (ci["type"] == "bool")
                  ? Checkbox(
                      onChanged: (bool value) {
                        setState(() {
                          _data[ci["name"]] = value;
                        });
                      },
                      value: _data[ci["name"]],
                    )
                  : Text("not implemented"),
            ],
          ));
      lst.add(row);
    }
    return lst;
  }

  void saveConfig() {
    SettingsUtil.overviewConfig.data[widget.overviewItemGuid] = _data;
    SettingsUtil.saveOverviewConfig();
    Navigator.pop(context);
  }
}
