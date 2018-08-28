public with sharing class CommonUtils2 {
    public static Map<Id,double> CalculateATPInventory(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {
        Map<Id,double> atpmap = new Map<Id,double>()  ;    
        Set<Id> itemids = new Set<Id>();        
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrominventory =[select sum(pbsi__qty__c) qty,PBSI__item_lookup__c
                        from PBSI__PBSI_Inventory__c 
                        where PBSI__item_lookup__c in :itemids 
				        and
				         	PBSI__Is_Valid__c = 'Yes'
				        and
				            PBSI__Is_Counted__c = 'Yes'
                        group by PBSI__item_lookup__c];
        for (AggregateResult ol : arqtyfrominventory)            atpmap.put((id)ol.get('PBSI__item_lookup__c'),(Double)ol.get('qty'));
        return atpmap;
    } 
    public static Map<Id,Map<date,double>> CalculateATPsolines(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {
        Map<Id,Map<date,double>> atpmap = new Map<Id,Map<date,double>>();      

        Set<Id> itemids = new Set<Id>();        

        Map<Id,List<date>> itemdatemap = new Map<Id,List<date>>();
        PBSI__Admin__c admin=PBSI__Admin__c.getorgdefaults();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfromsolines;
        if (admin <> null && admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c <> null)
        {
        	Date d=system.today()-admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c.longvalue();
          arqtyfromsolines=[select sum(PBSI__Quantity_Left_To_Ship__c) qty , PBSI__Estimated_Ship_Date__c oldate, pbsi__item__c
                        from PBSI__PBSI_Sales_Order_Line__c 
                        where pbsi__item__c in :itemids
                        and PBSI__Quantity_Left_To_Ship__c > 0
                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' 
                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed' 
                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled' 
                        and PBSI__Sales_Order__r.PBSI__Due_Date__c > :d
                        group by pbsi__item__c,PBSI__Estimated_Ship_Date__c];
        
        }
        else
        arqtyfromsolines=[select sum(PBSI__Quantity_Left_To_Ship__c) qty , PBSI__Estimated_Ship_Date__c oldate, pbsi__item__c 
                        from PBSI__PBSI_Sales_Order_Line__c 
                        where pbsi__item__c in :itemids
                        and PBSI__Quantity_Left_To_Ship__c > 0
                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' 
                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed' 
                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'  
                        group by pbsi__item__c,PBSI__Estimated_Ship_Date__c];
        for (AggregateResult ol :arqtyfromsolines)
            if (atpmap.containsKey((id)ol.get('PBSI__Item__c')))      atpmap.get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
            else        atpmap.put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')});
        return atpmap;                    
    }

    public static Map<Id,Map<date,double>> CalculateATPpolines(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {
        Map<Id,Map<date,double>> atpmap = new Map<Id,Map<date,double>>();      

        Set<Id> itemids = new Set<Id>();        
        
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)          itemids.add(s.PBSI__Item__c);
        List<AggregateResult>  arqtyfrompolines=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty , 
                                                    pbsi__purchase_order__r.PBSI__Due_Date__c oldate ,
                                                    PBSI__Item__c  
                        from PBSI__PBSI_Purchase_Order_Line__c  
                        where PBSI__Quantity_Left_To_Receive__c >0
                        and PBSI__Item__c in :itemids
                        group by PBSI__Item__c,pbsi__purchase_order__r.PBSI__Due_Date__c];
        for (AggregateResult ol :arqtyfrompolines)
            if (atpmap.containsKey((id)ol.get('PBSI__Item__c')))              atpmap.get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
            else          atpmap.put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=>(double)ol.get('qty')});
        return atpmap;                    
    }

    public static Map<Id,Map<date,double>> CalculateATPpwos(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<date,double>> atpmap = new Map<Id,Map<date,double>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)
            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrompwos=[select sum(PBSI__Quantity_Left__c) qty ,  PBSI__Delivery_Date__c oldate,pbsi__item__c
                        from PBSI__Production_Work_Order__c 
                        where pbsi__item__c in :itemids
                        and PBSI__Quantity_Left__c > 0
                        group by  pbsi__item__c,PBSI__Delivery_Date__c];
        for (AggregateResult ol :arqtyfrompwos)
            if (atpmap.containsKey((id)ol.get('PBSI__Item__c')))              atpmap.get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
            else             atpmap.put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=>(double)ol.get('qty')});


        return atpmap;                    
    }

    public static Map<Id,Map<date,double>> CalculateATPbompwos(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<date,double>> atpmap = new Map<Id,Map<date,double>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrombomcomponentspwo=[select sum(PBSI__Quantity_Left__c) qty ,
                                                        PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c oldate,
                                                        pbsi__item__c
                    from PBSI__BOM_Depletion_Line__c
                    where pbsi__item__C in :itemids
                    and PBSI__Quantity_Left__c > 0
                    and PBSI__Production_Work_Order__c <> null 
                    group by  pbsi__item__c,PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c];
        for (AggregateResult ol :arqtyfrombomcomponentspwo)
            if (atpmap.containsKey((id)ol.get('PBSI__Item__c')))                atpmap.get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
            else                atpmap.put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=>(double)ol.get('qty')});

       return atpmap;                    
    }

    public static Map<Id,Map<Id,double>> CalculateATPInventoryByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {
        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,double>> atpmap = new Map<Id,Map<Id,double>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrominventory =[select sum(pbsi__qty__c) qty,PBSI__item_lookup__c,PBSI__location_lookup__c                        from PBSI__PBSI_Inventory__c                         where PBSI__item_lookup__c in :itemids				        and				         	PBSI__Is_Valid__c = 'Yes'				        and				            PBSI__Is_Counted__c = 'Yes'                        group by PBSI__item_lookup__c,PBSI__location_lookup__c];
        for (AggregateResult ol : arqtyfrominventory)
            if (atpmap.containsKey((id)ol.get('PBSI__item_lookup__c')))                atpmap.get((id)ol.get('PBSI__item_lookup__c')).put((id)ol.get('PBSI__location_lookup__c'),(double)ol.get('qty'));
            else                atpmap.put((id)ol.get('PBSI__item_lookup__c'),new Map<id,double> {(id)ol.get('PBSI__location_lookup__c')=> (double)ol.get('qty')});
        return atpmap;      
    } 
    
    public static Map<Id,Map<Id,Map<date,double>>> CalculateATPsolinesByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        PBSI__Admin__c admin=PBSI__Admin__c.getorgdefaults();        list<AggregateResult> arqtyfromsolines;        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        if (admin <> null && admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c <> null)
        {
        	Date d=system.today()-admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c.longvalue();
          	arqtyfromsolines=[select sum(PBSI__Quantity_Left_To_Ship__c) qty , PBSI__Estimated_Ship_Date__c oldate, pbsi__item__c,PBSI__Location__c                        from PBSI__PBSI_Sales_Order_Line__c                        where pbsi__item__c in :itemids                        and PBSI__Quantity_Left_To_Ship__c > 0                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed'                       and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed'                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'                        and PBSI__Sales_Order__r.PBSI__Due_Date__c > :d                        group by pbsi__item__c,PBSI__Estimated_Ship_Date__c,PBSI__Location__c];        
        }
        else
        arqtyfromsolines=[select sum(PBSI__Quantity_Left_To_Ship__c) qty , PBSI__Estimated_Ship_Date__c oldate, pbsi__item__c,PBSI__Location__c                        from PBSI__PBSI_Sales_Order_Line__c                        where pbsi__item__c in :itemids                        and PBSI__Quantity_Left_To_Ship__c > 0                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed'                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed'                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'                         group by pbsi__item__c,PBSI__Estimated_Ship_Date__c,PBSI__Location__c];
        for (AggregateResult ol :arqtyfromsolines)
        {
            if (atpmap.containsKey((id)ol.get('PBSI__Location__c')))
			{
            	if (atpmap.get((id)ol.get('PBSI__Location__c')).containskey((id)ol.get('PBSI__Item__c')))               	atpmap.get((id)ol.get('PBSI__Location__c')).get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
                else            	atpmap.get((id)ol.get('PBSI__Location__c')).put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')});
			}
            else  {
                atpmap.put((id)ol.get('PBSI__Location__c'),new Map<Id,Map<date,double>>{(id)ol.get('PBSI__Item__c')=>new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')}});
            }
        }
        return atpmap;                    
    }
    
        public static Map<Id,Map<Id,Map<date,double>>> CalculateATPpolinesByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();        for (PBSI__PBSI_Sales_Order_Line__c s:solines)          itemids.add(s.PBSI__Item__c);
        List<AggregateResult>  arqtyfrompolines=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty ,                                                    pbsi__purchase_order__r.PBSI__Due_Date__c oldate ,                                                    PBSI__Item__c,                                                    PBSI__Location__c                         from PBSI__PBSI_Purchase_Order_Line__c                         where PBSI__Quantity_Left_To_Receive__c >0                        and PBSI__Item__c in :itemids                       group by PBSI__Item__c,pbsi__purchase_order__r.PBSI__Due_Date__c,PBSI__Location__c];
        for (AggregateResult ol :arqtyfrompolines)
        {
            if (atpmap.containsKey((id)ol.get('PBSI__Location__c')))
			{
            	if (atpmap.get((id)ol.get('PBSI__Location__c')).containskey((id)ol.get('PBSI__Item__c')))                	atpmap.get((id)ol.get('PBSI__Location__c')).get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
                else                	atpmap.get((id)ol.get('PBSI__Location__c')).put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')});
			}
            else            {                atpmap.put((id)ol.get('PBSI__Location__c'),new Map<Id,Map<date,double>>{(id)ol.get('PBSI__Item__c')=>new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')}});            }
        }
        return atpmap;                    
    }
    public static Map<Id,Map<Id,Map<date,double>>> CalculateATPpwosByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();        for (PBSI__PBSI_Sales_Order_Line__c s:solines)           itemids.add(s.PBSI__Item__c);        List<AggregateResult> arqtyfrompwos=[select sum(PBSI__Quantity_Left__c) qty ,          											PBSI__Delivery_Date__c oldate,        											PBSI__Item__c,        											PBSI__Location__c                        from PBSI__Production_Work_Order__c                        where pbsi__item__c in :itemids                        and PBSI__Quantity_Left__c > 0                        group by  pbsi__item__c,PBSI__Delivery_Date__c,PBSI__Location__c];
        for (AggregateResult ol :arqtyfrompwos)        {        	if (atpmap.containsKey((id)ol.get('PBSI__Location__c')))			{            	if (atpmap.get((id)ol.get('PBSI__Location__c')).containskey((id)ol.get('PBSI__Item__c')))                	atpmap.get((id)ol.get('PBSI__Location__c')).get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));                else                	atpmap.get((id)ol.get('PBSI__Location__c')).put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')});			}            else            {                atpmap.put((id)ol.get('PBSI__Location__c'),new Map<Id,Map<date,double>>{(id)ol.get('PBSI__Item__c')=>new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')}});           }        }
        return atpmap;                    
    }
    public static Map<Id,Map<Id,Map<date,double>>> CalculateATPbompwosByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);        List<AggregateResult> arqtyfrombomcomponentspwo=[select sum(PBSI__Quantity_Left__c) qty ,                                                        PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c oldate,                                                        PBSI__Production_Work_Order__r.PBSI__Location__c location,                                                        PBSI__Item__c                    from PBSI__BOM_Depletion_Line__c                   where PBSI__Item__c in :itemids                    and PBSI__Quantity_Left__c > 0                    and PBSI__Production_Work_Order__c <> null                    group by  PBSI__Item__c,PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c,PBSI__Production_Work_Order__r.PBSI__Location__c];
        for (AggregateResult ol :arqtyfrombomcomponentspwo)        {        	if (atpmap.containsKey((id)ol.get('location')))			{            	if (atpmap.get((id)ol.get('location')).containskey((id)ol.get('PBSI__Item__c')))                	atpmap.get((id)ol.get('location')).get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));                else                	atpmap.get((id)ol.get('location')).put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')});			}            else            {                atpmap.put((id)ol.get('location'),new Map<Id,Map<date,double>>{(id)ol.get('PBSI__Item__c')=>new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')}});            }        }
        return atpmap;                    
    }
 

}