import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openwrt_manager/ThemeChangeNotifier.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:provider/provider.dart';
import 'Page/mainPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsUtil.loadAppSettings().then((x) {
    runApp(
      ChangeNotifierProvider<ThemeChangeNotifier>(
        create: (BuildContext context) => ThemeChangeNotifier(),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FeatureDiscovery(
      child: MaterialApp(
        title: 'OpenWrt Manager',
        theme: Provider.of<ThemeChangeNotifier>(context, listen: true).currentTheme,
        home: MainPage(),
      ),
    );
  }
}
