import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class NetworkDeviceReply extends CommandReplyBase {
  NetworkDeviceReply(ReplyStatus status) : super(status);

  @override
  List<String> get commandParameters => ["luci-rpc", "getNetworkDevices"];

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data,{Device device}) {
    var i = NetworkDeviceReply(status);
    i.data = data;
    return i;
  }
}
