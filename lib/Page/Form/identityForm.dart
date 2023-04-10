import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/Identity.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:uuid/uuid.dart';

class IdentityForm extends StatefulWidget {
  final Identity? identity;
  final String? title;

  const IdentityForm({Key? key, this.identity, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var s = IdentityFormState();
    if (identity != null) {
      s._username.text = identity!.username!;
      s._password.text = identity!.password!;
      s._displayName.text = identity!.displayName!;
      s._editedGuid = identity!.guid;
    }
    return s;
  }
}

class IdentityFormState extends State<IdentityForm> {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  String? _editedGuid;

  static const double InputMargin = 7;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Display Name"),
                TextFormField(
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          top: InputMargin, bottom: InputMargin)),
                  controller: _displayName,
                ),
                SizedBox(height: 15),
                Text("Username"),
                TextFormField(
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          top: InputMargin, bottom: InputMargin)),
                  controller: _username,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Username is missing';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                Text("Password"),
                TextFormField(
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          top: InputMargin, bottom: InputMargin)),
                  controller: _password,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is missing';
                    }
                    return null;
                  },
                ),
                Column(mainAxisAlignment: MainAxisAlignment.end, children: <
                    Widget>[
                  Visibility(
                      visible: _editedGuid != null,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          height: 40,
                          child: SizedBox.expand(
                            child: ElevatedButton(
                                onPressed: () async {
                                  var res = await Dialogs.confirmDialog(context,
                                      title: 'Delete Identity ?',
                                      text: 'Please confirm identity deletion');
                                  if (res == ConfirmAction.CANCEL) return;
                                  var i = SettingsUtil.identities!
                                      .firstWhere((x) => x.guid == _editedGuid);
                                  SettingsUtil.getDevices().then((dvs) {
                                    var di = dvs!.firstWhereOrNull(
                                        (d) => d.identityGuid == i.guid);
                                    if (di != null) {
                                      Dialogs.simpleAlert(
                                          context,
                                          "Can not delete identity",
                                          "it is linked to a device");
                                    } else {
                                      SettingsUtil.identities!.remove(i);
                                      SettingsUtil.saveIdentities();
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                )),
                          ))),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      height: 40,
                      child: SizedBox.expand(
                        child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                var i = Identity();
                                if (_editedGuid != null)
                                  i = SettingsUtil.identities!
                                      .firstWhere((x) => x.guid == _editedGuid);
                                else
                                  i.guid = Uuid().v4().toString();
                                i.displayName = _displayName.text;
                                i.password = _password.text;
                                i.username = _username.text;
                                if (_editedGuid == null)
                                  SettingsUtil.identities!.add(i);
                                SettingsUtil.saveIdentities();
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            )),
                      ))
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
