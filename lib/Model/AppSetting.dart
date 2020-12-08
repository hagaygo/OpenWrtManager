class AppSetting 
{
  bool autoRefresh = false;
  int autoRefreshInterval = 10;
  bool darkTheme = false;

  Map toJson() => {
        'autoRefresh': autoRefresh,
        'autoRefreshInterval': autoRefreshInterval,        
        'darkTheme' : darkTheme
      };
      
      static AppSetting fromJson(Map<String, dynamic> json){
         var i = AppSetting();
         i.autoRefresh = json['autoRefresh'] ?? false;
         i.autoRefreshInterval = json['autoRefreshInterval'] ?? 5;         
         i.darkTheme = json['darkTheme'] ?? false;
         return i;         
       }
}