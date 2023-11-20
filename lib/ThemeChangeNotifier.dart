import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:openwrt_manager/settingsUtil.dart';

class ThemeChangeNotifier extends ChangeNotifier {
  toggleTheme() {
    if (hasListeners) notifyListeners();
  }

  ThemeData get currentTheme {
    try {
      var userMat3 = false;
      return (SettingsUtil.appSettings!.darkTheme)
          ? ThemeData.dark(useMaterial3: userMat3)
          : ThemeData.light(useMaterial3: userMat3);
    } catch (e) {
      log(e.toString());
      return ThemeData.light();
    }
  }
}
