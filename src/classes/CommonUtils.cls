public with sharing class CommonUtils {
    public static Map<Id,Map<Id,double>> CalculateATPTodayInventoryMap(Date dt,Set<Id> itemsids,boolean futurealocation,boolean useESD) 
    {
        double qoh=0;                
        double atpcalc=0;       
        Map<Id,Map<Id,double>>atpmap = new Map<Id,Map<Id,double>>();      
        Set<Id> locids = new Set<Id>();
        AggregateResult[] invs=[select sum(pbsi__qty__c) qty,
        										PBSI__location_lookup__c loc,
        										PBSI__item_lookup__c item 
        										from PBSI__PBSI_Inventory__c 										        
        										where										        	
        										PBSI__item_lookup__c in:itemsids									        
        										and	PBSI__Is_Valid__c = 'Yes'									        
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
            locids.add((id)ar.get('loc'));
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
            										and (PBSI__Status__c='Open' or PBSI__Status__c='Pending')                    
            										and PBSI__Item__c in:itemsids  
            										and PBSI__Closed__c = false                 
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
            	
            //	if (!maplocationdate.containskey((String)ar.get('reclot')))
        		//	maplocationdate.put((String)ar.get('reclot'),(Date)ar.get('date1'));               
            }
            //if (dt4==null || (dt4 <> null && dt4< (Date)ar.get('date1')))                    
            //dt4=(Date)ar.get('date1');

        } 
		Set<Id> excludedRTs = new Set<Id>();
		excludedRTs.add(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order'));
		excludedRTs.add(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal'));
        
        List<AggregateResult> arqtyfromsolines = [select sum(PBSI__Quantity_Left_To_Ship__c) qty, PBSI__Location__c  shiploc, pbsi__item__c item, PBSI__Estimated_Ship_Date__c esd 
        											from PBSI__PBSI_Sales_Order_Line__c                        
        											where pbsi__item__c in:itemsids
        										//	and PBSI__Estimated_Ship_Date__c >=:system.today() 
        											and PBSI__Quantity_Left_To_Ship__c > 0
        			                        		and PBSI__Location__c in : locids 
        		                                    and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'     
        		                                    and PBSI__Sales_Order__r.Sales_Order_Type__c != 'Forecast'  
													and PBSI__Sales_Order__r.RecordTypeId NOT IN :excludedRTs
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
	                        and PBSI__Closed__c = false
							and (PBSI__Status__c='Open' or PBSI__Status__c='Pending')                    
	                        group by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c];
        
        	for (AggregateResult ar : arqtyfrompoline)
	        {
	          	Id locidsoline = (id)ar.get('reclot');
				Id itemid = (id)ar.get('item');
				double qty = (double)ar.get('qty');
				Date date2;
/*				if (futurealocation)
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
        /*
        if (dt4!=null)
        {
            arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty,            			PBSI__Location__c reclot,            			PBSI__Item__c item                        
            from PBSI__PBSI_Purchase_Order_Line__c                         
            where PBSI__Due_Date__c <:dt4                        
            and PBSI__Quantity_Left_To_Receive__c >0                        
            and PBSI__Item__c in :itemsids                        and PBSI__Location__c in : locids                        group by PBSI__Item__c,PBSI__Location__c];
        }
        else
		{
            arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty,            			PBSI__Location__c reclot,            			PBSI__Item__c item                        
            from PBSI__PBSI_Purchase_Order_Line__c                         
            where PBSI__Due_Date__c <=:dt2                        
            and PBSI__Quantity_Left_To_Receive__c >0                        
            and PBSI__Item__c in :itemsids                        and PBSI__Location__c in : locids                        group by PBSI__Item__c,PBSI__Location__c];
		}        
        for (AggregateResult ar : arqtyfrompoline)
        {
        	if (atpmap.containsKey((id)ar.get('item')))
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('reclot')))	            	atpmap.get((id)ar.get('item')).put((id)ar.get('reclot'),atpmap.get((id)ar.get('item')).get((id)ar.get('reclot')) + (double)ar.get('qty'));
	        	
	            else	            	atpmap.get((id)ar.get('item')).put((id)ar.get('reclot'),(double) ar.get('qty'));
	        	
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('reclot') => (double) ar.get('qty')});
        }
          */    
/*
        List<AggregateResult> arqtyfrompwo=[select sum(PBSI__Quantity_Left__c) qty ,        				PBSI__Location__c pwoloc,        				pbsi__item__c item                        from PBSI__Production_Work_Order__c                        where pbsi__item__c in :itemsids                        and PBSI__Location__c in : locids                        and PBSI__Quantity_Left__c > 0                        and PBSI__Delivery_Date__c <=:dt2                        group by pbsi__item__c,PBSI__Location__c];
                        
        for (AggregateResult ar : arqtyfrompwo)
        {
        	if (atpmap.containsKey((id)ar.get('item'))) 
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('pwoloc')))            	atpmap.get((id)ar.get('item')).put((id)ar.get('pwoloc'),atpmap.get((id)ar.get('item')).get((id)ar.get('pwoloc')) + (double)ar.get('qty'));
	        	
	            else            	atpmap.get((id)ar.get('item')).put((id)ar.get('pwoloc'),(double) ar.get('qty'));
	        	
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('pwoloc') => (double) ar.get('qty')});
        }     
        List<AggregateResult> arqtyfrombomcomponents=[select sum(PBSI__Quantity_Left__c) qty,        		PBSI__Production_Work_Order__r.PBSI__Location__c bomloc,        		pbsi__item__c item        		from PBSI__BOM_Depletion_Line__c              where pbsi__item__C in :itemsids              and PBSI__Quantity_Left__c > 0              and ((PBSI__Production_Work_Order__c <> null and PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c <= :dt2)              OR (PBSI__Sales_Order__c <> null and pbsi__sales_order__r.pbsi__due_date__c <= :dt2))              and PBSI__Production_Work_Order__r.PBSI__Location__c in : locids              group by pbsi__item__c,PBSI__Production_Work_Order__r.PBSI__Location__c];                           
               for (AggregateResult ar : arqtyfrombomcomponents)
        {
        	if (atpmap.containsKey((id)ar.get('item')))
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('bomloc')))            	
	        		atpmap.get((id)ar.get('item')).put((id)ar.get('bomloc'),atpmap.get((id)ar.get('item')).get((id)ar.get('bomloc')) - (double)ar.get('qty'));
	        	
	            else
	               	atpmap.get((id)ar.get('item')).put((id)ar.get('bomloc'),-(double) ar.get('qty'));
	        	
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('bomloc') => (double) ar.get('qty')});
        }
  */            
        return atpmap;                    
    }  
 

    public static Map<Id,Map<Id,Map<Date,double>>> CalculateATPTodayInventoryMap2(Date dt,Set<Id> itemsids,boolean futurealocation,boolean useESD) 
    {
        double qoh=0;                
        double atpcalc=0;        
        Map<Id,Map<Id,Map<Date,double>>>atpmap = new Map<Id,Map<Id,Map<Date,double>>>();      
        Map<Id,Map<Id,Map<Date,double>>>atpmapinv = new Map<Id,Map<Id,Map<Date,double>>>();      
        Map<Id,Map<Id,Map<Date,double>>>atpmapso = new Map<Id,Map<Id,Map<Date,double>>>();      
        Map<Id,Map<Id,Map<Date,double>>>atpmappo = new Map<Id,Map<Id,Map<Date,double>>>();      
        Set<Id> locids = new Set<Id>();
  //      locids.add('a0X18000000c4kdEAA');
        AggregateResult[] invs=[select sum(pbsi__qty__c) qty,
        										PBSI__location_lookup__c loc,
        										PBSI__item_lookup__c item 
        										from PBSI__PBSI_Inventory__c 										        
        										where										        	
        										PBSI__item_lookup__c in:itemsids	
        										//and PBSI__location_lookup__c in:locids										        
        										and	PBSI__Is_Valid__c = 'Yes'									        
        										and PBSI__Is_Counted__c = 'Yes'									        
        										group by PBSI__item_lookup__c,PBSI__location_lookup__c];
        qoh=0;
		for (AggregateResult ar : invs)  
            locids.add((id)ar.get('loc'));
  /*
		for (AggregateResult ar : invs)  
		{
       		if (atpmap.containsKey((id)ar.get('item'))) 
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('loc'))) 
	        	{ 
	        		if (atpmap.get((id)ar.get('item')).get((id)ar.get('loc')).containskey(dt))
	        			atpmap.get((id)ar.get('item')).get((id)ar.get('loc')).put(dt,atpmap.get((id)ar.get('item')).get((id)ar.get('loc')).get(dt) + (double)ar.get('qty'));
	        		else
	        			atpmap.get((id)ar.get('item')).get((id)ar.get('loc')).put(dt,(double)ar.get('qty'));
	        	}
	            else
	               	atpmap.get((id)ar.get('item')).put((id)ar.get('loc'),new Map<date,double> { dt => (double)ar.get('qty')});
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<Id,Map<date,double>>{(id)ar.get('loc')=>new Map<date,double> { dt => (double)ar.get('qty')}});
       //     locids.add((id)ar.get('loc'));
        } 
*/
        Date dt2;        Date dt4;
        Map<Id,Map<Id,List<Date>>> maplocationdate = new Map<Id,Map<Id,List<Date>>>(); 
        if (dt!=null)            dt2 = date.newInstance(dt.year(), dt.month(), dt.day());
        else            dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day());
        if (futurealocation)
        {
            AggregateResult[]  arqtyfrompolines=[Select  PBSI__Due_Date__c date1,SUM(PBSI__Quantity_Left_To_Receive__c) qty,PBSI__Location__c loc,PBSI__Item__c item                                      
            										from PBSI__PBSI_Purchase_Order_Line__c                    
            										where PBSI__Due_Date__c >=:dt2                   
            										and PBSI__Quantity_Left_To_Receive__c >0
            										and (PBSI__Status__c='Open' or PBSI__Status__c='Pending')                    
            										and PBSI__Item__c in:itemsids  
            										and PBSI__Closed__c = false                 
            										group by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c                    
            										order by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c asc];
            for (AggregateResult ar:arqtyfrompolines) 
            {
            	Date dtdue = (Date)ar.get('date1');
				String itemid = 	(id)ar.get('item');
				String locid = (id)ar.get('loc');
            	if (maplocationdate.containsKey(itemid))
	        	{
		        	if (maplocationdate.get(itemid).containsKey(locid))// &&  maplocationdate.get((id)ar.get('item')).get((id)ar.get('loc')) == null)   
		        	{         	
		        		//maplocationdate.get((id)ar.get('item')).put((id)ar.get('loc'),maplocationdate.get((id)ar.get('item')).get((id)ar.get('loc')));
		        		maplocationdate.get(itemid).get(locid).add(dtdue);
		        		system.debug('ppp1='+(Date) ar.get('date1'));
		        	}
		            else          	
			        {
		        		system.debug('ppp2='+(Date) ar.get('date1'));
			            maplocationdate.get(itemid).put(locid, new List<Date> {dtdue});
			        } 
		    	}
	        	else
	        	{
		        		system.debug('ppp3='+(Date) ar.get('date1'));
	        		
	       			maplocationdate.put(itemid,new Map<id,List<Date>>{locid=> new List<Date> {dtdue}});
	        	}
            }
            system.debug('fff1='+maplocationdate.size());
        } 
		Set<Id> excludedRTs = new Set<Id>();
		excludedRTs.add(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order'));
		excludedRTs.add(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal'));
      
        List<AggregateResult> arqtyfromsolines = [select sum(PBSI__Quantity_Left_To_Ship__c) qty, PBSI__Location__c  loc, pbsi__item__c item, PBSI__Estimated_Ship_Date__c esd 
        											from PBSI__PBSI_Sales_Order_Line__c                        
        											where pbsi__item__c in:itemsids
        										//	and PBSI__Estimated_Ship_Date__c >=:system.today() 
        											and PBSI__Quantity_Left_To_Ship__c > 0
        			                        		and PBSI__Location__c in : locids 
        		                                    and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'     
        		                                    and PBSI__Sales_Order__r.Sales_Order_Type__c != 'Forecast'                    
													and PBSI__Sales_Order__r.RecordTypeId NOT IN :excludedRTs
        		                                    group by pbsi__item__c,PBSI__Location__c,PBSI__Estimated_Ship_Date__c];        
		for (AggregateResult ar : arqtyfromsolines)  
		{
			Date dtesd = (Date)ar.get('esd');
			String itemid = 	(id)ar.get('item');
			String locid = (id)ar.get('loc');
			Double qty = (double)ar.get('qty');		
			system.debug('ddd1='+qty);
			if (maplocationdate.containskey(itemid))
			{
				if (maplocationdate.get(itemid).containsKey(locid))
				{			
	          		List<Date> listdates = new List<Date>(); 
	          		listdates = 	maplocationdate.get(itemid).get(locid);		
	          		system.debug('kkk1='+listdates.size());		
					for (Date dtml : listdates )
					//for (Date dtml : maplocationdate.get(itemid).get(locid))
					{
						if (dtesd <= dtml )
						{					
				      		if (atpmap.containsKey(itemid)) 
				        	{
					        	if (atpmap.get(itemid).containsKey(locid)) 
					        	{ 
					        		if (atpmap.get(itemid).get(locid).containskey(dtml))
					        		{
					        			atpmap.get(itemid).get(locid).put(dtml,atpmap.get(itemid).get(locid).get(dtml) - qty);
					        			system.debug('eee1='+dtml);
					        			system.debug('eee2='+dtesd);
					        		}
					        		else
									{
					        			atpmap.get(itemid).get(locid).put(dtml,0 - qty);
					        			system.debug('eee3='+dtml);
					        			system.debug('eee4='+dtesd);
					        			
									}
					        	}
					            else
					            {
					               	atpmap.get(itemid).put(locid,new Map<date,double> { dtml => 0 - qty});
					            		system.debug('eee5='+dtml);
					        			system.debug('eee6='+dtesd);
					            }
				        	}
				        	else
				        	{
				       			atpmap.put(itemid,new Map<Id,Map<date,double>>{locid=>new Map<date,double> { dtml => 0 - qty}});
					        			system.debug('eee7='+dtml);
					        			system.debug('eee8='+dtesd);
				       			
				        	}
						}
					}
				}
			}
			else
			{
	      		if (atpmap.containsKey(itemid)) 
	        	{
		        	if (atpmap.get(itemid).containsKey(locid)) 
		        	{ 
		        		if (atpmap.get(itemid).get(locid).containskey(dtesd))
		        			atpmap.get(itemid).get(locid).put(dtesd,atpmap.get(itemid).get(locid).get(dtesd) - qty);
		        		else
		        			atpmap.get(itemid).get(locid).put(dtesd,0 - qty);
		        	}
		            else
		               	atpmap.get(itemid).put(locid,new Map<date,double> { dtesd => 0 - qty});
	        	}
	        	else
	       			atpmap.put(itemid,new Map<Id,Map<date,double>>{locid=>new Map<date,double> { dtesd => 0 - qty}});
			}
			
		}

		for (AggregateResult ar : invs)  
		{
			String itemid = 	(id)ar.get('item');
			String locid = (id)ar.get('loc');
			Double qty = (double)ar.get('qty');	
			system.debug('ddd2='+qty);
			if (qty > 0 )
			{									
	       		if (atpmap.containsKey(itemid)) 
	        	{
		        	if (atpmap.get(itemid).containsKey(locid)) 
		        	{ 
		        		for(Date dtmap : atpmap.get(itemid).get(locid).keyset())
		        		{
		        			system.debug('ccc1='+dtmap);
		        			atpmap.get(itemid).get(locid).put(dtmap,atpmap.get(itemid).get(locid).get(dtmap) + qty);
		        		}
		        	}
		            else
					{
	        			system.debug('ccc2='+dt2);
		               	atpmap.get(itemid).put(locid,new Map<date,double> { dt2 => qty});
					}
	        	}
	        	else
				{
	       			system.debug('ccc3='+dt2);
	       			atpmap.put(itemid,new Map<Id,Map<date,double>>{locid=>new Map<date,double> { dt2 => qty}});
				}
			}
        } 
			/*
			Date dts = (Date)ar.get('esd');
	        String itemid = (id)ar.get('item');
	        String locid = (id)ar.get('loc');
	        Double qty = (double)ar.get('qty');

			
       		if (atpmapso.containsKey(itemid)) 
        	{
	        	if (atpmapso.get(itemid).containsKey(locid)) 
	        	{ 
	        		if (atpmapso.get(itemid).get(locid).containskey(dts))
	        			atpmapso.get(itemid).get(locid).put(dts,atpmap.get(itemid).get(locid).get(dts) + qty);
	        		else
	        			atpmapso.get(itemid).get(locid).put(dts,qty);
	        	}
	            else
	               	atpmapso.get(itemid).put(locid,new Map<date,double> { dts => qty});
        	}
        	else
       			atpmapso.put(itemid,new Map<Id,Map<date,double>>{locid =>new Map<date,double> { dts => qty}});
        } 
*/
 			List<AggregateResult>  arqtyfrompoline;
	        arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty,
	            				PBSI__Location__c loc,
	            				PBSI__Item__c item,
	            				PBSI__Due_Date__c esd
	                        from PBSI__PBSI_Purchase_Order_Line__c  
	                        where 
	                        PBSI__Quantity_Left_To_Receive__c >0
	                        and PBSI__Item__c in :itemsids
	                        and PBSI__Location__c in : locids
	                        and PBSI__Due_Date__c > :system.today() 
	                        and PBSI__Closed__c = false
							and (PBSI__Status__c='Open' or PBSI__Status__c='Pending')                    
	                        group by PBSI__Item__c,PBSI__Location__c,PBSI__Due_Date__c];
        
		for (AggregateResult ar : arqtyfrompoline)  
		{
			Date dtesd = (Date)ar.get('esd');
			String itemid = 	(id)ar.get('item');
			String locid = (id)ar.get('loc');
			Double qty = (double)ar.get('qty');		
			system.debug('ddd11='+qty);
			if (maplocationdate.containskey(itemid))
			{
				if (maplocationdate.get(itemid).containsKey(locid))
				{			
					for (Date dtml : maplocationdate.get(itemid).get(locid))
					{
						if (dtesd <= dtml )
						{					
				      		if (atpmap.containsKey(itemid)) 
				        	{
					        	if (atpmap.get(itemid).containsKey(locid)) 
					        	{ 
					        		if (atpmap.get(itemid).get(locid).containskey(dtml))
					        		{
					        			atpmap.get(itemid).get(locid).put(dtml,atpmap.get(itemid).get(locid).get(dtml) + qty);
					        			system.debug('eee11='+dtml);
					        			system.debug('eee22='+dtesd);
					        		}
					        		else
									{
					        			atpmap.get(itemid).get(locid).put(dtml, qty);
					        			system.debug('eee33='+dtml);
					        			system.debug('eee44='+dtesd);
					        			
									}
					        	}
					            else
					            {
					               	atpmap.get(itemid).put(locid,new Map<date,double> { dtml => qty});
					            		system.debug('eee55='+dtml);
					        			system.debug('eee66='+dtesd);
					            }
				        	}
				        	else
				        	{
				       			atpmap.put(itemid,new Map<Id,Map<date,double>>{locid=>new Map<date,double> { dtml => qty}});
					        			system.debug('eee77='+dtml);
					        			system.debug('eee88='+dtesd);
				       			
				        	}
						}
					}
				}
			}
			else
			{
	      		if (atpmap.containsKey(itemid)) 
	        	{
		        	if (atpmap.get(itemid).containsKey(locid)) 
		        	{ 
		        		if (atpmap.get(itemid).get(locid).containskey(dtesd))
		        			atpmap.get(itemid).get(locid).put(dtesd,atpmap.get(itemid).get(locid).get(dtesd) - qty);
		        		else
		        			atpmap.get(itemid).get(locid).put(dtesd,0 - qty);
		        	}
		            else
		               	atpmap.get(itemid).put(locid,new Map<date,double> { dtesd => 0 - qty});
	        	}
	        	else
	       			atpmap.put(itemid,new Map<Id,Map<date,double>>{locid=>new Map<date,double> { dtesd => 0 - qty}});
			}
			
		}

/*		for (AggregateResult ar : arqtyfrompoline)  
		{
			Date dtp = (Date)ar.get('esd');
	        String itemid = (id)ar.get('item');
	        String locid = (id)ar.get('loc');
	        Double qty = (double)ar.get('qty');
			system.debug('ddd3='+qty);
			
       		if (atpmap.containsKey(itemid))
        	{
	        	if (atpmap.get(itemid).containsKey(locid)) 
	        	{ 
	        		if (atpmap.get(itemid).get(locid).containskey(dtp))
	        			atpmap.get(itemid).get(locid).put(dtp,atpmap.get(itemid).get(locid).get(dtp) + qty);
	        		else
	        			atpmap.get(itemid).get(locid).put(dtp,qty);
	        	} 
	            else
	               	atpmap.get(itemid).put(locid,new Map<date,double> { dtp => qty});
        	}
        	else
       			atpmap.put(itemid,new Map<Id,Map<date,double>>{locid =>new Map<date,double> { dtp => qty}});
        } 
  */      
        return atpmap;                    
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
        										and	PBSI__Is_Valid__c = 'Yes'									        
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
            	
            //	if (!maplocationdate.containskey((String)ar.get('reclot')))
        		//	maplocationdate.put((String)ar.get('reclot'),(Date)ar.get('date1'));               
            }
            //if (dt4==null || (dt4 <> null && dt4< (Date)ar.get('date1')))                    
            //dt4=(Date)ar.get('date1');

        } 
		Set<Id> excludedRTs = new Set<Id>();
		excludedRTs.add(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order'));
		excludedRTs.add(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal'));
                
        List<AggregateResult> arqtyfromsolines = [select sum(PBSI__Quantity_Left_To_Ship__c) qty, PBSI__Location__c  shiploc, pbsi__item__c item, PBSI__Estimated_Ship_Date__c esd 
        											from PBSI__PBSI_Sales_Order_Line__c                        
        											where pbsi__item__c in:itemsids
        										//	and PBSI__Estimated_Ship_Date__c >=:system.today() 
        											and PBSI__Quantity_Left_To_Ship__c > 0
        			                        		and PBSI__Location__c in : locids 
        		                                    and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed' and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'     
        		                                    and PBSI__Sales_Order__r.Sales_Order_Type__c != 'Forecast'                    
													and PBSI__Sales_Order__r.RecordTypeId NOT IN :excludedRTs
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
/*				if (futurealocation)
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
        /*
        if (dt4!=null)
        {
            arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty,            			PBSI__Location__c reclot,            			PBSI__Item__c item                        
            from PBSI__PBSI_Purchase_Order_Line__c                         
            where PBSI__Due_Date__c <:dt4                        
            and PBSI__Quantity_Left_To_Receive__c >0                        
            and PBSI__Item__c in :itemsids                        and PBSI__Location__c in : locids                        group by PBSI__Item__c,PBSI__Location__c];
        }
        else
		{
            arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty,            			PBSI__Location__c reclot,            			PBSI__Item__c item                        
            from PBSI__PBSI_Purchase_Order_Line__c                         
            where PBSI__Due_Date__c <=:dt2                        
            and PBSI__Quantity_Left_To_Receive__c >0                        
            and PBSI__Item__c in :itemsids                        and PBSI__Location__c in : locids                        group by PBSI__Item__c,PBSI__Location__c];
		}        
        for (AggregateResult ar : arqtyfrompoline)
        {
        	if (atpmap.containsKey((id)ar.get('item')))
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('reclot')))	            	atpmap.get((id)ar.get('item')).put((id)ar.get('reclot'),atpmap.get((id)ar.get('item')).get((id)ar.get('reclot')) + (double)ar.get('qty'));
	        	
	            else	            	atpmap.get((id)ar.get('item')).put((id)ar.get('reclot'),(double) ar.get('qty'));
	        	
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('reclot') => (double) ar.get('qty')});
        }
          */    
        List<AggregateResult> arqtyfrompwo=[select sum(PBSI__Quantity_Left__c) qty ,        				PBSI__Location__c pwoloc,        				pbsi__item__c item                        from PBSI__Production_Work_Order__c                        where pbsi__item__c in :itemsids                        and PBSI__Location__c in : locids                        and PBSI__Quantity_Left__c > 0                        and PBSI__Delivery_Date__c <=:dt2                        group by pbsi__item__c,PBSI__Location__c];
                        
        for (AggregateResult ar : arqtyfrompwo)
        {
        	if (atpmap.containsKey((id)ar.get('item'))) 
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('pwoloc')))            	atpmap.get((id)ar.get('item')).put((id)ar.get('pwoloc'),atpmap.get((id)ar.get('item')).get((id)ar.get('pwoloc')) + (double)ar.get('qty'));
	        	
	            else            	atpmap.get((id)ar.get('item')).put((id)ar.get('pwoloc'),(double) ar.get('qty'));
	        	
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('pwoloc') => (double) ar.get('qty')});
        }     
        List<AggregateResult> arqtyfrombomcomponents=[select sum(PBSI__Quantity_Left__c) qty,        		PBSI__Production_Work_Order__r.PBSI__Location__c bomloc,        		pbsi__item__c item        		from PBSI__BOM_Depletion_Line__c              where pbsi__item__C in :itemsids              and PBSI__Quantity_Left__c > 0              and ((PBSI__Production_Work_Order__c <> null and PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c <= :dt2)              OR (PBSI__Sales_Order__c <> null and pbsi__sales_order__r.pbsi__due_date__c <= :dt2))              and PBSI__Production_Work_Order__r.PBSI__Location__c in : locids              group by pbsi__item__c,PBSI__Production_Work_Order__r.PBSI__Location__c];                           
               for (AggregateResult ar : arqtyfrombomcomponents)
        {
        	if (atpmap.containsKey((id)ar.get('item')))
        	{
	        	if (atpmap.get((id)ar.get('item')).containsKey((id)ar.get('bomloc')))            	atpmap.get((id)ar.get('item')).put((id)ar.get('bomloc'),atpmap.get((id)ar.get('item')).get((id)ar.get('bomloc')) - (double)ar.get('qty'));
	        	
	            else	            	atpmap.get((id)ar.get('item')).put((id)ar.get('bomloc'),-(double) ar.get('qty'));
	        	
        	}
        	else
       			atpmap.put((id)ar.get('item'),new Map<id,double>{(id)ar.get('bomloc') => (double) ar.get('qty')});
        }
              
        return atpmap;                    
    }  

	public static string fn_getStringIds(set<id> IdsToConcatenate_List) {
		string strReturnedIds = '(';
		for (id idItem : IdsToConcatenate_List) {
			if (strReturnedIds.length() > 1)
				strReturnedIds += ',';
			strReturnedIds += '\'' + idItem + '\'';
		}
		strReturnedIds += ')';
		return strReturnedIds;
	}

     public static Set<Id> allLocationsByUserLocation()
    {
	   	List<PBSI__User_Location__c> userLoc ;	   	Set<Id> locationIds = new Set<Id>();	   	String inventorylocation;   		userLoc = [Select PBSI__Location__c From PBSI__User_Location__c where PBSI__User__c=:UserInfo.getUserId() and PBSI__Is_Active__c=true];
   		//userLoc = [Select PBSI__Location__c From PBSI__User_Location__c where PBSI__User__c=:UserInfo.getUserId()];
   		if (userLoc!=null && userLoc.size()>0)	inventorylocation = userLoc[0].PBSI__Location__c;
    	if (inventorylocation!=null)  		{    			SoqlService sql = new SoqlService(); locationIds = sql.GetAllLocationsFromParentId(inventorylocation);       		locationIds.add(inventorylocation);   		}
   		return locationIds;
    }
      public static Map<Id,Map<Id,double>> CalculateATPInventoryByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {
        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,double>> atpmap = new Map<Id,Map<Id,double>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrominventory =[select sum(pbsi__qty__c) qty,PBSI__item_lookup__c,PBSI__location_lookup__c                        from PBSI__PBSI_Inventory__c                        where PBSI__item_lookup__c in :itemids				        and				         	PBSI__Is_Valid__c = 'Yes'				        and				            PBSI__Is_Counted__c = 'Yes'                        group by PBSI__item_lookup__c,PBSI__location_lookup__c];        
        for (AggregateResult ol : arqtyfrominventory)
            if (atpmap.containsKey((id)ol.get('PBSI__item_lookup__c')))                atpmap.get((id)ol.get('PBSI__item_lookup__c')).put((id)ol.get('PBSI__location_lookup__c'),(double)ol.get('qty'));
            else                atpmap.put((id)ol.get('PBSI__item_lookup__c'),new Map<id,double> {(id)ol.get('PBSI__location_lookup__c')=> (double)ol.get('qty')});
        return atpmap;      
    } 
       public static Map<Id,Map<Id,Map<date,double>>> CalculateATPsolinesByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();PBSI__Admin__c admin=PBSI__Admin__c.getorgdefaults();list<AggregateResult> arqtyfromsolines;
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        if (admin <> null && admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c <> null)
        {
        	Date d=system.today()-admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c.longvalue();
          	arqtyfromsolines=[select sum(PBSI__Quantity_Left_To_Ship__c) qty , PBSI__Estimated_Ship_Date__c oldate, pbsi__item__c,PBSI__Location__c                        from PBSI__PBSI_Sales_Order_Line__c                        where pbsi__item__c in :itemids                        and PBSI__Quantity_Left_To_Ship__c > 0                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed'                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Packed'                        and PBSI__Sales_Order__r.PBSI__Status__c != 'Cancelled'                        and PBSI__Sales_Order__r.PBSI__Due_Date__c > :d                        group by pbsi__item__c,PBSI__Estimated_Ship_Date__c,PBSI__Location__c];

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

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)          itemids.add(s.PBSI__Item__c);
        List<AggregateResult>  arqtyfrompolines=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty ,                                                    pbsi__purchase_order__r.PBSI__Due_Date__c oldate ,                                                    PBSI__Item__c,                                                    PBSI__Location__c                         from PBSI__PBSI_Purchase_Order_Line__c                         where PBSI__Quantity_Left_To_Receive__c >0                        and PBSI__Item__c in :itemids                        group by PBSI__Item__c,pbsi__purchase_order__r.PBSI__Due_Date__c,PBSI__Location__c];        
        for (AggregateResult ol :arqtyfrompolines)        {
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

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)           itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrompwos=[select sum(PBSI__Quantity_Left__c) qty ,         											PBSI__Delivery_Date__c oldate,        											PBSI__Item__c,        											PBSI__Location__c                        from PBSI__Production_Work_Order__c                        where pbsi__item__c in :itemids                        and PBSI__Quantity_Left__c > 0                        group by  pbsi__item__c,PBSI__Delivery_Date__c,PBSI__Location__c];
                for (AggregateResult ol :arqtyfrompwos)
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
      public static Map<Id,Map<Id,Map<date,double>>> CalculateATPbompwosByLocation(List<PBSI__PBSI_Sales_Order_Line__c> solines) 
    {

        Set<Id> itemids = new Set<Id>();        Map<Id,Map<Id,Map<date,double>>> atpmap = new Map<Id,Map<Id,Map<date,double>>>();
        for (PBSI__PBSI_Sales_Order_Line__c s:solines)            itemids.add(s.PBSI__Item__c);
        List<AggregateResult> arqtyfrombomcomponentspwo=[select sum(PBSI__Quantity_Left__c) qty ,                                                        PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c oldate,                                                        PBSI__Production_Work_Order__r.PBSI__Location__c location,                                                        PBSI__Item__c                    from PBSI__BOM_Depletion_Line__c                    where PBSI__Item__c in :itemids                    and PBSI__Quantity_Left__c > 0                    and PBSI__Production_Work_Order__c <> null                    group by  PBSI__Item__c,PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c,PBSI__Production_Work_Order__r.PBSI__Location__c];
                for (AggregateResult ol :arqtyfrombomcomponentspwo)
        {
        	if (atpmap.containsKey((id)ol.get('location')))
			{
            	if (atpmap.get((id)ol.get('location')).containskey((id)ol.get('PBSI__Item__c')))                	atpmap.get((id)ol.get('location')).get((id)ol.get('PBSI__Item__c')).put((date)ol.get('oldate'),(double)ol.get('qty'));
                else                	atpmap.get((id)ol.get('location')).put((id)ol.get('PBSI__Item__c'),new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')});
			}
            else            {                atpmap.put((id)ol.get('location'),new Map<Id,Map<date,double>>{(id)ol.get('PBSI__Item__c')=>new Map<date,double> {(date)ol.get('oldate')=> (double)ol.get('qty')}});            }
        }
        return atpmap;                    
    }
        public static Set<String> GetStrSetByValueToSplit(String splitSeparator, String valueToSplit)
    {
        Set<String> valuesSet = new Set<String>();

        if(valueToSplit == null)            return valuesSet;

        String[] arrSplitedValue = valueToSplit.split(splitSeparator);

        for(String value: arrSplitedValue)
        {
            if(!CommonUtils.stringIsNullOrEmpty(value))                valuesSet.add(value);
        }

        return valuesSet;
    }
        public static Boolean stringIsNullOrEmpty(String value)
    {
        if(value != null)
        {
            value = value.trim();
            if(value != '')            {                return false;            }
        }

        return true;
    }
 	public static PBSI.SerialN[] getPackLineSerialsByLimitedSerials(List<List<PBSI.SerialN>> limitedSerials)
    {
         PBSI.SerialN[] serialnumbers = new PBSI.SerialN[]{};

         if(limitedSerials == null)
         {
            return serialnumbers;
            limitedSerials = new List<List<PBSI.SerialN>>();
         }

         for(List<PBSI.SerialN> serialList: limitedSerials)
            for(PBSI.SerialN serial: serialList)          serialnumbers.add(serial);
         return serialnumbers;
    }
    public static List<List<PBSI.SerialN>> GetLimitedSerials(List<PBSI.SerialN> allSerialsList)
    {
        Integer listLimit = 1000; 
        Integer counter = 0;
        List<PBSI.SerialN> tmpSerialList = new List<PBSI.SerialN>();
        List<List<PBSI.SerialN>> limitedSerials = new List<List<PBSI.SerialN>>();

        for (PBSI.SerialN serial: allSerialsList) 
        {
            if(counter < listLimit)
            {
               tmpSerialList.add(serial);               counter++;
            }
            else
            {
               limitedSerials.add(tmpSerialList);               tmpSerialList = new List<PBSI.SerialN>{serial};               counter = 0;
            }
        }  
        
        if(tmpSerialList.size() > 0 && tmpSerialList.size() <= listLimit)
            limitedSerials.add(tmpSerialList);
            
        return limitedSerials;
    }
    
 
}