import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'CommandReplyBase.dart';

class SystemLogReply extends CommandReplyBase {
  SystemLogReply(ReplyStatus status) : super(status);
  

  @override
  List<dynamic> get commandParameters {
    List<dynamic> lst = [];
    lst.addAll(["log", "read"]);
    lst.add({'lines': 1000, 'oneshot': true , 'stream' : false});
    return lst;
  }

  @override
  SystemLogReply createReply(ReplyStatus status, Map<String, dynamic>? data, {Device? device}) {
    var i = SystemLogReply(status);
    i.data = data;
    return i;
  }
}
