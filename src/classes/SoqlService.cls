public with sharing class SoqlService 
{
	public List<PBSI__PBSI_Inventory__c> GetValidInventoriesByLocations(Set<Id> locationIDs, Boolean lotForLocation, Set<Id> itemIDs)
	{
		String lotForLocClause;
		
		if(lotForLocation)
		{
			lotForLocClause = '	AND	PBSI__Lot__r.PBSI__Lot_For_Location__c = \'Yes\' ';
		}
		else
		{ 
		    lotForLocClause = '	AND	PBSI__Lot__r.PBSI__Lot_For_Location__c = \'No\' ' +
		    				  ' AND PBSI__Lot__r.PBSI__Lot_Status__c = \'Released\' ' +  
		    				  ' AND PBSI__Lot__r.PBSI__Expiration_Date__c > Today '; 
		}
		
		String sqlQuery = 'SELECT ' +
 					'PBSI__Qty__c, ' +
 					'Id, ' +
 					'PBSI__Real_Quantity__c, ' +
 					'PBSI__Lot__c, ' +
 					'PBSI__Lot__r.Name, ' +
 					'PBSI__Lot__r.PBSI__Location__c, ' +
 					'PBSI__location_lookup__r.Name, ' +
 					'PBSI__Area__c, ' +
 					'PBSI__Carton__c, ' +
 					'PBSI__item_lookup__c, ' +
 					'PBSI__item_lookup__r.Name, ' +
 					'PBSI__item_lookup__r.PBSI__Description__c, ' +
 					'PBSI__item_lookup__r.PBSI__Is_Serialized__c ' +
 			  'FROM ' +
 			  '		PBSI__PBSI_Inventory__c ' + 
 			  'WHERE ' +
 			  '	    PBSI__Qty__c > 0 ' +
 			  ' AND ' +
 			  '     PBSI__item_lookup__c IN: itemIDs ' +
 			  	lotForLocClause +  
 			  'and ' +
 			  '		PBSI__Is_Valid__c = \'Yes\' ' + 
 			  'and ' +
 			  '     PBSI__location_lookup__r.Name <> \'SHIP\' ' +
 			  'and ' +
 			  '		PBSI__location_lookup__c IN: locationIDs ' +
 			  'order by ' +
 			  '		PBSI__Lot__r.Name ' + 
 			  'ASC ';
 			  
 	    return Database.query(sqlQuery); 
	}
	
	public List<PBSI__PBSI_Sales_Order__c> GetSalesOrdersByIDs(Set<Id> soIDs)
	{
		String isoCode = '';
		if (UserInfo.isMultiCurrencyOrganization())
  	  		isoCode = '    CurrencyIsoCode, ';
		
		String sqlQuery = ' SELECT ' +  
		                       isoCode +
 						  '    Id, PBSI__hasMJ__c, ' +
 						  '    PBSI__Movement_Journal__c, Name, ' +
 						  '    PBSI__Status__c, PBSI__Contact__r.email, ' +
 						  '    PBSI__Contact__r.FirstName, PBSI__Contact__r.LastName, ' + 
 						  '    PBSI__Ship_Location__c, PBSI__Customer__c, ' + 
						  '    PBSI__Order_Date__c, PBSI__Delivery_Street__c, ' + 
						  '    PBSI__Delivery_City__c, PBSI__Delivery_State__c, ' + 
						  '    PBSI__Delivery_Postal_Code__c, PBSI__Delivery_Country__c, ' + 
						  '    PBSI__Contact__c, PBSI__Due_Date__c, ' + 
						  '    PBSI__Mode_of_Delivery__c, PBSI__Shipping_Instructions__c, ' +
						  '    PBSI__Delivery_Streetnew__c, PBSI__Contact_Email__c, ' + 
						  '    PBSI__Delivery_ATTN_to__c, PBSI__Delivery_Company__c, ' + 
						  '    PBSI__Delivery_Address_line2__c, PBSI__Delivery_Address_line_3__c, ' + 
						  '    PBSI__Delivery_ATTN_to_Phone__c, PBSI__BillingZip__c, ' +
						  '    PBSI__BillingCompany__c, PBSI__BillingStreet__c, ' +
						  '    PBSI__BillingCity__c, PBSI__BillingState__c, ' +
						  '    PBSI__BillingCountry__c, PBSI__Customer__r.BillingStreet, ' +
						  '    PBSI__Customer__r.BillingCity, PBSI__Customer__r.BillingState, ' +
						  '    PBSI__Customer__r.BillingPostalCode, PBSI__Customer__r.BillingCountry, ' +
						  '    PBSI__Delivery_County__c, PBSI__Customer_Purchase_Order__c, ' +
						  '    PBSI__Pack_Slip_Terms__c, PBSI__Customer__r.Name, ' +
						  '    PBSI__Comments__c,  PBSI__Terms_Conditions__c, ' +
						  '    PBSI__Tracking_Code__c, ' +
						  '    PBSI__Invoice_Date__c, PBSI__Order_Discount__c, PBSI__Order_Total__c, ' +
						  '    PBSI__Sales_Tax__c, PBSI__Shipping_Cost__c, ' +
						  '    PBSI__Shipping_Discount__c, ' +
						  '    PBSI__Misc_Charges__c, PBSI__Final_Order_Total__c, PBSI__From_Location__c ' +
						  ' FROM ' +
						  '    PBSI__PBSI_Sales_Order__c ' +
						  ' WHERE ' + 
						  '    Id IN: soIDs ';
                 
	    return Database.query(sqlQuery);         
	}
	public Set<Id> GetAllLocationsFromParentId(Id locId)
	{
		Set<Id> locids = new Set<Id>();	   	Id lastparentid=null;	   	Id parentid = locId;   		Set<Id> parentids = new Set<Id>();
   		parentids.add(locId);
	   	do{
	   		List<PBSI__PBSI_Location__c> loclist =[Select Id From PBSI__PBSI_Location__c where PBSI__Source_Location__c in :parentids];
	   		parentids.clear();
	   		for (PBSI__PBSI_Location__c l : loclist)
	   		{
		   		locids.add(l.Id);   				parentids.add(l.Id);
	   		}
	   	} 
	   	while (parentids.size()>0);
	   	return locids;
	}

	public Map<Id,double> getItemLocatorQty(Set<Id> inventorylocationids,Set<Id> itemsid) 
	{ 
		Map<Id,double> mapitemlocator = new Map<Id,double>();
		if (inventorylocationids.size()>0)
		{
/*       		List<AggregateResult> ar = [Select sum(PBSI__Quantity_On_Hand__c) qty,
								       		PBSI__Item__c 
								       		From PBSI__Item_Locator__c 
								       		where PBSI__Location__c in :inventorylocationids and PBSI__Item__c in :itemsid
								       		group by PBSI__Item__c];
	*/		List<AggregateResult> ar1 =[Select sum(PBSI__qty__c) qty, 
											PBSI__item_lookup__c 
											From PBSI__PBSI_Inventory__c								       		
								       		where PBSI__location_lookup__c in :inventorylocationids and PBSI__item_lookup__c in :itemsid
								       		group by PBSI__item_lookup__c];
								       		
//       		for (AggregateResult a:ar) 				mapitemlocator.put((Id)a.get('PBSI__Item__c'),(double) a.get('qty'));
       		for (AggregateResult a:ar1) 				mapitemlocator.put((Id)a.get('PBSI__item_lookup__c'),(double) a.get('qty'));
       	}
       	return mapitemlocator;
	}
	
}