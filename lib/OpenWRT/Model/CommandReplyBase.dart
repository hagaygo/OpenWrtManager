import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';

abstract class CommandReplyBase extends ReplyBase
{  
  
  int _replyTimeStamp;

  int get replyTimeStamp
  {
    return _replyTimeStamp;
  }

  CommandReplyBase(ReplyStatus status) : super(status)
  {
      _replyTimeStamp = DateTime.now().millisecondsSinceEpoch;
  }
  
  List<dynamic> get commandParameters; 

  Map<String, Object> data;

  Object createReply(ReplyStatus status,Map<String,Object> data, {Device device});
}