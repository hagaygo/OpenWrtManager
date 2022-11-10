import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class WirelessDeviceReply extends CommandReplyBase
{
  WirelessDeviceReply(ReplyStatus status) : super(status);

  @override  
  List<String> get commandParameters => ["luci-rpc","getWirelessDevices"];  

  @override
  WirelessDeviceReply createReply(ReplyStatus status, Map<String, Object> data,  {Device device}) {
    var i = WirelessDeviceReply(status);
    i.data = data;
    return i;
  }  
}
