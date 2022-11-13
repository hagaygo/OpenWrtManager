import 'package:openwrt_manager/Model/device.dart';
import 'CommandReplyBase.dart';

class DHCPLeaseReply extends CommandReplyBase {
  DHCPLeaseReply(status) : super(status);

  @override
  List<String> get commandParameters => ["luci-rpc", "getDHCPLeases"];
 
  @override
  DHCPLeaseReply createReply(status, Map<String, Object> data, {Device device}) {
    var i = DHCPLeaseReply(status);
    i.data = data;
    return i;
  }
}