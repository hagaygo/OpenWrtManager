class SelectedOverviewItem 
{
  String guid;
  String overiviewItemGuid;
  String deviceGuid;

  Map toJson() => {        
        'guid': guid,
        'overiviewItemGuid': overiviewItemGuid,
        'deviceGuid': deviceGuid,
      };
      
      static SelectedOverviewItem fromJson(Map<String, dynamic> json){
         var i = SelectedOverviewItem();
         i.guid = json['guid'].toString();
         i.overiviewItemGuid = json['overiviewItemGuid'].toString();
         i.deviceGuid = json['deviceGuid'].toString();         
         return i;         
       }
}