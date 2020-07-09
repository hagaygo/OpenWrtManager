class AppSetting 
{
  bool autoRefresh = false;
  int autoRefreshInterval = 10;

  Map toJson() => {
        'autoRefresh': autoRefresh,
        'autoRefreshInterval': autoRefreshInterval,        
      };
      
      static AppSetting fromJson(Map<String, dynamic> json){
         var i = AppSetting();
         i.autoRefresh = json['autoRefresh'];
         i.autoRefreshInterval = json['autoRefreshInterval'];         
         return i;         
       }
}