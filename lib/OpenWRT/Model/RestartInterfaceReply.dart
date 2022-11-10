import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class RestartInterfaceReply extends CommandReplyBase {
  RestartInterfaceReply(ReplyStatus status) : super(status);

  String interfaceName;
  String mac;

  @override
  List<dynamic> get commandParameters {
    List<dynamic> lst = [];
    lst.addAll(["file", "exec"]);
    lst.add({'command': '/sbin/ifup', 'params': [interfaceName], 'env': null});
    return lst;
  }

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data,
      {Device device}) {
    var i = RestartInterfaceReply(status);
    i.data = data;
    return i;
  }
}