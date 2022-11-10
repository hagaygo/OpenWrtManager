import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwrt_manager/Model/device.dart';
import 'package:openwrt_manager/Model/dhcpLease.dart';
import 'package:openwrt_manager/OpenWrt/Model/AuthenticateReply.dart';
import 'package:openwrt_manager/OpenWrt/Model/CommandReplyBase.dart';
import 'package:openwrt_manager/Overview/OverviewItemManager.dart';
import 'package:openwrt_manager/Overview/OverviewWidgetBase.dart';
import 'package:openwrt_manager/dataCache.dart';

class DHCPLeaseStatus extends OverviewWidgetBase {
  DHCPLeaseStatus(Device device, bool loading, AuthenticateReply authenticationStatus, List<CommandReplyBase> replies,
      OverviewItem item, String overviewItemGuid, Function doOverviewRefresh)
      : super(device, loading, authenticationStatus, replies, item, overviewItemGuid, doOverviewRefresh);

  @override
  DHCPLeaseStatusState createState() => DHCPLeaseStatusState();
}

class DHCPLeaseStatusState extends OverviewWidgetBaseState with TickerProviderStateMixin {

  static List<DHCPLease> getDHCPLeaseListFromJSON(dynamic data)
  {
    List<DHCPLease> dhcpLeaseList = [];
    for (var l in data) {
      var i = DHCPLease();
      try
      {
      i.expires = l["expires"];
      } catch(e) {
        i.expires = -1;
      }
      i.macAddress = l["macaddr"];
      i.ipAddress = l["ipaddr"];
      i.hostName = l["hostname"];
      dhcpLeaseList.add(i);
    }

    dhcpLeaseList.sort((a,b) => b.expires - a.expires);
    return dhcpLeaseList;
  }

  @override
  Widget get myWidget {
    var infoData = data[0][1];    

    var dhcpLeaseList  = getDHCPLeaseListFromJSON(infoData["dhcp_leases"]);    
    DataCache.updateData(dhcpLeaseList);

    List<Widget> rows = [];
    if (dhcpLeaseList.length == 0) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text("No lease data found.")],));
    } else
      for (var d in dhcpLeaseList) {
        var r = 
        Container(          
          padding: EdgeInsets.fromLTRB(5, 0, 5, 15),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
              Expanded(child: Text(d.macAddress)),
              Expanded(child: Align(alignment: Alignment.center, child: Text(d.ipAddress)))
              ],),
              SizedBox(height: 5),
              Row(children: <Widget>[
              Expanded(child: Text(d.expiresText)),
              Expanded(child: Align(alignment: Alignment.center, child: Text(d.hostName)))
              ],)
            ],
          ));
        rows.add(r);
      }

    return Column(
      children: rows,
    );
  }
}
