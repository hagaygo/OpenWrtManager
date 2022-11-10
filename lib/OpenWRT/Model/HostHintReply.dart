import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class HostHintReply extends CommandReplyBase {
  HostHintReply(ReplyStatus status) : super(status);

  @override
  List<String> get commandParameters => ["luci-rpc", "getHostHints"];

  @override
  HostHintReply createReply(ReplyStatus status, Map<String, Object> data, {Device device}) {
    var i = HostHintReply(status);
    i.data = data;
    return i;
  }
}
