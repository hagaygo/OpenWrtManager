import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/SelectedOverviewItem.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/Model/NetworkDeviceReply.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWRT/OpenWRTClient.dart';
import 'package:openwrt_manager/Overview/ActiveConnections.dart';
import 'package:openwrt_manager/Overview/DHCPLeaseStatus.dart';
import 'package:openwrt_manager/Overview/NetworkTraffic.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Overview/SystemInfo.dart';
import 'package:openwrt_manager/Overview/NetworkStatus.dart';
import 'package:openwrt_manager/Overview/WIFIStatus.dart';
import 'package:openwrt_manager/Page/devicesPage.dart';
import 'package:openwrt_manager/ThemeChangeNotifier.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'Form/OverviewItemSelectionForm.dart';
import 'identitiesPage.dart';
import 'package:feature_discovery/feature_discovery.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  get availableAutoRefreshIntervals => [
        DropdownMenuItem(value: 3, child: Text("3")),
        DropdownMenuItem(value: 5, child: Text("5")),
        DropdownMenuItem(value: 10, child: Text("10")),
        DropdownMenuItem(value: 15, child: Text("15"))
      ];

  String _appVersion = "";

  initVersionState() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      if (_appVersion.endsWith(".0"))
        _appVersion = _appVersion.substring(0, _appVersion.length - 2);
    } catch (exception) {
      _appVersion = "1.10"; // currently there is an error on windows build
    }
  }

  static const addOverviewFeatureId = "addOverviewFeatureId";
  static const showDrawerFeatureId = "showDrawerFeatureId";

  @override
  void initState() {
    super.initState();
    initVersionState();
    WidgetsBinding.instance.addObserver(this);

    SettingsUtil.loadOverviewConfig().then((b) {
      refreshOverviews();
    });

    SettingsUtil.loadAppSettings().then((b) {
      initAutoRefreshTimer();
    });

    FeatureDiscovery.discoverFeatures(
      context,
      const <String>{showDrawerFeatureId, addOverviewFeatureId},
    );
  }

  void reinitAutoRefreshTimer() {
    autoRefreshTimer?.cancel();
    initAutoRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Timer autoRefreshTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initAutoRefreshTimer();
      refreshOverviews();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      autoRefreshTimer?.cancel();
    }
  }

  void initAutoRefreshTimer() {
    if (_autoRefresh) {
      autoRefreshTimer = new Timer.periodic(
          Duration(seconds: SettingsUtil.appSettings.autoRefreshInterval),
          (Timer t) {
        var route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          refreshOverviews();
        }
      });
    }
  }

  void showAddDialog() {
    if (SettingsUtil.devices.length == 0) {
      Dialogs.simpleAlert(context, "No devices found",
          "You must add at least one device on devices menu");
    } else
      showOverviewDialog("Add Overview Item for a device", null);
  }

  void showOverviewDialog(String title, SelectedOverviewItem soi) {
    Dialogs.showMyDialog(
        context,
        OverviewItemSelectionForm(
          title: title,
          overviewItem: soi,
        )).then((_) => setState(() {
          if (!_autoRefresh) refreshOverviews();
        }));
  }

  void showEditOverviewDialog(SelectedOverviewItem soi) {
    showOverviewDialog("Update Overview Item", soi);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildDrawer(context),
      appBar: AppBar(
          title: Text('OpenWRT Overview'),
          leading: GestureDetector(
              onTap: () {
                if (_scaffoldKey.currentState.isDrawerOpen) {
                  _scaffoldKey.currentState.openEndDrawer();
                } else {
                  _scaffoldKey.currentState.openDrawer();
                }
              },
              child: DescribedFeatureOverlay(
                featureId: showDrawerFeatureId,
                tapTarget: Icon(Icons.menu),
                title: Text('Click here to open menu'),
                description: Text(
                    'On the menu you can setup identities, devices and more settings'),
                child: Icon(Icons.menu),
              ))),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: getOverviews(),
          ),
        ),
        onRefresh: () {
          refreshOverviews();
          return Future.value(null);
        },
      ),
      floatingActionButton: DescribedFeatureOverlay(
        featureId: addOverviewFeatureId,
        tapTarget: const Icon(Icons.add),
        title: Text('Add new overview to main view'),
        description: Text(
            'After setting up your device, you can add an overview for that device'),
        child: FloatingActionButton(
          onPressed: () {
            showAddDialog();
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  static const drawerIconWidth = 60.0;

  get _autoRefreshInterval {
    if (SettingsUtil.appSettings == null) return 10;
    return SettingsUtil.appSettings.autoRefreshInterval;
  }

  set _autoRefreshInterval(int val) {
    SettingsUtil.appSettings.autoRefreshInterval = val;
    SettingsUtil.saveAppSettings();
  }

  bool get _autoRefresh {
    if (SettingsUtil.appSettings == null) return false;
    return SettingsUtil.appSettings.autoRefresh;
  }

  set _autoRefresh(bool val) {
    SettingsUtil.appSettings.autoRefresh = val;
    SettingsUtil.saveAppSettings();
  }

  bool get _darkTheme {
    if (SettingsUtil.appSettings == null) return false;
    return SettingsUtil.appSettings.darkTheme;
  }

  set _darkTheme(bool val) {
    SettingsUtil.appSettings.darkTheme = val;
    SettingsUtil.saveAppSettings();
  }

  Widget buildDrawer(BuildContext context) {
    return Container(
        width: 250,
        child: Stack(children: <Widget>[
          Drawer(
              elevation: 100,
              child: ListView(padding: EdgeInsets.zero, children: <Widget>[
                Container(
                  height: 80,
                  child: DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Options'),
                            Expanded(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        SettingsUtil.getDevices().then((dvs) {
                                          Clipboard.setData(ClipboardData(
                                              text: OpenWRTClient
                                                      .lastJSONRequest +
                                                  "\n\n" +
                                                  OpenWRTClient
                                                      .lastJSONResponse +
                                                  "\n\n" +
                                                  jsonEncode(dvs)));
                                          Dialogs.simpleAlert(context, "",
                                              "Debug data\n Copied to clipboard");
                                        });
                                      },
                                      icon: Icon(Icons.help_center))
                                ]))
                          ],
                        )
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    margin: EdgeInsets.all(0.0),
                  ),
                ),
                ListTile(
                  leading: Container(
                      width: drawerIconWidth, child: const Icon(Icons.refresh)),
                  title: Text('Refresh'),
                  onTap: () {
                    Navigator.pop(context);
                    refreshOverviews();
                  },
                ),
                ListTile(
                  leading: Container(
                      width: drawerIconWidth,
                      child: const Icon(Icons.account_circle)),
                  title: Text('Identities'),
                  onTap: () {
                    SettingsUtil.getIdentities().then((ids) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IdentitiesPage()),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: Container(
                      width: drawerIconWidth, child: const Icon(Icons.router)),
                  title: Text('Devices'),
                  onTap: () {
                    SettingsUtil.getIdentities().then((ids) {
                      SettingsUtil.getDevices().then((dvs) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DevicesPage()),
                        ).then((value) {
                          refreshOverviews();
                        });
                      });
                    });
                  },
                ),
                ListTile(
                  leading: Container(
                      width: drawerIconWidth,
                      child: const Icon(Icons.device_hub)),
                  title: Text('Update Devices'),
                  onTap: () {
                    SettingsUtil.getIdentities().then((ids) {
                      SettingsUtil.getDevices().then((dvs) {
                        Navigator.pop(context);
                        updateDevicesData(dvs).then((x) {
                          Navigator.pop(context);
                          if (x.length > 0)
                            Dialogs.simpleAlert(
                                context, "Update Device failed", x.join(","));
                        });
                        Dialogs.showLoadingDialog(context);
                      });
                    });
                  },
                ),
                ListTile(
                    leading: Container(
                        width: 60,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Switch(
                              onChanged: (bool value) {
                                setState(() {
                                  _darkTheme = value;
                                  Provider.of<ThemeChangeNotifier>(context,
                                          listen: false)
                                      .toggleTheme();
                                });
                              },
                              value: _darkTheme,
                            ),
                          ],
                        )),
                    title: Text("Dark Mode")),
                ListTile(
                    leading: Container(
                        width: 60,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Switch(
                              onChanged: (bool value) {
                                setState(() {
                                  _autoRefresh = value;
                                  reinitAutoRefreshTimer();
                                });
                              },
                              value: _autoRefresh,
                            ),
                          ],
                        )),
                    title: Text("Auto Refresh")),
                Visibility(
                    visible: _autoRefresh,
                    child: ListTile(
                      title: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text("Refresh Interval"),
                          SizedBox(width: 20),
                          DropdownButton(
                            value: _autoRefreshInterval,
                            items: availableAutoRefreshIntervals,
                            onChanged: (value) {
                              setState(() {
                                _autoRefreshInterval = value;
                                reinitAutoRefreshTimer();
                              });
                            },
                          )
                        ],
                      ),
                    )),
              ])),
          Column(children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        padding: EdgeInsets.all(10), child: Text(_appVersion))))
          ])
        ]));
  }

  bool _overviewsLoaded = false;

  List<Widget> getOverviews() {
    List<Widget> lst = [];
    var requestMap = Map<String, List<CommandReplyBase>>();

    if (!_overviewsLoaded) {
      SettingsUtil.getIdentities().then((identities) {
        SettingsUtil.getDevices().then((devices) {
          SettingsUtil.getOverviews().then((overviews) {
            setState(() {
              _overviewsLoaded = true;
            });
          });
        });
      });
    } else {
      for (var oi in SettingsUtil.overviews) {
        if (!requestMap.containsKey(oi.deviceGuid))
          requestMap[oi.deviceGuid] = [];
        var l = requestMap[oi.deviceGuid];
        for (var n in OverviewItemManager.items[oi.overiviewItemGuid].commands)
          if (l.firstWhere((x) => x.runtimeType == n.runtimeType,
                  orElse: () => null) ==
              null) {
            var nr = n.createReply(ReplyStatus.Ok, null,
                device: SettingsUtil.devices
                    .firstWhere((d) => d.guid == oi.deviceGuid));
            if (nr is CommandReplyBase) {
              l.add(nr);
            } else
              l.addAll(nr);
          }
        lst.add(InkWell(
            onLongPress: () {
              showEditOverviewDialog(oi);
            },
            child: getOverviewMainWidget(oi)));
      }
    }

    if (_deviceAuthentication.keys.length >
        0) // means at least one device got authentication result
    {
      if (_deviceReply.keys.length >
          0) // at least one device got command replies
      {
        setState(() {});
      }
    } else if (_refreshing && requestMap.keys.length > 0) {
      for (var deviceGuid in requestMap.keys) {
        var d = SettingsUtil.devices.firstWhere((x) => x.guid == deviceGuid);
        var oc = OpenWRTClient(
            d,
            SettingsUtil.identities
                .firstWhere((x) => x.guid == d.identityGuid));
        oc.authenticate().then((res) {
          _deviceAuthentication[d] = res;
          if (res.status == ReplyStatus.Ok) {
            oc
                .getData(res.authenticationCookie, requestMap[d.guid])
                .then((dataResult) {
              setState(() {
                _deviceReply[d] = dataResult;
              });
            });
          } else {}
          setState(() {});
        });
      }
    }
    if (lst.length == 0) {
      setupEmptyOverviewText(lst);
    }

    return lst;
  }

  void setupEmptyOverviewText(List<Widget> lst) {
    if (SettingsUtil.devices.length > 0) {
      lst.add(Container(
          padding: EdgeInsets.all(5),
          child: Center(
              child: Text(
            "No overview added.\nUse + button to add overview for your device(s).",
            textAlign: TextAlign.center,
          ))));
    } else {
      lst.add(Container(
          padding: EdgeInsets.all(5),
          child: Center(
              child: Text(
            "No devices added.\nAdd them from menu option.",
            textAlign: TextAlign.center,
          ))));
    }
  }

  bool _refreshing = false;
  var _deviceAuthentication = Map<Device, AuthenticateReply>();
  var _deviceReply = Map<Device, List<CommandReplyBase>>();

  void refreshOverviews() {
    setState(() {
      _deviceAuthentication = Map<Device, AuthenticateReply>();
      _deviceReply = Map<Device, List<CommandReplyBase>>();
      _refreshing = true;
    });
  }

  getOverviewMainWidget(SelectedOverviewItem oi) {
    var ovi = OverviewItemManager.items[oi.overiviewItemGuid];
    var device = SettingsUtil.devices
        .firstWhere((x) => oi.deviceGuid == x.guid, orElse: () => null);
    if (device == null) return Text("Bad device");
    AuthenticateReply deviceAuthenticationStatus;
    if (_deviceAuthentication.containsKey(device))
      deviceAuthenticationStatus = _deviceAuthentication[device];
    List<CommandReplyBase> deviceReplies;
    if (_deviceReply.containsKey(device)) deviceReplies = _deviceReply[device];
    var inRefresh = _refreshing &&
        deviceReplies == null &&
        (deviceAuthenticationStatus == null ||
            deviceAuthenticationStatus.status == ReplyStatus.Ok);
    switch (ovi.type) {
      case OverviewItemType.SystemInfo:
        return SystemInfo(device, inRefresh, deviceAuthenticationStatus,
            deviceReplies, ovi, oi.guid, refreshOverviews);
        break;
      case OverviewItemType.NetworkStatus:
        return NetworkStatus(device, inRefresh, deviceAuthenticationStatus,
            deviceReplies, ovi, oi.guid, refreshOverviews);
        break;
      case OverviewItemType.NetworkTraffic:
        return NetworkTraffic(device, inRefresh, deviceAuthenticationStatus,
            deviceReplies, ovi, oi.guid, refreshOverviews);
        break;
      case OverviewItemType.WifiStatus:
        return WIFIStatus(device, inRefresh, deviceAuthenticationStatus,
            deviceReplies, ovi, oi.guid, refreshOverviews);
        break;
      case OverviewItemType.DHCPLeaseInfo:
        return DHCPLeaseStatus(device, inRefresh, deviceAuthenticationStatus,
            deviceReplies, ovi, oi.guid, refreshOverviews);
        break;
      case OverviewItemType.ActiveConnections:
        return ActiveConnections(device, inRefresh, deviceAuthenticationStatus,
            deviceReplies, ovi, oi.guid, refreshOverviews);
        break;
    }
  }
}

Future<List<String>> updateDevicesData(List<Device> devices) async {
  List<String> failedDevices = [];

  for (var d in devices) {
    var cli = OpenWRTClient(
        d, SettingsUtil.identities.firstWhere((i) => i.guid == d.identityGuid));

    try {
      await cli.authenticate().then((c) {
        cli.getData(c.authenticationCookie,
            [NetworkDeviceReply(ReplyStatus.Ok)]).then((res) {
          var interfaces =
              (res[0].data['result'] as List)[1] as Map<String, dynamic>;
          d.wifiDevices = interfaces.keys
              .where((i) => interfaces[i]['wireless'] == true)
              .toList();
          SettingsUtil.saveDevices();
        }).catchError((e) {
          failedDevices.add(d.displayName);
        });
      });
    } catch (e) {
      failedDevices.add(d.displayName);
    }
  }

  return Future.value(failedDevices);
}
