import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

class SystemInfoReply extends CommandReplyBase
{
  SystemInfoReply(ReplyStatus status) : super(status);

  @override  
  List<String> get commandParameters => ["system","info"];  

  @override
  SystemInfoReply createReply(ReplyStatus status, Map<String, Object> data,  {Device device}) {
    var i = SystemInfoReply(status);
    i.data = data;
    return i;
  }
}