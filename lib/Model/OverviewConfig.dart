class OverviewConfig
{
  OverviewConfig()
  {
    data = Map<String,Map<String,dynamic>>();
  }
  Map<String,Map<String,dynamic>> data;
  Map toJson() => {
        'data': data,        
      };
      
      static OverviewConfig fromJson(Map<String, dynamic> json){
         var i = OverviewConfig();
         for (var guid in json["data"].keys)
         {
           i.data[guid] = Map<String,dynamic>();
           i.data[guid].addAll(json["data"][guid]);
         }         
         return i;         
       }
}