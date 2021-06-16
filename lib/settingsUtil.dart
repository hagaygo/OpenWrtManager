import 'dart:convert';
import 'dart:io';

import 'package:openwrt_manager/Model/Identity.dart';
import 'package:openwrt_manager/Model/OverviewConfig.dart';
import 'package:openwrt_manager/Model/SelectedOverviewItem.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:path_provider/path_provider.dart';

import 'Model/AppSetting.dart';

class SettingsUtil {
  static final SettingsUtil _singleton = SettingsUtil._internal();

  factory SettingsUtil() {
    return _singleton;
  }

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  SettingsUtil._internal();

// overview configs

static OverviewConfig _overviewConfig;

  static OverviewConfig get overviewConfig {
    return _overviewConfig;
  }

  static Future<File> get overviewConfigFile async {
    final path = await localPath;
    var filename = '$path/overviewConfig.json';
    return File(filename);
  }

  static Future<bool> loadOverviewConfig() async {
    await overviewConfigFile.then((f) {
      if (f.existsSync()) {
        String data = f.readAsStringSync();
        _overviewConfig = OverviewConfig.fromJson(json.decode(data));
        return Future.value(true);
      }
      _overviewConfig = OverviewConfig();
      return Future.value(false);
    });
    return Future.value(false);
  }

  static void saveOverviewConfig() {
    var json = jsonEncode(overviewConfig);
    overviewConfigFile.then((f) => {f.writeAsString(json)});
  }

// app settings

  static AppSetting _appSetting;

  static AppSetting get appSettings {
    return _appSetting;
  }

  static Future<File> get appSettingsFile async {
    final path = await localPath;
    var filename = '$path/appSetting.json';
    return File(filename);
  }

  static Future<bool> loadAppSettings() async {
    try
    {
    await appSettingsFile.then((f) {
      if (f.existsSync()) {
        String data = f.readAsStringSync();
        _appSetting = AppSetting.fromJson(json.decode(data));
        return Future.value(true);
      }
      _appSetting = AppSetting();
      return Future.value(false);
    });
    return Future.value(false);
    }
    catch (e)
    {
      _appSetting = AppSetting();
      return Future.value(false);
    }
  }

  static void saveAppSettings() {
    var json = jsonEncode(appSettings);
    appSettingsFile.then((f) => {f.writeAsString(json)});
  }

// selected overview items

  static Future<File> get overviewsFile async {
    final path = await localPath;
    var filename = '$path/overviews.json';
    return File(filename);
  }

  static List<SelectedOverviewItem> _overviews;

  static List<SelectedOverviewItem> get overviews {
    if (_overviews == null) {
      _overviews = [];
      loadOverviews();
    }
    return _overviews;
  }

  static Future<List<SelectedOverviewItem>> getOverviews() async {
    if (_overviews == null) {
      await loadOverviews();
    }
    return _overviews;
  }

  static Future loadOverviews() async {
    await overviewsFile.then((f) {
      if (f.existsSync()) {
        String data = f.readAsStringSync();
        List parsedList = json.decode(data);
        _overviews = parsedList
            .map((val) => SelectedOverviewItem.fromJson(val))
            .toList();
      }
    });
  }

  static void saveOverviews() {
    var json = jsonEncode(SettingsUtil._overviews);
    overviewsFile.then((f) => {f.writeAsString(json)});
  }

// devices

  static Future<File> get devicesFile async {
    final path = await localPath;
    var filename = '$path/devices.json';
    return File(filename);
  }

  static List<Device> _devices;

  static List<Device> get devices {
    if (_devices == null) {
      _devices = [];
      loadDevices();
    }
    return _devices;
  }

  static Future<List<Device>> getDevices() async {
    if (_devices == null) {
      await loadDevices();
    }
    return _devices;
  }

  static Future loadDevices() async {
    devicesFile.then((f) {
      if (f.existsSync()) {
        String data = f.readAsStringSync();
        List parsedList = json.decode(data);
        _devices = parsedList.map((val) => Device.fromJson(val)).toList();
      }
    });
  }

  static void saveDevices() {
    var json = jsonEncode(SettingsUtil.devices);
    devicesFile.then((f) => {f.writeAsString(json)});
  }

// identities
  static Future<File> get identitiesFile async {
    final path = await localPath;
    var filename = '$path/identities.json';
    return File(filename);
  }

  static List<Identity> _identitites;

  static List<Identity> get identities {
    if (_identitites == null) {
      _identitites = [];
      loadIdentities();
    }
    return _identitites;
  }

  static Future<List<Identity>> getIdentities() async {
    if (_identitites == null) {
      await loadIdentities();
    }
    return _identitites;
  }

  static Future loadIdentities() async {
    identitiesFile.then((f) {
      if (f.existsSync()) {
        String data = f.readAsStringSync();
        List parsedList = json.decode(data);
        _identitites = parsedList.map((val) => Identity.fromJson(val)).toList();
      }
    });
  }

  static void saveIdentities() {
    var json = jsonEncode(SettingsUtil.identities);
    identitiesFile.then((f) => {f.writeAsString(json)});
  }
}
