public with sharing class ViewSoLinesController 
{  
    PBSI__PBSI_Sales_Order_Line__c[] lines;
    PBSI__PBSI_Sales_Order__c salesOrder;
    public List<EnhancedLine> eline; 
    Integer count=0;
    Boolean showVersion=false;
    boolean twodec=true;
    public String []propertynames=new String[]{'Item_Version','DecimalPlaces'};  
    Map<String, Schema.SObjectField> M = Schema.SObjectType.PBSI__PBSI_Item__c.fields.getMap();
    public PBSI__Admin__c CS{get;set;}
    public boolean isClone{get;set;}
    public string soid{get;set;}
    public PBSI__PBSI_Location__c soLocation = null;
    public String selectedLineNRs {get; set;}
    public String allLineNRs {get; set;}    
    public ViewSoLinesController(ApexPages.StandardController controller) 
    {
        
        controller.addFields(new list<string>{'pbsi__due_date__c', 'PBSI__Status__c'});     
        CS=PBSI__Admin__c.getOrgDefaults();
        soid=controller.getId();       
        SoqlService soqlService = new SoqlService();         
        this.salesOrder = soqlService.GetSalesOrdersByIDs(new Set<Id>{ soid })[0];  
        getProperties();      
        isClone=false;      
        this.selectedLineNRs = '';
        
        capturelines();  
        
        if(this.salesOrder.PBSI__From_Location__c == null)          {           ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.INFO, 'No “From Location” value entered for this order.');            ApexPages.addMessage(msg1);        }
    } 
    
    public boolean getuse4cost()    {       return (cs != null && cs.PBSI__Use_Cost_4_dec_on_Item_Master__c);    }
    
    public  boolean  getshowbom()    {      return (cs != null && cs.PBSI__bom_versioning_enabled__c);    }
    
    public ViewSoLinesController()    
    {     
        soid = System.currentPageReference().getParameters().get('id');       
        this.selectedLineNRs = '';
        CS=PBSI__Admin__c.getOrgDefaults();     
        getProperties();        
        salesorder=[select id,PBSI__due_date__c, PBSI__From_Location__c from PBSI__PBSI_Sales_Order__c where id=:soid];    
    }
    
    public List<EnhancedLine> geteline()    {       if (eline == null) capturelines();      if (isClone)        for (EnhancedLine e: eline)     {          e.line.PBSI__quantity_picked__c =0;      }       return eline;    }
    
   public PageControllerBase pageController  { get;    set {      if (value!= null) {   pageController  = value;    pageController .setnewsocomponent(this);      }    }  }
public void capturelines()
{
    try
    {
    count=0;    Map<String, Schema.SObjectField> M = Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.fields.getMap();
     
    string str='select PBSI__Location__c,ATP_By_Location__c,pbsi__item__r.PBSI__Item_Type__c,PBSI__bom__c, d.CreatedById,d.PBSI__Ship_Date1__c,d.PBSI__Parent_Line__c,d.PBSI__Item_Condition__c,d.PBSI__Item__r.PBSI__Bom_Type__c,d.PBSI__Item__r.PBSI__Sales_Order_Description__c,d.PBSI__ItemDescription__c,d.PBSI__Item_Description_Long__c,d.Id,d.CreatedDate,d.PBSI__Serial_Number__c,d.PBSI__Line_Number__c,d.PBSI__Price_Type__c,d.PBSI__Item__r.PBSI__Cost__c,d.PBSI__Item__r.PBSI__Cost4__c,d.PBSI__TransactionType__c,d.PBSI__Item__r.Name,d.PBSI__Item__r.PBSI__Quantity_on_Hand__c ,d.PBSI__Item__r.PBSI__Standard_Lead_Time_for_PO_Receipt__c,d.PBSI__Item__r.PBSI__Standard_Lead_Time__c,d.PBSI__Quantity_Needed__c,d.PBSI__Estimated_Ship_Date__c ,d.PBSI__Sales_Order__c,'+ 
                 +'d.PBSI__Total_Price__c,d.PBSI__Sales_Order__r.PBSI__Customer__c,d.PBSI__Total_Price4__c, d.PBSI__Quantity_Picked__c, d.PBSI__Price__c,d.PBSI__Price4__c, d.PBSI__Line_Status__c,d.PBSI__Item__r.PBSI__description__c,'+
                +'d.PBSI__Item__r.PBSI__Configurable__c,d.PBSI__Item__c,d.PBSI__Item__r.PBSI__No_Of_Versions__c,PBSI__Item_Version__c,PBSI__Final_Total_Price__c, PBSI__Cancelled__c, Cancelling_Reason__c,'+
                +'d.PBSI__Item__r.PBSI__Not_Available_For_Sale__c,PBSI__Item_SOLine_Description__c,PBSI__Unit_of_Measure__c,PBSI__Item__r.PBSI__defaultunitofmeasure__c';
                
      if (M.containsKey('CurrencyIsoCode')) str+=',CurrencyIsoCode ';      if (cs != null && cs.PBSI__Fields_On_viewSOLines__c != null) str+=' ,'+cs.PBSI__Fields_On_viewSOLines__c;
      str+=' from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Item__c <> null AND d.PBSI__Sales_Order__c= \''+soid+'\' order by d.CreatedDate';
      lines=Database.query(str);                    Map<Id,Double> itemQtyR=new Map<Id,Double>();
    
        for (PBSI__PBSI_Sales_Order_Line__c l: lines)     if (l.PBSI__Item__c != null)          itemQtyR.put(l.PBSI__Item__c, 0); 
  
        Map<Id,List<PBSI__Item_Version__c>> itemVersions;       
        if (showVersion)  itemVersions=getItemVersions(lines);          
        eline=new EnhancedLine[]{};
            
        Map<Id,List<PBSI__Unit__c>> itemUnits=getUnitsOfMeasure(lines); 
        
        set<id> locationids=new set<id>();        set<id> itemids=new set<id>();    
        
        this.allLineNRs = '';
        Integer lineNumber;
        
        for( PBSI__PBSI_Sales_Order_Line__c l:this.lines)
        {
            lineNumber = ++count;
            itemids.add(l.pbsi__item__c);
            if (l.pbsi__location__c <> null) locationids.add(l.pbsi__location__c);
            else            if (salesorder.PBSI__From_Location__c <> null)             locationids.add(salesorder.PBSI__From_Location__c);
            List<PBSI__Item_Version__c> itemVersionsList;           
            if (showVersion)  itemVersionsList=itemVersions.get(l.PBSI__Item__c);
            EnhancedLine enhancedLine = new EnhancedLine(l, lineNumber, 0, 0, itemUnits.get(l.PBSI__Item__c),itemVersionsList);
            enhancedLine.itemId = l.PBSI__Item__c;          enhancedLine.qonhand = 0;           eline.add(enhancedLine);
            this.allLineNRs += lineNumber + ';';
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
                                    
                                    
/*             invs=[select id,Current_ATP__c,PBSI__item_lookup__c,PBSI__location_lookup__c from PBSI__PBSI_Inventory__c 
                        where  PBSI__item_lookup__c in: itemids and PBSI__location_lookup__c in:locationids];
        
               for (PBSI__PBSI_Inventory__c i:invs)
               {

                    if (atpmap.containskey(i.PBSI__item_lookup__c))                 
                    {                       atpmap.get(i.PBSI__item_lookup__c).put(i.PBSI__location_lookup__c,i.Current_ATP__c);                    }
                    else                    
                    {                       atpmap.put(i.PBSI__item_lookup__c,new map<id,decimal>{i.PBSI__location_lookup__c => i.Current_ATP__c});                 }
               }
*/

        }
        
        if(this.salesOrder.PBSI__From_Location__c != null)
        {
            Map<Id,Double> solinesqty=calculateReservedSOLines(lines, itemQtyR);            Map<Id,double> polinesqty=calculateQtyOnPos(lines);
        
            if(eline.size() > 0)                SetLinesQtyOnHand(eline);
            
            for(EnhancedLine l: eline)
            {
                l.atp =0;  
                if (l.line.PBSI__Location__c <> null )
                {
                    
                    if( atpmap.containskey(l.line.pbsi__item__c) && atpmap.get(l.line.pbsi__item__c).containskey(l.line.pbsi__location__c))                     
                        l.atpbyloc = atpmap.get(l.line.pbsi__item__c).get(l.line.pbsi__location__c);
                } 
                else 
                {
            
                    if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(l.line.pbsi__item__c) && atpmap.get(l.line.pbsi__item__c).containskey(salesorder.PBSI__from_Location__c))                       
                        l.atpbyloc = atpmap.get(l.line.pbsi__item__c).get(salesorder.PBSI__from_Location__c);
                }       
                Double qres = solinesqty.get(l.line.PBSI__Item__c);        
                if(qres == null)                    qres = 0;
                if (l.qonhand <> null)                      l.atp = l.qonhand+polinesqty.get(l.line.pbsi__item__c);                 l.atp -= qres;              l.qreserved = qres;     
                if (l.atp < 0)    l.atp=0;
            }
        }   
    
    Set<Id> bomids=new Set<Id>();    for( PBSI__PBSI_Sales_Order_Line__c l:lines)      if   (l.PBSI__bom__c != null) bomids.add(l.PBSI__bom__c);
      
    if (bomids.size() > 0)     {        Map<Id,PBSI__bom__c> boms=new Map<Id,PBSI__bom__c>([select Id,Name from PBSI__bom__c where Id in:bomids]);      for( EnhancedLine e:eline)      if (e.line.PBSI__bom__c != null)            e.bom=boms.get(e.line.PBSI__bom__c);}  
         }
    catch(Exception e){system.debug(e);}  
    
}
public boolean getshowPriceType(){  if (CS != null && CS.PBSI__Use_Wholesale_Price__c == true) return true;return false;}
public Map<Id,Double> calculateQtyOnPos(List<PBSI__PBSI_Sales_Order_Line__c> solines)
{

    Map<Id,Double> itemQtyR=new Map<Id,Double>();for (PBSI__PBSI_Sales_Order_Line__c l: solines)       if (l.PBSI__Item__c != null) itemQtyR.put(l.PBSI__Item__c,0);
    if (itemQtyR.size() > 0)
       for (AggregateResult  ol:[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty ,PBSI__Item__c       from PBSI__PBSI_Purchase_Order_Line__c d  where pbsi__purchase_order__r.PBSI__Due_Date__c <= :salesorder.PBSI__Due_Date__c      and PBSI__Quantity_Left_To_Receive__c >0        and PBSI__Item__c in : itemQtyR.keySet()        and pbsi__purchase_order__r.pbsi__delivery_location__c =:salesorder.pbsi__from_location__c      group by PBSI__Item__c ])
         
            itemQtyR.put((id)ol.get('PBSI__Item__c'),(Double)ol.get('qty'));    return itemQtyR;    
}
public Map<Id,Double>  calculateReservedQtyOppLines(List<PBSI__PBSI_Sales_Order_Line__c> solines)
{
    Map<Id,Double> itemQtyR=new Map<Id,Double>();for (PBSI__PBSI_Sales_Order_Line__c l: solines)       if (l.PBSI__Item__c != null) itemQtyR.put(l.PBSI__Item__c,0);
    if (itemQtyR.size() > 0)       for (AggregateResult  ol:[Select  SUM(PBSI__Quantity__c) qty ,PBSI__Item__c       From PBSI__PBSI_Opportunity_Line__c d  where CreatedDate = LAST_90_DAYS and PBSI__Line_Status__c = 'Open' and PBSI__Item__c in : itemQtyR.keySet() and PBSI__Quantity__c > 0 group by PBSI__Item__c ])         itemQtyR.put((id)ol.get('PBSI__Item__c'),(Double)ol.get('qty'));    return itemQtyR;      
}

public Map<Id,Double>  calculateReservedSOLines(List<PBSI__PBSI_Sales_Order_Line__c> solines, Map<Id, Double> itemQtyR)
{
    if(itemQtyR.size() > 0)
    {
        List<AggregateResult> soLinesAggResult;     List<AggregateResult> deplLinesAggResult;
        
        /*
        if (this.salesOrder.PBSI__From_Location__c == null)
        {
            soLinesAggResult = [Select  SUM(PBSI__Total_Unit_Qty_Left_To_Ship__c) qty,PBSI__Item__c  
                                   From PBSI__PBSI_Sales_Order_Line__c   
                                   where PBSI__TransactionType__c = 'sale' and PBSI__Line_Status__c = 'Open' and PBSI__Item__c in : itemQtyR.keySet() and PBSI__Quantity_Left_To_Ship__c > 0 and (PBSI__Sales_Order__r.PBSI__Status__c= 'Open' or PBSI__Sales_Order__r.PBSI__Status__c='Partially Complete')  and (PBSI__Location__c = null or (PBSI__Location__c <> null and PBSI__Location__r.PBSI__Count_in_Inventory__c <> 'No'))
                                   group by PBSI__Item__c ];
            
            deplLinesAggResult = [Select SUM(PBSI__Quantity_Left__c) qty, PBSI__Item__c 
                                  from PBSI__BOM_Depletion_Line__c
                                  where PBSI__Sales_Order_Line__r.PBSI__Line_Status__c ='Open'
                                  and PBSI__Quantity_Left__c > 0 
                                  and  PBSI__Sales_Order_Line__r.PBSI__TransactionType__c = 'sale' 
                                  and PBSI__Item__c in :itemQtyR.keySet()
                                  group by PBSI__Item__c];                     
        }
        */
        
        if(this.salesOrder.PBSI__From_Location__c != null)
        {
            soLinesAggResult = [SELECT                          SUM(PBSI__Total_Unit_Qty_Left_To_Ship__c) qty, PBSI__Item__c                        FROM                            PBSI__PBSI_Sales_Order_Line__c
                        WHERE                           PBSI__TransactionType__c = 'sale'                       and                             PBSI__Line_Status__c = 'Open'                       and                             PBSI__Item__c in : itemQtyR.keySet() 
                        and                             PBSI__Quantity_Left_To_Ship__c > 0                      and                             (PBSI__Sales_Order__r.PBSI__Status__c= 'Open'                   or                           PBSI__Sales_Order__r.PBSI__Status__c='Partially Complete')  
                        AND                         PBSI__Sales_Order__r.PBSI__From_Location__c =: this.salesOrder.PBSI__From_Location__c                       group by PBSI__Item__c];
                        
            deplLinesAggResult = [Select                                        SUM(PBSI__Quantity_Left__c) qty, PBSI__Item__c                                from                                      PBSI__BOM_Depletion_Line__c
                                  where                                         PBSI__Sales_Order_Line__r.PBSI__Line_Status__c ='Open'
                                  and                                       PBSI__Quantity_Left__c > 0                                and                                       PBSI__Sales_Order_Line__r.PBSI__TransactionType__c = 'sale'                               and                                       PBSI__Item__c in :itemQtyR.keySet()
                                  and
                                        PBSI__Sales_Order_Line__r.PBSI__Sales_Order__r.PBSI__From_Location__c =: this.salesOrder.PBSI__From_Location__c
                                  group by 
                                        PBSI__Item__c]; 
        }
        
       for (AggregateResult ol: soLinesAggResult)          itemQtyR.put((id)ol.get('PBSI__Item__c'),(Double)ol.get('qty'));
       
       for (AggregateResult ar : deplLinesAggResult)
         if (itemQtyR.containsKey((id)ar.get('PBSI__Item__c')))          itemQtyR.put((id)ar.get('PBSI__Item__c'),itemQtyR.get((id)ar.get('PBSI__Item__c'))+(double)ar.get('qty'));
         else           itemQtyR.put((id)ar.get('PBSI__Item__c'),(Double)ar.get('qty')); 
        } 
        
    return itemQtyR;      
}
public Map<Id,Double>  calculateReservedQtyQuotes(List<PBSI__PBSI_Sales_Order_Line__c> solines)
{
    Map<Id,Double> itemQtyR=new Map<Id,Double>();
    if (CS != null && CS.PBSI__Include_Quotes_in_ATP__c == true)
    {
        for (PBSI__PBSI_Sales_Order_Line__c l: solines)    if (l.PBSI__Item__c != null) itemQtyR.put(l.PBSI__Item__c,0);
        if (itemQtyR.size() > 0)       for (AggregateResult  ol:[Select  SUM(PBSI__Quantity__c) qty,PBSI__Item__c From PBSI__Quote_Line__c d  where CreatedDate = LAST_90_DAYS and PBSI__Quote__r.PBSI__Sales_Order__c = null and d.PBSI__Item__c in : itemQtyR.keySet() and PBSI__Quantity__c > 0 group by PBSI__Item__c ])              itemQtyR.put((id)ol.get('PBSI__Item__c'),(Double)ol.get('qty'));
    }
    return itemQtyR;      
}
public Map<Id,List<PBSI__Unit__c>> getUnitsOfMeasure(List<PBSI__PBSI_Sales_Order_Line__c> solines)
{
    Map<Id,List<PBSI__Unit__c>> itemUnits=new Map<Id,List<PBSI__Unit__c>>{};
    for (PBSI__PBSI_Sales_Order_Line__c l: solines)    if (l.PBSI__Item__c != null) itemUnits.put(l.PBSI__Item__c,new List<PBSI__Unit__c>());
    if (itemUnits.size() > 0)   for (PBSI__Unit__c u:[select Id,Name,PBSI__Item__c,PBSI__Sale_Price__c,PBSI__Sale_Price4__c from PBSI__Unit__c where PBSI__Item__c in :itemUnits.keySet() and (PBSI__Applies_To__c = 'Sales Order' or PBSI__Applies_To__c = NULL)])     itemUnits.get(u.PBSI__Item__c).add(u);

    return itemUnits;
}
public Map<Id,List<PBSI__Item_Version__c>>  getItemVersions(List<PBSI__PBSI_Sales_Order_Line__c> solines)
{
    Map<Id,List<PBSI__Item_Version__c>> itemVersions=new Map<Id,List<PBSI__Item_Version__c>>{};
    for (PBSI__PBSI_Sales_Order_Line__c l: solines)    if (l.PBSI__Item__c != null) itemVersions.put(l.PBSI__Item__c,new List<PBSI__Item_Version__c>());
    if (itemVersions.size() > 0)    for (PBSI__Item_Version__c itv : [Select Id, Name, PBSI__Item__c, PBSI__Version_Number__c, PBSI__Notes__c, PBSI__Active_Date__c, PBSI__Active__c from PBSI__Item_Version__c where PBSI__Item__c in :itemVersions.KeySet() order by CreatedDate desc])       itemVersions.get(itv.PBSI__Item__c).add(itv);
    return   itemVersions;  
}
public void getProperties()
{
    List<PBSI__Property__c> properties=[select PBSI__Property_Name__c,PBSI__Property_Value__c from  PBSI__Property__c where PBSI__Property_Name__c  in :propertynames];
    for (PBSI__Property__c p: properties)
        if (p.PBSI__Property_Name__c == 'DecimalPlaces' && p.PBSI__Property_Value__c == '4') twodec=false;
        else            if (p.PBSI__Property_Name__c == 'Item_Version' && p.PBSI__Property_Value__c == 'Yes' ) showVersion=true;
    
}
public boolean gettwodec(){ return twodec;}
public boolean getshowVersion(){return showVersion;}
public EnhancedLine[] getLines() {return this.eline;}
    public pagereference advancedatp() 
    {
            integer l = Integer.valueOf(System.currentPageReference().getParameters().get('line1'))-1;
            system.debug('aaaa=' + l);
            system.debug('aaaa2=' + eline[l].itemId);
            Date dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day()); 
            Set<Id> itemids = new Set<Id>();
            itemids.add(eline[l].itemId);
            Set<Id> locids = new Set<Id>();
            locids.add(eline[l].line.PBSI__Location__c);
            system.debug('zzz1='+eline[l].line.PBSI__Location__c);
            Map<Id,Map<Id,double>> atpmap = new Map<Id,Map<Id,double>>(); 
            Map<Id,Map<Id,Map<Date,double>>> atpmap2;           
/*          if (locids.size()>0)
                atpmap = CalculateATPTodayInventoryMapLocation(dt2,itemids,locids,true,true);
            else
                atpmap = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemids,true,true);
*/
            atpmap2 = CommonUtils.CalculateATPTodayInventoryMap2(dt2,itemids,true,true);
            system.debug('aaaa1=' + atpmap2.size());
            double atpcalc = 0;
            double warning =20; 
            
            if (atpmap2.containskey(eline[l].itemId)) 
                system.debug('tttt1');

            //if (atpmap2.get(eline[l].itemId).containskey(eline[l].line.pbsi__location__c)) 
                //system.debug('tttt2'); 
            
            if (eline[l].line.PBSI__Location__c <> null )
            {
                system.debug('zzz1='+eline[l].line.PBSI__Location__c);
                if( atpmap.containskey(eline[l].itemId) && atpmap.get(eline[l].itemId).containskey(eline[l].line.pbsi__location__c)) 
                    eline[l].atpbyloccalc = atpmap.get(eline[l].itemId).get(eline[l].line.pbsi__location__c);
                if( atpmap2.containskey(eline[l].itemId) && atpmap2.get(eline[l].itemId).containskey(eline[l].line.pbsi__location__c))
                {
                    Map<Date,double> mapdates = new Map<Date,double>(); 
                    mapdates = atpmap2.get(eline[l].itemId).get(eline[l].line.pbsi__location__c);
                    system.debug('bbb4=' + mapdates.size());
                    List<Date> listdates = new List<Date>();
                    listdates.addall(mapdates.keyset());
                    listdates.sort();
                    for(Date d:listdates)
                    {
                        atpcalc = mapdates.get(d);
                        system.debug('bbb1=' + atpcalc);
                        system.debug('bbb2=' + d);
                        system.debug('bbb3=' + mapdates.get(d));
                        eline[l].atpbyloccalc2 =atpcalc ;
                        eline[l].atpdate = d;
                        //if (atpcalc >= warning)
                            //break;                                            
                    }
                } 
            } 
            else 
            {
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(eline[l].itemId) && atpmap.get(eline[l].itemId).containskey(salesorder.PBSI__from_Location__c))
                    eline[l].atpbyloccalc = atpmap.get(eline[l].itemId).get(salesorder.PBSI__from_Location__c);
            } 
            if (eline[l].atpbyloccalc==null)
                eline[l].atpbyloccalc =0; 
                    
        return null;
    }
    
    
        public static Map<Id,Map<Id,double>> CalculateATPTodayInventoryMapLocation(Date dt,Set<Id> itemsids,Set<Id> locids,boolean futurealocation,boolean useESD) 
    {
        double qoh=0;                
        double atpcalc=0;        
        Map<Id,Map<Id,double>>atpmap = new Map<Id,Map<Id,double>>();      
       // Set<Id> locids = new Set<Id>();
        AggregateResult[] invs=[select sum(pbsi__qty__c) qty,
                                                PBSI__location_lookup__c loc,
                                                PBSI__item_lookup__c item 
                                                from PBSI__PBSI_Inventory__c                                                
                                                where                                                   
                                                PBSI__item_lookup__c in:itemsids    
                                                and PBSI__location_lookup__c in:locids                                      
                                                and PBSI__Is_Valid__c = 'Yes'                                           
                                                and PBSI__Is_Counted__c = 'Yes'                                         
                                                group by PBSI__item_lookup__c,PBSI__location_lookup__c];
        qoh=0;
        for (AggregateResult ar : invs)  
        {
            if (atpmap.containsKey((id)ar.get('item')))
            {
                if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('loc')))              
                    atpmap.get((id)ar.get('item')).put((id)ar.get('loc'),atpmap.get((id)ar.get('item')).get((id)ar.get('loc')) + (double)ar.get('qty'));
                else
                    atpmap.get((id)ar.get('item')).put((id)ar.get('loc'),(double) ar.get('qty'));
            }
            else
                atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('loc') => (double) ar.get('qty')});
          //  locids.add((id)ar.get('loc'));
        } 
        Date dt2;        Date dt4;
        Map<Id,Map<Id,Date>> maplocationdate = new Map<Id,Map<Id,Date>>(); 
        if (dt!=null)            dt2 = date.newInstance(dt.year(), dt.month(), dt.day());
        else            dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day());
        if (futurealocation)
        {
            AggregateResult[]  arqtyfrompolines=[Select  PBSI__Due_Date__c date1,SUM(PBSI__Quantity_Left_To_Receive__c) qty,PBSI__Location__c loc,PBSI__Item__c item                                      
                                                    from PBSI__PBSI_Purchase_Order_Line__c                    
                                                    where PBSI__Due_Date__c >=:dt2                   
                                                    and PBSI__Quantity_Left_To_Receive__c >0                    
                                                    and PBSI__Item__c in:itemsids                   
                                                    group by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c                    
                                                    order by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c desc];
            for (AggregateResult ar:arqtyfrompolines) 
            {
                if (maplocationdate.containsKey((id)ar.get('item')))
                {
                    if (maplocationdate.get((id)ar.get('item')).containsKey((id)ar.get('loc')) &&  maplocationdate.get((id)ar.get('item')).get((id)ar.get('loc')) == null)              
                        maplocationdate.get((id)ar.get('item')).put((id)ar.get('loc'),maplocationdate.get((id)ar.get('item')).get((id)ar.get('loc')));
                    else            
                        maplocationdate.get((id)ar.get('item')).put((id)ar.get('loc'),(Date) ar.get('date1')); 
                    system.debug('p1='+(id)ar.get('item'));
                    system.debug('p2='+(id)ar.get('loc'));
                    system.debug('p3='+(Date)ar.get('date1'));
                }
                else
                {
                    system.debug('p11='+(id)ar.get('item'));
                    system.debug('p22='+(id)ar.get('loc'));
                    system.debug('p33='+(Date)ar.get('date1'));
                    maplocationdate.put((id)ar.get('item'),new Map<id,Date>{(id)ar.get('loc') => (Date) ar.get('date1')});
                }
                
            //  if (!maplocationdate.containskey((String)ar.get('reclot')))
                //  maplocationdate.put((String)ar.get('reclot'),(Date)ar.get('date1'));               
            }
            //if (dt4==null || (dt4 <> null && dt4< (Date)ar.get('date1')))                    
            //dt4=(Date)ar.get('date1');

        } 
        
        List<AggregateResult> arqtyfromsolines = [select sum(PBSI__Quantity_Left_To_Ship__c) qty, PBSI__Location__c  shiploc, pbsi__item__c item, PBSI__Estimated_Ship_Date__c esd 
                                                    from PBSI__PBSI_Sales_Order_Line__c                        
                                                    where pbsi__item__c in:itemsids
                                                //  and PBSI__Estimated_Ship_Date__c >=:system.today() 
                                                    and PBSI__Quantity_Left_To_Ship__c > 0
                                                    and PBSI__Location__c in : locids 
                                                    and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'     
                                                    and PBSI__Sales_Order__r.Sales_Order_Type__c != 'Forecast'                    
                                                    group by pbsi__item__c,PBSI__Location__c,PBSI__Estimated_Ship_Date__c];        
        for (AggregateResult ar : arqtyfromsolines)
        {

            Id locidsoline = (id)ar.get('shiploc');
            Date date2;
            Id itemid = (id)ar.get('item');
            double qty = (double)ar.get('qty');
            
            if (futurealocation)
            {
                if (maplocationdate.containskey(itemid))
                    if (maplocationdate.get(itemid).containsKey(locidsoline))               
                        date2= maplocationdate.get(itemid).get(locidsoline);
            }
            //else
                //date2 = system.today(); 
            system.debug('a1='+ itemid);
            system.debug('a2='+ locidsoline);
            system.debug('a3='+ qty);
            system.debug('a4='+ date2);
            /*
            if (futurealocation)
            {
                if (maplocationdate.containskey((String)ar.get('shiploc')))
                    date2= maplocationdate.get((String)ar.get('shiploc'));
            }
            else
                date2 = system.today();
            */

            if (atpmap.containsKey(itemid))
            {
                if (atpmap.get(itemid).containsKey(locidsoline))                
                {
                    //if (futurealocation && date2!=null)
                    if (date2!=null)
                    {
                        system.debug('a5='+ (Date)ar.get('esd'));
                        if ((Date)ar.get('esd') <= date2)
                        {
                            system.debug('a6='+ qty);
                            atpmap.get(itemid).put(locidsoline,atpmap.get(itemid).get(locidsoline) - qty);
                        }
                    }
                    else                    
                        atpmap.get(itemid).put(locidsoline,atpmap.get(itemid).get(locidsoline) - qty);              
                }
                else
                {                   
                    //if (useESD && date2!=null)
                    if (date2!=null)
                    {
                        if ((Date)ar.get('esd') <= date2)
                        {
                            atpmap.get(itemid).put(locidsoline,-qty);
                            system.debug('a5='+ qty);
                            
                        }
                    }
                    else                    
                        atpmap.get(itemid).put(locidsoline,-qty);               
                }
            }
            else            
            {                   
                //if (useESD && date2!=null)
                if (date2!=null)
                {
                    if ((Date)ar.get('esd') <= date2)
                        atpmap.put(itemid,new Map<id,double>{locidsoline => -qty});
                }
                else                    
                    atpmap.put(itemid,new Map<id,double>{locidsoline => -qty});             
            }
        } 

            List<AggregateResult>  arqtyfrompoline;
            arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty,
                                PBSI__Location__c reclot,
                                PBSI__Item__c item,
                                PBSI__Due_Date__c esd
                            from PBSI__PBSI_Purchase_Order_Line__c  
                            where 
                            PBSI__Quantity_Left_To_Receive__c >0
                            and PBSI__Item__c in :itemsids
                            and PBSI__Location__c in : locids
                            and PBSI__Due_Date__c =:system.today() 
                            group by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c];
        
            for (AggregateResult ar : arqtyfrompoline)
            {
                Id locidsoline = (id)ar.get('reclot');
                Id itemid = (id)ar.get('item');
                double qty = (double)ar.get('qty');
                Date date2;
/*              if (futurealocation)
                {
                    if (maplocationdate.containskey(itemid))
                        if (maplocationdate.get(itemid).containsKey(locidsoline))               
                            date2= maplocationdate.get(itemid).get(locidsoline);
                }
                else
                */
                    date2 = system.today(); 
            
                
                if (atpmap.containsKey(itemid))
                {
                    if (atpmap.get(itemid).containsKey(locidsoline))                        
                    {
                        //if (useESD && date2!=null)
                        if (date2!=null)
                        {
                            if ((Date)ar.get('esd') <= date2)
                                atpmap.get(itemid).put(locidsoline,atpmap.get(itemid).get(locidsoline) + qty);
                        }
                        //else                  
                            //atpmap.get(itemid).put(locidsoline,atpmap.get(itemid).get(locidsoline) + qty);
                    }
                    else
                    {
                        //if (useESD && date2!=null)
                        if (date2!=null)
                        {
                            if ((Date)ar.get('esd') <= date2)
                                atpmap.get(itemid).put(locidsoline,qty);
                        }
                        //else
                            //atpmap.get(itemid).put(locidsoline,qty);
                    }
                }
                else
                {
                    //if (useESD && date2!=null)
                    if (date2!=null)
                    {
                        if ((Date)ar.get('esd') <= date2)
                            atpmap.put(itemid,new Map<id,double>{locidsoline => qty});
                    }
                    //else
                        //atpmap.put(itemid,new Map<id,double>{locidsoline => qty});
                }
                    
            }
        return atpmap;                    
    }  
    
public pagereference createRMA() 
{
    
    
    PBSI__PBSI_Sales_Order_Line__c soline=eline[Integer.valueOf(System.currentPageReference().getParameters().get('line1'))-1].line;
    
    if (soline.PBSI__Item__r.PBSI__Bom_Type__c == 'BOM-Phantom') return new PageReference(Page.PBSi__createRMA.getUrl()+'?soid='+soline.Id+'&returl='+'/'+soid);
    else
    {
    Case c=new Case(PBSI__Return_Type__c='From Customer',PBSI__Sales_Order__c=soline.PBSI__Sales_Order__c,AccountId=soline.PBSI__Sales_Order__r.PBSI__Customer__c); insert c;
    PBSI__RMA_Lines__c rline=new PBSI__RMA_Lines__c(PBSI__Serial_Numbers__c=soline.PBSI__Serial_Number__c,PBSI__Item__c=soline.PBSI__Item__c,PBSI__Quantity__c=soline.PBSI__Quantity_Picked__c,PBSI__RMA__c=c.Id,PBSI__Sales_Order_Line__c=soline.Id,PBSI__Unit_of_Measure__c=soline.PBSI__Unit_of_Measure__c,PBSI__bom__c=soline.PBSI__bom__c);    insert rline;
    string url='/'+c.Id;    PageReference rma=new PageReference(url);   return rma;
    }
    return null;
}
public pagereference newLine() 
{ 
   PBSI__PBSI_Sales_Order_Line__c linenew= new PBSI__PBSI_Sales_Order_Line__c();
  
    linenew.PBSI__Sales_Order__c=this.soid;     linenew.PBSI__TransactionType__c='sale';    linenew.PBSI__Quantity_Picked__c=0;    linenew.PBSI__Price__c=0;    linenew.PBSI__Price4__c=0;    linenew.PBSI__Quantity_Needed__c=0;    linenew.PBSI__Estimated_Ship_Date__c = salesorder.PBSI__Due_Date__c;
    eline.add(new EnhancedLine( linenew,++count,null,null,null,null) );
 return null;
 } 
 public pagereference changePrice()
 { 
    Integer l=Integer.valueOf(System.currentPageReference().getParameters().get('line1'));
    if (eline[l-1].item != null) 
    {
        if (eline[l-1].line.PBSI__Price_Type__c == 'Wholesale')             eline[l-1].line.PBSI__Price__c=eline[l-1].item.PBSI__Wholesale_Price__c;
            
            else
            {
                if (M.containsKey('Sales_Price_5__c'))
                         eline[l-1].line.PBSI__Price__c=(Double)eline[l-1].item.get('Sales_Price_5__c');
                         else                        {                          eline[l-1].line.PBSI__Price__c=eline[l-1].item.PBSI__salesprice__c;                             eline[l-1].line.PBSI__Price4__c=eline[l-1].item.PBSI__salesprice4__c;                        }
            }
             
    }
    else
    if (eline[l-1].line.PBSI__Item__c != null)
    {
            if (M.containsKey('Sales_Price_5__c'))              eline[l-1].item=Database.query('Select PBSI__Sales_Price_5__c,PBSI__Item_Description_Long__c,PBSI__Sales_Order_Description_Long__c,PBSI__Standard_Lead_Time_for_PO_Receipt__c,Id,PBSI__Sales_Order_Description__c,PBSI__Wholesale_Price__c,PBSI__Is_Service__c,PBSI__Not_Available_For_Sale__c,PBSI__salesprice__c,PBSI__salesprice4__c,PBSI__Quantity_on_Hand__c,PBSI__Standard_Lead_Time__c,PBSI__description__c  From PBSI__PBSI_Item__c where Id=\''+  eline[l-1].line.PBSI__Item__c +'\' limit 1');
            else                eline[l-1].item=[select Id,PBSI__Wholesale_Price__c,PBSI__salesprice__c,PBSI__salesprice4__c from PBSI__PBSI_Item__c where Id =:eline[l-1].line.PBSI__Item__c];
     
     if (eline[l-1].line.PBSI__Price_Type__c == 'Wholesale')        eline[l-1].line.PBSI__Price__c=eline[l-1].item.PBSI__Wholesale_Price__c;
     else
     {
        if (M.containsKey('Sales_Price_5__c'))                       eline[l-1].line.PBSI__Price__c=(Double)eline[l-1].item.get('Sales_Price_5__c');
        else        {           eline[l-1].line.PBSI__Price__c=eline[l-1].item.PBSI__salesprice__c;             eline[l-1].line.PBSI__Price4__c=eline[l-1].item.PBSI__salesprice4__c;       }
     }
    }
    
    return null;
 }
 public boolean NotshowSHort() {    return ( CS == null  ||  (CS != null && CS.PBSI__Use_Short_Item_Description__c == false)) ;      }
 
   private void SetLinesQtyOnHand(List<EnhancedLine> enhancedLines)
   {
      if(this.salesOrder.PBSI__From_Location__c != null)
      {
          Set<Id> itemIDs = new Set<Id>();      for(EnhancedLine enhancedLine: enhancedLines)             itemIDs.add(enhancedLine.itemId);
          
          Map<Id, PBSI__PBSI_Item__c> itemMap = new Map<Id, PBSI__PBSI_Item__c>([SELECT Id, PBSI__Quantity_on_Hand__c FROM PBSI__PBSI_Item__c WHERE ID IN: itemIDs]);
          Map<Id,Double> itemsQtyOnHandMap = new Map<Id,Double>();        Boolean usingLots=true;
              
          for (PBSI__Property__c p: [select PBSI__Property_Name__c,PBSI__Property_Value__c from PBSI__Property__c  where PBSI__Property_Name__c = 'Lot_Usage'])          if (p.PBSI__Property_Value__c == 'No')              usingLots=false;
                
          SoqlService soqlservice = new Soqlservice();       
          List<PBSI__PBSI_Inventory__c> inv = soqlService.GetValidInventoriesByLocations(new Set<Id>{ this.salesOrder.PBSI__From_Location__c },                                                                                      !usingLots,                                                                                         itemIDs);        
          for(PBSI__PBSI_Inventory__c inventory: inv)         {           Double qtyOnHand = itemsQtyOnHandMap.get(inventory.PBSI__item_lookup__c);           if(qtyOnHand == null)              qtyOnHand = 0;       qtyOnHand += inventory.PBSI__qty__c;            itemsQtyOnHandMap.put(inventory.PBSI__item_lookup__c, qtyOnHand);       }             
          
          for(EnhancedLine enhancedLine: enhancedLines)
          {
               Double qtyOnHand = itemsQtyOnHandMap.get(enhancedLine.itemId);          
               if(qtyOnHand == null)                 qtyOnHand = 0;            
               enhancedLine.qonhand = (qtyOnHand).intValue();
          }
      }       
   }
 
 public pagereference getItemInformation()
 {
    Integer l=Integer.valueOf(System.currentPageReference().getParameters().get('line1'));
    
    PBSI__PBSI_Item__c it;  String itemName=eline[l-1].itemName;    PBSI__Admin__c CS = PBSI__Admin__c.getOrgDefaults();
    
    if (M.containsKey('Sales_Price_5__c'))
    try{        it=Database.query('Select PBSI__Item_Type__c,PBSI__Bom_Type__c ,Name,PBSI__defaultunitofmeasure__c ,PBSI__Sales_Price_5__c,PBSI__Item_Description_Long__c,PBSI__Sales_Order_Description_Long__c,PBSI__Standard_Lead_Time_for_PO_Receipt__c,Id,PBSI__Sales_Order_Description__c,PBSI__Wholesale_Price__c,PBSI__Is_Service__c,PBSI__Not_Available_For_Sale__c,PBSI__salesprice__c,PBSI__salesprice4__c,PBSI__Quantity_on_Hand__c,PBSI__Standard_Lead_Time__c,PBSI__description__c  From PBSI__PBSI_Item__c where Id=\''+  eline[l-1].line.PBSI__Item__c +'\' limit 1');   }   catch(Exception e){}
    else
    
    try     {       it=[Select PBSI__Item_Type__c ,PBSI__Bom_Type__c , Name,PBSI__defaultunitofmeasure__c ,PBSI__Item_Description_Long__c,PBSI__Sales_Order_Description_Long__c,PBSI__Standard_Lead_Time_for_PO_Receipt__c,Id,PBSI__Sales_Order_Description__c,PBSI__Wholesale_Price__c,PBSI__Is_Service__c,PBSI__Not_Available_For_Sale__c,PBSI__salesprice__c,PBSI__salesprice4__c,PBSI__Quantity_on_Hand__c,PBSI__Standard_Lead_Time__c,PBSI__description__c  From PBSI__PBSI_Item__c where Id =:eline[l-1].line.PBSI__Item__c limit 1];     }   catch(Exception e){}
    
    
    if (it != null && it.PBSI__Not_Available_For_Sale__c == false && (it == eline[l-1].item  || it.Name == eline[l-1].itemName) == false)
    {
            eline[l-1].item=it;         eline[l-1].itemName=it.Name;            eline[l-1].itemId=it.Id;
            
            if(this.salesOrder.PBSI__From_Location__c != null)              SetLinesQtyOnHand(new EnhancedLine[] { eline[l-1]} );
            else                eline[l-1].qonhand = 0;
            
            if (it.PBSI__Standard_Lead_Time__c != null)             eline[l-1].leadtime=it.PBSI__Standard_Lead_Time__c.intValue();
            
            if (it.PBSI__Standard_Lead_Time_for_PO_Receipt__c != null)
                if (eline[l-1].leadtime == null)                   eline[l-1].leadtime=it.PBSI__Standard_Lead_Time_for_PO_Receipt__c.intValue();
                else                    eline[l-1].leadtime+=it.PBSI__Standard_Lead_Time_for_PO_Receipt__c.intValue();
                
            if (it.PBSI__Is_Service__c == true)             eline[l-1].line.PBSI__Quantity_Needed__c=1;
            
            if (it.PBSI__Sales_Order_Description_Long__c != null && NotshowShort())                 eline[l-1].itemdescr = it.PBSI__Sales_Order_Description_Long__c;
            else if (it.PBSI__Item_Description_Long__c != null && NotshowSHort())               eline[l-1].itemdescr=it.PBSI__Item_Description_Long__c;
            else if (it.PBSI__Sales_Order_Description__c != null )                  eline[l-1].itemdescr=it.PBSI__Sales_Order_Description__c;
            else                eline[l-1].itemdescr=it.PBSI__description__c;
             
             if (M.containsKey('Sales_Price_5__c'))              eline[l-1].line.PBSI__Price__c=(Double)it.get('Sales_Price_5__c');
             else            {              eline[l-1].line.PBSI__Price__c=it.PBSI__salesprice__c;              eline[l-1].line.PBSI__Price4__c=it.PBSI__salesprice4__c;             }
             
             Map<Id,Double> itemQtyR=new Map<Id,Double>();           itemQtyR.put(eline[l-1].itemId, 0);             Double atp=0;           Double qres=0;
            
             if(this.salesOrder.PBSI__From_Location__c != null)
             {
            
                 Map<Id,Double> solinesqty=calculateReservedSOLines(new PBSI__PBSI_Sales_Order_Line__c[] {eline[l-1].line}, itemQtyR);
                 qres += solinesqty.get(it.Id);          
                 if(qres == null) qres = 0;
                 /*          
               List <PBSI__PBSI_Inventory__c> invs=[select id,Current_ATP__c,PBSI__item_lookup__c,PBSI__location_lookup__c from PBSI__PBSI_Inventory__c where 
                   PBSI__item_lookup__c =:it.Id and PBSI__location_lookup__c =:salesOrder.PBSI__From_Location__c];
        
               for (PBSI__PBSI_Inventory__c i:invs)                 atp = i.Current_ATP__c;
                */
            List<ATP__c> atplist =[Select a.Location__c, a.Item__c, a.Current_ATP__c From ATP__c a
                                    where a.Location__c =:salesOrder.PBSI__From_Location__c and a.Item__c =:it.Id];
               for (ATP__c i:atplist)
               {
                atp = i.Current_ATP__c;
               }


                eline[l-1].atpbyloc = atp;      
             }
     
             eline[l-1].atp=atp;             eline[l-1].qreserved=qres;         eline[l-1].itemUnits = getUnitsOfMeasure(new PBSI__PBSI_Sales_Order_Line__c[] {eline[l-1].line}).get(it.Id);
            
            if (showversion)               eline[l-1].itemVersions = getItemVersions(new PBSI__PBSI_Sales_Order_Line__c[] {eline[l-1].line}).get(it.Id);
    
            Set<Id> itemsids = new Set<Id>();
            itemsids.add(it.Id);
/*
            Date dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day()); 
            dt2 = salesorder.PBSI__Due_Date__c;
            Map<Id,Map<Id,double>> atpmap = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,true,true);
            
            if (eline[l-1].line.PBSI__Location__c <> null )
            {
                if( atpmap.containskey(it.Id) && atpmap.get(it.Id).containskey(eline[l-1].line.pbsi__location__c))
                    eline[l-1].atpbyloc = atpmap.get(it.ID).get(eline[l-1].line.pbsi__location__c);
            } 
            else 
            {
                if (salesorder.PBSI__from_Location__c <> null && atpmap.containskey(it.Id) && atpmap.get(it.Id).containskey(salesorder.PBSI__from_Location__c))
                    eline[l-1].atpbyloc = atpmap.get(it.Id).get(salesorder.PBSI__from_Location__c);
            }       
    */      
            
     if (cs != null && cs.PBSI__bom_versioning_enabled__c )
    if (it.PBSI__item_type__c == 'BOM')
    {
     List<SelectOption> options =new List<SelectOption>();
    
            for (PBSI__BOM__c b:[select PBSI__Default__c,id ,Name ,PBSI__version_number__c,PBSI__revision__c from PBSI__BOM__c where PBSI__Item__c =:it.id order by createdDate])
         
          { 
            
            string s='';            if (b.PBSI__version_number__c != null) s+=' '+b.PBSI__version_number__c;
            if (b.PBSI__revision__c != null) s+='.'+b.PBSI__revision__c;            if (b.PBSI__default__c ) s+=' -Default';
             if (b.PBSI__default__c && options.size() > 0 && eline[l-1].line.id == null)               options.add(0,new SelectOption(b.Id,b.Name+s));
               else         options.add(new SelectOption(b.Id,b.Name+s));
          }
         if (options.size() == 0 ) {options.add(new SelectOption('','--None--'));}           eline[l-1].boms=options;
    }
    
    }
    else
    {
        if (it == null)         {       String s='Item you entered is not valid on line  : ' + (l);        ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, s);        ApexPages.addMessage(msg1);      }
        else        if (it.PBSI__Not_Available_For_Sale__c)         {           String s='Item is not available for sale  on line  : ' + (l);            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, s);            ApexPages.addMessage(msg1);        }
    }
    
    return null;
 }
   public pagereference deleteLine()
   {
   
           try
           {
                   Integer linetodelete=Integer.valueOf(System.currentPageReference().getParameters().get('lineNo'));                  String lineN=eline[linetodelete-1].line.PBSI__Line_Number__c;
                   PBSI__PBSI_Sales_Order_Line__c[] ll=[select  d.PBSI__Line_Number__c,d.PBSI__Sales_Order__c from PBSI__PBSI_Sales_Order_Line__c d where d.PBSI__Sales_Order__c= :soid and d.PBSI__Line_Number__c= :lineN];
                    if (ll.size() > 0 && isClone == false )   delete ll[0];
                   this.eline.remove(linetodelete-1);                  count--;                for (integer i=linetodelete-1;i<count;i++) eline[i].lineNumber=(eline[i].lineNumber)-1;
            }
            catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));}
     return null;
   }
 
 public pagereference creditLine()
 {
         try
           {
                   Integer linetodelete=Integer.valueOf(System.currentPageReference().getParameters().get('linecred'));                PBSI__PBSI_Sales_Order_Line__c linec=eline[linetodelete-1].line;                linec.PBSI__TransactionType__c='credit';                update linec;
                 
    string str='select pbsi__item__r.PBSI__Item_Type__c,PBSI__bom__c,d.CreatedById,d.PBSI__Ship_Date1__c,d.PBSI__Parent_Line__c,d.PBSI__Item_Condition__c,d.PBSI__Item__r.PBSI__Bom_Type__c,d.PBSI__Item__r.PBSI__Sales_Order_Description__c,d.PBSI__ItemDescription__c,d.PBSI__Item_Description_Long__c,d.Id,d.CreatedDate,d.PBSI__Serial_Number__c,d.PBSI__Line_Number__c,d.PBSI__Price_Type__c,d.PBSI__Item__r.PBSI__Cost__c,d.PBSI__Item__r.PBSI__Cost4__c,d.PBSI__TransactionType__c,d.PBSI__Item__r.Name,d.PBSI__Item__r.PBSI__Quantity_on_Hand__c ,d.PBSI__Item__r.PBSI__Standard_Lead_Time_for_PO_Receipt__c,d.PBSI__Item__r.PBSI__Standard_Lead_Time__c,d.PBSI__Quantity_Needed__c,d.PBSI__Estimated_Ship_Date__c ,d.PBSI__Sales_Order__c,'+ 
                 +'d.PBSI__Total_Price__c,d.PBSI__Sales_Order__r.PBSI__Customer__c,d.PBSI__Total_Price4__c, d.PBSI__Quantity_Picked__c, d.PBSI__Price__c,d.PBSI__Price4__c, d.PBSI__Line_Status__c,d.PBSI__Item__r.PBSI__description__c,'+
                +'d.PBSI__Item__r.PBSI__Configurable__c,d.PBSI__Item__c,d.PBSI__Item__r.PBSI__No_Of_Versions__c,PBSI__Item_Version__c,PBSI__Final_Total_Price__c, '+
                +'d.PBSI__Item__r.PBSI__Not_Available_For_Sale__c,PBSI__Item_SOLine_Description__c,PBSI__Unit_of_Measure__c,PBSI__Item__r.PBSI__defaultunitofmeasure__c';
                
      if (M.containsKey('CurrencyIsoCode')) str+=',CurrencyIsoCode ';      if (cs != null && cs.PBSI__Fields_On_viewSOLines__c != null) str+=','+cs.PBSI__Fields_On_viewSOLines__c;
      str+=+' from PBSI__PBSI_Sales_Order_Line__c d where Id= \''+linec.Id+'\' limit 1';
              
                 
                   
      linec=Database.query(str);     linec.PBSI__TransactionType__c='sale';                update linec; linec=Database.query(str);   eline[linetodelete-1].line=linec;  
   
            }
           
            catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));}
     return null;
 }
 public pagereference addlines() { PageReference NewItemPage;     NewItemPage= new PageReference('/apex/PBSI__ItemGroupLines?id=' + soid+'&objtype=salesorder&returl=/apex/PBSI__viewsowithItemGroupSelection');    return NewItemPage; }
  public pagereference addlines1() { PageReference NewItemPage;     NewItemPage= new PageReference('/apex/PBSI__ItemGroupLines?id=' + soid+'&objtype=salesorder&returl=/apex/c__ViewSoLines');    return NewItemPage; }
 public boolean validateInfo()
 {
    boolean ok=true;
     for(EnhancedLine el:eline)
      if (el.line.PBSI__Quantity_Needed__c == 0 && el.has0quant == true && el.line.PBSI__Parent_Line__c == null)      {         ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Quantity Needed is 0 for this line!' );      el.errorqty='border-size:2px; border-color:red;border-style:solid;';        el.has0quant=false;         ApexPages.addMessage(msg1);         ok=false;     }
      else    {       el.errorqty='';      el.has0quant=true;     }   return ok;                            
 }
 
 // Changed by Elaine 
    public pagereference PerformActionOnSelected()
   {
        String action = System.currentPageReference().getParameters().get('action');
        Set<String> setSelLineNRs = CommonUtils.GetStrSetByValueToSplit(';', this.selectedLineNRs);
        Set<Id> linesToProcessIDs = new Set<Id>();
        List<PBSI__PBSI_Sales_Order_Line__c> linesToProcess = new List<PBSI__PBSI_Sales_Order_Line__c>();
        PBSI__Admin__c admin = PBSI__Admin__c.getOrgDefaults();
        Map<String, Schema.SObjectField> M = Schema.SObjectType.PBSI__PBSI_Item__c.fields.getMap();
        
        try
        {
            for(String lineNr: setSelLineNRs)
            {
                Integer iLineNr = Integer.valueOf(lineNr);
                EnhancedLine lineToProcess = this.eline[Integer.valueOf(lineNr) - 1];
                
                if(lineToProcess.line.Id != null)
                {
                    if((action == 'delete' && lineToProcess.actionTitle == 'Delete') || (action == 'credit' && lineToProcess.actionTitle == 'Credit') || (action == 'cancel'))
                    {   
                        linesToProcessIDs.add(lineToProcess.line.Id);                      if(action == 'credit' || action == 'cancel')     linesToProcess.add(lineToProcess.line);
                    }       
                }
                 
                //if(action == 'delete' && lineToProcess.actionTitle == 'Delete')
                if((action == 'delete' && lineToProcess.actionTitle == 'Delete') || action == 'deleteSOL')           this.eline[iLineNr - 1].isDeleted = true;   
            }
            
            //if(action == 'delete')
            if(action == 'delete' || action == 'deleteSOL')
            {       
                if(linesToProcessIDs.size() > 0)                {                    delete [select                                Id                            from                                PBSI__PBSI_Sales_Order_Line__c d                            where                                Id IN: linesToProcessIDs];                }
                
                Integer lineNumber = 0;            this.allLineNRs = '';
                
                List<EnhancedLine> newEline = new List<EnhancedLine>();
                
                this.count = 0;
                
                for(EnhancedLine eLine: this.eline)                {                    if(!eLine.isDeleted)                   {                        lineNumber ++;    eLine.lineNumber = lineNumber;     this.allLineNRs += lineNumber + ';';           this.count ++;           newEline.add(eLine);                    }                }
                
                this.eline.clear();
                
                this.eline.addAll(newEline);
            }
            else
            {
                for(PBSI__PBSI_Sales_Order_Line__c line: linesToProcess)          
                {
                    if(action == 'credit')  line.PBSI__TransactionType__c='credit';
                    if(action == 'cancel')  line.PBSI__Cancelled__c = true; 
                    //line.PBSI__TransactionType__c='credit';
                }
                
                update linesToProcess;
                
                string str = 'select ' +
                             '    d.PBSI__Discounted_Pricec__c, ' +
                             '    d.PBSI__Discount__c, ' +
                             '    pbsi__item__r.PBSI__Item_Type__c, ' +
                             '    PBSI__bom__c, ' +
                             '    d.CreatedById, ' +
                             '    d.PBSI__Ship_Date1__c, ' +
                             '    d.PBSI__Parent_Line__c, ' +
                             '    d.PBSI__Item_Condition__c, ' +
                             '    d.PBSI__Item__r.PBSI__Bom_Type__c, ' +
                             '    d.PBSI__Item__r.PBSI__Sales_Order_Description__c, ' +
                             '    d.PBSI__ItemDescription__c, ' +
                             '    d.PBSI__Item_Description_Long__c, ' +
                             '    d.Id,d.CreatedDate, ' +
                             '    d.PBSI__Serial_Number__c, ' +
                             '    d.PBSI__Line_Number__c, ' +
                             '    d.PBSI__Price_Type__c, ' +
                             '    d.PBSI__Item__r.PBSI__Cost__c, ' +
                             '    d.PBSI__Item__r.PBSI__Cost4__c, ' +
                             '    d.PBSI__TransactionType__c, ' +
                             '    d.PBSI__Item__r.Name, ' +
                             '    d.PBSI__Item__r.PBSI__Quantity_on_Hand__c, ' +
                             '    d.PBSI__Item__r.PBSI__Standard_Lead_Time_for_PO_Receipt__c, ' +
                             '    d.PBSI__Item__r.PBSI__Standard_Lead_Time__c,d.PBSI__Quantity_Needed__c,d.PBSI__Estimated_Ship_Date__c , ' +
                             '    d.PBSI__Sales_Order__c, d.PBSI__Total_Price__c, d.PBSI__alt_Total_Price__c, d.PBSI__Sales_Order__r.PBSI__Customer__c,d.PBSI__Total_Price4__c, ' +
                             '    d.PBSI__Quantity_Picked__c, d.PBSI__Price__c,d.PBSI__Price4__c, d.PBSI__Line_Status__c,d.PBSI__Item__r.PBSI__description__c, '+
                             '    d.PBSI__Item__r.PBSI__Configurable__c,d.PBSI__Item__c,d.PBSI__Item__r.PBSI__No_Of_Versions__c,PBSI__Item_Version__c,'+
                             '    d.PBSI__Item__r.PBSI__Not_Available_For_Sale__c,PBSI__Item_SOLine_Description__c,PBSI__Unit_of_Measure__c,PBSI__Final_Total_Price__c, ' +
                             '    PBSI__Item__r.PBSI__defaultunitofmeasure__c ';
                
                             if (M.containsKey('CurrencyIsoCode'))        str+=',CurrencyIsoCode ';
              
                             if (admin != null && admin.PBSI__Fields_On_viewSOLines__c != null)         str += ',' + admin.PBSI__Fields_On_viewSOLines__c;
              
                             str +=+ ' from PBSI__PBSI_Sales_Order_Line__c d where Id IN: linesToProcessIDs ';
                      
                             List<PBSI__PBSI_Sales_Order_Line__c> result = Database.query(str);
             
                             for(PBSI__PBSI_Sales_Order_Line__c line: result)
                             {
                                line.PBSI__TransactionType__c='sale';         line.PBSI__Serial_Number__c=null;
                             }
                
                             update result;
                             
                             capturelines();
            }
     }
     catch(Exception e)     {        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));     }
     
        M = null;        admin = null;       this.selectedLineNRs = '';       return null;
    }
    public pagereference atpplanner() 
    {
        PBSI__PBSI_Sales_Order_Line__c soline=eline[0].line;
        PageReference NewItemPage;        NewItemPage= new PageReference('/apex/atpplanner?id=' + soline.Id);        return NewItemPage;
    }    
 public pagereference saveChanges() 
 { 
    if (!validateInfo())        return null;Boolean ok = true;  Database.UpsertResult[] UR;
        
    try
    {
         PBSI__PBSI_Sales_Order_Line__c[] savelines=new PBSI__PBSI_Sales_Order_Line__c[]{};
         Boolean cancelError = false;
         for(EnhancedLine el:eline) {
         	 savelines.add(el.line);
         	 if (el.line.PBSI__Cancelled__c == true && 
         	 	(el.line.Cancelling_Reason__c == null || el.line.Cancelling_Reason__c == '')) {
         	 		cancelError = true;
         	 	}
         }
         if (cancelError) {
         	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please provide a Cancelling Reason!'));
         	return null;
         } else {
         	UR= Database.upsert(savelines, false);
         }
      }
      catch(DMLException e){}
        
      for(integer i=0;i<UR.size();i++)      {        if (!UR[i].isSuccess())         {          for (Database.Error e:ur[i].getErrors())       {       String s=e.getMessage()+'  on line : ' + (i+1);             ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR,s );            ApexPages.addMessage(msg1);             ok=false;        }        }      }
  
      if (ok == true)         capturelines();      return null;
  }
}