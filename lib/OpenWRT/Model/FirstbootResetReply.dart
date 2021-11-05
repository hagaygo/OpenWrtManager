import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWRT/Model/ReplyBase.dart';
import 'CommandReplyBase.dart';

class FirstbootResetReply extends CommandReplyBase {
  FirstbootResetReply(ReplyStatus status) : super(status);

  @override
  List<dynamic> get commandParameters {
    List<dynamic> lst = [];
    lst.addAll(["file", "exec"]);
    lst.add({
      'command': '/sbin/firstboot',
      'params': ['-r', '-y']
    });
    return lst;
  }

  @override
  FirstbootResetReply createReply(ReplyStatus status, Map<String, Object> data,
      {Device device}) {
    var i = FirstbootResetReply(status);
    i.data = data;
    return i;
  }
}
