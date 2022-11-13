import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class StartupServiceReply extends CommandReplyBase {
  StartupServiceReply(ReplyStatus status) : super(status);

  @override
  List<String> get commandParameters => ["luci", "getInitList"];

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data, {Device device}) {
    var i = StartupServiceReply(status);
    i.data = data;
    return i;
  }
}

class StartupServiceCommandReply extends CommandReplyBase {
  StartupServiceCommandReply(ReplyStatus status, this.name, this.action) : super(status);

  final String name;
  final String action;

  @override
  List<dynamic> get commandParameters {
    List<dynamic> lst = [];
    lst.addAll(["luci", "setInitAction"]);
    lst.add({'name': name, 'action': action});
    return lst;
  }

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data, {Device device}) {
    var i = StartupServiceReply(status);
    i.data = data;
    return i;
  }
}
