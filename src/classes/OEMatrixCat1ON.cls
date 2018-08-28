@isTest(SeeAllData=true)
global with sharing class OEMatrixCat1ON {
  public OEMatrixCat1ON() {}
@RemoteAction
global static List<String> getCat(String soid) {
    List<String> result = new List<String>();
    result.add(JSON.serialize( [SELECT Id, Name, PBSI__Item_Group_Code__c FROM PBSI__PBSI_Item_Group__c] ));
    result.add(JSON.serialize( [SELECT Id, Name, European_Size__c, MM__c, Style_Year__c, UK_Size__c, US_Men__c, US_Women__c, US_Size__c FROM Sizes__c] ));
    result.add(JSON.serialize( [SELECT Id, Name, Size__c, PBSI__Item_Group__c, Fabric_Code__c, Fabric_Description__c, PBSI__description__c, Style_Year__c, PBSI__salesprice__c FROM PBSI__PBSI_Item__c WHERE Size__c != null] ));
    result.add(JSON.serialize( [SELECT Id, Name, Fabric_Description__c FROM Fabric__c] )); 
    result.add(JSON.serialize( [SELECT Id, Name FROM Style_Year__c] )); 
    PBSI__PBSI_Sales_Order__c[] oeorder = [SELECT Id, Name, PBSI__Status__c,PBSI__From_Location__c,PBSI__Customer__r.CurrencyIsoCode,PBSI__Customer__r.PBSI__Account_Group__c FROM PBSI__PBSI_Sales_Order__c WHERE Id=:soid];
    result.add(JSON.serialize( oeorder ));
    result.add(JSON.serialize( [SELECT Id, Name, PBSI__Quantity_Needed__c, PBSI__Item__c, PBSI__Quantity_Picked__c, PBSI__Price__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c=:soid] ));
    result.add(PBSI__PBSI_Item__c.PBSI__Quantity_on_Hand__c.getDescribe().getLabel() );
    result.add(PBSI__PBSI_Item__c.PBSI__salesprice__c.getDescribe().getLabel() );
    result.add(JSON.serialize(UserInfo.getLanguage()));
    result.add( System.Label.OEM_Save_btn );
    result.add( System.Label.OEM_Cancel_btn );
    result.add( System.Label.OEM_Title );
    if(null==oeorder[0].PBSI__Customer__r.CurrencyIsoCode || null==oeorder[0].PBSI__Customer__r.PBSI__Account_Group__c) result.add(JSON.serialize( new List<PBSI__Trade_Agreement__c>() ));
    else result.add(JSON.serialize( [SELECT Id, Name,CurrencyIsoCode, PBSI__TPrice__c,PBSI__Item_Group_Selection__c,PBSI__Date_From__c FROM PBSI__Trade_Agreement__c WHERE IsCurrent__c='Y' AND PBSI__Applies_To__c='Sales Order' AND PBSI__Item_Group_Selection__c!=null AND PBSI__Account_Group_Selection__c=:oeorder[0].PBSI__Customer__r.PBSI__Account_Group__c AND CurrencyIsoCode=:oeorder[0].PBSI__Customer__r.CurrencyIsoCode ORDER BY PBSI__Date_From__c] ));
    return result;
}
@RemoteAction
global static List<String> getItemStat(String itmid,Id frLocat) {
    List<String> result = new List<String>();
    result.add(JSON.serialize( [SELECT Id, Name, PBSI__description__c, PBSI__Quantity_on_Hand__c FROM PBSI__PBSI_Item__c WHERE Id=:itmid] ));
     Integer tqal = 0;
    if(frLocat!=null) {
      PBSI__PBSI_Inventory__c[] qsal = [SELECT Id,PBSI__qty__c FROM PBSI__PBSI_Inventory__c WHERE PBSI__qty__c>0 AND PBSI__item_lookup__c=:itmid AND PBSI__location_lookup__c=:frLocat];
      for(PBSI__PBSI_Inventory__c qal:qsal) tqal = tqal+ qal.PBSI__qty__c.intValue();
    }
    result.add(JSON.serialize( tqal ));
    return result;
}
@RemoteAction
global static List<String> addOrderLines(String soid,List<String> ordrList) {
    PBSI__PBSI_Sales_Order__c var_SalesOrder = [SELECT Id, PBSI__From_Location__c FROM PBSI__PBSI_Sales_Order__c WHERE Id = :soid LIMIT 1];
    List<PBSI__PBSI_Sales_Order_Line__c> sols = new List<PBSI__PBSI_Sales_Order_Line__c>();
  for(String ors : ordrList) {
    Map<String,String> kvps = (Map<String,String>)JSON.deserialize(ors,Map<String,String>.class);
      PBSI__PBSI_Sales_Order_Line__c sol = new PBSI__PBSI_Sales_Order_Line__c();
      sol.PBSI__Sales_Order__c = soid;
      sol.PBSI__Item__c = kvps.get('PBSI_Item__c');
      sol.PBSI__Quantity_Needed__c = decimal.valueOf(kvps.get('PBSI__Quantity_Needed__c'));
        sol.PBSI__Location__c = var_SalesOrder.PBSI__From_Location__c;
      /*sol.PBSI__Ship_Date__c = sol.PBSI__Estimated_Ship_Date__c;*/
      if(null!=soid) sols.add(sol);
  }
  insert sols;
    List<String> result = new List<String>();
  for(PBSI__PBSI_Sales_Order_Line__c sol : sols) {
      result.add(sol.Id);
  }
    return result;
}
public static testMethod void test1() {
  Test.StartTest();
  String soid = [SELECT Id FROM PBSI__PBSI_Sales_Order__c LIMIT 1].Id;
  List<String> cat = getCat(soid);

  String itmid = [SELECT Id FROM PBSI__PBSI_Item__c LIMIT 1].Id;
  List<String> ist = getItemStat(itmid,null);
  List<String> ordrList = new List<String>();
  ordrList.add('{\"PBSI_Item__c\":\"'+itmid+'\",\"PBSI__Quantity_Needed__c\":1}');
  // 2015-01-05 MBI CHG FROM
  // List<String> aor = addOrderLines(null,ordrList);
  // 2015-01-05 MBI CHG TO
  List<String> aor = addOrderLines(soid,ordrList);
  // 2015-01-05 MBI CHG END

  OEMatrixCat1ON oemc = new OEMatrixCat1ON();
  Test.StopTest();
}
}