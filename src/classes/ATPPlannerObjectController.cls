public with sharing class ATPPlannerObjectController {
	public PBSI__PBSI_Sales_Order_Line__c input{get;set;}
	public PBSI__PBSI_Item_Group__c inputitemgroup {get;set;}
	public List<ATP__c> atplist {get;set;}
	public List<String> locationlist {get;set;}
	public Map<String,Map<String,Double>> mapatp {get;set;}
	public Datetime lastatpdate {get;set;}
	public PBSI__Admin__c admin{get;set;}
	public double warninglevel {get;set;}
	public List<string> inputitemgroupid {get;set;}
	public List<string> inputfabriccode {get;set;}
	public string inputsize {get;set;}
	public string inputlocation {get;set;} 
	public String renderingService { get; private set; }
	public String renderedContentType{get;set;}
	public ATPPlannerObjectController()
	{
	     admin= PBSI__Admin__c.getOrgDefaults();
		if (admin!=null && admin.ATP_Warning_Level__c!=null)
			warninglevel = admin.ATP_Warning_Level__c; 
		else
			warninglevel = 1000;
	    input=new PBSI__PBSI_Sales_Order_Line__c();
	    refresh();
	    renderedContentType  = 'text/html';
	} 
	/*
	   public String renderedContentType {
        get {
            String renderedContentType = 'text/html'; // the default
            if( ! this.renderingAsHtml() ) {
                renderedContentType = 'application/vnd.ms-excel#ATPPlannerGlobal.xls';
            }
            return renderedContentType;
        }
    }
	
	    public Boolean renderingAsHtml() {
        return ( (renderingService == null) || ( ! renderingService.startsWith('Excel')) );
    }
	*/
	public pagereference ExportExcel()
	{
		//renderingService = 'Excel';
		renderedContentType = 'application/vnd.ms-excel#ATPPlannerGlobal.xls';
		//PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
		//pageRef.setRedirect(true);
		//return pageRef;
		return null;
	}	
	
	public pagereference calculate()
	{ 
		BatchATPObject ba = new BatchATPObject();
        Database.executeBatch(ba);
		ApexPages.addMessage(new ApexPAges.Message(ApexPages.Severity.Info, 'Batch Job is running'));   
		return null;     
	}
	public List<SelectOption> getitemgroup()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All', 'All'));		
		List<PBSI__PBSI_Item_Group__c> listig = [Select Name from PBSI__PBSI_Item_Group__c  order by Name];
		for (PBSI__PBSI_Item_Group__c i : listig)
			options.add(new SelectOption(i.Id,i.Name));
		return options;
	}

	public List<SelectOption> getfabriccode()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All', 'All'));		
		List<Fabric__c> listig = [Select Name From Fabric__c where id IN (Select Fabric_Code__c From PBSI__PBSI_Item__c)  order by Name];
		for (Fabric__c i : listig)
			options.add(new SelectOption(i.Id,i.Name));
		return options;
	}
		
	public List<SelectOption> getsize()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All', 'All'));		
		List<Sizes__c> listig = [Select Name From Sizes__c where id IN (Select Size__c From PBSI__PBSI_Item__c)  order by Name];
		for (Sizes__c i : listig)
			options.add(new SelectOption(i.Id,i.Name));
		return options;
	}

	public List<SelectOption> getlocation()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All', 'All'));		
		List<PBSI__PBSI_Location__c> listig = [Select Name From PBSI__PBSI_Location__c order by Name];
		for (PBSI__PBSI_Location__c i : listig)
			options.add(new SelectOption(i.Id,i.Name));
		return options;
	}

	public void refresh()
	{
	    atplist = new List<ATP__c>();
	    locationlist = new List<String>();
	     mapatp = new Map<String,Map<STring,Double>>();
	     Set<String> locationset = new Set<String>();
	     Set<String> itemset = new Set<String>();
		//String xid = ApexPages.currentPage().getParameters().get('inputitemgroupid');	     
		//String xid = inputitemgroup.Id;
		String sqlstr ='Select Item__r.Name,Location__c,Location__r.Name,Current_ATP__c,Current_ATP_Last_Calculated_at__c From ATP__c where Location__r.Is_Stock_Location__c=true ';
	     if (inputitemgroupid!=null && (inputitemgroupid.size() > 0 && inputitemgroupid[0]!='All'))
	     	sqlstr += ' and Item__r.PBSI__Item_Group__c =:inputitemgroupid ';
		 if (inputfabriccode!=null && (inputfabriccode.size() > 0 && inputfabriccode[0]!='All'))
		 {
//		 	Set<String> fabriccodeset = new Set<String>();
	//	 	for (String  i : inputfabriccode)
		 		
	     	sqlstr += ' and Item__r.Fabric_Code__c in:inputfabriccode ';
		 }
		if (inputsize!=null && inputsize!='All')
	     	sqlstr += ' and Item__r.Size__c =:inputsize ';

		if (inputlocation!=null && inputlocation!='All')
	     	sqlstr += ' and Location__c =:inputlocation ';
	     sqlstr +=	' order by Item__r.Name limit 100';
		atplist = Database.query(sqlstr); 
/*	     if (inputitemgroupid==null)
	    	atplist = [Select Item__r.Name,Location__c,Location__r.Name,Current_ATP__c,Current_ATP_Last_Calculated_at__c From ATP__c where Location__r.Is_Stock_Location__c=true order by Item__r.Name limit 1000];
	    else
	    	atplist = [Select Item__r.Name,Location__c,Location__r.Name,Current_ATP__c,Current_ATP_Last_Calculated_at__c From ATP__c where Location__r.Is_Stock_Location__c=true and Item__r.PBSI__Item_Group__c =:inputitemgroupid order by Item__r.Name limit 1000];
	*/
	    ////and PBSI__Item__r.PBSI__Item_Group__c =:inputitemgroup.Id
	    for (ATP__c a:atplist)
	    {
			lastatpdate = a.Current_ATP_Last_Calculated_at__c;
	    	locationset.add(a.Location__r.Name);
	    	itemset.add(a.Item__r.Name);
	    	//if (!locationlist.contains(a.Location__r.Name))
	    		//locationlist.add(a.Location__r.Name);
	    }
	    for (String itemname : itemset)
	    	for (String locname : locationset)
			{
				if (mapatp.containskey(itemname))
	    		{
	    			if (!mapatp.get(itemname).containskey(locname))
	    				mapatp.get(itemname).put(locname,0);
	    		}
	    		else
	    			mapatp.put(itemname, new Map<String,Double> {locname=> 0});
				
			}	    
	    for (ATP__c a:atplist)
	    {
	    	if (mapatp.containskey(a.Item__r.Name))
	    	{
	    		if (mapatp.get(a.Item__r.Name).containskey(a.Location__r.Name))
	    			mapatp.get(a.Item__r.Name).put(a.Location__r.Name,a.Current_ATP__c);
	    	}
//	    	else
	//    		mapatp.put(a.Item__r.Name, new Map<String,Double> {a.Location__r.Name => a.Current_ATP__c});
	    }
	    locationlist.addall(locationset);
		
	}
}