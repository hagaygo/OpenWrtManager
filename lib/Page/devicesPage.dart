import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/Page/Form/deviceActionForm.dart';
import 'package:openwrt_manager/Page/identitiesPage.dart';
import 'package:openwrt_manager/settingsUtil.dart';

import 'Form/deviceForm.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({Key key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  void showAddDialog() {
    if (SettingsUtil.identities.length == 0) {
      Dialogs.simpleAlert(
          context, "", "No identities are defined\nAdd at least one identity",
          buttonText: "Add identity", closeAction: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => IdentitiesPage()));
      });
      return;
    }
    showDeviceDialog(DeviceForm(
      title: "Add OpenWrt Device",
    ));
  }

  void showDeviceDialog(DeviceForm iForm) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(iForm.title),
                  ),
                  body: Center(
                    child: ListView(
                      children: [iForm],
                    ),
                  ),
                ))).then((_) => setState(() {}));
  }

  void showDeviceActionDialog(Device d) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(d.displayName + " Device Actions"),
                  ),
                  body: Center(
                    child: ListView(
                      children: [DeviceActionForm(d)],
                    ),
                  ),
                ))).then((_) => setState(() {}));
  }

  void showEditDialog(Device d) {
    showDeviceDialog(DeviceForm(
      device: d,
      title: "Edit OpenWrt Device",
    ));
  }

  List<Widget> getDevices() {
    List<Widget> lst = [];
    for (var d in SettingsUtil.devices) {
      var lt = Container(
          child: ListTile(
              leading: const Icon(Icons.router),
              title: Row(children: <Widget>[
                Text(d.displayName),
                Expanded(
                    child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      child: Text("Actions"),
                      onPressed: () {
                        showDeviceActionDialog(d);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      )),
                ))
              ]),
              onTap: () => {showEditDialog(d)}),
          decoration: new BoxDecoration(
              border: new Border(
                  bottom: new BorderSide(width: 0.5, color: Colors.grey))));
      lst.add(lt);
    }
    return lst;
  }

  @override
  void initState() {
    super.initState();
    FeatureDiscovery.discoverFeatures(
      context,
      const <String>{addDeviceFeatureId},
    );
  }

  static const addDeviceFeatureId = "addDeviceFeatureId";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('OpenWrt Devices'),
        ),
        body: Center(
          child: ListView(
            children: getDevices(),
          ),
        ),
        floatingActionButton: DescribedFeatureOverlay(
          featureId: addDeviceFeatureId,
          tapTarget: const Icon(Icons.add),
          title: Text('Add new device'),
          description: Text(
              'Device contains your OpenWrt device info (Identity & Ip address).\nAfter setting up a device you can add overview on main page to view specified info for that device.'),
          child: FloatingActionButton(
            onPressed: () {
              showAddDialog();
            },
            child: Icon(Icons.add),
          ),
        ));
  }
}
