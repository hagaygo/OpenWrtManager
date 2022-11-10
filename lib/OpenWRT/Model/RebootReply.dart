import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'CommandReplyBase.dart';

class RebootReply extends CommandReplyBase {
  RebootReply(ReplyStatus status) : super(status);

  @override
  List<dynamic> get commandParameters {
    List<dynamic> lst = [];
    lst.addAll(["file", "exec"]);
    lst.add({'command': '/sbin/reboot', 'params': null, 'env': null});
    return lst;
  }

  @override
  RebootReply createReply(ReplyStatus status, Map<String, Object> data, {Device device}) {
    var i = RebootReply(status);
    i.data = data;
    return i;
  }
}
