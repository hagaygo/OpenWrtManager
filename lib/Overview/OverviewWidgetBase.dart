import 'package:flutter/material.dart';
import 'package:openwrt_manager/Dialog/Dialogs.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/OpenWrtClient.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Page/Form/OverviewConfigForm.dart';
import 'package:openwrt_manager/settingsUtil.dart';
import 'package:flutter/services.dart';

abstract class OverviewWidgetBase extends StatefulWidget {
  final Device device;
  final bool loading;
  final AuthenticateReply authenticationStatus;
  final List<CommandReplyBase> replies;
  final OverviewItem item;
  final String overviewItemGuid;
  final Function doOverviewRefresh;
  OverviewWidgetBase(this.device, this.loading, this.authenticationStatus,
      this.replies, this.item, this.overviewItemGuid, this.doOverviewRefresh);

  List<Type> get replyTypes => item.commands.map((x) => x.runtimeType).toList();
}

abstract class OverviewWidgetBaseState extends State<OverviewWidgetBase> {
  static const iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 230, 230, 230)),
        borderRadius: new BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Column(children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Row(
                      children: <Widget>[
                        Visibility(
                          visible: widget.loading,
                          child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              width: iconSize,
                              height: iconSize,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(10)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 255, 255, 0),
                                        Color.fromARGB(255, 128, 128, 0)
                                      ],
                                      tileMode: TileMode.repeated,
                                    )),
                              )),
                        ),
                        Visibility(
                          visible: !widget.loading,
                          child: Container(
                            decoration: new BoxDecoration(
                              gradient: getOverviewStatusOk()
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 0, 255, 0),
                                        Color.fromARGB(255, 0, 50, 0)
                                      ],
                                      tileMode: TileMode.repeated,
                                    )
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromARGB(255, 255, 0, 0),
                                        Color.fromARGB(255, 100, 0, 0)
                                      ],
                                    ),
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(10)),
                            ),
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            height: iconSize,
                            width: iconSize,
                          ),
                        ),
                        Expanded(child: Container()),
                        Text(
                          "${widget.device.displayName} ${widget.item.displayName}",
                        ),
                        Expanded(child: Container()),
                        Container(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Visibility(
                                  visible: supportsExpand && !noDataAtAll,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          expanded = !expanded;
                                        });
                                      },
                                      child: Container(
                                          padding: EdgeInsets.zero,
                                          width: iconSize * 1.5,
                                          height: iconSize * 1.5,
                                          child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: expanded
                                                  ? Icon(Icons.expand_less)
                                                  : Icon(Icons.expand_more))))),
                              Visibility(
                                  visible: supportsConfig,
                                  child: InkWell(
                                    onTap: () {
                                      showConfig();
                                    },
                                    child: Container(
                                        width: iconSize * 1.5,
                                        height: iconSize * 1.5,
                                        child: FittedBox(
                                            child: Icon(Icons.settings))),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )))
          ],
        ),
        Container(decoration: BoxDecoration(), child: getWidget())
      ]),
    );
  }

  @protected
  List<Widget> getRows(Map<dynamic, dynamic> data,
      {double firstRowWidth = 120}) {
    List<Widget> lst = [];
    for (var k in data.keys) {
      var r = Container(
          padding: EdgeInsets.all(2),
          child: Row(children: <Widget>[
            Container(
              width: firstRowWidth,
              child: k is String ? Text(k) : k,
            ),
            data[k] is String ? Flexible(child: Text(data[k] ?? "")) : data[k]
          ]));
      lst.add(r);
    }
    return lst;
  }

  @protected
  List<dynamic> oldData;

  @protected
  bool expanded = false;

  bool get supportsExpand {
    return false;
  }

  bool get supportsConfig {
    return false;
  }

  List<dynamic> get data {
    var rp =
        widget.replies?.where((x) => widget.replyTypes.contains(x.runtimeType));
    if (rp != null && rp.length > 0) {
      List<dynamic> orderdList = [];
      for (var r in widget
          .replyTypes) // pass reply data in the order of replyTypes property
      {
        var f = rp.where((x) => x.runtimeType == r);
        orderdList.addAll(f);
      }

      try {
        oldData = orderdList.map((x) => x.data["result"]).toList();
      } catch (e) {}
      return oldData;
    }
    return oldData;
  }

  Widget get myWidget;

  @protected
  bool badReplyData = false;

  int lastReplyTimeStamp = 0;

  bool get noDataAtAll {
    return oldData == null && data == null;
  }

  bool _gotNewData;

  @protected
  bool get gotNewData {
    return _gotNewData;
  }

  int get currentReplyTimeStamp {
    if (widget.replies == null || widget.replies.length == 0) return 0;
    return widget.replies.first.replyTimeStamp;
  }

  Widget _getMyWidget() {
    try {
      _gotNewData = currentReplyTimeStamp > 0 &&
          currentReplyTimeStamp != lastReplyTimeStamp;
      var w = myWidget;
      lastReplyTimeStamp = currentReplyTimeStamp;
      _gotNewData = false;
      badReplyData = false;
      return w;
    } catch (e, stackTrace) {
      badReplyData = true;
      return generateErrorText(
          e, stackTrace, "Error parsing reply from device");
    }
  }

  Column generateErrorText(e, StackTrace stackTrace, String text) {
    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Expanded(child: Text(text))]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
            child: Text("Copy Debug Trace To Clipboard"),
            onPressed: () async {
              Clipboard.setData(ClipboardData(
                  text: e.toString() +
                      "\n" +
                      stackTrace.toString() +
                      "\n" +
                      OpenWrtClient.lastJSONRequest +
                      "\n" +
                      OpenWrtClient.lastJSONResponse));
            })
      ]),
    ]);
  }

  Widget getWidget() {
    var errorText = "";
    if (widget.replies != null && widget.replies.length > 0) {
      if (widget.replies.any((x) => x.status == ReplyStatus.NotFound))
        errorText =
            "Authentication is successful but command not found on device.\nplease verify your device OpenWrt version is supported by this app.";
      else if (widget.replies.any((x) => x.status != ReplyStatus.Ok))
        errorText =
            "Authentication is successful but error response returned from device.\nplease verify your device OpenWrt version is supported by this app.";
    }
    if (errorText == "") {
      switch (widget.authenticationStatus?.status) {
        case ReplyStatus.Timeout:
          errorText = "Connection Timeout";
          break;
        case ReplyStatus.Forbidden:
          errorText = "Authentication Failed";
          break;
        case ReplyStatus.Error:
          errorText = "Error";
          break;
        case ReplyStatus.HandshakeError:
          errorText = "Secure connection error , bad certificate ?";
          break;
        case ReplyStatus.NotFound:
          errorText =
              "Url not found , check if your openwrt version is supported";
          break;
        default:
      }
    }

    return Column(children: <Widget>[
      Visibility(
          visible: !(noDataAtAll),
          child: data == null ? Text("No Data Available") : _getMyWidget()),
      Row(
        children: <Widget>[
          Expanded(
              child: Visibility(
            child: Text("$errorText"),
            visible: noDataAtAll,
          )),
        ],
      )
    ]);
  }

  bool getOverviewStatusOk() {
    return ((widget.authenticationStatus?.status == ReplyStatus.Ok ||
            (widget.authenticationStatus == null && oldData != null)) &&
        !badReplyData);
  }

  Map<String, dynamic> get configData {
    return SettingsUtil.overviewConfig.data[widget.overviewItemGuid];
  }

  @protected
  List<Map<String, dynamic>> get configItems {
    return null;
  }

  void showConfig() {
    if (configItems == null || configItems.length == 0)
      showConfigAlert();
    else
      Dialogs.showMyDialog(
              context,
              OverviewConfigForm(configItems, widget.device, widget.item,
                  widget.overviewItemGuid))
          .then((_) => setState(() {}));
  }

  void showConfigAlert() {
    Dialogs.simpleAlert(context, "Error", "No data for configuration");
  }
}
