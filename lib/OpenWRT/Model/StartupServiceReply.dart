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
