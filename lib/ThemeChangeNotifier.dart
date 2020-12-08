import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:openwrt_manager/settingsUtil.dart';

class ThemeChangeNotifier extends ChangeNotifier {

  toggleTheme() {
    if (hasListeners)
      notifyListeners();
  }

  ThemeData get currentTheme 
  {
    try
    {
        return (SettingsUtil.appSettings.darkTheme) ? ThemeData.dark() : ThemeData.light();
    }
    catch (e) 
    {
      log(e.toString());
      return ThemeData.light();
    }
  }
}