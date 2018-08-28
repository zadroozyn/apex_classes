public with sharing class LookupSearch {
	
	String objName;
	public String searchvalue{get;set;}
	public String fieldtoSearch{get;set;}
	public List<PBSI__PBSI_Item__c> items{get;set;}
	public List<Res> results{get;set;}
	Map<String, Schema.SObjectField> M =Schema.SObjectType.PBSI__PBSI_Item__c.fields.getMap();
	public string col2Label{get;set;}
	public String displayNotAvailableForSale;  
	PBSI__Admin__c admin=PBSI__Admin__c.getOrgDefaults();
	
	public  LookupSearch() 
	{
		objName=System.currentPageReference().getParameters().get('objname');
		displayNotAvailableForSale = System.currentPageReference().getParameters().get('displayNotAvailableForSale');
		String itemID = System.currentPageReference().getParameters().get('itemID');
		
		fieldtoSearch = 'Name';
		
		if (admin != null && admin.PBSI__Default_Field_on_Enhanced_Lookup_Item__c != null)
		{
		   fieldtoSearch=admin.PBSI__Default_Field_on_Enhanced_Lookup_Item__c;
		   if(fieldtoSearch == 'description__c')
		   	  fieldtoSearch = 'pbsi__description__c';
		}
		  
		if(itemID != null && itemID != '')
		{   
			PBSI__PBSI_Item__c selectedItem = Database.query('SELECT ' + fieldtoSearch + ' FROM PBSI__PBSI_Item__c WHERE Id = \'' + itemID + '\'');
			this.searchvalue = (string)selectedItem.get(fieldtoSearch);
		}
	}
	
	public List<SelectOption> getfields()
	{
		//SObjectType objToken = Schema.getGlobalDescribe().get('PBSI__PBSI_Item__c');
		//DescribeSObjectResult objDef = objToken.getDescribe();
	  List<SelectOption> options=new List<SelectOption>();
	   
		 
	   List<String> fieldlist=new List<String>();
	   for (string  s:M.keySet())
	    if (M.get(s).getDescribe().getType() == Schema.DisplayType.string || M.get(s).getDescribe().getType() == Schema.DisplayType.textarea)
	   fieldlist.add(s);
	   fieldlist.sort();
		
		for (string s : fieldlist)
	    {
	    	if(s != 'pbsi__item_description_long__c' &&
	    	   s != 'pbsi__purchase_order_description_long__c' &&
	    	   s != 'pbsi__sales_order_description_long__c')
	      	{  
	      	   if(s == 'description__c')
	      	   	  s = 'pbsi__description__c';
	      	   	  	 
	      	   options.add(new SelectOption(s, M.get(s).getDescribe().getLabel()));
	      	}
	    }
	    
		return options;
		
	}
	
	// Changed by Elaine
	public pagereference search()
	{
	 	if (fieldtoSearch != 'name')
		    col2Label=M.get(fieldtoSearch).getDescribe().getLabel();
		
		String text='%'+searchvalue+'%';
		List<String> separated=searchvalue.split(' ');
		system.debug(separated);
		
		String opplCondition = '';			
		if(this.displayNotAvailableForSale == 'No')
		{
			opplCondition = ' AND ' +
				   			'    PBSI__Not_Available_For_Sale__c = false ';
		}
		
		if (separated.size() > 1)
		{
			String str;
			
			if (fieldtoSearch != 'name')
			 	str='select Id,Name,'+fieldtoSearch+' from PBSI__PBSI_Item__c where ';
			else
			 	str='select Id,Name from PBSI__PBSI_Item__c where ';
			
			for (integer i=0;i<separated.size();i++)
			{
				if (i != 0) str+=' and ';
			 		str+=fieldtoSearch+' like \'%'+separated[i]+'%\'';
			}

			str += opplCondition;
			
			str+=' limit 1000';
			
			system.debug(str);
			
			items=Database.query(str);
		}
		else
		{
			if (fieldtoSearch != 'name')
				items=Database.query('select Id,Name,'+fieldtoSearch+' from PBSI__PBSI_Item__c where '+fieldtoSearch +' like \''+text+'\' '+ opplCondition +' limit 1000');
			else
				items=Database.query('select Id,Name from PBSI__PBSI_Item__c where '+fieldtoSearch +' like \''+text+'\' ' + opplCondition + ' limit 1000');
		}
		
		results=new List<Res>();
		
		for (PBSI__PBSI_Item__c i:items)
		{
		  	Res r=new Res(i);
		  	  	
		  	if (fieldtoSearch != 'name')
		  	    r.col2value=(string)i.get(fieldtoSearch);
		  	  
		  	results.add(r);
	    }
		
		return null;
	}
	
	public class Res{
		public PBSI__PBSI_Item__c it{get;set;}
		public string col2value{get;set;}
		
		public Res(PBSI__PBSI_Item__c i)
		{
			it=i;
			
		}
	}

}