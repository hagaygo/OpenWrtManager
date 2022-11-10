import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class RRDNSReply extends CommandReplyBase {
  RRDNSReply(ReplyStatus status) : super(status);

  List<String> ipList;
  String mac;

  @override
  List<dynamic> get commandParameters => ["network.rrdns", "lookup", {"addrs" : ipList}];

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data,
      {Device device}) {
    var i = RRDNSReply(status);
    i.data = data;
    return i;
  }
}