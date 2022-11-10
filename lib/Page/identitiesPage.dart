import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/Identity.dart';
import 'package:openwrt_manager/settingsUtil.dart';

import 'Form/identityForm.dart';

class IdentitiesPage extends StatefulWidget {
  IdentitiesPage({Key key}) : super(key: key);

  @override
  _IdentitiesPageState createState() => _IdentitiesPageState();
}

class _IdentitiesPageState extends State<IdentitiesPage> {
  void showAddDialog() {
    showIdentityDialog(IdentityForm(
      title: "Add New Identity",
    ));
  }

  void showIdentityDialog(IdentityForm iForm) {
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

  @override
  void initState() {
    super.initState();
    FeatureDiscovery.discoverFeatures(
      context,
      const <String>{addIdentityFeatureId},
    );
  }

  void showEditDialog(Identity i) {
    showIdentityDialog(IdentityForm(
      identity: i,
      title: "Edit Identity",
    ));
  }

  List<Widget> getIdentities() {
    List<Widget> lst = [];
    for (var i in SettingsUtil.identities) {
      var lt = Container(
          child: ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(i.displayName.length == 0 ? i.username : i.displayName),
              onTap: () => {showEditDialog(i)}),
          decoration: new BoxDecoration(border: new Border(bottom: new BorderSide(width: 0.5, color: Colors.grey))));
      lst.add(lt);
    }
    return lst;
  }

  static const addIdentityFeatureId = "addIdentityFeatureId";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('OpenWrt Identities'),
        ),
        body: Center(
          child: ListView(
            children: getIdentities(),
          ),
        ),
        floatingActionButton: DescribedFeatureOverlay(
          featureId: addIdentityFeatureId,
          tapTarget: const Icon(Icons.add),
          title: Text('Add new identity'),
          description: Text(
              'Identity contains your credentials (username & password) for authenticating against your OpenWrt device.\nYou must setup at least one identity in order to connect your OpenWrt device(s).'),
          child: FloatingActionButton(
            onPressed: () {
              showAddDialog();
            },
            child: Icon(Icons.add),
          ),
        ));
  }
}
