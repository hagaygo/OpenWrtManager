import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LogViewerForm extends StatefulWidget {
  LogViewerForm(this.getContent) : super();

  final Future<List<String>> Function() getContent;

  LogViewerFormState _state;

  @override
  State<StatefulWidget> createState() {
    _state = LogViewerFormState(getContent);
    return _state;
  }

  void refresh() {
    _state.refresh();
  }
}

class LogViewerFormState extends State<LogViewerForm> {
  Future<List<Widget>> getLines() async {
    var lines = await getContent();
    List<Widget> lst = [];
    for (var line in lines.reversed) {
      lst.add(Container(padding: EdgeInsets.all(2), child: Text(line.trim(), textScaleFactor: 0.8)));
    }

    return lst;
  }

  final Future<List<String>> Function() getContent;

  LogViewerFormState(this.getContent) {
    refresh();
  }

  void refresh() {
    if (_initialLinesLoaded) {
      setState(() {
        _initialLinesLoaded = false;
      });
    } else
      _initialLinesLoaded = false;
    getLines().then((dataLines) => {setLines(dataLines)});
  }

  List<Widget> _lines = [];
  bool _initialLinesLoaded = false;

  void setLines(List<Widget> lines) {
    setState(() {
      _lines = lines;
      _initialLinesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.all(5),
          child: _initialLinesLoaded
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _lines))
              : Container(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Loading...")]),
                ),
        ));
  }
}
