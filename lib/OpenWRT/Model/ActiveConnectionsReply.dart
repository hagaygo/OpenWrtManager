import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class ActiveConnectionsReply extends CommandReplyBase {
  ActiveConnectionsReply(ReplyStatus status) : super(status);

  @override
  List<String> get commandParameters => ["luci", "getConntrackList"];

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data,{Device device}) {
    var i = ActiveConnectionsReply(status);
    i.data = data;
    return i;
  }
}
