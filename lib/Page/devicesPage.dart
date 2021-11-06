import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/RebootReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/FirstbootResetReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/OpenWRTClient.dart';
import 'package:openwrt_manager/Page/identitiesPage.dart';
import 'package:openwrt_manager/settingsUtil.dart';

import 'Form/deviceForm.dart';
import 'Form/commandsForm.dart';

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
      title: "Add OpenWRT Device",
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

  void showCommandsDialog(CommandsForm iForm) {
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

  void showEditDialog(Device d) {
    showDeviceDialog(DeviceForm(
      device: d,
      title: "Edit OpenWRT Device",
    ));
  }

  void showRunCommandDialog(Device d) {
    showCommandsDialog(CommandsForm(
      device: d,
      title: "Run Command",
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
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                    ),
                    onPressed: () {
                      showEditDialog(d);
                    },
                    child: Text("Edit"),
                  ),
                ))
              ]),
              onTap: () => {showRunCommandDialog(d)}),
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
          title: Text('OpenWRT Devices'),
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
              'Device contains your OpenWRT device info (Identity & Ip address).\nAfter setting up a device you can add overview on main page to view specified info for that device.'),
          child: FloatingActionButton(
            onPressed: () {
              showAddDialog();
            },
            child: Icon(Icons.add),
          ),
        ));
  }
}
