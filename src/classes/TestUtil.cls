/**
 * Utility methods for test classes
 *
 * Author: Elaine Iovcev
 *
 * ver 1.1 2014-05-28 Mehmet Birgi <mehmet.birgi@nefos.com>
 *                      Fixed illegal country error
 *
 * Copyright (c) 2014 Nefos GmbH
 *
 **/
public with sharing class TestUtil 
{
	public static PBSI__Property__c GetProperty(String propName, String propValue)
	{
		 return new PBSI__Property__c(Name = String.valueOf(system.now()),
	                                  PBSI__Property_Name__c = propName,
	                                  PBSI__Property_Value__c = propValue); 
	}
	
	public static Account GetAccount()
	{
        //String accountCountry = 'United States';
        //pw_ccpro__CountryObject__c country = new pw_ccpro__CountryObject__c();
        //country.Name = accountCountry;
        //country.pw_ccpro__IsoCode_2__c = 'US';
        //country.pw_ccpro__IsoCode_3__c = 'USA';
        //insert country;
		return new Account(Name = 'Account', 
                           BillingCountry = 'United States',
						   ShippingCountry = 'United States',
                           BillingState = 'Alaska',  
                           ShippingState = 'Alaska',  
                           PBSI__Payment_Terms__c = 'Net 35');
	}
	
	public static PBSI__PBSI_Location__c GetLocation()
	{
		return new PBSI__PBSI_Location__c(Name = String.valueOf(system.now()), 
	 															PBSI__description__c = 'Shipping',
	 															PBSI__Default_for_Account__c = false);
	}
	
	public static PBSI__PBSI_Item_Group__c GetItemGroup()
	{
		return new PBSI__PBSI_Item_Group__c(Name = 'Group', 
		 									PBSI__Description__c = 'PBS Tools', 
		 									PBSI__Item_Group_Code__c = '876',
                                            Group_Description__c = 'Test');
	}
	
	public static PBSI__PBSI_Item__c GetItem(String locationId, String groupID)
	{
        return new PBSI__PBSI_Item__c(Name = String.valueOf(system.now()), 
                                      PBSI__purchaseprice__c = 2, 
                                      PBSI__salesprice__c = 88, 
                                      PBSI__description__c = 'Hammer test', 
                                      PBSI__defaultunitofmeasure__c = 'EA', 
                                      PBSI__Default_Location__c = locationId, 
                                      PBSI__Lot_Tracking__c = true, 
                                      PBSI__Item_Group__c = groupID,
                                      EAN_Number__c = String.valueOf(system.now()));
	}
	
	public static PBSI__Unit__c GetItemUnit(String itemID)
	{
		 return new PBSI__Unit__c(Name = String.valueOf(system.now()),
                                  PBSI__Item__c = itemID,
                                  PBSI__Applies_To__c = 'Sales Order'); 
	}
	
	public static PBSI__Item_Version__c GetItemVersion(String itemID)
	{
		 return new PBSI__Item_Version__c(Name = String.valueOf(system.now()),
		                                  PBSI__Item__c = itemID); 
	}
	
	public static PBSI__Bom__c CreateBom()
	{
		 return new PBSI__Bom__c(Name = String.valueOf(system.now()));
		  						 //PBSI__version_number__c = 10,
		  						 //PBSI__revision__c = 10,
		  						 //PBSI__default__c = true); 
	}
    public static PBSI__BOM__c CreateBom(Id itemID)
    {
           return new PBSI__BOM__c(Name = 'BOM' + itemID,
                                   PBSI__Item__c = itemID);
    }
	
	public static PBSI__PBSI_Sales_Order_Line__c GetSalesOrderLine(String salesOrderID, String itemID)
	{
    	 PBSI__PBSI_Sales_Order_Line__c salesOrderLine = new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = salesOrderID, 
    	 																					PBSI__Quantity_Needed__c = 4, 
    	 																					PBSI__Quantity_Picked__c = 3,
    	 																					PBSI__Item__c = itemID, 
    	 																					PBSI__Price__c = 5,
    	 																					PBSI__TransactionType__c = 'Sale');
     
	     return salesOrderLine;
	}
	
	public static User createAdminUser(String adminUserName){
        Profile p = [select id from profile where name = 'System Administrator'];
        User adminUser= new User(username = adminUserName,
                                alias = 'admin',
                                email = 'admin@on.test',
                                emailencodingkey = 'UTF-8',
                                //Ignore_Specified_Validation_Rules__c = true,
                                lastname = 'Testing',
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                profileid = p.Id,
                                c2g__APILicenseKey__c = 'c0a0c4f774b2ee7528eb56e7cd81ee35fae64f3e',
                                timezonesidkey = 'Europe/Berlin');
        insert adminUser;
        System.debug('Created User: ' + adminUser);
        return adminUser;
    }
    public static On_Payment_Terms__c createPaymentTerms(Integer termDays){
    	On_Payment_Terms__c opt = new On_Payment_Terms__c(Name='Test', 
    													  Terms_Days__c = termDays);
          insert opt;
          return opt;
    }
 
     public static PBSI__BOM_Line__c GetBomLine(String itemID, String bomId)
    {
           return new PBSI__BOM_Line__c(PBSI__BOM__c = bomId, 
                                        PBSI__Item__c = itemID);
    }
    
}