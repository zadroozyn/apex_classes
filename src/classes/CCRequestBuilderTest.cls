@isTest
class CCRequestBuilderTest {
	public static final List<String> SOBJECT_TYPES_API_NAMES = new List<String> {'c2g__AsOfAging__c','c2g__CancelPayment__c','c2g__ReportingBalance__c','c2g__codaAccountingCurrency__c','c2g__codaBankAccount__c','c2g__codaBankReconciliation__c','c2g__codaBankStatement__c','c2g__codaBudget__c','c2g__codaCashEntry__c','c2g__codaCashMatchingHistory__c','c2g__codaCompany__c','c2g__codaCreditNote__c','c2g__codaCurrencyRevaluationGroup__c','c2g__codaCurrencyRevaluation__c','c2g__codaGroupingReference__c','c2g__codaIntercompanyDefinition__c','c2g__codaIntercompanyTransfer__c','c2g__codaInvoice__c','c2g__codaJournal__c','c2g__codaMatchingReference__c','c2g__codaPaymentMediaControl__c','c2g__codaPaymentMediaSummary__c','c2g__codaPaymentTemplate__c','c2g__codaPayment__c','c2g__codaPurchaseCreditNote__c','c2g__codaPurchaseInvoice__c','c2g__codaTextDefinition__c','c2g__codaTransaction__c','c2g__codaYear__c'};

	@testSetup 
	static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		new TestCustomSettingsFactory();

		Test.startTest();
		PBSI__Admin__c admin =  PBSI__Admin__c.getOrgDefaults();
		admin.PBSI__Use_Ship_Lot_for_SOLine__c = true;
		admin.PBSI__Use_Pallets__c=false;
		admin.PBSI__do_not_calculate_atp__c = false;
		admin.PBSI__Pack_More_than_Needed_on_SO__c=true; 
		admin.PBSI__Allow_Packing_0_Qty_Orders__c=true; 
		admin.PBSI__Do_Not_Allow_Display_More_Qty_Pack__c=true;
		admin.PBSI__Always_show_serial_number_on_pack_SO__c=true;
		admin.PBSI__Create_SNT_at_Pack_time_for_all_items__c=false;
		admin.pbsi__Don_t_change_SoLine_Q_Pack_on_Drop_Ship__c=false;
		admin.pbsi__Use_Not_Counted_Loc_on_Receive_and_Pack__c=false;
		admin.PBSI__Show_taxable_field_on_line_items__c = true;
		admin.PBSI__Use_tax_codes__c = true;
		admin.PBSI__Prevent_So_Packing_if_Status_is__c = 'Y';
		admin.PBSI__Update_Ship_Date_on_Line_Shipping__c = true;
		admin.PBSI__Update_Ship_Date_when_all_Lines_Shipped__c = true;
		admin.PBSI__Use_ATP_by_Locations__c=true;
		admin.PBSI__Force_Packing_From_Location__c=false;    
		admin.PBSI__Use_in_ATP_SOs_w_ship_date_in_last__c=3;
		admin.PBSI__Use_User_Location__c = false;
		upsert admin;

		PBSI__Property__c prop;
		try {
			prop=[select id from PBSI__Property__c where pbsi__property_name__c='Lot_Usage'];
		}
		catch(exception e){}
		if (prop == null) {
			prop = TestUtil.GetProperty('Lot_Usage','Yes');
			insert prop;
		} else {
			prop.pbsi__property_value__c='Yes';
			update prop; 
		}

		PBSI__Property__c prop2;
		try {
			prop2=[select id from PBSI__Property__c where pbsi__property_name__c='UseCarton'];
		} catch(exception e){}
		if (prop2 == null) {
			prop2 = TestUtil.GetProperty('UseCarton','Yes');
			insert prop2;
		} else {
			prop2.pbsi__property_value__c='Yes';
			update prop2; 
		}

		Id queueId = [SELECT Id FROM Group WHERE DeveloperName = 'FF_On_AG'].Id;
		c2g__codaCompany__c company = createCurrentCompany('On AG', new User(Id=UserInfo.getUserId()), '012D0000000kLjq',true, '2345234523');


		c2g__codaYear__c year = new c2g__codaYear__c();
		year.Name = String.valueOf(System.today().year());
		year.c2g__AutomaticPeriodList__c =  true;
		year.c2g__OwnerCompany__c = company.Id;
		year.c2g__ExternalId__c = 'yzsd1234';
		year.c2g__NumberOfPeriods__c = 11;
		year.c2g__StartDate__c = System.today() - 10;
		year.c2g__Status__c = 'Open';
		year.c2g__PeriodCalculationBasis__c = '445';
		year.c2g__YearEndMode__c = 'Full Accounting Code';
		year.c2g__UnitOfWork__c = 12;
		year.OwnerId = queueId;
		insert year;

		c2g__codaPeriod__c period = new c2g__codaPeriod__c();
		period.Name ='Test period';
		period.c2g__ExternalId__c = 'period_external_Id';
		period.c2g__StartDate__c = System.today() - 10;
		period.c2g__EndDate__c= System.today() + 10;
		period.c2g__OwnerCompany__c = company.Id;
		period.c2g__PeriodNumber__c = '123';
		period.c2g__Description__c = 'test Desc';
		period.c2g__PeriodGroup__c = 'Q1';
		period.c2g__PeriodNumber__c = '1';
		period.c2g__YearName__c = year.Id;
		insert period;

		c2g__codaAccountingCurrency__c accountring_currency = new c2g__codaAccountingCurrency__c();
		accountring_currency.c2g__OwnerCompany__c = company.Id;
		accountring_currency.c2g__DecimalPlaces__c = 2;
		accountring_currency.Name = 'USD';
		accountring_currency.c2g__Dual__c = true ;
		accountring_currency.OwnerId = queueId;
		insert accountring_currency;

		c2g__codaExchangeRate__c rate = new c2g__codaExchangeRate__c();
		rate.c2g__ExchangeRateCurrency__c = accountring_currency.Id;
		rate.c2g__OwnerCompany__c = company.Id;
		rate.c2g__ExternalId__c = '12323232';
		rate.c2g__Rate__c = 44.55;
		rate.c2g__StartDate__c = System.today() - 10;
		rate.c2g__UnitOfWork__c = 10;
		insert rate;

		c2g__codaGeneralLedgerAccount__c glAcc = TestUtility.createGeneralLedgerAccount('GLA', false, 'Balance Sheet', 1, true);
		c2g__codaTaxCode__c taxCode = TestUtility.createTaxCode('some kind of Vat', glAcc.Id, true);
		c2g__codaAccountingCurrency__c accCurrency = TestUtility.createAccountingCurrency('USD', company.Id, true);



		pbsi__pbsi_location__c euStock = tdf.locations.createSObject('CH-Stock', false);
		euStock.KN_Client_Id__c = 'OAG';
		euStock.KN_Email_Template_Id__c = '00XD00000025LHO';
		euStock.KN_Logical_Address__c = 'LUCTN04';
		euStock.KN_Order_Type_Code__c = 'OAO';
		euStock.KN_Unit_of_measurement__c = 'EA';
		tdf.locations.insertAll();

		pw_ccpro__CountryObject__c switzerland = tdf.countries.createSObject('Switzerland', 'CH', 'CHF', false);
		switzerland.Dealer_location__c = euStock.Id;
		switzerland.Webshop_location__c = euStock.Id;
		tdf.countries.insertAll();

		Account a = tdf.accounts.createSObject('Test Account', 'USD', false);
		a.Status__c = 'Active';
		a.BillingCountry = 'Switzerland';
		a.ShippingCountry = 'Switzerland';
		a.pw_ccpro__ShippingCountryLookup__c = switzerland.Id;
		tdf.accounts.insertAll();

		PBSI__Address_Tracker__c add1=new PBSI__Address_Tracker__c(Name='addss1',PBSI__Account__c=tdf.accounts.getSObject('Test Account').Id,PBSI__Tax_Code__c=taxCode.Id,PBSI__Use_AddressTrackerName_for_Delivery_Comp__c=true);
		PBSI__Pallet__c pall = new PBSI__Pallet__c(PBSI__Description__c='pall1',PBSI__Location__c=tdf.locations.getSObject('CH-Stock').Id);
		insert pall;

		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

		SObject item1 = tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', tdf.locations.getSObject('CH-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7640165317761', false);
		SObject item2 = tdf.items.createSObject('4.4102 W 7', 100, 120, 'test desc', tdf.locations.getSObject('CH-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7630040505581', false);
		tdf.items.createSObject('4.4103 W 8', 100, 120, 'test desc', tdf.locations.getSObject('CH-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7640165319192', false);

		SObject item3 = tdf.items.createSObject('4.4102 W 8.5', 100, 120, 'test desc', tdf.locations.getSObject('CH-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7640165319338', false);
		SObject item4 = tdf.items.createSObject('4.4103 W 9', 100, 120, 'test desc', tdf.locations.getSObject('CH-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7640165319345', false);
		tdf.items.insertAll();

		PBSI__Unit__c unit2 = TestUtil.GetItemUnit(item2.Id);
		insert unit2;

		Ascent2FF__Sales_Order_Posting_Profile__c postingProfile3 = 
			new Ascent2FF__Sales_Order_Posting_Profile__c(Ascent2FF__Item__c = item3.Id,
					Ascent2FF__Inventory_Issue_Account__c = glAcc.Id,
					Ascent2FF__COGS_Account__c = glAcc.Id);
		Ascent2FF__Sales_Order_Posting_Profile__c postingProfile4 = 
			new Ascent2FF__Sales_Order_Posting_Profile__c(Ascent2FF__Item__c = item4.Id,
					Ascent2FF__Inventory_Issue_Account__c = glAcc.Id,
					Ascent2FF__COGS_Account__c = glAcc.Id);
		insert new List<Ascent2FF__Sales_Order_Posting_Profile__c>{postingProfile3, postingProfile4};
		PBSI__Serial_Number_Tracker__c  snt1=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser1',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item1.Id);
		PBSI__Serial_Number_Tracker__c  snt2=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser2',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item2.Id);
		PBSI__Serial_Number_Tracker__c  snt3=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser3',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item3.Id);
		PBSI__Serial_Number_Tracker__c  snt4=new PBSI__Serial_Number_Tracker__c (PBSI__Serial_Number__c='ser4',PBSI__New_Date_Received__c=system.today(),PBSI__Item__c=item4.Id);
		List<PBSI__Serial_Number_Tracker__c> snttoinsert=new List<PBSI__Serial_Number_Tracker__c>{snt1,snt2,snt3,snt4};
		insert snttoinsert;

		SObject so = tdf.salesOrders.createSObject(tdf.accounts.getSObject('Test Account').Id, 'Re-Order', tdf.locations.getSObject('CH-Stock').Id, false);
		tdf.salesOrders.insertAll();

		tdf.orderStages.createSObject('Processing', so.Id, false);
		tdf.orderStages.insertAll();
		Test.stopTest();
	}

	public static c2g__codaCompany__c createCurrentCompany(String CompanyName, User SomeUser, String recordType, Boolean selectAsCurrent, String taxRegistrationNumber){
		Group companyOwnerQueue = new Group(Type='Queue', Name=CompanyName);
		System.runAs(SomeUser){ //to avoid mixed dml error
			insert companyOwnerQueue;
			List<QueueSObject> queueSObjectList=new List<QueueSObject> ();
			for(String sobjectTypeAPIName: SOBJECT_TYPES_API_NAMES){
				QueueSObject queuesObjectTypeToAdd = new QueueSObject(SobjectType=sobjectTypeAPIName, QueueId=companyOwnerQueue.Id);
				queueSObjectList.add(queuesObjectTypeToAdd);
			}
			insert queueSObjectList;
			if(selectAsCurrent){
				insert new GroupMember(GroupId=companyOwnerQueue.Id, UserOrGroupId=someUser.ID);
			}
		}
		c2g__codaCompany__c company=new c2g__codaCompany__c(Name=companyName, c2g__VATRegistrationNumber__c=taxRegistrationNumber,OwnerId=companyOwnerQueue.Id);
		if(recordType!=null){
			company.RecordTypeId=recordType;
		}
		System.runAs(SomeUser){
			insert company;
			c2g__codaUserCompany__c userCompany=new c2g__codaUserCompany__c(c2g__Company__c=company.Id, c2g__User__c=SomeUser.Id);
			insert userCompany;
		}
		return company;
	}

	@isTest
	static void salesOrderTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c so = (PBSI__PBSI_Sales_Order__c) tdf.salesOrders.getAllSobjects()[0];
		List<PBSI__PBSI_Sales_Order_Line__c> lSoLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		lSoLines.add(
				new PBSI__PBSI_Sales_Order_Line__c(
					PBSI__Sales_Order__c = so.Id,
					PBSI__Item__c = tdf.items.getSObject('4.4102 W 8.5').ID,
					PBSI__Quantity_Needed__c = 5,
					PBSI__Quantity_Picked__c = 0
					)
				);
		insert lSoLines;
		List<PBSI__Lot__c> lots = new List<PBSI__Lot__c>();
		for(PBSI__PBSI_Sales_Order_Line__c line: lSoLines) {
			lots.add(
					new PBSI__Lot__c(
						PBSI__Item__c = line.PBSI__Item__c,
						PBSI__Location__c = tdf.locations.getSObject('CH-Stock').Id
						)
					);

		}
		insert lots;

		List<PBSI__PBSI_Inventory__c> invs = new List<PBSI__PBSI_Inventory__c>();
		for(Integer i = 0; i < lSoLines.size(); i++) {
			PBSI__PBSI_Sales_Order_Line__c line = lSoLines[i];
			invs.add(
					new PBSI__PBSI_Inventory__c(
						PBSI__item_lookup__c = line.PBSI__Item__c,
						PBSI__Lot__c = lots[i].Id,
						PBSI__location_lookup__c = tdf.locations.getSObject('CH-Stock').Id,
						PBSI__qty__c = 50
						)
					);	
		}
		insert invs;
		List<PBSI__Shipped_Sales_Order_Line__c> lSOPackedLines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		for(Integer i = 0; i < lSoLines.size(); i++) {
			PBSI__PBSI_Sales_Order_Line__c line = lSoLines[i];
			lSOPackedLines.add(
					new PBSI__Shipped_Sales_Order_Line__c(
						PBSI__Sales_Order__c = so.Id,
						PBSI__Sales_Order_Line__c = line.Id,
						PBSI__Quantity_Shipped__c = line.PBSI__Quantity_Needed__c,
						PBSI__Lot__c = lots[i].Id,
						PBSI__Item__c = line.PBSI__Item__c,
						Shipment_status__c = 'Processing'
						)
					);

		}

		Test.setMock(HttpCalloutMock.class, new CustomApexLoginMock());
		insert lSOPackedLines;
		Id stageId = tdf.orderStages.getSObjectId('0');
		Test.startTest();
		CCRequestBuilder builder = new CCRequestBuilder(stageId);
		AsyncRequestManager manager = builder.getRequestManager();
		Test.stopTest();
	}

	@isTest
	static void webOrderTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c so = (PBSI__PBSI_Sales_Order__c) tdf.salesOrders.getAllSobjects()[0];
		so.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'web_order');
		so.PBSI__From_Location__c = tdf.locations.getSObject('CH-Stock').Id;
		update so;
		List<PBSI__PBSI_Sales_Order_Line__c> lSoLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		lSoLines.add(
				new PBSI__PBSI_Sales_Order_Line__c(
					PBSI__Sales_Order__c = so.Id,
					PBSI__Item__c = tdf.items.getSObject('4.4102 W 8.5').ID,
					PBSI__Quantity_Needed__c = 5,
					PBSI__Quantity_Picked__c = 0
					)
				);
		insert lSoLines;
		List<PBSI__Lot__c> lots = new List<PBSI__Lot__c>();
		for(PBSI__PBSI_Sales_Order_Line__c line: lSoLines) {
			lots.add(
					new PBSI__Lot__c(
						PBSI__Item__c = line.PBSI__Item__c,
						PBSI__Location__c = tdf.locations.getSObject('CH-Stock').Id
						)
					);

		}
		insert lots;

		List<PBSI__PBSI_Inventory__c> invs = new List<PBSI__PBSI_Inventory__c>();
		for(Integer i = 0; i < lSoLines.size(); i++) {
			PBSI__PBSI_Sales_Order_Line__c line = lSoLines[i];
			invs.add(
					new PBSI__PBSI_Inventory__c(
						PBSI__item_lookup__c = line.PBSI__Item__c,
						PBSI__Lot__c = lots[i].Id,
						PBSI__location_lookup__c = tdf.locations.getSObject('CH-Stock').Id,
						PBSI__qty__c = 50
						)
					);	
		}
		insert invs;
		List<PBSI__Shipped_Sales_Order_Line__c> lSOPackedLines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		for(Integer i = 0; i < lSoLines.size(); i++) {
			PBSI__PBSI_Sales_Order_Line__c line = lSoLines[i];
			lSOPackedLines.add(
					new PBSI__Shipped_Sales_Order_Line__c(
						PBSI__Sales_Order__c = so.Id,
						PBSI__Sales_Order_Line__c = line.Id,
						PBSI__Quantity_Shipped__c = line.PBSI__Quantity_Needed__c,
						PBSI__Lot__c = lots[i].Id,
						PBSI__Item__c = line.PBSI__Item__c,
						Shipment_status__c = 'Processing'
						)
					);

		}

		Test.setMock(HttpCalloutMock.class, new CustomApexLoginMock());
		insert lSOPackedLines;
		Id stageId = tdf.orderStages.getSObjectId('0');
		Test.startTest();
		CCRequestBuilder builder = new CCRequestBuilder(stageId);
		AsyncRequestManager manager = builder.getRequestManager();
		Test.stopTest();
	}
}