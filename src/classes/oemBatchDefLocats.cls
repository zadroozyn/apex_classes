/**
 * Account trigger for setting default locations
 *
 * Author: Unknown
 *
 * ver 1.1 2014-05-30 Mehmet Birgi <mehmet.birgi@nefos.com>
 *                      Adapted to premium package of AddressTools
 *
 * Copyright (c) 2014 Nefos GmbH
 *
 **/
global class oemBatchDefLocats implements Database.Batchable<sObject> {

	Boolean doTest = false;

	global oemBatchDefLocats() {

	}

	global oemBatchDefLocats(Boolean test) {
		doTest = test;
	}

	// start premium version of address tools
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(doTest) return Database.getQueryLocator('select Id,ShippingCountry,Shipping_Country_Link__c,Default_Location__c from Account LIMIT 1');
		else return Database.getQueryLocator('select Id,ShippingCountry,Shipping_Country_Link__c,Default_Location__c from Account');
	}

	global void execute(Database.BatchableContext BC,List<Account> scope) {
		pw_ccpro__CountryObject__c[] cs = [select ID,Name,pw_ccpro__IsoCode_2__c,pw_ccpro__IsoCode_3__c,ShortCode__c from pw_ccpro__CountryObject__c];
		WhichLocation__c[] wls = [select Country__c,Location__c from WhichLocation__c];
		Map<Id, Id> wlm = new Map<Id, Id> ();
		for(WhichLocation__c wl:wls) wlm.put(wl.Country__c, wl.Location__c);
		for(Account a : scope){
			String sc = a.ShippingCountry;
			for(pw_ccpro__CountryObject__c c:cs) {
				if(sc==c.Name || sc==c.pw_ccpro__IsoCode_2__c || sc==c.pw_ccpro__IsoCode_3__c || sc==c.ShortCode__c) { 
					a.Shipping_Country_Link__c = c.Id;
					Id dwl = wlm.get(c.Id);
					if(dwl!=null) a.Default_Location__c = dwl;
					break; 
				}
			}
		} 
		update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

	public static testMethod void test1() {
		Test.StartTest();
		oemBatchDefLocats tbdl = new oemBatchDefLocats(true);
		Id batchInstanceId = Database.executeBatch(tbdl);
		//Account a= [select Id,ShippingCountry,Shipping_Country_Link__c,Default_Location__c from Account LIMIT 1];
		Account a = TestUtility.createAccount('Test Account ' + String.valueOf(system.now()), 'CHF', true);
		System.debug('a: ' + a);
		PBSI__PBSI_Sales_Order__c so = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=a.Id);
		insert so;
		Test.StopTest();
	}
	// end premium version of address tools
	

	/*
	// start temp version for address tools deinstallation
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(doTest) return Database.getQueryLocator('select Id,ShippingCountry,Shipping_CountryTemp_Link__c,Default_Location__c from Account LIMIT 1');
		else return Database.getQueryLocator('select Id,ShippingCountry,Shipping_CountryTemp_Link__c,Default_Location__c from Account');
	}

	global void execute(Database.BatchableContext BC,List<Account> scope) {
		CountryTemp__c[] cs = [select ID,Name,IsoCode_3__c,IsoCode_2__c,ShortCode__c from CountryTemp__c];
		WhichLocation__c[] wls = [select CountryTemp__c,Location__c from WhichLocation__c];
		Map<Id, Id> wlm = new Map<Id, Id> ();
		for(WhichLocation__c wl:wls) wlm.put(wl.CountryTemp__c, wl.Location__c);
		for(Account a : scope){
			String sc = a.ShippingCountry;
			for(CountryTemp__c c:cs) {
				if(sc==c.Name || sc==c.IsoCode_3__c || sc==c.IsoCode_2__c || sc==c.ShortCode__c) { 
					a.Shipping_CountryTemp_Link__c = c.Id;
					Id dwl = wlm.get(c.Id);
					if(dwl!=null) a.Default_Location__c = dwl;
					break; 
				}
			}
		} 
		update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

	public static testMethod void test1() {
		Test.StartTest();
		oemBatchDefLocats tbdl = new oemBatchDefLocats(true);
		Id batchInstanceId = Database.executeBatch(tbdl);
		Account a= [select Id,ShippingCountry,Shipping_CountryTemp_Link__c,Default_Location__c from Account LIMIT 1];
		PBSI__PBSI_Sales_Order__c so = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=a.Id);
		insert so;
		Test.StopTest();
	}
	// end temp version for address tools deinstallation
	*/
		
}