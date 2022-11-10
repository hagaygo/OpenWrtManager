import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class DeleteClientReply extends CommandReplyBase {
  DeleteClientReply(ReplyStatus status) : super(status);

  String interfaceName;
  String mac;

  @override
  List<dynamic> get commandParameters {
    List<dynamic> lst = [];
    lst.addAll(["hostapd." + interfaceName, "del_client"]);
    lst.add({"addr": mac, "deatuh": true, "reason": 1, "ban_time": 3000});
    return lst;
  }

  @override
  Object createReply(ReplyStatus status, Map<String, Object> data,
      {Device device}) {
    var i = DeleteClientReply(status);
    i.data = data;
    return i;
  }
}
