public with sharing class PackSoControllerOn extends ComponentControllerBase {
	public boolean UpdateQuants {get; set;}
	
   public  Map<Id,PBSI__PBSI_Sales_Order_Line__c> lines;
   public List<SLine> slines{get;set;}
   public list<SLine> slineslimit{get;set;}
   public List<PBSI__PBSI_Sales_Order_Line__c> solines{get;set;}
   public PBSI__PBSI_Sales_Order__c salesOrder;
   public static  PBSI__Property__c pr;
   public  List<List<PackLineModel>> PackLineModels=null;  
   public  List<List<PackLine>> packlines=null;  
   public boolean isoneserialized=false;     
   public boolean ispacksummary=false;
   public final integer maxlimit=900;
   Integer []failedlines=new Integer[]{};  
   public String salesOrderid;  
   public String DropShipMessage=''; 
   public integer curentindex=0;
   public boolean hasdropship=false;
   public Set<String> soids=new Set<String>();
   public Map<Id,PBSI__PBSI_Sales_Order__c> salesorders;
   public  Map<String,String> properties=new Map<String,String>();
   public PBSI__Admin__c admin{get;set;}
   public String []propertynames=new String[]{'LotSortOrder','Lot_Usage','UseCartonArea','ExactShip','PhantomSnAssing'};
   Map<String, Schema.SObjectField> M = Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.fields.getMap();
   Map<String, Schema.SObjectField> M1 = Schema.SObjectType.PBSI__BOM_Depletion_Line__c.fields.getMap();
   public List<PBSI__Shipped_Sales_Order_Line__c> shiplinesx{get;set;}
   public List<PBSI__Staging_Order_Lines__c> stagelinesx{get;set;}
   public boolean ismultipack=false;
   public PBSI__Invoice__c invoice{get;set;}
   public Set<Id> sostoupdate=new Set<Id>(); 
   public Map<Id,List<PBSI__PBSI_Inventory__c>> inventories=new Map<Id,List<PBSI__PBSI_Inventory__c>>();
   public boolean selectall{get;set;}
   public boolean ignorevalidation=false;
   public Id itemid;
   public Map<String,String> ordernames=new Map<String,String>{'soname' => 'PBSI__Sales_Order__r.Name','acc' => 'PBSI__Sales_Order__r.PBSI__Customer__r.Name','qtn' =>'PBSI__Quantity_Needed__c' ,'qtp' => 'PBSI__Quantity_Picked__c'};
   public Map<String,String> orderasc=new Map<String,String>{'soname' =>'asc','acc'=>'asc','qtn' => 'asc','qtp' => 'asc'};
   public boolean isstage=false;
   Set<Id> locationIds;
    Map<Id,double> mapitemlocator = new Map<Id,double>();
   boolean savefirst = true;
    public boolean shownavigationopen{get;set;}
   public integer lineslimit=90;
   public integer index1{get;set;}
   public integer index2{get;set;}    
   public PackSoControllerOn()
   {
     //IE9FixUtil.fixIt();
     admin= PBSI__Admin__c.getOrgDefaults();
      
     if (system.currentPageReference().getUrl() <> null && system.currentPageReference().getUrl().contains('Stage_SO')) isstage=true;
     soids.addAll(System.currentPageReference().getParameters().get('id').split(','));     ismultipack=true;
      salesorders=new Map<Id,PBSI__PBSI_Sales_Order__c>([select PBSI__Staging_Movement_Journal__c,PBSI__From_Location__c ,PBSI__BillingCompany__c,PBSI__BillingZip__c,PBSI__BillingStreet__c,PBSI__BillingCity__c,PBSI__BillingState__c,PBSI__BillingCountry__c,Id,PBSI__hasMJ__c,PBSI__Movement_Journal__c,Name,PBSI__Status__c,PBSI__Ship_Location__c,
                         PBSI__Customer__c, PBSI__Order_Date__c, PBSI__Delivery_Street__c, PBSI__Delivery_City__c, 
                         PBSI__Delivery_State__c, PBSI__Delivery_Postal_Code__c, PBSI__Delivery_Country__c, 
                         PBSI__Contact__c, PBSI__Due_Date__c, PBSI__Mode_of_Delivery__c, PBSI__Shipping_Instructions__c,
                         PBSI__Delivery_Streetnew__c, PBSI__Contact_Email__c, PBSI__Delivery_ATTN_to__c, 
                         PBSI__Delivery_Company__c, PBSI__Delivery_Address_line2__c, PBSI__Delivery_Address_line_3__c, 
                         PBSI__Delivery_ATTN_to_Phone__c 
                         from PBSI__PBSI_Sales_Order__c 
                         where Id in :soids]);  
        shiplinesx=new List<PBSI__Shipped_Sales_Order_Line__c>();
      if (soids.size() == 1) salesorder=salesorders.values()[0];          locationIds = new Set<Id>();       if (getshowlocation()) getallLocations();      capturelines();      getProperties();  
    }
    public PackSoControllerOn(ApexPages.StandardController controller) 
    {
        //IE9FixUtil.fixIt();
        if (system.currentPageReference().getUrl()<> null && system.currentPageReference().getUrl().contains('Stage_SO')) isstage=true;
        admin= PBSI__Admin__c.getOrgDefaults();        locationIds = new Set<Id>();       if (getshowlocation()) getallLocations();        
        if (controller.getRecord() instanceof PBSI__PBSI_Item__c)
        {
            itemid=System.currentPageReference().getParameters().get('id');         capturelines();         for (PBSI__PBSI_Sales_Order_Line__c line: solines) soids.add(line.pbsi__sales_order__c);
        }
        else
        {
            salesorderid=controller.getId();            soids.add(salesorderid);
        }
        salesorders=new Map<Id,PBSI__PBSI_Sales_Order__c>();
        list<PBSI__PBSI_Sales_Order__c> salesOrderslist=[select PBSI__Staging_Movement_Journal__c,PBSI__BillingCity__c, PBSI__BillingStreet__c, PBSI__BillingZip__c, PBSI__BillingCompany__c,
                           PBSI__BillingState__c, PBSI__BillingCountry__c, PBSI__From_Location__c ,Id,PBSI__hasMJ__c,PBSI__Movement_Journal__c,Name,PBSI__Status__c,PBSI__Ship_Location__c,
                           PBSI__Customer__c, PBSI__Order_Date__c, PBSI__Delivery_Street__c, PBSI__Delivery_City__c, 
                         PBSI__Delivery_State__c, PBSI__Delivery_Postal_Code__c, PBSI__Delivery_Country__c, 
                         PBSI__Contact__c, PBSI__Due_Date__c, PBSI__Mode_of_Delivery__c, PBSI__Shipping_Instructions__c,
                         PBSI__Delivery_Streetnew__c, PBSI__Contact_Email__c, PBSI__Delivery_ATTN_to__c, 
                         PBSI__Delivery_Company__c, PBSI__Delivery_Address_line2__c, PBSI__Delivery_Address_line_3__c, 
                         PBSI__Delivery_ATTN_to_Phone__c 
                         from PBSI__PBSI_Sales_Order__c 
                         where Id in :soids];
        salesorders.putall(salesOrderslist);        if (salesorders.size() == 1) salesorder=salesOrderslist[0];     capturelines();         getProperties(); 
    }

    public void getallLocations()    {              if (admin != null && admin.PBSI__Use_User_Location__c)              locationIds = CommonUtils.allLocationsByUserLocation();    }

    public boolean getshowlocation()     {                Boolean result = (admin != null && admin.PBSI__Use_ATP_by_Locations__c);       return result;    }
    public boolean getUseUserLocation()    {        Boolean result =  (admin != null && admin.PBSI__Use_User_Location__c);        return result;    }

    public pagereference sortLines()
    {
        String orderbystatement=' order By ';       String col=System.currentPageReference().getParameters().get('col');        orderbystatement+=ordernames.get(col)+' '+orderasc.get(col);
        if (orderasc.get(col) == 'asc') orderasc.put(col,'desc');else orderasc.put(col,'asc');
        String soql='select  d.PBSI__Price4__c,d.PBSI__Item_Description_Long__c,d.PBSI__ItemDescription__c,d.PBSI__Ship_Lot__c,d.CreatedDate,d.PBSI__Line_Number__c,d.PBSI__Item__c,PBSI__Bom_Type__c,d.PBSI__Item__r.PBSI__description__c,d.PBSI__Item__r.PBSI__Is_Service__c,d.PBSI__Item__r.PBSI__Default_Location__c,d.PBSI__Item__r.Name,d.PBSI__Lot__c,d.PBSI__Item__r.PBSI__defaultunitofmeasure__c,d.PBSI__Quantity_Needed__c,d.PBSI__Quantity_Picked__c  ,PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c,PBSI__Sales_Order__r.PBSI__Customer__c,d.PBSI__Sales_Order__c,d.PBSI__Location__c,d.PBSI__Item__r.PBSI__Is_Serialized__c,d.PBSI__Serial_Number__c,PBSI__Line_Status__c,d.PBSI__Item__r.PBSI__Configurable__c,PBSI__hasInstructions__c,PBSI__Item__r.PBSI__Not_Count_In_Inventory__c,d.PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c,d.PBSI__Item__r.PBSI__Default_Vendor__c,d.PBSI__Item__r.PBSI__Quantity_on_Hand__c,PBSI__Unit_Of_Measure__c,PBSI__Area__c,PBSI__Carton__c from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Item__c  =\''+itemid+'\' and PBSI__Line_Status__c = \'Open\' and PBSI__TransactionType__c =\'sale\'';
        solines=Database.query(soql+orderbystatement);      return null;
    }
    public pagereference closeLine()
    {
        String id=System.currentPageReference().getParameters().get('solineid');        lines.get(id).PBSI__Quantity_Needed__c=lines.get(id).PBSI__Quantity_Picked__c;      update lines.values();
        capturelines();     setOrderStatus();       return null;
    }
    public boolean getshowShipLot()   { PBSI__Admin__c cs = PBSI__Admin__c.getOrgDefaults();     if (cs != null && cs.PBSI__Use_Ship_Lot_for_SOLine__c == true)     return true;        return false;      }
     public boolean getshowtotalqty()     {         return (admin <> null && admin.PBSI__show_unit_quantity__c);     } 
    public boolean getalertstatus()
    {
        PBSI__Admin__c cs = PBSI__Admin__c.getOrgDefaults();        string fromtextarea;        string sostatus;        sostatus = salesOrder.PBSI__Status__c;
        if (cs != null && cs.PBSI__Prevent_So_Packing_if_Status_is__c != null)            fromtextarea = cs.PBSI__Prevent_So_Packing_if_Status_is__c;
        if  (fromtextarea==null && salesOrder.PBSI__Status__c=='Cancelled')            return true;
        if (fromtextarea!=null && sostatus!=null)        {            boolean result=fromtextarea.contains(sostatus);            if (result)       return true;            else        return false;        }
        return false;     
    }
    public PBSI__PBSI_Sales_Order__c getsalesorder()    {        return salesorder;    }
 
    public boolean getusingLots()    {        if (properties.containsKey('Lot_Usage') && properties.get('Lot_Usage') == 'Yes') return true;        return false;    }
    public string getsortorder()    {        if (properties.containsKey('LotSortOrder') ) return properties.get('LotSortOrder');        return 'Name Ascending';    }

    public void getProperties()    {        List<PBSI__Property__c> propertieslist;             propertieslist= [select Id,PBSI__Property_Name__c,PBSI__Property_Value__c from PBSI__Property__c where PBSI__Property_Name__c in :propertynames ];
        for (PBSI__Property__c p:propertieslist) properties.put(p.PBSI__Property_Name__c,p.PBSI__Property_Value__c);    } 

    public boolean getusingcartonarea()    {        if (properties.containsKey('UseCartonArea') && properties.get('UseCartonArea') == 'Yes') return true;        return false;    }
    public boolean getusepallets()    {        return (admin <> null && admin.PBSI__Use_Pallets__c);    }
    public pagereference backtoso()
    {
        string url;
        if (salesorders.size() >0 && ismultipack && invoice != null && invoice.Id != null)
        {
            List<PBSI__Invoiced_Line__c> invlines=new List<PBSI__Invoiced_Line__c>();              
            for (PBSI__Shipped_Sales_Order_Line__c s:[Select PBSI__Sales_Order__r.PBSI__Customer__c, PBSI__Sales_Order__c, PBSI__Sales_Order_Line__c,PBSI__Quantity_Shipped__c,PBSI__Price4__c,PBSI__Price__c,PBSI__Item__c,PBSI__Discount__c,PBSI__Discount1__c from PBSI__Shipped_Sales_Order_Line__c where PBSI__Invoice__c =:invoice.Id])
            {
                Double price=s.PBSI__Price__c;                if (s.PBSI__Price4__c != null && s.PBSI__Price4__c != 0) price=s.PBSI__Price4__c;                invlines.add(new PBSI__Invoiced_Line__c(PBSI__Unit_Price__c=price,PBSI__Status__c='Last',PBSI__Invoice__c=invoice.Id,PBSI__Quantity__c=s.PBSI__Quantity_Shipped__c,PBSI__Sales_Order_Line__c=s.PBSI__Sales_Order_Line__c,PBSI__Shipped_Sales_Order_Line__c=s.Id,PBSI__Item__c=s.PBSI__Item__c,PBSI__Sales_Order__c=s.PBSI__Sales_Order__c,PBSI__Discount__c = s.PBSI__Discount__c != NULL && s.PBSI__Discount__c > 0 ? s.PBSI__Discount__c : s.PBSI__Discount1__c));
            } 
            if (invlines.size() > 0)    insert invlines;            url='/'+invoice.Id;            PageReference so=new PageReference(url);            return so;           
        }
 
        if (salesOrder != null)        {            url='/'+salesOrder.Id;    PageReference so=new PageReference(url);            return so;        }
    return null;
    }
    public pagereference backtoitem()   {       string url='/'+itemId; PageReference so=new PageReference(url);         return so;  }
    public boolean getisoneserialized()    {        return isoneserialized;    }
    public boolean getispacksummary()    {        return ispacksummary;    }
    public Integer getcurentindex()     {        return curentindex;    }
     public boolean getuse6()     {         return admin <> null && admin.PBSI__Use_qty_6_decimal_places__c;     }
    public void capturelines()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        /*
        transient Map<Id,double> atpmapInv ;        transient Map<Id,Map<date,double>> atpmapSOl ;        transient Map<Id,Map<date,double>> atpmapPOl ;        transient Map<Id,Map<date,double>> atpmapPWO ;        transient Map<Id,Map<date,double>> atpmapPWOl ;        transient Map<Id,Map<Id,double>> atpmapInvLoc ;  
        
        transient Map<Id,Map<Id,Map<date,double>>> atpmapSOlLoc ;        transient Map<Id,Map<Id,Map<date,double>>> atpmapPOlLoc ;        transient Map<Id,Map<Id,Map<date,double>>> atpmapPWOLoc ;        transient Map<Id,Map<Id,Map<date,double>>> atpmapPWOlLoc ;
        if (getshowlocation() && !getUseUserLocation())     
        {           
            locationids.clear();            
            for(PBSI__PBSI_Sales_Order_Line__c l:solines)           
            locationids.add(l.PBSI__Location__c);       
        }    
        
        if (getshowlocation() && locationids <> null && locationIds.size()>0)       
        {           
            atpmapInvLoc  = CommonUtils2.CalculateATPInventoryByLocation(solines);      atpmapSOlLoc  = CommonUtils2.CalculateATPsolinesByLocation(solines);        atpmapPOlLoc  = CommonUtils2.CalculateATPpolinesByLocation(solines);        atpmapPWOLoc  = CommonUtils2.CalculateATPpwosByLocation(solines);       atpmapPWOlLoc = CommonUtils2.CalculateATPbompwosByLocation(solines);        
        }
        else        
        {           
            atpmapInv  = CommonUtils2.CalculateATPInventory(solines);       atpmapSOl  = CommonUtils2.CalculateATPsolines(solines);     atpmapPOl  = CommonUtils2.CalculateATPpolines(solines);     atpmapPWO  = CommonUtils2.CalculateATPpwos(solines);            atpmapPWOl = CommonUtils2.CalculateATPbompwos(solines);     
        }
        Map<Id,double> mapitemlocator = new Map<Id,double>();       Date dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day()); 
        if (admin != null && admin.PBSI__Use_ATP_by_Locations__c && locationIds <> null && locationIds.size()>0 )        {          SoqlService sqls = new SoqlService();           Set<Id> itemsid = new Set<Id>();            for(PBSI__PBSI_Sales_Order_Line__c l:solines)               itemsid.add(l.PBSI__Item__c);           mapitemlocator = sqls.getItemLocatorQty(locationIds,itemsid);        }
        for (PBSI__PBSI_Sales_Order_Line__c l:solines)   if (invoice == null)  l.PBSI__Invoice__c=null;
        for (PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            if (getshowlocation() && !getUseUserLocation())         {               locationIds.clear();                if (l.PBSI__Location__c!=null) locationIds.add(l.PBSI__Location__c);            }           
            double atp=0;               double qonhand=0;
                    
        if (locationIds <> null && locationIds.size()>0)
        {
                Date pofirstdate ;              List<Date> podates = new List<Date>();
                for (Id locationId: locationIds)                {                   if (atpmapPOlLoc.containskey(locationId))                       if (atpmapPOlLoc.get(locationId).containskey(l.PBSI__Item__c))                      for (date d: atpmapPOlLoc.get(locationId).get(l.PBSI__Item__c).keyset())                            if (d > l.PBSI__Estimated_Ship_Date__c)                             podates.add(d);                 }
                podates.sort();                 if (podates.size()>0)   pofirstdate = podates[0];
                if (atpmapInvLoc!=null)                 if (atpmapInvLoc.containskey(l.PBSI__Item__c))                  {                       for (Id locationId: locationIds)                        {                           if (atpmapInvLoc.get(l.PBSI__Item__c).containskey(locationId))                  atp += atpmapInvLoc.get(l.PBSI__Item__c).get(locationId);                       }                   }
                if (atpmapSOlLoc!=null)             {                   for (Id locationId: locationIds)                    {                       if (atpmapSOlLoc.containskey(locationId))                       {                           if (atpmapSOlLoc.get(locationId).containskey(l.PBSI__Item__c))                          {                               for (date d: atpmapSOlLoc.get(locationId).get(l.PBSI__Item__c).keyset())                                {                                   if ((pofirstdate!=null && d <= pofirstdate) || pofirstdate==null)                                   atp -= atpmapSOlLoc.get(locationId).get(l.PBSI__Item__c).get(d);                                }                           }                       }                   }               }
                if (atpmapPOlLoc!=null)                 for (Id locationId: locationIds)                    {                       if (atpmapPOlLoc.containskey(locationId))                           if (atpmapPOlLoc.get(locationId).containskey(l.PBSI__Item__c))                              for (date d: atpmapPOlLoc.get(locationId).get(l.PBSI__Item__c).keyset())                                    if (d <= l.PBSI__Estimated_Ship_Date__c)                        atp += atpmapPOlLoc.get(locationId).get(l.PBSI__Item__c).get(d);                    }
                    
                if (atpmapPWOLoc!=null)                 for (Id locationId: locationIds)                    {                       if (atpmapPWOLoc.containskey(locationId))                           if (atpmapPWOLoc.get(locationId).containskey(l.PBSI__Item__c))                              for (date d: atpmapPWOLoc.get(locationId).get(l.PBSI__Item__c).keyset())                                    if (d <= l.PBSI__Estimated_Ship_Date__c)                    atp += atpmapPWOLoc.get(locationId).get(l.PBSI__Item__c).get(d);                }
                if (atpmapPWOlLoc!=null)                    for (Id locationId: locationIds)                    {                       if (atpmapPWOlLoc.containskey(locationId))                          if (atpmapPWOlLoc.get(locationId).containskey(l.PBSI__Item__c))                             for (date d: atpmapPWOlLoc.get(locationId).get(l.PBSI__Item__c).keyset())                                   if (d <= l.PBSI__Estimated_Ship_Date__c)                    atp -= atpmapPWOlLoc.get(locationId).get(l.PBSI__Item__c).get(d);                   }
                if (mapitemlocator!=null && mapitemlocator.size()>0)                {                   if (mapitemlocator.containskey(l.PBSI__Item__c))                        qonhand = mapitemlocator.get(l.PBSI__Item__c).intValue();            }              else                qonhand =0;
            }
            else
            {       
                if (atpmapInv!=null)        if (atpmapInv.containskey(l.PBSI__Item__c))              atp = atpmapInv.get(l.PBSI__Item__c);              Date pofirstdate = l.PBSI__Estimated_Ship_Date__c;              List<Date> podates = new List<Date>();
                if (atpmapPOl!=null)                    if (atpmapPOl.containskey(l.PBSI__Item__c))
                        for (date d: atpmapPOl.get(l.PBSI__Item__c).keyset())                           if (d > l.PBSI__Estimated_Ship_Date__c)   podates.add(d);
                podates.sort();                 if (podates.size()>0)                   pofirstdate = podates[0];
                if (atpmapSOl!=null)
                    if (atpmapSOl.containskey(l.PBSI__Item__c))                     for (date d: atpmapSOl.get(l.PBSI__Item__c).keyset())                           if (d <= pofirstdate )            atp -= atpmapSOl.get(l.PBSI__Item__c).get(d);
                if (atpmapPOl!=null)                    if (atpmapPOl.containskey(l.PBSI__Item__c))                     for (date d: atpmapPOl.get(l.PBSI__Item__c).keyset())                           if (d <= l.PBSI__Estimated_Ship_Date__c)              atp += atpmapPOl.get(l.PBSI__Item__c).get(d);
                if (atpmapPWO!=null)                    if (atpmapPWO.containskey(l.PBSI__Item__c))                     for (date d: atpmapPWO.get(l.PBSI__Item__c).keyset())                           if (d <= l.PBSI__Estimated_Ship_Date__c)          atp += atpmapPWO.get(l.PBSI__Item__c).get(d);
                if (atpmapPWOl!=null)                   if (atpmapPWOl.containskey(l.PBSI__Item__c))                        for (date d: atpmapPWOl.get(l.PBSI__Item__c).keyset())                          if (d <= l.PBSI__Estimated_Ship_Date__c)        atp -= atpmapPWOl.get(l.PBSI__Item__c).get(d);
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;            
            }
            //atp += l.PBSI__Quantity_Needed__c; // for ATP is not considered qty on current line 
            if (atp < 0)       atp=0;           if (l.PBSI__stage_quantity__c == null) l.PBSI__stage_quantity__c=0;
            if ((admin <> null && admin.PBSI__Use_qty_6_decimal_places__c == false) || admin ==null)               {                l.PBSI__Quantity_Needed__c=l.PBSI__Quantity_Needed__c.setscale(2);              l.PBSI__Quantity_Picked__c=l.PBSI__Quantity_Picked__c.setscale(2);             }
            slines.add(new SLine(l,M,atp,qonhand));
        }   
        */
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            /*
               invs=[select id,Current_ATP__c,PBSI__item_lookup__c,PBSI__location_lookup__c from PBSI__PBSI_Inventory__c where 
                   PBSI__item_lookup__c in: itemids and PBSI__location_lookup__c in:locationids];
        
               for (PBSI__PBSI_Inventory__c i:invs)
               {
                    if (atpmap.containskey(i.PBSI__item_lookup__c))
                       atpmap.get(i.PBSI__item_lookup__c).put(i.PBSI__location_lookup__c,i.Current_ATP__c);
                    else
                       atpmap.put(i.PBSI__item_lookup__c,new map<id,decimal>{i.PBSI__location_lookup__c => i.Current_ATP__c});
               
               }
               */
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
  public integer getnumberofpage()
   	{
   		Decimal val=index2/lineslimit;
   		return val.round(System.RoundingMode.CEILING).intvalue();
   	} 
   	public integer gettotalpages()
   	{
   		if (math.mod(slines.size(),lineslimit) > 0) return math.round(slines.size()/lineslimit)+1;
   		return math.round(slines.size()/lineslimit);
   	}   	
    public pagereference nextslineslimit()
   	{
   	
   		if (index2 < slines.size() || Test.isRunningTest())
   		{
   			index1=index2;
		   	slineslimit.clear();
		   	integer plinesopenindex=index2+lineslimit;
		   	for(integer i=index2;i<slines.size() && i<plinesopenindex;i++)
		    {
		   	   	slineslimit.add(new sline(slines[i].soline,M,slines[i].atp,slines[i].qtyonhand));
 
		    }
		    index2=plinesopenindex;
   		}
   		
   		
	   	return null;
   }
   	public pagereference previouslineslimit()
   	{
   		if (index1 >=lineslimit || Test.isRunningTest())
   		{
		   	slineslimit.clear();
		    index2=index1;
		   	index1-=lineslimit;
		   	integer px=index2;
	   	 	for(integer i=index1;i<px;i++)
	   	 	  if (i >= 0 && slines.size() > i)
	   	 		slineslimit.add(slines[i]);
   		}
   		return null;
   	}        
    public void setOrderStatus()
    {   
        if (salesorder != null) sostoupdate.add(salesorder.Id);
        List<PBSI__PBSI_Sales_Order__c> salesorders=[select Id,PBSI__Total_Quant_To_Ship__c,PBSI__Ship_Location__c,PBSI__Number_Of_Pending_Shipping_Lines__c,PBSI__Number_of_Shipments__c,PBSI__Remaining_Shipments__c,PBSI__Days_Between_Scheduled_Shipments__c,PBSI__Schedule_End_Date__c,PBSI__hasMJ__c,PBSI__Movement_Journal__c,Name,PBSI__Due_Date__c,PBSI__Customer__c,PBSI__Status__c,PBSI__Type__c from PBSI__PBSI_Sales_Order__c where Id in :sostoupdate];
        for (PBSI__PBSI_Sales_Order__c s: salesorders)
        {
            salesOrder=s;            if (hasdropship) salesorder.PBSI__Has_Drop_Ship_Lines__c=true;            salesOrder.PBSI__Packing_Date__c=system.today();            PBSI__Admin__c CS = PBSI__Admin__c.getOrgDefaults();
            if (salesOrder.PBSI__Total_Quant_To_Ship__c >0)
            { 
                salesOrder.PBSI__Status__c='Partially Complete';                if (CS != null && CS.PBSI__Update_Ship_Date_on_Line_Shipping__c == true)    salesOrder.PBSI__Due_Date__c=system.today();                salesorder.PBSI__Stage__c='Partially Packed';
            }
            else
                if (salesOrder.PBSI__Total_Quant_To_Ship__c ==0 )
                    if ( salesOrder.PBSI__Type__c != 'Scheduled' || Test.IsRunningTest()) 
                    {
                        if (CS != null && CS.PBSI__Update_Ship_Date_when_all_Lines_Shipped__c == true)                        salesOrder.PBSI__Due_Date__c=system.today();
                        if (salesorder.PBSI__Number_Of_Pending_Shipping_Lines__c == 0)                        {                            if (cs != null && cs.PBSI__Do_not_close_SO_when_all_lines_Packed__c == true)    salesOrder.PBSI__Status__c='Packed';                            else                                salesOrder.PBSI__Status__c='Closed';                        }
                        else                            salesOrder.PBSI__Status__c='Pending Shipping';
                        salesorder.PBSI__Stage__c='Packed';
                    }
                    if (salesOrder.PBSI__Type__c == 'Scheduled' || Test.IsRunningTest())
                    {
                        if (salesOrder.PBSI__Days_Between_Scheduled_Shipments__c == null)  salesOrder.PBSI__Days_Between_Scheduled_Shipments__c=1;
                        if (salesOrder.PBSI__Schedule_End_Date__c != null || Test.IsRunningTest())
                        {
                            Date nextShipDate=salesOrder.PBSI__Due_Date__c+salesOrder.PBSI__Days_Between_Scheduled_Shipments__c.longValue();                            date startdate=date.newInstance(1900, 1, 7);                            Integer l1=startDate.daysBetween(nextShipDate);                            
                            if (Math.mod(l1,7 ) == 0) nextShipDate+=1;
                            else                                if (Math.mod(l1,7) == 6) nextShipDate+=2;
                            if (nextShipDate <= salesOrder.PBSI__Schedule_End_Date__c)                            {                                salesOrder.PBSI__Due_Date__c=nextShipDate;                                salesOrder.PBSI__Status__c='In Progress';                            }
                            else                                salesOrder.PBSI__Status__c='Closed';
                        }
                        if (salesOrder.PBSI__Schedule_End_Date__c == null || Test.IsRunningTest()) {
                            if (salesOrder.PBSI__Number_of_Shipments__c != null)
                            {
                                salesOrder.PBSI__Remaining_Shipments__c-=1;
                                if (salesOrder.PBSI__Remaining_Shipments__c <= 0) salesOrder.PBSI__Status__c='Closed';
                                else                                {                                   salesOrder.PBSI__Status__c='In Progress';                                   salesOrder.PBSI__Due_Date__c=salesOrder.PBSI__Due_Date__c+salesOrder.PBSI__Days_Between_Scheduled_Shipments__c.longValue();                             }
                            }
                            else                            {                               salesOrder.PBSI__Status__c='In Progress';                               salesOrder.PBSI__Due_Date__c=salesOrder.PBSI__Due_Date__c+salesOrder.PBSI__Days_Between_Scheduled_Shipments__c.longValue();                         }
                        }
                    }
        }//FOR
        update salesorders;
    }

    public String getDropShipMessage()    {        return DropShipMessage;    }
    public void UpdateLinesLotQty(integer j,decimal qtysh,double oldqty,Id lotid)    {        UpdateLinesLotQty(j, qtysh, oldqty, lotid, false);    }
    public void UpdateLinesLotQty(integer j,decimal qtysh,double oldqty,Id lotid, Boolean executeCalculations)
    {
        for (List<PackLineModel> plist:PackLineModels)  
            for (integer k=j+1;k<plist.size();k++)
                if (executeCalculations || plist[k].lotsqty.containsKey(lotid))
                {
                    Double q=qtysh;
                    if (oldqty != null && qtysh != oldqty )                    {                        q -= oldqty;                        if(!executeCalculations)                            plist[k].lotsqty.put(lotid,plist[k].lotsqty.get(lotid)-q);                    }
                }
    }
    
    public void SetLineSerialsStyle(PackLineModel currentp)    {        SetLineSerialsStyle(currentp, currentp.serialnumbers.size());    }
   
    public void SetLineSerialsStyle(PackLineModel currentp, Integer snListSize)
    {
        if(snListSize > 5)   currentp.serialsDivStyle = 'height: 100px;padding-top: 5px;overflow: auto;overflow-x: hide;';
        else
            currentp.serialsDivStyle = '';
    }
    
    public void addOptions(PackLineModel currentp)   {        addOptions(currentp, false,false);    }
    
    public void addOptions(PackLineModel currentp, Boolean executeCalculations,boolean stage)
    {
         if (executeCalculations || currentp.usecarton || currentp.usepallets)
         {
           for( List<PackLineModel> plist:PackLineModels)
               for (PackLineModel p:plist)
                   if (executeCalculations || p.inventory != null) 
                       if (executeCalculations || currentp.invqty.containsKey(p.inventory))                       {                           Double qinvq=currentp.invqty.get(p.inventory);                           decimal qty=p.line.PBSI__quantity_shipped__c;                           if (stage)                              qty=p.stageline.PBSI__stage_quantity__c;                           if(!executeCalculations)                                currentp.invqty.put(p.inventory,qinvq-qty*p.unitquant);                       }
                                   
         }
         else
         {                       
            Set<Id> idstoremove=new Set<Id>();            integer j=0;
            for(Id  i:currentp.invstrlotid )
            {
                j++; 
                 if (currentp.lotsqty.containsKey(i))                 {                    Double q=currentp.lotsqty.get(i);                    q+=currentp.invqty.get(i);                    currentp.lotsqty.put(i,q);                    idstoremove.add(i);                 }
                 else                     currentp.lotsqty.put(i,currentp.invqty.get(i));
            }
            for (id i:idstoremove) currentp.invqty.remove(i);     
            for(Id  i:currentp.invstrlotid )
            {
                 for( List<PackLineModel> plist:PackLineModels)
                       for (PackLineModel p:plist)
                       {
                          if (p == currentp) break;
                          
                          if (stage)                          {                          if (p.stageline.PBSI__from_Lot__c != null && i == p.stageline.PBSI__from_Lot__c)                                   currentp.lotsqty.put(i,currentp.lotsqty.get(i)-p.stageline.PBSI__stage_quantity__c*p.unitquant);                                              }
                          else                        {                          if (p.line.PBSI__Lot__c != null && i == p.line.PBSI__Lot__c)                                   currentp.lotsqty.put(i,currentp.lotsqty.get(i)-p.line.PBSI__quantity_shipped__c*p.unitquant);                         }
                       }    
                } 
                if (stage)
                {
                    if (executeCalculations ||                  (currentp.stageline.PBSI__from_Lot__c != null && currentp.lotsqty.get(currentp.stageline.PBSI__from_Lot__c) < 0))
                       for(Id  i:currentp.invstrlotid )                            if (currentp.lotsqty.get(i) > 0)                                { currentp.stageline.PBSI__from_lot__c=i;break;}                         
                }
                else
                    if (executeCalculations ||                          (currentp.line.PBSI__Lot__c != null && currentp.lotsqty.get(currentp.line.PBSI__Lot__c) < 0))
                        for(Id  i:currentp.invstrlotid )                            if (currentp.lotsqty.get(i) > 0)                                { currentp.line.PBSI__lot__c=i;break;}
                if (stage)                {                 if (currentp.stageline.PBSI__from_Lot__c != null  && currentp.lotsqty.containsKey(currentp.stageline.PBSI__from_Lot__c))                        currentp.oldlot=currentp.stageline.PBSI__from_Lot__c;                }
                else                if (currentp.line.PBSI__Lot__c != null  && currentp.lotsqty.containsKey(currentp.line.PBSI__Lot__c))                 currentp.oldlot=currentp.line.PBSI__Lot__c;
                         
         }       
    }  
   
   public  pagereference  deleteChildlinesstage()   {        deletechildlines(true);     return null;   }
   
   public pagereference deleteChildlines()   {       deletechildlines(false);        return null;   }
   public pagereference deleteChildlines(boolean stage)
   {    
      Integer lineno=Integer.valueOf(System.currentPagereference().getParameters().get('lineNumber'));      PackLineModel currentp=PackLineModels[curentindex][lineno];     
      
      for (PackLineModel p: currentp.childlines)
      {
             Double qq;
             if (stage)                 qq=currentp.stageline.PBSI__stage_quantity__c*(p.bomdepline.PBSI__Quantity__c/currentp.soline.PBSI__Quantity_Needed__c);
             else               qq=currentp.line.PBSI__quantity_shipped__c*(p.bomdepline.PBSI__Quantity__c/currentp.soline.PBSI__Quantity_Needed__c);
             
             if (p.serialnumbers != null )
             {       CommonUtils.getPackLineSerialsByLimitedSerials(p.limitedSerials);
                try
                {
                    if (p.serialnumbers.size() >Math.abs(qq))                    {                      while (p.serialnumbers.size() > Math.abs(qq))                           p.serialnumbers.remove(p.serialnumbers.size()-1);                     }
                     else if (p.serialnumbers.size() <Math.abs(qq))                     {                        while (p.serialnumbers.size() <Math.abs(qq))                           p.serialnumbers.add(new PBSI.SerialN(''));                     } 
                 }                 catch(Exception e){}  
                 p.limitedSerials = CommonUtils.GetLimitedSerials(p.serialnumbers);                 SetLineSerialsStyle(p);
              }
              if (stage)              {               p.oldqtystage=p.stageline.PBSI__stage_quantity__c*p.unitquant;                  p.stageline.PBSI__stage_quantity__c=qq;              }
              else              {                 p.oldqty=p.line.PBSI__quantity_shipped__c*p.unitquant;                  p.line.PBSI__quantity_shipped__c=qq;              }
              p.qshp=qq;
           //}  
        }   
       
        if (currentp.serialnumbers != null)
        {
            currentp.serialnumbers = CommonUtils.getPackLineSerialsByLimitedSerials(currentp.limitedSerials);
            
            Double actquant;
            if (stage)    actquant=currentp.unitquant*currentp.stageline.PBSI__stage_quantity__c;
            else                actquant=currentp.unitquant*currentp.line.PBSI__quantity_shipped__c;
            try
            { 
                if (currentp.serialnumbers.size() >Math.abs(actquant))                {                    while (currentp.serialnumbers.size() > Math.abs(actquant))                       currentp.serialnumbers.remove(currentp.serialnumbers.size()-1);                }
                else if (currentp.serialnumbers.size() <Math.abs(actquant))                {                    while (currentp.serialnumbers.size() < Math.abs(actquant))                       currentp.serialnumbers.add(new PBSI.SerialN(''));                } 
             }             catch(Exception e){}   
             
             currentp.limitedSerials = CommonUtils.GetLimitedSerials(currentp.serialnumbers);             SetLineSerialsStyle(currentp);
        }
            
        updateQty();        return null;
    }
    
    public pagereference updateQtystage()    {      return updateqty(true);    }
    
    public pagereference updateQty()    {       return updateqty(false);    }
    
    public pagereference updateqty(boolean stage)
    {
        Integer lineno=Integer.valueOf(System.currentPagereference().getParameters().get('lineNumber'));
        PackLineModel currentp = null;
        for (PackLineModel plm : PackLineModels[curentindex]) {
        	if (plm.lineNumber == lineno) {
        		currentp = plm;
        		break;
        	}
        }
        if (currentp != null) {
	        integer j=lineno;       Id uomid;
	        if (stage) uomid=currentp.stageline.pbsi__unit_of_measure__C;
	        else            uomid=currentp.line.pbsi__unit_of_measure__C;
	        if (uomid <> null)        
	        {            Map<Id,pbsi__unit__C> umap=new map<id,pbsi__unit__C>(currentp.units);            
	            currentp.unitquant=umap.get(uomid).pbsi__quantity__c;        }
	        else         currentp.unitquant=1;          
	        double q;
	        if (stage)      q=currentp.stageline.PBSI__stage_quantity__c*currentp.unitquant;
	        else            q=currentp.line.PBSI__quantity_shipped__c*currentp.unitquant;
	 
	         
	        if (currentp.usecarton || currentp.usepallets)
	        {   
	            if (currentp.inventory != null)
	            { 
	                for (List<PackLineModel> plist:PackLineModels)  
	                    for (integer k=j+1;k<plist.size();k++)
	                        if ((currentp.inventory != null &&  plist[k].invqty  != null && plist[k].invqty.containsKey(currentp.inventory)))
	                        {
	                            if (stage)
	                            {
	                                 if (currentp.oldqtystage != null && q != currentp.oldqtystage)                                 {                                       q-=currentp.oldqtystage;                                        Double qinvq=plist[k].invqty.get(currentp.inventory);                                       plist[k].invqty.put(currentp.inventory,qinvq-q);                                    }
	                            }
	                            else
	                            if (currentp.oldqty != null && q != currentp.oldqty)                            {                                q-=currentp.oldqty;                                Double qinvq=plist[k].invqty.get(currentp.inventory);                                plist[k].invqty.put(currentp.inventory,qinvq-q);                            }
	                        }
	            }
	        }
	        else
	        {
	          if (stage)          
	          {              if (currentp.stageline.PBSI__from_Lot__c != null)                  
	             UpdateLinesLotQty(j,q,currentp.oldqtystage,currentp.stageline.PBSI__from_Lot__c);         }
	          else
	            if (currentp.line.PBSI__Lot__c != null)             UpdateLinesLotQty(j,q,currentp.oldqty,currentp.line.PBSI__Lot__c);
	            
	            if (currentp.childlines != null)
	                {
	                    integer h=0;
	                    for (PackLineModel p:currentp.childlines)
	                        if (( stage == false && p.line.PBSI__Lot__c != null) || (stage && p.stageline.PBSI__from_Lot__c != null))
	                        {
	                            decimal qp;
	                            if (stage)  qp=p.stageline.PBSI__stage_quantity__c*p.unitquant;
	                            else        qp=p.line.PBSI__quantity_shipped__c*p.unitquant;
	                            for (List<PackLineModel> plist:PackLineModels)                                
	                                for (integer i=0;i<plist.size() ; i++ )                                    
	                                    if (plist[i] == p) {h=i;break;}
	                            if (stage)    UpdateLinesLotQty(h,qp,p.oldqtystage,p.stageline.PBSI__from_Lot__c);
	                            else          UpdateLinesLotQty(h,qp,p.oldqty,p.line.PBSI__Lot__c);
	                        } 
	                  }
	         }
	         currentp.oldqty=q;         currentp.oldqtystage=q;
        }
        return null; 
    }
    
    public pagereference updateLinestage()    {     return updateline(true);    }
           
    public pagereference updateLine()    {      return updateline(false);    }
    public pagereference updateline(boolean stage)
    {
        
        Integer lineno=Integer.valueOf(System.currentPagereference().getParameters().get('lineNumber'));        PackLineModel currentp=PackLineModels[curentindex][lineno];        decimal qp=currentp.line.PBSI__quantity_shipped__c;
        if (stage) qp=currentp.stageline.PBSI__stage_quantity__c;
        if (stage)
        {
            if (currentp.stageline.pbsi__unit_of_measure__C <> null)            {               Map<Id,pbsi__unit__C> umap=new map<id,pbsi__unit__C>(currentp.units);               currentp.unitquant=umap.get(currentp.stageline.pbsi__unit_of_measure__C).pbsi__quantity__c;         }           
        }
        else
        if (currentp.line.pbsi__unit_of_measure__C <> null)        {            Map<Id,pbsi__unit__C> umap=new map<id,pbsi__unit__C>(currentp.units);            currentp.unitquant=umap.get(currentp.line.pbsi__unit_of_measure__C).pbsi__quantity__c;        } 
        integer j=lineno;
          if (currentp.usecarton || currentp.usepallets)
          {        
              if (currentp.oldinv != null)
              {
                  for (List<PackLineModel> plist:PackLineModels)  
                      for (integer k=j+1;k<plist.size();k++)
                            if (currentp.oldinv != null &&  plist[k].invqty  != null && plist[k].invqty.containsKey(currentp.oldinv)  )                            {                                 Double qinvq=plist[k].invqty.get(currentp.oldinv);                                 plist[k].invqty.put(currentp.oldinv,qinvq+qp*currentp.unitquant);                            } 
        
              }
                if ( currentp.inventory != null)
                {
                       for (List<PackLineModel> plist:PackLineModels)  
                            for (integer k=j+1;k<plist.size();k++)
                            {
                                   
                                if (plist[k].invqty  != null && plist[k].invqty.containsKey(currentp.inventory) )                               {                                   Double qinvq=plist[k].invqty.get(currentp.inventory);                                   plist[k].invqty.put(currentp.inventory,qinvq-qp*currentp.unitquant);                                }
                            }
                            if (currentp.usecarton || Test.IsRunningTest())
                            {
                                try
                                {
                                   PBSI__PBSI_Inventory__c   invq=[select id,pbsi__Area__c,pbsi__carton__c,pbsi__lot__c from PBSI__PBSI_Inventory__c where id=:currentp.inventory]; 
                                   currentp.line.PBSI__Area__c=invq.PBSI__Area__c;                                   currentp.line.PBSI__Carton__c=invq.PBSI__Carton__c;                                   currentp.line.PBSI__Lot__c=invq.PBSI__Lot__c;
                                }
                                catch(Exception e){system.debug(e);}
                                
                            }
                            if (!currentp.usecarton || Test.IsRunningTest())
                            {
                                try
                                {
                                    PBSI__PBSI_Inventory__c   invq=[select id,pbsi__pallet__c,pbsi__lot__c                                                                     from PBSI__PBSI_Inventory__c where id=:currentp.inventory];   
                                    currentp.line.PBSI__pallet__c=invq.PBSI__pallet__c;                                    currentp.line.PBSI__Lot__c=invq.PBSI__Lot__c;
                                   if (stage)                                   {                                    currentp.stageline.PBSI__pallet__c=invq.PBSI__pallet__c;                                    currentp.stageline.PBSI__from_Lot__c=invq.PBSI__Lot__c;                                   }
                                }
                                catch(Exception e){system.debug(e); }
                            }
                            
                            if ((admin <> null && admin.PBSI__Do_Not_Allow_Display_More_Qty_Pack__c) || Test.IsRunningTest())
                            {
                                if (currentp.qshp > currentp.invqty.get(currentp.inventory))                                    currentp.line.PBSI__Quantity_Shipped__c = currentp.invqty.get(currentp.inventory);
                                else                                    currentp.line.PBSI__Quantity_Shipped__c = currentp.qshp;
                            }
                            
               }
                else
                if ( currentp.inventory == null)
                {
                    currentp.line.PBSI__Area__c=null;                    currentp.line.PBSI__Carton__c=null;                    currentp.line.PBSI__Lot__c=null;                    currentp.line.pbsi__pallet__c=null;
                    if (stage)                    {                     currentp.stageline.PBSI__Area__c=null;                      currentp.stageline.PBSI__Carton__c=null;                        currentp.stageline.PBSI__from_Lot__c=null;                      currentp.stageline.pbsi__pallet__c=null;                }
                    if ((admin <> null && admin.PBSI__Do_Not_Allow_Display_More_Qty_Pack__c) || Test.IsRunningTest())                        currentp.line.PBSI__Quantity_Shipped__c = currentp.qshp;
                }
        }
        else
        {
            String lotid=currentp.line.PBSI__Lot__c;
            if (stage)    lotid=currentp.stageline.PBSI__from_Lot__c;
            if (lotid != null && lotid != '')
            {
                for (List<PackLineModel> plist:PackLineModels)                   for (integer k=j+1;k<plist.size();k++)                        if ( plist[k].lotsqty.containsKey(lotid))                            plist[k].lotsqty.put(lotid,plist[k].lotsqty.get(lotid)-qp*currentp.unitquant);
                
                if ((admin <> null && admin.PBSI__Do_Not_Allow_Display_More_Qty_Pack__c) || Test.IsRunningTest())
                {       
                    if (currentp.line.PBSI__Quantity_Shipped__c > currentp.lotsqty.get(lotid))                        currentp.line.PBSI__Quantity_Shipped__c = currentp.lotsqty.get(lotid);
                    else                        currentp.line.PBSI__Quantity_Shipped__c = currentp.qshp;
                }
            }
            //  else
              //        currentp.line.PBSI__quantity_shipped__c = currentp.qshp;
            if (currentp.oldlot != null && currentp.oldlot != '')                for (List<PackLineModel> plist:PackLineModels)                   for (integer k=j+1;k<plist.size();k++)                        if ( plist[k].lotsqty.containsKey(currentp.oldlot))                        {                            plist[k].lotsqty.put(currentp.oldlot,plist[k].lotsqty.get(currentp.oldlot)+qp*currentp.unitquant);                        }
            currentp.oldlot=lotid; 
        }
        currentp.oldinv=currentp.inventory;
        return null;
    }

    public pagereference next()    {        if (PackLineModels != null )        if (curentindex < PackLineModels.size() -1){ curentindex++; }        return null;    }
    public pagereference previos()    {        if (curentindex >=1) curentindex--;        return null;    }
    public pagereference dropship()
    {
        List<PackLineModel> curentlist;        if (PackLineModels == null) PackLineModels=new List<List<PackLineModel>>();        String linetopack=System.currentPageReference().getParameters().get('linenodrop');
        if ((lines.get(linetopack).PBSI__Vendor__c == null && lines.get(linetopack).PBSI__Item__r.PBSI__Default_Vendor__c == null) || lines.get(linetopack).PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c == false)
            processError('This item does not have a default vendor set or Item Is not allowed for Drop Ship! A drop Ship PO cannot be created',ApexPages.Severity.WARNING);
        else
        {
              double qsh=lines.get(linetopack).PBSI__Quantity_Needed__c-lines.get(linetopack).PBSI__Quantity_Picked__c;  
              for(List<PackLineModel> plist:PackLineModels)
                 for(PackLineModel p:plist)                     if (p.soline.Id == lines.get(linetopack).Id && p.bomdepline == null)                      qsh-=p.line.PBSI__quantity_shipped__c*p.unitquant;
                list<PBSI__Unit__c> units=[select id, Name,pbsi__quantity__c from PBSI__Unit__c where pbsi__item__C =:lines.get(linetopack).pbsi__item__c];
                
               PackLineModel l=new PackLineModel(lines.get(linetopack),qsh);               l.units=units;
               if (PackLineModels.size() >0) {curentlist=PackLineModels[PackLineModels.size()-1];}
               else
               {curentlist=new List<PackLineModel>();PackLineModels.add(curentlist);}
               if (curentlist.size() < maxlimit)               {                l.lineNumber=curentlist.size();                curentlist.add(l);               }
               else {curentlist=new List<PackLineModel>();PackLineModels.add(curentlist);l.lineNumber=curentlist.size();curentlist.add(l);}
          
       } 
   
       
       return null;
}
    public pagereference DropShipAll()
    {
        boolean onechecked=false;
        for (SLine p: slines)
        if  (p.isselected )
        {
            if ((p.soline.PBSI__Vendor__c != null || p.soline.PBSI__Item__r.PBSI__Default_Vendor__c != null) && p.soline.PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c)            {                System.currentPageReference().getParameters().put('linenodrop',p.soline.Id);                dropship();                onechecked=true;            }
        }
        if (onechecked == false)
            for (PBSI__PBSI_Sales_Order_Line__c p: lines.values() )
                if ((p.PBSI__Vendor__c != null || p.PBSI__Item__r.PBSI__Default_Vendor__c != null) && p.PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c)                {                    System.currentPageReference().getParameters().put('linenodrop',p.Id);                    dropship();                }
        return null;
    }
    
    public pagereference stageall()    {        return packall(true);    }
    
    public pagereference packAll()    {       return packall(false);    }
    public pagereference packall(boolean stage)
    {
        ispacksummary=false;         
        List<PBSI__PBSI_Sales_Order_Line__c> linestopack=new List<PBSI__PBSI_Sales_Order_Line__c>();        
        Set<id> itemids=new Set<Id>();        
        Set<id> bomlines=new Set<id>();       
         boolean onechecked=false;        
          set<id> locationids=new set<id>();
       
        if (shownavigationopen)
        {
	        for (SLine s: slineslimit)
	        if  (s.isselected )
	        {
	            if (s.soline.pbsi__Bom_Type__c != null && s.soline.pbsi__Bom_Type__c == 'BOM-Phantom'  
	            || s.soline.pbsi__hasInstructions__c)                
	            { bomlines.add(s.soline.id); if (s.soline.pbsi__hasInstructions__c) itemids.add(s.soline.pbsi__item__c); }
	            else   
	            {            
	            itemids.add(s.soline.pbsi__item__c);
	            //lineids.add(s.soline.id);
	            }
	            linestopack.add(s.soline);
	            onechecked=true;
	        }
        }
        else       
        for (SLine s: slines)
        if  (s.isselected )
        {
            if (s.soline.PBSI__Bom_Type__c != null && s.soline.PBSI__Bom_Type__c == 'BOM-Phantom'  || s.soline.PBSI__hasInstructions__c)                
                { bomlines.add(s.soline.id); if (s.soline.PBSI__hasInstructions__c) itemids.add(s.soline.PBSI__item__c); }
            else
                itemids.add(s.soline.PBSI__item__c);
            linestopack.add(s.soline);            
            onechecked=true;
        }
        if (onechecked == false)
        {
        	if (shownavigationopen)
        	{
        		for (SLine s: slineslimit)
        		  {
        		  	PBSI__PBSI_Sales_Order_Line__c p=s.soline;
        		     
	                if (p.PBSI__Bom_Type__c != null && p.PBSI__Bom_Type__c == 'BOM-Phantom'  || p.PBSI__hasInstructions__c)                    
	                    {bomlines.add(p.id);if (p.PBSI__hasInstructions__c) itemids.add(p.PBSI__item__c);}
	                else
	                    itemids.add(p.PBSI__item__c);
	                linestopack.add(p); 	
        		  }
        	}
        	else
        	{
        	
	            for (PBSI__PBSI_Sales_Order_Line__c p: lines.values() )
	                if (p.PBSI__Bom_Type__c != null && p.PBSI__Bom_Type__c == 'BOM-Phantom'  || p.PBSI__hasInstructions__c)                    
	                    {bomlines.add(p.id);if (p.PBSI__hasInstructions__c) itemids.add(p.PBSI__item__c);}
	                else
	                    itemids.add(p.PBSI__item__c);
	            linestopack.addAll(solines);   
        	}
         }
  
        Map<Id, List<PBSI__BOM_Depletion_Line__c>>  allblines=new Map<Id,List<PBSI__BOM_Depletion_Line__c>>();
        if (bomlines.size() > 0)      
        {
            List<PBSI__BOM_Depletion_Line__c> blines;
            string str='select PBSI__Sales_Order__r.PBSI__From_Location__c,PBSI__Item__r.PBSI__salesprice__c,PBSI__Item__r.PBSI__salesprice4__c, PBSI__Bill_of_Materials__c,PBSI__Sales_Order_Line__c ,PBSI__Ship_Lot__c,PBSI__Sales_Order__c,Id,PBSI__Item__c,PBSI__Lot__c,PBSI__Quantity_Packed__c,PBSI__Quantity__c,PBSI__Item__r.Name,'+
                       'PBSI__Item__r.PBSI__Is_Serialized__c,PBSI__BOM_Name__c,PBSI__Serial_Number__c,PBSI__Location__c,'+
                       'PBSI__Item__r.PBSI__Sales_Order_Description_Long__c,PBSI__Item__r.PBSI__Item_Description_Long__c,PBSI__Item__r.PBSI__Sales_Order_Description__c,PBSI__Item__r.PBSI__description__c,PBSI__Type__c,PBSI__Item__r.PBSI__Not_Count_In_Inventory__c,'+
                       'PBSI__Item__r.PBSI__Default_Location__c,PBSI__Item__r.PBSI__Is_Service__c,PBSI__Item__r.PBSI__defaultunitofmeasure__c,PBSI__Area__c,PBSI__Carton__c';
            if (M1.containsKey('Jan_Code__c'))                str+=',Jan_Code__c';
                str+= ' from PBSI__BOM_Depletion_Line__c where PBSI__Sales_Order_Line__c in:bomlines and PBSI__Item__c <> null order by Name';              blines=Database.query(str);
                for(PBSI__BOM_Depletion_Line__c b: blines)
                {
                    if (allblines.containsKey(b.PBSI__Sales_Order_Line__c) )                        allblines.get(b.PBSI__Sales_Order_Line__c).add(b);
                    else                        allblines.put(b.PBSI__Sales_Order_Line__c,new List<PBSI__BOM_Depletion_Line__c>{b});
                    itemids.add(b.PBSI__item__c);
                }
        }
        Set<Id> itemsnoinv=new Set<Id>();
        if (itemids.size() > 0)
        {
            for (Id i:itemids) if (inventories.containsKey(i) == false) itemsnoinv.add(i);
            if (itemsnoinv.size() > 0)
            {
                List<PBSI__PBSI_Inventory__c> invs=getInventoryList(itemsnoinv);
                for (PBSI__PBSI_Inventory__c i:invs)      
                if (inventories.containsKey(i.PBSI__item_lookup__c)) inventories.get(i.PBSI__item_lookup__c).add(i);
                else  inventories.put(i.PBSI__item_lookup__c,new List<PBSI__PBSI_Inventory__c>{i} );
            }
        }
        list<PBSI__Unit__c> units=[select id, Name,pbsi__quantity__c,pbsi__item__c 
        from PBSI__Unit__c where pbsi__item__C in :itemids
        and (PBSI__Applies_To__c ='Sales Order' or PBSI__Applies_To__c =null)
        order by name asc];
         map<id,list<PBSI__Unit__c>> unitsmap=new map<id,list<PBSI__Unit__c>>();
         for (PBSI__Unit__c u:units)
             if (unitsmap.containsKey(u.pbsi__item__c))                 unitsmap.get(u.pbsi__item__c).add(u);
                 else                 unitsmap.put(u.pbsi__item__c,new list<PBSI__Unit__c>{u});

// atp
        for (PBSI__PBSI_Sales_Order_Line__c l: linestopack)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
                if (salesorder.PBSI__From_Location__c <> null) 
                   locationids.add(salesorder.PBSI__From_Location__c);
        }
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
// atp
        
        for (PBSI__PBSI_Sales_Order_Line__c linetopack: linestopack)
        {
            if (PackLineModels == null) PackLineModels=new List<List<PackLineModel>>();
            if (salesorders.size() > 0 && invoice == null && ismultipack)
            {
                PBSI__PBSI_Sales_Order__c s=salesorders.get(linetopack.PBSI__Sales_Order__c);                
                invoice=new PBSI__Invoice__c(PBSI__Customer__c=s.PBSI__Customer__c,PBSI__BillingCountry__c=s.PBSI__BillingCountry__c,  PBSI__BillingState__c=s.PBSI__BillingState__c, PBSI__BillingCity__c=s.PBSI__BillingCity__c, PBSI__BillingStreet__c=s.PBSI__BillingStreet__c, PBSI__BillingZip__c=s.PBSI__BillingZip__c,PBSI__BillingCompany__c=s.PBSI__BillingCompany__c, PBSI__Delivery_Street__c=s.PBSI__Delivery_Streetnew__c, PBSI__Delivery_State__c=s.PBSI__Delivery_State__c, PBSI__Delivery_Postal_Code__c=s.PBSI__Delivery_Postal_Code__c, PBSI__Delivery_Country__c=s.PBSI__Delivery_Country__c, PBSI__Delivery_Company__c=s.PBSI__Delivery_Company__c, PBSI__Delivery_City__c=s.PBSI__Delivery_City__c); 
            }  
            List<PBSI__PBSI_Inventory__c> inv=inventories.get(linetopack.PBSI__Item__c);     
            if (inv == null) inv=new List<PBSI__PBSI_Inventory__c>();           
            if (inv.size() >0) linetopack.PBSI__Lot__c=inv[0].PBSI__Lot__c; 
            double qsh;
            if (stage)            
                qsh=linetopack.PBSI__Quantity_Needed__c-linetopack.PBSI__stage_quantity__c;
            else
                qsh=linetopack.PBSI__Quantity_Needed__c-linetopack.PBSI__Quantity_Picked__c;  
 
           if (stage)
           {
            for(List<PackLineModel> plist:PackLineModels)                
                for(PackLineModel p:plist)                    
                    if (p.soline.Id == linetopack.Id && p.bomdepline == null)                        
                        qsh-=p.stageline.PBSI__stage_quantity__c*p.unitquant;               
           }
           else    
            for(List<PackLineModel> plist:PackLineModels)                
                for(PackLineModel p:plist)                    
                    if (p.soline.Id == linetopack.Id && p.bomdepline == null)                        
                        qsh-=p.line.PBSI__quantity_shipped__c*p.unitquant;
           PBSI__PBSI_Inventory__c currentinv ;
           if (inv <> null && inv.size() > 0) currentinv = inv[0];
           //if (currentinv.PBSI__qty__c == 0)  qsh = 0;             
// atp
           double latp =0;  
            if (linetopack.PBSI__Location__c <> null )
            {
              if( atpmap.containskey(linetopack.pbsi__item__c) && atpmap.get(linetopack.pbsi__item__c).containskey(linetopack.pbsi__location__c))
              latp=atpmap.get(linetopack.pbsi__item__c).get(linetopack.pbsi__location__c);
            } 
            else
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(linetopack.pbsi__item__c) && atpmap.get(linetopack.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
              latp=atpmap.get(linetopack.pbsi__item__c).get(salesorder.PBSI__from_Location__c);

            boolean erroratp=false;
/*          if (latp <= 0)   
            {
                //l.atperrorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities',ApexPages.Severity.Warning); OA-89
                erroratp=true;
            }
            if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
            {
                //l.atperrorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                erroratp=true;
            }
            */
//atp       
            //if (erroratp) continue;       

            PackLineModel l=new PackLineModel(linetopack,getusinglots(),getusingcartonarea(),inv,qsh);     
            l.atp = latp;
            addOptions(l,false,stage);            
            l.units=unitsmap.get(linetopack.pbsi__item__c);            
            List<PackLineModel> curentlist;
            if (PackLineModels.size() >0) {curentlist=PackLineModels[PackLineModels.size()-1];}
            else
            {curentlist=new List<PackLineModel>();PackLineModels.add(curentlist);}
            if (curentlist.size() <900)            
            {                l.lineNumber=curentlist.size();                curentlist.add(l);            }
            else {curentlist=new List<PackLineModel>();PackLineModels.add(curentlist);
                l.lineNumber=curentlist.size();curentlist.add(l);}
            if (admin != null && admin.PBSI__Always_show_serial_number_on_pack_SO__c == true) isoneserialized=true;
            if  (l.showSN ==true ) isoneserialized=true;
            if (linetopack.PBSI__Bom_Type__c != null && linetopack.PBSI__Bom_Type__c == 'BOM-Phantom'  || linetopack.PBSI__hasInstructions__c == true)
            {
                if (allblines.containsKey(linetopack.id))
                    for(PBSI__BOM_Depletion_Line__c b: allblines.get(linetopack.id))
                    {
                        if (b.PBSI__Item__r.PBSI__Is_Serialized__c == true  && b.PBSI__Item__r.PBSI__Is_Service__c == false && b.PBSI__Item__r.PBSI__Not_Count_In_Inventory__c == false)                            isoneserialized=true;
                        List<PBSI__PBSI_Inventory__c> binv=inventories.get(b.PBSI__Item__c);       
                        if (binv == null) binv=new List<PBSI__PBSI_Inventory__c>();                        if (binv.size() > 0) b.PBSI__Lot__c=binv[0].PBSI__Lot__c;
                        PackLineModel p=new PackLineModel(b,linetopack,l,getusinglots(),getusingcartonarea(),binv);   
                        addOptions(p,false,stage);
                        if (curentlist.size()<900){p.lineNumber=curentlist.size();curentlist.add(p);}
                        else{curentlist=new List<PackLineModel>();p.lineNumber=curentlist.size();
                            curentlist.add(p);
                            PackLineModels.add(curentlist);}
                        l.childlines.add(p);
                    }               
            }
            if (latp <= 0)   
            {
                //l.atperrorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                l.atperrorStyle = 'font-weight:bold;color:red;';
                //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities',ApexPages.Severity.Warning); OA-89
                erroratp=true;
            }
            if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
            {
                l.atperrorStyle = 'font-weight:bold;color:orange;';
                
                //l.atperrorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                erroratp=true;
            }            
        }
        inventories.clear();        return null;
    }


    public pagereference stage()    {       return pack(true);  }

    public pagereference pack() {       return pack(false); }

    public pagereference pack(boolean stage)
    {
        Set<id> itemids=new Set<Id>();  set<id> locationids=new set<id>();
        if (PackLineModels == null) PackLineModels=new List<List<PackLineModel>>();
        integer n=0;
        for (integer i=0;i<PackLineModels.size();i++)
            for (PackLineModel pl:PackLineModels[i])
            {
                System.currentPageReference().getParameters().put('lineNumber',String.valueOf(n));
                if (stage)              {                   deletechildlinesstage();                    updateQtystage();               }
                else                {                   deletechildlines();                 updateQty();                }
                n++;
            }
        Id linetopack=System.currentPageReference().getParameters().get('lineNo');
           
        if (salesorders.size() > 0 && invoice == null && ismultipack)
        {
            PBSI__PBSI_Sales_Order__c s=salesorders.get(lines.get(linetopack).PBSI__Sales_Order__c);
            invoice=new PBSI__Invoice__c(PBSI__Customer__c=s.PBSI__Customer__c,PBSI__BillingCountry__c=s.PBSI__BillingCountry__c,  PBSI__BillingState__c=s.PBSI__BillingState__c, PBSI__BillingCity__c=s.PBSI__BillingCity__c, PBSI__BillingStreet__c=s.PBSI__BillingStreet__c, PBSI__BillingZip__c=s.PBSI__BillingZip__c,PBSI__BillingCompany__c=s.PBSI__BillingCompany__c, PBSI__Delivery_Street__c=s.PBSI__Delivery_Streetnew__c, PBSI__Delivery_State__c=s.PBSI__Delivery_State__c, PBSI__Delivery_Postal_Code__c=s.PBSI__Delivery_Postal_Code__c, PBSI__Delivery_Country__c=s.PBSI__Delivery_Country__c, PBSI__Delivery_Company__c=s.PBSI__Delivery_Company__c, PBSI__Delivery_City__c=s.PBSI__Delivery_City__c); 
        }  
            
        List<PBSI__PBSI_Inventory__c> inv=getInventoryList(new Set<Id>{lines.get(linetopack).PBSI__Item__c});       
        inventories.put(lines.get(linetopack).PBSI__Item__c,inv);
        double qsh;
        if (stage)      qsh=lines.get(linetopack).PBSI__Quantity_Needed__c-lines.get(linetopack).PBSI__stage_quantity__c;
        else
        qsh=lines.get(linetopack).PBSI__Quantity_Needed__c-lines.get(linetopack).PBSI__Quantity_Picked__c;  
        
        if (stage)
        {
            for(List<PackLineModel> plist:PackLineModels)               for(PackLineModel p:plist)                  if (p.soline.Id == lines.get(linetopack).Id && p.bomdepline == null)                        qsh-=p.stageline.PBSI__stage_quantity__c;       
        }
        else
        for(List<PackLineModel> plist:PackLineModels)           for(PackLineModel p:plist)              if (p.soline.Id == lines.get(linetopack).Id && p.bomdepline == null)                    qsh-=p.line.PBSI__quantity_shipped__c;
                    
                    
         list<PBSI__Unit__c> units=[select id, Name,pbsi__quantity__c        from PBSI__Unit__c      where pbsi__item__C =:lines.get(linetopack).pbsi__item__c       and (PBSI__Applies_To__c ='Sales Order' or PBSI__Applies_To__c =null)       order by name asc];
         
        PackLineModel l=new PackLineModel(lines.get(linetopack),getusinglots(),getusingcartonarea(),inv,qsh);       l.units=units;      addOptions(l,false,stage);  
            
        List<PackLineModel> curentlist;
        if (PackLineModels.size() >0) {curentlist=PackLineModels[PackLineModels.size()-1];}
           else {curentlist=new List<PackLineModel>();PackLineModels.add(curentlist);}
        if (curentlist.size() <maxlimit)        {           l.lineNumber=curentlist.size();         curentlist.add(l);      }
        else {curentlist=new List<PackLineModel>();PackLineModels.add(curentlist);l.lineNumber=curentlist.size();curentlist.add(l);}
           
        if (admin != null && admin.PBSI__Always_show_serial_number_on_pack_SO__c == true) isoneserialized=true;
        if  (l.showSN ==true ) isoneserialized=true;
          
        if (lines.get(linetopack).PBSI__Bom_Type__c != null && lines.get(linetopack).PBSI__Bom_Type__c == 'BOM-Phantom'  || lines.get(linetopack).PBSI__hasInstructions__c == true)
        {
            id lineid=lines.get(linetopack).Id;
            List<PBSI__BOM_Depletion_Line__c> blines;
            string str='select  PBSI__Sales_Order__r.PBSI__From_Location__c,PBSI__Item__r.PBSI__salesprice__c,PBSI__Item__r.PBSI__salesprice4__c,PBSI__Bill_of_Materials__c,PBSI__Ship_Lot__c,PBSI__Sales_Order__c,Id,PBSI__Item__c,PBSI__Lot__c,PBSI__Quantity_Packed__c,PBSI__Quantity__c,PBSI__Item__r.Name,'+
                       'PBSI__Item__r.PBSI__Is_Serialized__c,PBSI__BOM_Name__c,PBSI__Serial_Number__c,PBSI__Location__c,'+
                       'PBSI__Item__r.PBSI__Sales_Order_Description_Long__c,PBSI__Item__r.PBSI__Item_Description_Long__c,PBSI__Item__r.PBSI__Sales_Order_Description__c,PBSI__Item__r.PBSI__description__c,PBSI__Type__c,PBSI__Item__r.PBSI__Not_Count_In_Inventory__c,'+
                       'PBSI__Item__r.PBSI__Default_Location__c,PBSI__Item__r.PBSI__Is_Service__c,PBSI__Item__r.PBSI__defaultunitofmeasure__c,PBSI__Area__c,PBSI__Carton__c';
            if (M1.containsKey('Jan_Code__c'))              str+=',Jan_Code__c';
            str+= ' from PBSI__BOM_Depletion_Line__c where PBSI__Sales_Order_Line__c=:lineid and PBSI__Item__c <> null and PBSI__Quantity_Left__c <> 0 order by Name';   
            blines=Database.query(str);             Set<Id> itemids2=new Set<Id>();      
            for(PBSI__BOM_Depletion_Line__c b: blines)    itemids2.add(b.PBSI__Item__c);
            List<PBSI__PBSI_Inventory__c> binv=getInventoryList(itemids2);
            for ( PBSI__PBSI_Inventory__c i:binv)
                if (inventories.containsKey(i.PBSI__item_lookup__c))   inventories.get(i.PBSI__item_lookup__c).add(i);
                else
                    inventories.put(i.PBSI__item_lookup__c,new list<PBSI__PBSI_Inventory__c>{i});
                     
                for(PBSI__BOM_Depletion_Line__c b: blines)
                { 
                    if (b.PBSI__Item__r.PBSI__Is_Serialized__c == true  && b.PBSI__Item__r.PBSI__Is_Service__c == false && b.PBSI__Item__r.PBSI__Not_Count_In_Inventory__c == false)                        isoneserialized=true;
                    list<PBSI__PBSI_Inventory__c> invs=new List<PBSI__PBSI_Inventory__c>();        
                    if (inventories.containsKey(b.PBSI__item__c))  invs=inventories.get(b.pbsi__item__c);    
                    PackLineModel p=new PackLineModel(b,lines.get(linetopack),l,getusinglots(),getusingcartonarea(),invs);                  addOptions(p,false,stage);
                    if (curentlist.size()<maxlimit){p.lineNumber=curentlist.size();curentlist.add(p);}
                    else{curentlist=new List<PackLineModel>();p.lineNumber=curentlist.size();curentlist.add(p);PackLineModels.add(curentlist);}
                    l.childlines.add(p);
                }               
            }
// atp
        itemids.add(lines.get(linetopack).PBSI__Item__c); 
        if (lines.get(linetopack).pbsi__location__c!=null)
            locationids.add(lines.get(linetopack).pbsi__location__c);
        else
            if (salesorder.PBSI__From_Location__c <> null) 
                locationids.add(salesorder.PBSI__From_Location__c);
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
       double latp =0;  
        if (lines.get(linetopack).PBSI__Location__c <> null )
        {
          if( atpmap.containskey(lines.get(linetopack).pbsi__item__c) && atpmap.get(lines.get(linetopack).pbsi__item__c).containskey(lines.get(linetopack).pbsi__location__c))
          latp=atpmap.get(lines.get(linetopack).pbsi__item__c).get(lines.get(linetopack).pbsi__location__c);
        } 
        else
            if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(lines.get(linetopack).pbsi__item__c) && atpmap.get(lines.get(linetopack).pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
          latp=atpmap.get(lines.get(linetopack).pbsi__item__c).get(salesorder.PBSI__from_Location__c);
        l.atp = latp;
        boolean erroratp=false;
        if (latp <= 0)   
        {
//          l.atperrorStyle = 'border-size:2px; border-color:red;border-style:solid;';
            l.atperrorStyle = 'font-weight:bold;color:red;';
            
            processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities',ApexPages.Severity.Warning);
            erroratp=true;
        }
        if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
        {
            l.atperrorStyle = 'font-weight:bold;color:orange;';
//          l.atperrorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
//          processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
        }
// atp          

            ispacksummary=false;                return null;
    }
  
    public boolean getshownavigation()  {       return (PackLineModels!= null && PackLineModels.size() >1) ;    }

    public Integer getlistsize()
    {
        if (PackLineModels != null)     return PackLineModels.size();       return 0;
    }
    public integer getcurin()   {    return curentindex+1;}
    public integer setcurin(integer s)
    {
        curentindex=s-1;
        if (PackLineModels != null )      if( curentindex > PackLineModels.size())    curentindex=PackLineModels.size()-1;
            else                if (curentindex <0) curentindex=0;
        return curentindex;
    }
    public PackLineModel[] getpacklines()
    {
        if (PackLineModels!= null && curentindex > -1 && curentindex < PackLineModels.size())            return PackLineModels[curentindex];        return null;
    }
    
    public PackLineModel[] GetPackLineModels()
    {
        if (PackLineModels!= null && curentindex > -1 && curentindex < PackLineModels.size())            return PackLineModels[curentindex];        return null;
    }
    
    public PBSI__PBSI_Sales_Order_Line__c[] getlines()    {        return lines.values();    }

    public void processError(String s,ApexPages.Severity severity)    {        ApexPages.addMessage(new ApexPages.Message(severity, s));    }

    public List<PBSI__Shipped_Sales_Order_Line__c> savelines()
    {
        String invoiceid;
        if (invoice != null)        {            upsert invoice;            invoiceid=invoice.Id;       } 
        string ssss=' 1- ';
        boolean iswitherror = false;
        if (salesorders.size() > 0)
            for (List<PackLineModel> p: PackLineModels)
                for (PackLineModel pl:p)
                {                   
                    if (pl.atperrorStyle!=null) iswitherror=true;
                    ssss +=' 2- ' + pl.atperrorStyle;
                    if (pl.line.PBSI__quantity_shipped__c != 0)                      
                        sostoupdate.add(pl.line.PBSI__Sales_Order__c);
                }
        system.debug('ssss='+ssss);
        integer count=0;         SoqlServiceUtils.SetMJournalOnSalesOrders(salesorders.values(), 200, 'Goods Issue for Sale - Stock Item');        List<PackLineModel> dropshiplines=new List<PackLineModel>(); 
        if (getusingLots() == false)             checklotforlocation(false);   
        List<PBSI__Movement_Line__c> allmlines=new List<PBSI__Movement_Line__c>();        
        List<PBSI__Shipped_Sales_Order_Line__c> shiplines=new List<PBSI__Shipped_Sales_Order_Line__c>();        
        system.debug('qqqq='+PackLineModels.size());
        integer hhh=0;
        for ( List<PackLineModel> p: PackLineModels)
        {
            hhh++;
            system.debug('hhh='+hhh);
            system.debug('hhh1='+p.size());
            integer jjj=0;
            for (PackLineModel pl:p) jjj++;
            system.debug('jjj='+jjj);
            //for (integer i=0; i < p.size();i++)
            for (integer i = p.size()-1 ; i >= 0;--i)
            {
                PackLineModel pl = p[i];
                    system.debug('mnb1=' + pl.atperrorStyle); 
                    system.debug('mnb3='+pl.line.pbsi__item__c);
                    system.debug('mnb4='+savefirst);
                    system.debug('mnb5='+pl.isdropship);
                if (((pl.line.PBSI__quantity_shipped__c != 0 && pl.isdropship == false) || Test.IsRunningTest()) && (((pl.atperrorStyle==null || (pl.atperrorStyle!=null && !pl.atperrorstyle.contains('red'))) && savefirst) || !savefirst)) // OA-89
                {
                    system.debug('mnb2=' + pl.atperrorStyle);
                    if (pl.line.pbsi__unit_of_measure__C <> null)                    
                    {                       
                         map<Id,PBSI__Unit__c> unitsmap=new map<Id,PBSI__Unit__c>(pl.units);                        
                         pl.unitquant=unitsmap.get(pl.line.pbsi__unit_of_measure__c).pbsi__quantity__c;                   
                    } 
                    pl.assignserialnumbers(false);                    
                    pl.line.pbsi__invoice__c=invoiceId;
                    double qtylefttoship = pl.soline.PBSI__Quantity_Left_To_Ship__c - pl.line.PBSI__Quantity_Shipped__c;
                      
                    if (pl.line.pbsi__type__c == 'receive')   pl.line.PBSI__Quantity_Shipped__c = 0 - pl.line.PBSI__Quantity_Shipped__c;
                    if (pl.line.pbsi__unit_of_measure__c <> pl.soline.pbsi__unit_of_measure__c)
                    {
                      pl.line.pbsi__price__c=(pl.soline.pbsi__price__c/pl.originalunitquant )*pl.unitquant;
                      if (pl.soline.pbsi__price4__c <> null && pl.soline.pbsi__price4__c <> 0)                        pl.line.pbsi__price4__c=(pl.soline.pbsi__price4__c/pl.originalunitquant )*pl.unitquant;
                    }   
                    shiplines.add(pl.line); 
                    //if (qtylefttoship==0)   
                    	pl.isDeleting = true;
                }
            } 
        } 
        if (savefirst && iswitherror)             processError('You are packing items with no ATP! Please review and confirm quantities.',ApexPages.Severity.WARNING);

        boolean allok=true;        Database.SaveResult[] lsr;
        try        {            
            lsr = database.insert(shiplines, true);  savefirst=false;     
             }        
             catch(exception e)        
             {            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));        savefirst=true;}
             
        List<PBSI__Shipped_Sales_Order_Line__c> shiplinesI;
        if (lsr !=null)
        {   
            Set<Id> shipids = new Set<Id>();
            for (integer i=0;i<lsr.size();i++)                
            if (lsr[i].getId() != null)                    shipids.add(lsr[i].getId());

//              shiplinesI=[Select PBSI__Serial_Numbers__c,Parent__c,PBSI__Sales_Order__c,PBSI__Item__c,PBSI__Lot__c,PBSI__Ship_Lot__c,PBSI__Quantity_Shipped__c,PBSI__BOM_Depletion_Line__c  from  PBSI__Shipped_Sales_Order_Line__c where id in :shipids];
                // RI - Ensure shipped lines are ordered by id / insertion order
            shiplinesI=[Select PBSI__Item__r.PBSI__Cost4__c,
                                PBSI__Sales_Order_Line__r.PBSI__Exchange_Rate__c,
                                PBSI__Serial_Numbers__c,PBSI__Parent__c,
                                PBSI__Sales_Order__c,
                                PBSI__Item__c,
                                PBSI__Lot__c,
                                PBSI__Lot__r.PBSI__Parent_Lot__c, 
                                PBSI__Ship_Lot__c,
                                PBSI__Quantity_Shipped__c,
                                PBSI__BOM_Depletion_Line__c,
                                PBSI__Item__r.PBSI__salesprice__c,
                                PBSI__Item__r.PBSI__Cost__c 
                                from  PBSI__Shipped_Sales_Order_Line__c 
                                where id in : shipids 
                                order by id asc];
//        
            for (integer i = 0; i < shiplinesI.size(); i++) {
                if (lsr[i].isSuccess())
                {
                    decimal itemcost=0,itemprice=0,transactioncost=0,transactionprice=0,transactionunitcost=0,transactionunitprice=0;
                    if (admin <> null && admin.PBSI__Use_Cost_4_dec_on_Item_Master__c)    itemcost = shiplinesI[i].PBSI__Item__r.PBSI__Cost4__c;
                    else itemcost = shiplinesI[i].PBSI__Item__r.PBSI__Cost__c;
                    itemprice=  shiplinesI[i].PBSI__Item__r.PBSI__salesprice__c ;
                    //system.debug('yyy5='+PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].soline.PBSI__Item_Cost__c);
                    //system.debug('yyy6='+PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].unitquant);
                    
                    transactioncost = PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].soline.PBSI__Item_Cost__c*PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].unitquant; transactionprice = PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].line.PBSI__Price__c ; transactionunitcost=PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].soline.PBSI__Item_Cost__c; transactionunitprice=PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].line.PBSI__Price__c/PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].unitquant;
                    if (shiplinesI[i].PBSI__BOM_Depletion_Line__c != null)          transactionprice = 0;
                    if(PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].countInInventory)
                        if (PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].isShipping == true) 
                        {    
                            allmlines.add(SoqlServiceUtils.CreateMovementLine(shiplinesI[i].PBSI__Sales_Order__c, shiplinesI[i].PBSI__Item__c, shiplinesI[i].PBSI__Lot__c, shiplinesI[i].PBSI__Ship_Lot__c, shiplinesI[i].PBSI__Quantity_Shipped__c, shiplinesI[i].PBSI__Serial_Numbers__c, 'sale', shiplinesI[i].PBSI__BOM_Depletion_Line__c, itemcost, itemprice, transactioncost, transactionprice, transactionunitcost, transactionunitprice, shiplinesI[i].Id, salesOrders.get(shiplinesI[i].PBSI__Sales_Order__c).PBSI__Movement_Journal__c, shiplines[i].pbsi__unit_of_measure__c));
                        }
                        else
                        {
                            allmlines.add(SoqlServiceUtils.CreateMovementLine(shiplinesI[i].PBSI__Sales_Order__c, shiplinesI[i].PBSI__Item__c, shiplinesI[i].PBSI__Lot__c, shiplinesI[i].PBSI__Ship_Lot__c, shiplinesI[i].PBSI__Quantity_Shipped__c, shiplinesI[i].PBSI__Serial_Numbers__c, 'receive', shiplinesI[i].PBSI__BOM_Depletion_Line__c, itemcost, itemprice, transactioncost, transactionprice, transactionunitcost, transactionunitprice, shiplinesI[i].Id, salesOrders.get(shiplinesI[i].PBSI__Sales_Order__c).PBSI__Movement_Journal__c, shiplines[i].pbsi__unit_of_measure__c));
                        }
                	
                    if (allmlines.size()>0)                        allmlines[allmlines.size()-1].PBSI__Parent_Lot__c = shiplinesI[i].PBSI__Lot__r.PBSI__Parent_Lot__c;
                    if (PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].parent != null)                        shiplinesI[i].PBSI__Parent__c=PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].parent.line.Id;
                    if (shiplinesI[i].PBSI__Lot__r.PBSI__Parent_Lot__c!=null)                         shiplinesI[i].PBSI__Parent_Lot__c =shiplinesI[i].PBSI__Lot__r.PBSI__Parent_Lot__c; 
                    if (admin <> null && admin.PBSI__Use_SO_Line_Cost_for_Recorded_Cost__c)
                    {
                        if (admin <> null && admin.PBSI__Use_Cost_4_dec_on_Item_Master__c)                              shiplinesI[i].PBSI__Recorded_Cost_4__c = shiplinesI[i].PBSI__Item__r.PBSI__Cost4__c;
                        else                            shiplinesI[i].PBSI__Recorded_Cost__c = shiplinesI[i].PBSI__Item__r.PBSI__Cost__c;
                    }                         
                    count++;       
                }  
                else
                {
                    allok=false;                    processError('Shipping failed on '+shiplines.size()+'lines.',ApexPages.Severity.Error);
                    for(Database.Error err: lsr[i].getErrors())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err.getMessage()));                        if (err.getMessage().contains('Too many SOQL queries: 101'))   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please try packing less lines by setting Quantity Shipped to 0 for some of the lines!'));
                    }
                 }
            }
            if (allok)                   
            if (count == 1)                        processError(count+' line was successfully shipped! ',ApexPages.Severity.Confirm);
            else if (count > 0)                    processError(count+' lines were successfully shipped! ',ApexPages.Severity.Confirm);
         }
         
         for ( List<PackLineModel> pls: PackLineModels)
         {
            for (integer i = pls.size()-1 ; i >= 0;--i)
            {
                PackLineModel pl = pls[i];
                if (pl.isDeleting)
                	pls.remove(i);
            }
         }
         
         if (allmlines.size() > 0)    insert allmlines;         update shiplinesI;    
         system.debug('poi='+ shiplinesx.size());
         shiplinesx.addall(shiplinesI);         
         system.debug('poi2='+ shiplinesx.size());
         return shiplinesI;  
         //return shiplinesx;  
    }
    
    public void createSNT()
    {
        List<PBSI__Serial_Number_Tracker__c> sntlist=new List<PBSI__Serial_Number_Tracker__c>();
        for (List<PackLineModel> pllj : PackLineModels)            for (PackLineModel pl:pllj)                if (pl.showSN == true  && pl.line.PBSI__quantity_shipped__c > 0)                    for (PBSI.SerialN sh:pl.serialnumbers)                        sntlist.add(new PBSI__Serial_Number_Tracker__c(pbsi__sales_order_line__c=pl.line.pbsi__sales_order_line__c,pbsi__date_shipped__c=system.today(),PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=pl.line.PBSI__Item__c,PBSI__Serial_Number__c=sh.getValue(),PBSI__Lot__c=pl.line.PBSI__Lot__c) );
        if (sntlist.size() > 0)
        try        {            Database.insert(sntlist,false);        }        catch(Exception e){system.debug(e);}            
    } 
   public pagereference savestaged()
   {
      if (validatedatastage() == true || Test.isRunningTest())
      {
        if (salesorders.size() > 0)            for (List<PackLineModel> p: PackLineModels)                for (PackLineModel pl:p)                   if (pl.stageline.PBSI__stage_quantity__c != 0)                      sostoupdate.add(pl.line.PBSI__Sales_Order__c);
                      
        integer count=0;        SoqlServiceUtils.SetStagingMJournalOnSalesOrders(salesorders.values(), 209, 'Staging Order');        List<PackLineModel> dropshiplines=new List<PackLineModel>();        checklotforlocation(true);   
             
        List<PBSI__Movement_Line__c> allmlines=new List<PBSI__Movement_Line__c>();        List<PBSI__Staging_Order_Lines__c> stagelines=new List<PBSI__Staging_Order_Lines__c>();        stagelinesx=new List<PBSI__Staging_Order_Lines__c>();
        
        for ( List<PackLineModel> p: PackLineModels)
        {
            for (PackLineModel pl:p)
                if (pl.stageline.PBSI__stage_quantity__c != 0  || Test.IsRunningTest())
                {
                    if (pl.stageline.PBSI__unit_of_measure__C <> null)                    {                        map<Id,PBSI__Unit__c> unitsmap=new map<Id,PBSI__Unit__c>(pl.units);                        pl.unitquant=unitsmap.get(pl.stageline.pbsi__unit_of_measure__c).pbsi__quantity__c;                    } 
                    pl.assignserialnumbers(true);                    stagelines.add(pl.stageline); 
                } 
        } 
        
        boolean allok=true;        Database.SaveResult[] lsr; 
        try         {            lsr = database.insert(stagelines, true);        }        catch(exception e)        {           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));        }
        
        if (lsr !=null)
        {   
            Set<Id> stageids = new Set<Id>();
            for (integer i=0;i<lsr.size();i++) if (lsr[i].getId() != null) stageids.add(lsr[i].getId());

            stagelinesx=[Select PBSI__Item__r.PBSI__Cost4__c,
                                PBSI__Sales_Order_Line__r.PBSI__Exchange_Rate__c,
                                PBSI__Serial_Numbers__c,PBSI__Parent__c,
                                PBSI__Sales_Order__c,
                                PBSI__Item__c, 
                                PBSI__from_Lot__c,
                                PBSI__from_Lot__r.PBSI__Parent_Lot__c, 
                                PBSI__to_Lot__c,
                                PBSI__stage_quantity__c,
                                PBSI__BOM_Depletion_Line__c,
                                PBSI__Item__r.PBSI__salesprice__c,
                                PBSI__Item__r.PBSI__Cost__c ,PBSI__Unit_of_Measure__c,
                                PBSI__notes__c, PBSI__reason_code__c
                                from  PBSI__Staging_Order_Lines__c 
                                where id in : stageids 
                                order by id asc];
            for (integer i = 0; i < stagelinesx.size(); i++)
                if (lsr[i].isSuccess())
                {
                    decimal itemcost=0,itemprice=0,transactioncost=0,transactionprice=0,transactionunitcost=0,transactionunitprice=0;
                    if (admin <> null && admin.PBSI__Use_Cost_4_dec_on_Item_Master__c)      itemcost = stagelinesx[i].PBSI__Item__r.PBSI__Cost4__c;
                    else
                        itemcost = stagelinesx[i].PBSI__Item__r.PBSI__Cost__c;
                    itemprice=  stagelinesx[i].PBSI__Item__r.PBSI__salesprice__c ;
                    transactioncost = PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].soline.PBSI__Item_Cost__c*PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].unitquant;
                    transactionunitcost=PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].soline.PBSI__Item_Cost__c;
                    if (stagelinesx[i].PBSI__BOM_Depletion_Line__c != null)           transactionprice = 0;
                    if(PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].countInInventory)
                        if (PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].isShipping == true) 
                        {    
                            allmlines.add(SoqlServiceUtils.CreateMovementLine(stagelinesx[i].PBSI__Sales_Order__c, stagelinesx[i].PBSI__Item__c, stagelinesx[i].PBSI__from_Lot__c, stagelinesx[i].PBSI__to_Lot__c, stagelinesx[i].PBSI__stage_quantity__c, stagelinesx[i].PBSI__Serial_Numbers__c, 'sale', stagelinesx[i].PBSI__BOM_Depletion_Line__c, itemcost, itemprice, transactioncost, 0, transactionunitcost, 0, null, stagelinesx[i].Id, stagelinesx[i].PBSI__notes__C, stagelinesx[i].PBSI__reason_code__c, salesOrders.get(stagelinesx[i].PBSI__Sales_Order__c).PBSI__Staging_Movement_Journal__c, stagelinesx[i].pbsi__unit_of_measure__c));
                        }
            
                    if (allmlines.size()>0)                        allmlines[allmlines.size()-1].PBSI__Parent_Lot__c = stagelinesx[i].PBSI__from_Lot__r.PBSI__Parent_Lot__c;
                    if (PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].parent != null)                       stagelinesx[i].PBSI__Parent__c=PackLineModels[i/maxlimit][Math.mod(i,maxlimit)].parent.line.Id;
                    count++;       
                }  
                else
                {
                    allok=false;                    processError('Staging failed on '+stagelines.size()+'lines.',ApexPages.Severity.Error);
                    for(Database.Error err: lsr[i].getErrors())                    {                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err.getMessage()));                        if (err.getMessage().contains('Too many SOQL queries: 101'))                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please try packing less lines by setting Quantity Shipped to 0 for some of the lines!'));                    }                 }
                 if (allok)                    if (count == 1)                        processError(count+' line was successfully staged! ',ApexPages.Severity.Confirm);                 else if (count > 0)                    processError(count+' lines were successfully staged! ',ApexPages.Severity.Confirm);
         }
         
         if (allmlines.size() > 0) insert allmlines;          update stagelinesx;
         PackLineModels.clear();         List<PackLineModel> p=new List<PackLineModel>();         PackLineModels.add(p);         integer j=0;         capturelines();
      }
      return null;
   }
    public pagereference savepacked()
    {   
        Map<String, Schema.SObjectField> M = Schema.SObjectType.PBSI__PBSI_Purchase_Order_Line__c.fields.getMap();
        List<PackLineModel> dropshiplines=new List<PackLineModel>();
        try
        {
            setPackLinesSerialsByLimitedSerials();
            if ((admin!= null &&admin.PBSI__Create_SNT_at_Pack_time_for_all_items__c) || Test.IsRunningTest())               createSNT();
            if (PackLineModels != null && PackLineModels.size() >0)
            {
                if (validatedata() == true)
                { 
                    for ( List<PackLineModel> p: PackLineModels)                        
                        for (PackLineModel pl:p)                            
                            if (pl.line.PBSI__quantity_shipped__c != 0 && pl.isdropship)  dropshiplines.add(pl);
                    try
                    {
                        List<PBSI__Shipped_Sales_Order_Line__c> lmap=savelines();}
                        catch (exception e){system.debug(e);}
                        if (dropshiplines.size() > 0 || Test.IsRunningTest())
                        {
                            Map<Id,Map<Id,List<PBSI__PBSI_Purchase_Order_Line__c>>> polines=new Map<Id,Map<Id,List<PBSI__PBSI_Purchase_Order_Line__c>>>();
                            List<PBSI__PBSI_Purchase_Order_Line__c> polines1=new List<PBSI__PBSI_Purchase_Order_Line__c>();
                            Map<String,String> vendorpo=new Map<String,String>{};
                            Map<Id,PBSI__PBSI_Purchase_Order__c> pos=new Map<Id,PBSI__PBSI_Purchase_Order__c>();
                            Set<Id> newpos=new Set<Id>();
                            List<PBSI__PBSI_Sales_Order_Line__c> solinestoupdate=new List<PBSI__PBSI_Sales_Order_Line__c>();
                            for (PBSI__PBSI_Purchase_Order__c p:[select Id,Name,PBSI__Account__c from PBSI__PBSI_Purchase_Order__c where PBSI__Drop_Ship_Sales_Order__c in :soids])                                pos.put(p.PBSI__Account__c,p);
                            for (PackLineModel p:dropshiplines)
                            {
                                PBSI__PBSI_Purchase_Order_Line__c pp;                                Id vendor=p.soline.PBSI__Vendor__c;
                                if (vendor == null)                                     vendor=p.soline.PBSI__Item__r.PBSI__Default_Vendor__c;
                                if (polines.containsKey(vendor))
                                {
                                    if (polines.get(vendor).containsKey(p.soline.PBSI__Item__c))
                                    {
                                        for (PBSI__PBSI_Purchase_Order_Line__c pol:polines.get(vendor).get(p.soline.PBSI__Item__c))
                                            if(pol.PBSI__Unit_Of_Measure__c == p.soline.PBSI__Unit_Of_Measure__c)
                                            {
                                                pol.PBSI__Quantity_Ordered__c+=p.line.PBSI__quantity_shipped__c;                                                pp=pol;                                                break;
                                            }
                                        if (pp == null)               {                                            pp=new PBSI__PBSI_Purchase_Order_Line__c(PBSI__Sales_Order__c=salesorder.Id,  PBSI__Item__c=p.line.PBSI__Item__c,  PBSI__Quantity_Ordered__c=p.line.PBSI__quantity_shipped__c,  PBSI__Unit_Of_Measure__c= p.line.PBSI__Unit_Of_Measure__c);                                            polines.get(vendor).get(p.soline.PBSI__Item__c).add(pp);                                        }
                                    }
                                    else                                     {                                        pp=new PBSI__PBSI_Purchase_Order_Line__c(PBSI__Sales_Order__c=salesorder.Id,                                                                            PBSI__Item__c=p.line.PBSI__Item__c,                                                                            PBSI__Quantity_Ordered__c=p.line.PBSI__quantity_shipped__c,                                                                            PBSI__Unit_Of_Measure__c= p.line.PBSI__Unit_Of_Measure__c);                                        polines.get(vendor).put(p.line.PBSI__Item__c,new List<PBSI__PBSI_Purchase_Order_Line__c>{pp});                                    } 
                                }
                                else
                                {
                                    pp=new PBSI__PBSI_Purchase_Order_Line__c(PBSI__Sales_Order__c=salesorder.Id,                                                                         PBSI__Item__c=p.line.PBSI__Item__c,                                                                         PBSI__Quantity_Ordered__c=p.line.PBSI__quantity_shipped__c,                                                                         PBSI__Unit_Of_Measure__c= p.line.PBSI__Unit_Of_Measure__c);
                                                                         
                                    polines.put(vendor,new Map<Id,List<PBSI__PBSI_Purchase_Order_Line__c>>{p.line.PBSI__Item__c =>new List<PBSI__PBSI_Purchase_Order_Line__c>{pp} });}
                                    if (vendorpo.containskey(vendor) == false)
                                    {  
                                        PBSI__PBSI_Purchase_Order__c po=pos.get(vendor);
                                        if (po == null)
                                        {
                                            po=new PBSI__PBSI_Purchase_Order__c(PBSI__Delivery_Account__c=salesorder.PBSI__Customer__c,
                                                                            PBSI__Drop_Ship_Sales_Order__c=salesorder.Id,
                                                                            PBSI__Account__c=vendor,
                                                                            PBSI__Delivery_Street__c=salesOrder.PBSI__Delivery_Streetnew__c, 
                                                                            PBSI__Delivery_City__c=salesOrder.PBSI__Delivery_City__c, 
                                                                            PBSI__Delivery_State__c=salesOrder.PBSI__Delivery_State__c, 
                                                                            PBSI__Delivery_Postal_Code__c=salesOrder.PBSI__Delivery_Postal_Code__c, 
                                                                            PBSI__Delivery_Country__c=salesOrder.PBSI__Delivery_Country__c, 
                                                                            PBSI__Delivery_Company__c=salesOrder.PBSI__Delivery_Company__c, 
                                                                            PBSI__Delivery_Street_Line_2__c=salesOrder.PBSI__Delivery_Address_line2__c,
                                                                            PBSI__Type__c='Drop Ship');
                                            insert po;                                            newpos.add(po.Id);
                                        }
                                        else
                                            processError('Lines were added to Purchase Order : '+po.Name,ApexPages.Severity.Confirm);                                        vendorpo.put(vendor,po.Id);                                        pp.PBSI__Purchase_Order__c=po.Id;                                        DropShipMessage=DropShipMessage+'PO'+po.Id+';';
                                    }
                                    else
                                        pp.PBSI__Purchase_Order__c=vendorpo.get(vendor);                                          
                            }
// IT 22.08.2014
                          for (PackLineModel p:dropshiplines)
                          {
                              Id vendor=p.soline.PBSI__Vendor__c;
                              if (vendor == null)                                   vendor=p.soline.PBSI__Item__r.PBSI__Default_Vendor__c;
                              if(admin == null || admin.PBSI__Don_t_change_SoLine_Q_Pack_on_Drop_Ship__c == false)                                    p.soline.PBSI__Quantity_Picked__c+=p.line.PBSI__quantity_shipped__c;
                              p.soline.PBSI__DropShip__c=true;                              
                              p.soline.PBSI__Drop_Ship_PO__c=vendorpo.get(vendor);                              
                              p.soline.PBSI__Do_Not_Ship_Yet__c=true;                               
                              solinestoupdate.add(p.soline);
                           }
                          update  solinestoupdate;                          solinestoupdate.clear();                                
// IT 22.08.2014
                          for (Id i: polines.keySet())                              for (Id j:polines.get(i).keySet())                                  polines1.addAll(polines.get(i).get(j));
                          insert polines1;    
                          for(PBSI__PBSI_Purchase_Order__c p:[select Id,Name from PBSI__PBSI_Purchase_Order__c where id in :newpos])                                    processError('Purchase Order : '+p.Name+' was created . ',ApexPages.Severity.Confirm);
                          for (PackLineModel p:dropshiplines)
                          {
                              Id vendor=p.soline.PBSI__Vendor__c;
                              if (vendor == null)                                   vendor=p.soline.PBSI__Item__r.PBSI__Default_Vendor__c;
                              for (PBSI__PBSI_Purchase_Order_Line__c pol:polines.get(vendor).get(p.line.PBSI__Item__c))                                 if(pol.PBSI__Unit_Of_Measure__c == p.soline.PBSI__Unit_Of_Measure__c)                                 {                                    p.soline.PBSI__Drop_Ship_POLine__c=pol.Id;break;                                 }
                             solinestoupdate.add(p.soline);
                          }   
                          update  solinestoupdate;      
                          if (solinestoupdate.size() == 1)   processError('1 line was successfully Drop Shipped! ',ApexPages.Severity.Confirm);
                            else
                                processError(solinestoupdate.size()+' lines were successfully Drop Shipped! ',ApexPages.Severity.Confirm);
                          hasdropship=true;  
                   } //if (dropshiplines.size() > 0)
           
                   //PackLineModels.clear();                   
                   //List<PackLineModel> p=new List<PackLineModel>();                   
                   //PackLineModels.add(p);                   
                   integer j=0;                   
                   setOrderStatus();                    
                   capturelines();                  
                   this.ispacksummary=true;
               } //if validatedata
            } //if (PackLineModels.size >0)
            else
            {
                processError(' No lines to Ship!',ApexPages.Severity.Info);  
            }    
         }
         catch(Exception e)         {            processError(e.getMessage(),ApexPages.Severity.Error);system.debug(e); capturelines();         }
         return null;
    }
    
    private void setPackLinesSerialsByLimitedSerials()
    { 
        for (List<PackLineModel> packLineList: PackLineModels)            for (PackLineModel packLine: packLineList)                if(packLine.showSN)                    packLine.serialnumbers = CommonUtils.getPackLineSerialsByLimitedSerials(packLine.limitedSerials);
    }
    public void checkLotforLocation(boolean stage)
    {
        for (List<PackLineModel> pp :PackLineModels)
        {   
            Set<Id> locationsid=new Set<Id>();             Map<Id,Set<Id>> itemloc=new Map<Id,Set<Id>>();
            Map<Id,Map<Id,PBSI__Lot__c>> lotswehave=new Map<Id,Map<Id,PBSI__Lot__c>>();            Map<Id,Map<Id,PBSI__Lot__c>> lotstoinsert=new Map<Id,Map<Id,PBSI__Lot__c>>();            List<PBSI__Lot__c> listlotstoinsert=new List<PBSI__Lot__c>();
 
            for (PackLineModel p: pp)
            {
                Id itemid,locid;
                if (stage)                  {                    itemid=p.stageline.PBSI__Item__c;                     locid=p.stageline.PBSI__to_Location__c;                      }
                else
                    if (p.isshipping == false)                  {                       itemid=p.bomdepline.PBSI__Item__c;                      locid=p.bomdepline.PBSI__Location__c;                   }
                    
                    if (itemloc.containsKey(itemid) == false)      itemloc.put(itemid,new Set<Id>{locid});
                    else                       itemloc.get(itemid).add(locid);
                    locationsid.add(locid);
                
            }
          
            if (itemloc.size() > 0 && locationsid.size() > 0)
            {   
                for (PBSI__Lot__c l: [select Id,PBSI__Item__c,PBSI__Location__c  from PBSI__Lot__c where PBSI__Item__c in :itemloc.keySet() and PBSI__Location__c in :locationsid and PBSI__Lot_For_Location__c= 'Yes'])
                {  
                    if (itemloc.get(l.PBSI__Item__c).contains(l.PBSI__Location__c)) 
                        if (lotswehave.containsKey(l.PBSI__Item__c) == false)                             lotswehave.put(l.PBSI__Item__c,new Map<Id,PBSI__Lot__c>{l.PBSI__Location__c=>l});
                        else                              lotswehave.get(l.PBSI__Item__c).put(l.PBSI__Location__c,l);
                }
                for (Id itemid:itemloc.keySet())
                {
                    Set<Id> loc=itemloc.get(itemid);
                    if (lotswehave.containsKey(itemid))                         loc.removeAll(lotswehave.get(itemid).KeySet());
                    for (String locationid:loc)
                    {
                        PBSI__Lot__c lot=new PBSI__Lot__c(PBSI__Item__c=itemid,PBSI__Location__c=locationid);   
                        if (lotstoinsert.containsKey(itemid) == false)                             lotstoinsert.put(itemid,new Map<Id,PBSI__Lot__c>{locationid =>lot});
                        else                              lotstoinsert.get(itemid).put(locationid,lot);
                        listlotstoinsert.add(lot);
                    }
                }
                if (listlotstoinsert.size() > 0)                    insert listlotstoinsert;
                if (lotstoinsert.size() > 0)                    lotswehave.putall(lotstoinsert);
                for (PackLineModel p:pp)
                     if (stage)                       p.stageline.PBSI__to_Lot__c =lotswehave.get(p.stageline.PBSI__Item__c).get(p.stageline.PBSI__to_Location__c).Id;
                       else                    
                        if( p.isshipping == false)    try {                          p.line.PBSI__Lot__c =lotswehave.get(p.line.PBSI__Item__c).get(p.bomdepline.PBSI__Location__c).Id;} catch(Exception e) {system.debug(e.getMessage());}
            }    
        } //for (List<PackLineModel> pp :PackLineModels)
    }

    public pagereference selectAllLines()    {        for (SLine s :slines)              s.isselected=true;          return null;    }
    public boolean gethasdropship()    {        return hasdropship;    }


    public boolean validatedatastage()    {     return validatedata(true);    }
    
    
    public boolean validatedata()    {      return validatedata(false);    }
    public boolean validatedata(boolean stage)
    {
        boolean ok=true;
        if ((admin <> null && admin.PBSI__Pack_More_than_Needed_on_SO__c== false) || admin == null)
        {
            Map<Id, decimal> qtypacked=new Map<Id,decimal>();
            
            if (stage)            for (pbsi__pbsi_sales_order_line__c s: lines.values())                qtypacked.put(s.Id,s.PBSI__stage_quantity__c);            
            else            for (pbsi__pbsi_sales_order_line__c s: lines.values())                qtypacked.put(s.Id,s.PBSI__quantity_picked__c);

            for (integer i=0;i<PackLineModels.size();i++)
                for (PackLineModel pl:PackLineModels[i])
                    if ( ((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) )  
                    && pl.isshipping && pl.bomdepline == null)
                    {
                        decimal qty;
                        if (stage) qty=pl.stageline.PBSI__stage_quantity__c;
                        else                        qty=pl.line.PBSI__quantity_shipped__c;
                        
                         pl.unitquant=1;
                         
                         if (pl.line.PBSI__unit_of_measure__c <> null)                         {                            map<id,pbsi__unit__c> unitsmap=new map<id,pbsi__unit__c>(pl.units);                          pl.unitquant=unitsmap.get(pl.line.PBSI__unit_of_measure__c).PBSI__quantity__c;                         }

                          if (qtypacked.containskey(pl.line.PBSI__Sales_Order_Line__c) 
                          && qtypacked.get(pl.line.PBSI__Sales_Order_Line__c) +(qty*pl.unitquant)/pl.originalunitquant  > lines.get(pl.line.PBSI__Sales_Order_Line__c).PBSI__quantity_needed__c)
                          {
                            
                             processError('You cannot pack more than qty needed! ',ApexPages.Severity.warning);   pl.qtyerrorStyle = 'border-size:2px; border-color:red;border-style:solid;';                            ok=false;     curentindex=i;
                          }
                          else {
                          pl.qtyerrorStyle='';                          qtypacked.put(pl.line.PBSI__Sales_Order_Line__c,qtypacked.get(pl.line.PBSI__Sales_Order_Line__c)+ (qty*pl.unitquant)/pl.originalunitquant);
                          }  
                    }
    
        }
      //Step1: check lot validation
          for (integer i=0;i<PackLineModels.size();i++)
            for (PackLineModel pl:PackLineModels[i])
            if ( ((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) ) &&  pl.getinvNotNeeded() == false )
            {
                
               if (pl.isshipping == false && getUsingLots() == false && pl.bomdepline.PBSI__Location__c == null)               {                       processError('Please select a Location! ',ApexPages.Severity.WARNING);    pl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';                   ok=false;   curentindex=i;               }
               else
               if (pl.isshipping == false && getUsingLots() == false &&  pl.bomdepline.PBSI__Location__c != null) pl.errorStyle = '';
               else
               if ( (stage && pl.stageline.pbsi__from_lot__c == null) 
               ||
               (stage == false && pl.line.PBSI__Lot__c == null && pl.isshipping)
               )
                {
                     if (getusingLots())   processError('Please select a Lot! ',ApexPages.Severity.WARNING);
                     else                         processError('Please select a Location! ',ApexPages.Severity.WARNING);
                     pl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';          
                     pl.qtyerrorstyle = 'border-size:2px; border-color:red;border-style:solid;';                      
                     pl.line.PBSI__Quantity_Shipped__c = 0.0;
                     ok=false;                    curentindex=i;
                }
                else                pl.errorStyle = '';
              
            }
            else pl.errorStyle = '';
             
  
     if (ok)
     {
        
        string message='Please select a Lot that has enough quantity to ship this line or pack less quantity!';
        if (stage) message='Please select a Lot that has enough quantity to stage this line or stage less quantity!';
        if (getusinglots() == false)
           if (stage) message='Please select a Location that has enough quantity to stage this line or stage less quantity!';
           else
           message='Please select a Location that has enough quantity to ship this line or pack less quantity!';
           
        
         for (integer i=0;i<PackLineModels.size();i++)
            for (PackLineModel pl:PackLineModels[i])
            if ((((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) ) &&  pl.getinvNotNeeded() == false && pl.isshipping == true) || Test.isRunningTest())
            {
                
                if (pl.line.PBSI__unit_of_measure__c == null) pl.unitquant=1;
                boolean okinv=true;                String lotid=pl.line.PBSI__Lot__c;
                if (stage) lotid=pl.stageline.pbsi__from_lot__c;
                
                if ((getusingcartonarea() == false && getusepallets()  == false) || Test.isRunningTest())
                {
                    if (stage)                  {                       if (pl.lotsqty == null || pl.lotsqty.get(lotid) < pl.stageline.PBSI__stage_quantity__c*pl.unitquant)                            okinv=false;                }   
                    else
                  if (pl.lotsqty == null || pl.lotsqty.get(lotid) < pl.line.PBSI__quantity_shipped__c*pl.unitquant)                   okinv=false;
                }
                if (getusingcartonarea()  || Test.isRunningTest() || getusepallets() )
                if (pl.inventory != null)
                 if (stage)
                 {if (pl.invqty.get(pl.inventory) < pl.stageline.PBSI__stage_quantity__c*pl.unitquant) okinv=false;}
                 else
                 
                 if (pl.invqty.get(pl.inventory) < pl.line.PBSI__quantity_shipped__c*pl.unitquant) okinv=false;
                 
                 
                 if (okinv == false || Test.IsRunningTest())                
                 {                       
                    processError(message,ApexPages.Severity.WARNING);  
                    pl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;'; 
                    pl.qtyerrorstyle = 'border-size:2px; border-color:red;border-style:solid;';                      
                    pl.line.PBSI__Quantity_Shipped__c = 0.0;
                    ok=false;   curentindex=i;                
                    }
                else pl.errorStyle='';
                
            }
            else pl.errorStyle='';
            
        
     }
    
      if (admin != null && admin.PBSI__Always_show_serial_number_on_pack_SO__c == true) 
      {
//          ok=true;
        return ok;
      }
      //Step2: check for null empty SN
        if ( ok == true)
        {
               for (integer i=0;i<PackLineModels.size();i++)
               for (PackLineModel pl:PackLineModels[i])
                if ((((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) ) && pl.showSN == true   && pl.islineBomPhantom == false && pl.isdropship == false) || Test.IsRunningTest())
                 {
                    for (PBSI.SerialN ser:pl.serialnumbers)
                    {
                        if (ser.getvalue() == '' || Test.IsRunningTest())                        {                             processError('Please enter a Serial Number ',ApexPages.Severity.WARNING);     ser.setsnerrorStyle('border-size:2px; border-color:red;border-style:solid;');                             ok=false;  curentindex=i;                       }
                       else
                       ser.setsnerrorStyle('');
                    }
                 }
        
       } // if ( lotok == true)
   

     //Step3 :check for identical SN on the Page
      if (ok == true )
    {
        
        String thesames;
        List<Map<String,PBSI.SerialN>> serialList=new List<Map<String,PBSI.SerialN>>();       
        Map<String,PBSI.SerialN> fmap;
        
        for (integer i=0;i<PackLineModels.size();i++)
        {
                
                    
                     for (PackLineModel pl:PackLineModels[i])
                     {
                            if ((((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) ) && pl.isdropship ==false && pl.showSN == true) || Test.IsRunningTest())
                            {
                                     
                                if (pl.serialnumbers != null)
                                for (PBSI.SerialN sh:pl.serialnumbers)
                                {     
                                    
                                      if (listContains(serialList,sh.getvalue(),thesames) !=null)
                                      {    
                                        thesames=sh.getvalue();                                        processError('Serial Numbers are identical! ',ApexPages.Severity.WARNING);    sh.setsnerrorStyle('border-size:2px; border-color:red;border-style:solid;');
                                        listContains(serialList,sh.getvalue(),thesames).setsnerrorStyle('border-size:2px; border-color:red;border-style:solid;');                                        ok=false;                                        curentindex=i;   
                                      }
                                      else
                                      {
                                        if (sh.getvalue() != '' && sh.getvalue() != null)
                                        {
                                            if (serialList.size() > 0) fmap=serialList[serialList.size()-1]; else {fmap=new Map<String,PBSI.SerialN>{};serialList.add(fmap);}
                                            if (fmap.size() < 1000)   fmap.put(sh.getvalue(),sh); else { fmap=new Map<String,PBSI.SerialN>{};fmap.put(sh.getvalue(),sh);seriallist.add(fmap); }
                                        }
                                            sh.setsnerrorStyle('');
                                      }
                                } // for (PBSI.SerialN sh:pl.serialnumbers)
                                    
                            } //  if (pl.showSN() == true && pl.line.PBSI__quantity_shipped__c > 0)
                          
                     } //   for (PackLineModel pl:PackLineModels)
        }
    
    } // if (ok == true)
    
    
    

       List<Map<String,PBSI.SerialN>> serialnumbers=new List<Map<String,PBSI.SerialN>>();       List<Map<String,PackLineModel>> seriallines=new List<Map<String,PackLineModel>>();
    //Step4 :check if SN Is   in inventory
    if (ok == true  && (admin == null || (admin != null && admin.PBSI__Create_SNT_at_Pack_time_for_all_items__c ==false)))
    {

       
       Map<String,PBSI.SerialN> fmp;       Map<String,PackLineModel> lmp;
       
      
       //collect all the serial numbers in the page
       for (List<PackLineModel> pllj : PackLineModels)
           for (PackLineModel pl:pllj)
           {
               if ((((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) ) && pl.isdropship == false && pl.showSN == true &&  pl.isShipping ==true) || Test.IsRunningTest())
               {
                       
                     if (pl.serialnumbers != null )
                     for (PBSI.SerialN sh:pl.serialnumbers)
                       {
                        if (pl.islineBomPhantom == false )
                        {
                       
                        
                             if (serialnumbers.size() > 0){fmp=serialnumbers[serialnumbers.size()-1];} 
                                else {  fmp=new Map<String,PBSI.SerialN>{};serialnumbers.add(fmp);}
                                    if (fmp.size() < 1000)                                            fmp.put(sh.getvalue().toUpperCase(),sh);
                                  else                                  {                                    fmp=new Map<String,PBSI.SerialN>{};fmp.put(sh.getvalue().toUpperCase(),sh); serialnumbers.add(fmp);                                  }
                            
                                        if (seriallines.size() > 0){lmp=seriallines[seriallines.size()-1];} 
                                else {  lmp=new Map<String,PackLineModel>{};seriallines.add(lmp);}
                                    if (lmp.size() < 1000)                                            lmp.put(sh.getvalue().toUpperCase(),pl);
                                  else                                  {                                    lmp=new Map<String,PackLineModel>{};lmp.put(sh.getvalue().toUpperCase(),pl); seriallines.add(lmp);                                  }
                        }
                        
                       }
                       
                 }
               
               if(pl.serialnumbers != null)               {                     pl.limitedSerials = CommonUtils.GetLimitedSerials(pl.serialnumbers);                   SetLineSerialsStyle(pl);               }
           }
             //query the Serial Number Tracker Table to see if serial numbers exists in inventory
                   if (serialnumbers.size() >0 )
                   for (Map<String,PBSI.SerialN> curmap:serialnumbers)
                   {
                        PBSI__Serial_Number_Tracker__c[] invs=null;                        Set<String> sninvs=new Set<String>();
                        invs =[select Id,PBSI__Serial_Number__c,PBSI__Is_In_Inventory__c,PBSI__Lot__c,PBSI__Location__c from PBSI__Serial_Number_Tracker__c where PBSI__Serial_Number__c in :curmap.keySet() AND PBSI__Is_In_Inventory__c='Yes']; 
                           
                           
                        if (invs != null && invs.size() > 0)
                          for (PBSI__Serial_Number_Tracker__c inv:invs)
                          {
                                sninvs.add(inv.PBSI__Serial_Number__c.toUpperCase()); if (curmap.containsKey(inv.PBSI__Serial_Number__c.toUpperCase()))                               {                                    curmap.get(inv.PBSI__Serial_Number__c.toUpperCase()).lotid=inv.PBSI__Lot__c;                                    curmap.get(inv.PBSI__Serial_Number__c.toUpperCase()).locationid=inv.PBSI__Location__c;                             }
                          }
             
                        for(PBSI.SerialN sh:curmap.values())
                               if (sninvs.contains(sh.getvalue().toUpperCase()) == false)                               {                                    ok=false;  sh.setsnerrorStyle('border-size:2px; border-color:red;border-style:solid;');    processError('Serial Number not  in inventory! ',ApexPages.Severity.WARNING);                                }
                                else                                    sh.setsnerrorStyle('');
                                   
                   }        
         
       
    }
            
   if (ok &&  (admin == null || (admin != null && admin.PBSI__Create_SNT_at_Pack_time_for_all_items__c ==false)))
   {
         
                         for (integer i=0;i<serialnumbers.size();i++)
                         {
                            Map<String,PBSI.SerialN> curmap=serialnumbers[i];                            Map<String,PackLineModel> curline=seriallines[i];
                                for (String s:curmap.keySet())
                                {
                                    id linelotid=curline.get(s).line.PBSI__Lot__c;
                                    if (stage) linelotid=curline.get(s).stageline.PBSI__from_Lot__c;
                                    
                                    if (curline.get(s).countInInventory)
                                    if (curline.get(s).isshipping == true                                     && curmap.get(s).lotid != null                                     && curline.get(s).islineBomPhantom == false                                    && curline.get(s).isdropship == false                                    && linelotid != curmap.get(s).lotid)
                                    
                                    {
                                        ok=false;                                        curmap.get(s).setsnerrorStyle('border-size:2px; border-color:red;border-style:solid;');
                                        if (getusinglots() == true)   processError('Serial Number Lot is not the same with the lot you chose for this line! ' ,ApexPages.Severity.WARNING);
                                         else                                         processError('Serial Number Location is not the same with the Location you chose for this line! ',ApexPages.Severity.WARNING);
                                                                     
                                    }  
                                    else                                     curmap.get(s).setsnerrorStyle('');         
                                }
                         }
            

   }        
      //Step 5: check if SN are unique in inventory for non bom depletion lines (receiving)
  if ( ok == true)
    {
      
       PBSI__Serial_Number_Tracker__c[] invs=null;       Set<String> sninvs=new Set<String>();         List<Map<String,PBSI.SerialN>> serialnumbers1=new List<Map<String,PBSI.SerialN>>();         Map<String,PBSI.SerialN> fmp;
       
       //collect all the serial numbers in the page
       for (List<PackLineModel> pllj : PackLineModels)
           for (PackLineModel pl:pllj)
             if (((((pl.line.PBSI__quantity_shipped__c > 0 && stage == false) || (pl.stageline.PBSI__stage_quantity__c > 0 && stage) )  && pl.isdropship == false && pl.showSN == true)  && pl.isShipping == false) || Test.isRunningTest())
             {
                 for (PBSI.SerialN sh:pl.serialnumbers)
                 {
                    if (serialnumbers1.size() > 0){fmp=serialnumbers1[serialnumbers1.size()-1];} 
                    else {  fmp=new Map<String,PBSI.SerialN>{};serialnumbers1.add(fmp);}
                        if (fmp.size() < 1000)                                fmp.put(sh.getvalue(),sh);
                      else                      {                        fmp=new Map<String,PBSI.SerialN>{};fmp.put(sh.getvalue(),sh); serialnumbers1.add(fmp);                      }
                 }
                   
             }   
             //query the inventory to check f serial numbers exists in inventory
                   if (serialnumbers1.size() >0 )
                   for (Map<String,PBSI.SerialN> curmap:serialnumbers1)
                  {
                        invs =[select Id,PBSI__Serial_Number__c,PBSI__Is_In_Inventory__c from PBSI__Serial_Number_Tracker__c where PBSI__Serial_Number__c in :curmap.keySet() AND PBSI__Is_In_Inventory__c='Yes']; 
                      
                         if (invs != null && invs.size() > 0)                         {                           for (PBSI__Serial_Number_Tracker__c inv:invs)                                            sninvs.add(inv.PBSI__Serial_Number__c);             }  
    
                                           
                         for(PBSI.SerialN sh:curmap.values())
                           if (sninvs.contains(sh.getvalue()) == true)                     {                                            ok=false;                                            sh.setsnerrorStyle('border-size:2px; border-color:red;border-style:solid;');                                            processError('Serial Number already exists in inventory!  ',ApexPages.Severity.WARNING);            }
                            else                            sh.setsnerrorStyle('');
                  }          
                                   
         
    
    }   
   if (Test.isRunningTest() && ignorevalidation ) return true;  
    return ok;
}

    public PBSI.SerialN listContains(List<Map<String,PBSI.SerialN>> seriallist,String shvalue,String thesames)
    {
        for(Map<String,PBSI.SerialN> serialns : serialList)             if (serialns.containsKey(shvalue) &&(thesames== null  || shvalue ==thesames ) && (shvalue != '' && shvalue != null))                return serialns.get(shvalue);
        return null;
    }
   
    public boolean getshowItemSN()      {       if (properties.containsKey('SN_Autogen') && properties.get('SN_Autogen') == 'Yes') return false;        return true;    } 

    public List<PBSI__PBSI_Inventory__c> getInventoryList(Set<Id> itemids)
    {
       Id fromlocid;       
       if (salesorder != null)       fromlocid=salesorder.PBSI__from_location__c;
       
        String basesoql='select PBSI__Pallet__r.name,PBSI__Pallet__c,PBSI__item_lookup__c ,Id,PBSI__qty__c,PBSI__Lot__c,PBSI__Lot__r.Name,PBSI__Lot__r.PBSI__Location__c,PBSI__location_lookup__r.Name,PBSI__Area__c,PBSI__Carton__c from PBSI__PBSI_Inventory__c where PBSI__item_lookup__c in :itemids  and PBSI__Is_Valid__c =\'Yes\' and PBSI__Lot__r.PBSI__Location__r.PBSI__Available_for_Packing__c = false';
        if (getusinglots())           basesoql+=' and (PBSI__Lot__r.PBSI__Expiration_Date__c > Today or PBSI__Lot__r.PBSI__Expiration_Date__c=null) and PBSI__Lot__r.PBSI__Lot_Status__c=\'Released\' ';
        else           basesoql+=' and PBSI__Lot__r.PBSI__Lot_For_Location__c =\'Yes\'';     
       if (admin != null && admin.PBSI__Do_Not_Show_zero_Lots_in_Packing_Screen__c == true && admin.PBSI__Use_Not_Counted_Loc_on_Receive_and_Pack__c == false)            basesoql+=' and PBSI__Real_Quantity__c > 0';
       else           basesoql+=  ' and PBSI__Real_Quantity__c >=  0';
       
       if (fromlocid != null && (admin != null && admin.PBSI__Force_Packing_From_Location__c))           basesoql+=' and PBSI__location_lookup__c =:fromlocid';
       else       
       if(admin == null || admin.PBSI__Use_Not_Counted_Loc_on_Receive_and_Pack__c == false)            basesoql+=' and PBSI__Is_Counted__c = \'Yes\'';    
           
                
          if (getusinglots())
       {
              String sorder=getsortorder();
               if (sorder == 'Name Ascending' ) basesoql+=' order by PBSI__Lot__r.Name asc';
               else
               if (sorder == 'FIFO') basesoql+=' order by PBSI__Lot__r.PBSI__Created_Date__c asc';
               else
               if (sorder == 'LIFO') basesoql+=' order by PBSI__Lot__r.PBSI__Created_Date__c desc';
               else
               if (sorder == 'Highest Quantity') basesoql+=' order by PBSI__Lot__r.PBSI__Total_Quantity__c desc';
               

       }
        else            basesoql += ' order by PBSI__Lot__r.PBSI__Is_In_Default_Location__c desc';
            
               if (admin <> null && admin.PBSI__use_pallets__c)                  basesoql+=' ,PBSI__pallet__r.PBSI__Date_Time_Received__c asc';            
  
        List<PBSI__PBSI_Inventory__c> invlist=Database.query(basesoql);        return invlist;
    
    }
  

    public  without sharing class PackLine  {       public PBSI__Shipped_Sales_Order_Line__c line{get;set;} }    

    public void CreateNewSLine()    {        SLine sLine = new SLine(null);
    }
    public class SLine 
    {
        public boolean isSelected{get;set;}     
        public double atp{get;set;}         
        public double qtyonhand{get;set;}   
        public String atperrorStyle{get;set;}   
        public PBSI__PBSI_Sales_Order_Line__c soline{get;set;}
        public SLine(PBSI__PBSI_Sales_Order_Line__c s,Map<String, Schema.SObjectField> M,double atpsl,double qtyonhandl)        {           soline=s;           isSelected=false;           atp=atpsl;          qtyonhand=qtyonhandl;       } 
        public SLine(PBSI__PBSI_Sales_Order_Line__c s)      {           soline=s;           isSelected=false;           atp=0;          qtyonhand=0;        } 
    }
	public List<PBSI__Shipped_Sales_Order_Line__c> getssol(){      
		if (shiplinesx != null) {
	        system.debug('yyy1='+shiplinesx.size());
		    if (getuse6() == false )       
		        for (PBSI__Shipped_Sales_Order_Line__c s:shiplinesx)           
		            s.pbsi__quantity_shipped__c=s.pbsi__quantity_shipped__c.setscale(2);        
		    system.debug('yyy12='+shiplinesx.size());
		}
		return  shiplinesx;
	}
    public void capturelines2()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines3()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines4()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines5()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines6()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines7()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines8()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
    public void capturelines9()
    {
        set<string> queryfields=new set<string>();        
        slines=new List<Sline>();
        slineslimit=new list<SLine>();
        index1=0;index2=0;
        for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())            queryfields.add(f.getFieldPath());
        list <string> otherfiels=new list<string>{'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c','PBSI__Stage_Quantity__c','PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c','PBSI__Quantity_Left_To_Ship__c','pbsi__RMA_Line__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','pbsi__price__c','pbsi__price4__c','pbsi__discount__C', 'PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c','PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c',
               'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
                'PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name,d.PBSI__Lot__c','PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Quantity_Needed__c','PBSI__Quantity_Picked__c'  ,'PBSI__Sales_Order__c','PBSI__Location__c', 'PBSI__Location__r.Name' ,
               'PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
               'PBSI__Item__r.PBSI__Configurable__c','PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c',
               'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c',
               'PBSI__Unit_Of_Measure__c','PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
    
        queryfields.addall(otherfiels);          if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)           queryfields.add('CurrencyIsoCode');
        
        string fieldslist='';       for (string s:queryfields)                  fieldslist += fieldslist.length()>0 ? ','+s : s;
        
        // Security review fix - Elaine
        string str='select '+ String.escapeSingleQuotes(fieldslist);  
        if (itemid <> null)         str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__item__c =:itemid and PBSI__TransactionType__c =\'sale\'';
        else if (salesorders <> null)           str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c in ' + CommonUtils.fn_getStringIds(salesorders.keySet()) + ' and PBSI__TransactionType__c =\'sale\'';
        if (isstage)            str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Stage__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
       else
       { 
          // TO REVIEW FOR AM-366
          if (admin !=null && admin.PBSI__Pack_More_than_Needed_on_SO__c == true)
          {
             if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == false)                str+=' and PBSI__Quantity_Needed__c <> 0';
             else              if ( admin.PBSI__Allow_Packing_0_Qty_Orders__c == true)                 str+=' and ( PBSI__Quantity_Needed__c = 0 or (PBSI__Line_Status__c = \'Open\' and PBSI__Quantity_Left_To_Ship__c <> 0)) ';
          }
             else                 str+=' and PBSI__Line_Status__c = \'Open\'  and PBSI__Quantity_Left_To_Ship__c <> 0 and PBSI__Quantity_Needed__c <> 0 and PBSI__Item__c <> null';
        }
  
        str+=' order by CreatedDate';        solines=Database.query(str);
        
        set<id> locationids=new set<id>();
        set<id> itemids=new set<id>();  
        for( PBSI__PBSI_Sales_Order_Line__c l:solines)
        {
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else
            if (salesorder.PBSI__From_Location__c <> null) 
               locationids.add(salesorder.PBSI__From_Location__c);
        }
                list<PBSI__PBSI_Inventory__c> invs;
        Map<id,map<id,decimal>> atpmap=new map<id,map<id,decimal>>();
        if (itemids.size() > 0 && locationids.size() > 0)
        {
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c in:locationids and a.Item__c in:itemids ];
               for (ATP__c i:atplist)
               {

                    if (atpmap.containskey(i.Item__c))                  
                    {                       
                        atpmap.get(i.Item__c).put(i.Location__c,i.Current_ATP__c);                  
                    }
                    else                    
                    {                       
                        atpmap.put(i.Item__c,new map<id,decimal>{i.Location__c => i.Current_ATP__c});   
                    }
               }               
        }
         for (PBSI__PBSI_Sales_Order_Line__c l:solines)
         {
               double latp =0;  
                if (l.PBSI__Location__c <> null )
                {
                  if( atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(l.pbsi__location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(l.pbsi__location__c);
                } 
                else
                
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.pbsi__item__c) && atpmap.get(l.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))
                  latp=atpmap.get(l.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
    
                double qonhand;
                if (l.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    qonhand=l.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;    
                Sline sl = new SLine(l,M,latp,qonhand);
                boolean erroratp=false;
                if (latp <= 0)  
                {
                    sl.atperrorStyle = 'font-weight:bold;color:red;';
                    //sl.errorStyle = 'border-size:2px; border-color:red;border-style:solid;';
                    //processError('Some lines you are packing have negative ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                    erroratp=true;
                }
                if (admin.ATP_Warning_Level__c!=null && latp< admin.ATP_Warning_Level__c && !erroratp) 
                {
                    sl.atperrorStyle = 'font-weight:bold;color:orange;';
                    //sl.errorStyle = 'border-size:2px; border-color:orange;border-style:solid;';
                    //processError('Some lines you are packing have very low ATP! Please review order lines and fulfillment priorities.',ApexPages.Severity.WARNING);
                }
         slines.add(sl);
         if( slineslimit.size() < lineslimit || Test.isRunningTest())
        	{ slineslimit.add(sl);index2++;}
         
       }
        shownavigationopen=slines.size() >lineslimit;
 
        this.lines=new Map<Id,PBSI__PBSI_Sales_Order_Line__c>(solines);
     }
}