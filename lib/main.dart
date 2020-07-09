import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Page/mainPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return FeatureDiscovery(
      child: MaterialApp(
        title: 'OpenWRT Manager',
        theme: ThemeData(        
          primarySwatch: Colors.blue,
        ),
        home: MainPage(),
      ),
    );
  }
}