import 'package:openwrt_manager/OpenWrt/Model/ActiveConnectionsReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/DHCPLeaseReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/HostHintReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/NetworkDeviceReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/NetworkInterfaceReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/ReplyBase.dart';
import 'package:openwrt_manager/OpenWrt/Model/SystemBoardReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/SystemInfoReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/WifiAssociatedClientReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/WirelessDeviceReply.dart';

enum OverviewItemType
{
  SystemInfo,
  NetworkStatus,
  NetworkTraffic,
  WifiStatus,
  DHCPLeaseInfo,
  ActiveConnections
}

class OverviewItem
{
  OverviewItem(this.displayName, this.type, this.commands);

  final String displayName;  
  final OverviewItemType type;
  final List<CommandReplyBase> commands;
}
class OverviewItemManager
{
  static Map<String,OverviewItem>  items =
  {    
    // do not change guids , they are stored on app device configuration files    
    '1bad2951-ee53-4ee4-95b6-ced2ed816b32' : OverviewItem("System Info", OverviewItemType.SystemInfo , [SystemInfoReply(ReplyStatus.Ok), SystemBoardReply(ReplyStatus.Ok),DHCPLeaseReply(ReplyStatus.Ok)]),
    '96630e65-4da2-4d1b-81d1-7f6716d0d0cf' : OverviewItem("Network Status", OverviewItemType.NetworkStatus , [NetworkInterfaceReply(ReplyStatus.Ok)]),
    'db7b2fe8-cf9b-4a01-bce4-c56e293d458a' : OverviewItem("Network Traffic", OverviewItemType.NetworkTraffic , [NetworkDeviceReply(ReplyStatus.Ok),NetworkInterfaceReply(ReplyStatus.Ok)]),
    '25bafd01-816f-4d76-a88c-ef49a6120fa2' : OverviewItem("WIFI Status", OverviewItemType.WifiStatus , [HostHintReply(ReplyStatus.Ok),WirelessDeviceReply(ReplyStatus.Ok),WifiAssociatedClientReply(ReplyStatus.Ok)]),    
    '892fdf21-0cce-4e58-b1d9-c35e456fdf3d' : OverviewItem("DHCP Leases", OverviewItemType.DHCPLeaseInfo , [DHCPLeaseReply(ReplyStatus.Ok)]),    
    '9aef9078-a8a6-4fdb-8b65-b6e2e8dd55e1' : OverviewItem("Active Connections", OverviewItemType.ActiveConnections , [ActiveConnectionsReply(ReplyStatus.Ok)]),
  };
}