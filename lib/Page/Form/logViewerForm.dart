import 'dart:convert';

import 'package:flutter/cupertino.dart';

class LogViewerForm extends StatefulWidget {
  const LogViewerForm(this.content) : super();

  final String content;

  @override
  State<StatefulWidget> createState() {
    var s = LogViewerFormState();
    return s;
  }
}

final ScrollController _controller = ScrollController();

List<Widget> getLines(String text) {
  List<Widget> lst = [];
  for (var line in new LineSplitter().convert(text)) {
    lst.add(Text(line.trim(), textScaleFactor: 0.8));
  }

  return lst;
}

class LogViewerFormState extends State<LogViewerForm> {
  
  bool _needsScroll = true;
  
  @override
  Widget build(BuildContext context) {
    if (_needsScroll) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.jumpTo(_controller.position.maxScrollExtent));
    _needsScroll = false;
  }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _controller,
      child: Container(
        child: SingleChildScrollView(          
            scrollDirection: Axis.horizontal,          
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: getLines(widget.content))),
      ),
    );
  }  
}