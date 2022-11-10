import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'CommandReplyBase.dart';

class NetworkInterfaceReply extends CommandReplyBase {
  NetworkInterfaceReply(ReplyStatus status) : super(status);

  @override
  List<String> get commandParameters => ["network.interface", "dump"];

  @override
  NetworkInterfaceReply createReply(ReplyStatus status, Map<String, Object> data, {Device device}) {
    var i = NetworkInterfaceReply(status);
    i.data = data;
    return i;
  }
}
