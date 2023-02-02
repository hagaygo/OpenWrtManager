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

  List<String> getCurrentLines() {
    return _state._currentLines;
  }

  void scroll(double y, double x) {
    _state.verticalScrollController.animateTo(y, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  void refresh() {
    _state.refresh();
  }
}

class LogViewerFormState extends State<LogViewerForm> {
  List<int> _foundTextLines = [];

  Future<List<Widget>> getLines() async {
    if (_currentLines == null) _currentLines = await getContent();
    List<Widget> lst = [];

    var textSpans = <TextSpan>[];
    int counter = 0;
    for (var line in _currentLines) {
      if (_searchText != null && _searchText.length > 0 && line.contains(_searchText)) {
        textSpans.add(TextSpan(text: line.substring(0, line.indexOf(_searchText))));
        var ts = TextSpan(text: _searchText, style: TextStyle(backgroundColor: Colors.yellow));
        textSpans.add(ts);
        textSpans.add(TextSpan(text: line.substring(line.indexOf(_searchText) + _searchText.length)));
        _foundTextLines.add(counter);
      } else
        textSpans.add(TextSpan(text: line));
      textSpans.add(TextSpan(text: "\n"));
      counter++;
    }
    lst.add(Container(
        padding: EdgeInsets.all(2),
        child: SelectableText.rich(
          TextSpan(children: textSpans),
          textScaleFactor: 0.8,
        )));
    return lst;
  }

  final Future<List<String>> Function() getContent;
  List<String> _currentLines;
  String _searchText;

  LogViewerFormState(this.getContent) {
    refresh();
  }

  void refresh() {
    _currentLines = null;
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

  ScrollController verticalScrollController = ScrollController();
  ScrollController horizontalScrollController = ScrollController();
  String _lastSearchText;
  int _lastFoundIndex = 0;

  final searchTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.all(2),
            child: Row(
              children: [
                Text("Search Text"),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child:
                            TextField(controller: searchTextController, decoration: InputDecoration(isDense: true)))),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _searchText = searchTextController.text;
                        getLines().then((l) {
                          _lines = l;
                          if (_foundTextLines.length > 0) {
                            verticalScrollController.jumpTo((_foundTextLines[0] * 12).toDouble());
                          }
                        });
                      });
                    },
                    icon: Icon(Icons.search))
              ],
            )),
        Expanded(
          child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: _initialLinesLoaded
                        ? SingleChildScrollView(
                            controller: horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _lines))
                        : Container(
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Loading...")]),
                          ),
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
