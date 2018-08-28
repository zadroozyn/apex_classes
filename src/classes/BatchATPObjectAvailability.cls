public with sharing class BatchATPObjectAvailability implements Database.Batchable<SObject> 
{
		public List<PBSI__PBSI_Inventory__c> start(Database.BatchableContext bcMain)
    {
        return [select pbsi__qty__c,PBSI__Lot__c, id, PBSI__item_lookup__c,PBSI__location_lookup__c,pbsi__area__c,pbsi__Carton__c,pbsi__pallet__c,Current_ATP__c, Current_ATP_Last_Calculated_at__c 
        				from PBSI__PBSI_Inventory__c
        				where PBSI__item_lookup__c <> null  //and    PBSI__item_lookup__c='a0W18000001bOoX'     
        				//order by PBSI__item_lookup__r.name asc,createdDate asc
        				//for update
        				]; 
    }
    
    public void execute(Database.BatchableContext bcMain, List<PBSI__PBSI_Inventory__c> invs) 
    {
		Date dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day());
		Double warning=0;
		PBSI__Admin__c CS=PBSI__Admin__c.getOrgDefaults();
		 if (CS != null && CS.ATP_Warning_Level__c !=null) warning = CS.ATP_Warning_Level__c ;
		Set<Id> itemsids = new Set<Id>();
		for (PBSI__PBSI_Inventory__c i2:invs)
			itemsids.add(i2.PBSI__item_lookup__c);
       	Map<Id,Map<Id,Map<Date,double>>> atpmap = CommonUtils.CalculateATPTodayInventoryMap2(dt2,itemsids,true,true);
       	List<ATP__c> atplist = [Select Availability_Date__c,Item__c,Location__c,Current_ATP__c,Current_ATP_Last_Calculated_at__c,AV_Date_ATP_Last_Calculated_at__c,Av_Date_ATP__c from ATP__c where Item__c in:itemsids];
       	List<ATP__c> atplisttoupdate = new List<ATP__c>();
       	List<ATP__c> atplisttoinsert = new List<ATP__c>();
       	List<PBSI__PBSI_Inventory__c> listintoupdate = new List<PBSI__PBSI_Inventory__c>();
       	Date todaydate = system.today();
		for (PBSI__PBSI_Inventory__c i:invs)
        {
        	boolean exist = false;
        	double curentatp = 0;
        	double atpcalc =0;
        	Date avdate;
        	if (atpmap.containskey(i.PBSI__item_lookup__c))
        		if (atpmap.get(i.PBSI__item_lookup__c).containskey(i.PBSI__location_lookup__c))
				{
	          		Map<Date,double> mapdates = new Map<Date,double>(); 
	          		mapdates = atpmap.get(i.PBSI__item_lookup__c).get(i.PBSI__location_lookup__c);
	          		List<Date> listdates = new List<Date>();
	          		listdates.addall(mapdates.keyset());
	          		listdates.sort();
	          		for(Date d:listdates)
	          		{
	          			atpcalc = mapdates.get(d);
						curentatp =atpcalc	;
						avdate = d;
	        			if (atpcalc >= warning)
							break;											
	          		}
				}        		
        		
        	for (ATP__c a : atplist)
        	{
        		if (a.Item__c == i.PBSI__item_lookup__c && a.Location__c == i.PBSI__location_lookup__c)
        		{
	        		//a.Current_ATP__c = curentatp;
	        		a.Av_Date_ATP__c = curentatp;
	        		a.AV_Date_ATP_Last_Calculated_at__c = system.today();
	        		if (avdate > todaydate) {
	        			if (curentatp >= warning) {
	        				a.Availability_Date__c = avdate;
	        			} else {
	        				a.Availability_Date__c = null;
	        			}
	        		} else {
	        			a.Availability_Date__c = null;
	        		}
	        		a.Inventory__c = i.Id;
	        		atplisttoupdate.add(a);
	        		exist = true;
        		}
        	}	
			if (!exist)
    		{
    			ATP__c ai = new ATP__c(Item__c = i.PBSI__item_lookup__c, Location__c = i.PBSI__location_lookup__c,Av_Date_ATP__c = curentatp,AV_Date_ATP_Last_Calculated_at__c = datetime.now(),Inventory__c = i.Id);
    			atplisttoinsert.add(ai);
    		}
        }
        Map<Id,ATP__c> mapatp = new Map<Id,ATP__c>();
        mapatp.putAll(atplisttoupdate);
        //update atplisttoupdate; 
        update mapatp.values();
        insert atplisttoinsert;
    }   
    public void finish(Database.BatchableContext bc)
    {

    	        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                                from AsyncApexJob where Id = :BC.getJobId()];
 
        // Create and send an email with the results of the batch.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        mail.setToAddresses(new String[] {a.CreatedBy.Email});
       
        mail.setSenderDisplayName('Salesforce');
        mail.setSubject('Inventory atp batch job is' + a.Status);
        mail.setPlainTextBody('The batch apex job processed ' + a.TotalJobItems +
        ' batches with ' + a.NumberofErrors + ' failures.');
 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }	
	

}