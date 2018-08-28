@isTest public class TestDataFactory {
	public AccountTestHelper accounts;
	public ContactTestHelper contacts;
	public CountryTestHelper countries;
	public LocationTestHelper locations;
	public SalesOrderTestHelper salesOrders;
	public MasterOrderTestHelper masterOrders;
	public TransferOrderTestHelper transferOrders;
	public CollectionTestHelper collections;
	public ItemGroupTestHelper itemGroups;
	public OnPaymentTermsTestHelper paymentTerms;
	public ItemTestHelper items;
	public SalesOrderLineTestHelper salesOrderLines;
	public Dimension2TestHelper dimensions2;
	public OrderStageTestHelper orderStages;
	public TrackingTestHelper trackings;
	public TrackingNumberTestHelper trackingNumbers;
	public TrackingNumberItemTestHelper trackingNumberItems;

	private TestDataFactory () {
		accounts = new AccountTestHelper('Account');
		contacts = new ContactTestHelper('Contact');
		countries = new CountryTestHelper('Contact');
		locations = new LocationTestHelper('PBSI__PBSI_Location__c');
		salesOrders = new SalesOrderTestHelper('PBSI__PBSI_Sales_Order__c');
		masterOrders = new MasterOrderTestHelper('Master_order__c');
		transferOrders = new TransferOrderTestHelper('PBSI__Transfer_Order__c');
		collections = new CollectionTestHelper('Collection__c');
		itemGroups = new ItemGroupTestHelper('PBSI__PBSI_Item_Group__c');
		paymentTerms = new OnPaymentTermsTestHelper('On_Payment_Terms__c');
		items = new ItemTestHelper('PBSI__PBSI_Item__c');
		salesOrderLines = new SalesOrderLineTestHelper('PBSI__PBSI_Sales_Order_Line__c');
		dimensions2 = new Dimension2TestHelper('c2g__codaDimension2__c');
		orderStages = new OrderStageTestHelper('Order_stage__c');
		trackings = new TrackingTestHelper('Tracking__c');
		trackingNumbers = new TrackingNumberTestHelper('Tracking_Number__c');
		trackingNumberItems = new TrackingNumberItemTestHelper('Tracking_Number_Item__c');
	}

	public static TestDataFactory instance {
		public get {
			if(TestDataFactory.instance == null) {
				TestDataFactory.instance = new TestDataFactory();
			}
			return TestDataFactory.instance;
		}
		private set;
	}

	public class AccountTestHelper extends TestDataSObjectHelper {

		public AccountTestHelper(String sObjectApiName){
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, CurrencyIsoCode, Name, Account_Number_new__c, c2g__CODADimension2__c, Firstname, Lastname, RecordTypeId FROM Account];
		}

		public Account createSObject(String name, String currencyIsoCode, boolean doInsert){
			Account returnValue = TestUtility.createAccount(name, currencyIsoCode, doInsert);
			addSObjectToMap(returnValue);
			return returnValue;
		}

		public Account createSObject(String name, String currencyIsoCode, Id recordTypeId, boolean doInsert){
			Account returnValue = new Account();
			returnValue.Name = name;
			returnValue.CurrencyIsoCode = currencyIsoCode;
			returnValue.c2g__CODACreditLimitEnabled__c = true;
			returnValue.c2g__CODACreditLimit__c = 10000;
			returnValue.BillingCountry = 'Switzerland';
			returnValue.RecordTypeId = recordTypeId;
			addSObjectToMap(returnValue);
			return returnValue;
		}

		public Account createSObject(String firstname, String lastname, String currencyIsoCode, boolean doInsert){
			Account returnValue = new Account();
			returnValue.Firstname = firstname;
			returnValue.Lastname = lastname;
			returnValue.CurrencyIsoCode = currencyIsoCode;
			returnValue.c2g__CODACreditLimitEnabled__c = true;
			returnValue.c2g__CODACreditLimit__c = 10000;
			returnValue.BillingCountry = 'Switzerland';
			returnValue.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Web_Account');
			addSObjectToMap(returnValue);
			return returnValue;
		}
	}

	public class ContactTestHelper extends TestDataSObjectHelper {

		public ContactTestHelper(String sObjectApiName){
			super(sObjectApiName, false, 'Lastname');
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Firstname, Lastname, Email, Function__c FROM Contact];
		}

		public Contact createSObject(String lastname, String email, Id accountId, boolean doInsert){
			Contact returnValue = new Contact(Lastname = lastname, Email = email, AccountId = accountId);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class CountryTestHelper extends TestDataSObjectHelper {
		public CountryTestHelper(String sObjectApiName) {
			super(sObjectApiName, false, 'Name');
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Name, pw_ccpro__IsoCode_2__c, pw_ccpro__IsoCode_3__c FROM pw_ccpro__CountryObject__c];
		}

		public pw_ccpro__CountryObject__c createSObject(String name, String isocode2char, String isocode3char, boolean doInsert){
			pw_ccpro__CountryObject__c returnValue = new pw_ccpro__CountryObject__c(Name = name, pw_ccpro__IsoCode_2__c = isocode2char, pw_ccpro__IsoCode_3__c = isocode3char);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class LocationTestHelper extends TestDataSObjectHelper {

		public LocationTestHelper(String sObjectApiName){
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name FROM PBSI__PBSI_Location__c];
		}

		public PBSI__PBSI_Location__c createSObject(String name, boolean doInsert){
			PBSI__PBSI_Location__c returnValue = new PBSI__PBSI_Location__c(Name = name);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}

		public PBSI__PBSI_Location__c createSObject(String name, boolean isTransit, boolean doInsert) {
			PBSI__PBSI_Location__c returnValue = this.createSObject(name, false);
			returnValue.PBSI__In_Transit__c = isTransit;
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}

	}

	public class SalesOrderTestHelper extends TestDataSObjectHelper {

		public SalesOrderTestHelper(String sObjectApiName){
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, PBSI__Customer__c, PBSI__BillingCountry__c, Sales_Order_Type__c, PBSI__From_Location__c, Bill_Of_Delivery_B2C_Template_ID__c, Return_Information_Template__c, Culture__c, TransmissionIdentification__c, Proforma_Template_ID__c, Bill_of_Delivery__c, Bill_of_Delivery_Partial_Conga_ID__c, Purchase_Confirmation__c, PBSI__Contact__r.Id, Shipping_Confirmation_Invoice_Email_ID__c, Notified_Fulfiller__c, Fulfiller__c, Transmission_Count__c, KN_Shipping_Notice_Sent__c, Bill_Of_Delivery_PDF_Id__c, Return_Information_Pdf_Id__c, On_Payment_Term__c, Master_order__c, Master_order__r.Id, Master_order__r.Name, PBSI__Order_Total__c, PBSI__Shipping_Cost__c, Pre_Order_Final_Order_Total__c, PBSI__Sales_Tax__c, Total_Quantity_Of_Shoes_On_Order__c, Early_bird_discount__c, Visibility_discount__c, Pre_Order_Discount_override__c, VAT_Amount__c, RecordTypeId, PBSI__From_Location__r.KN_Email_Template_Id__c FROM PBSI__PBSI_Sales_Order__c];
		}

		public PBSI__PBSI_Sales_Order__c createSObject(Id accountId, String orderType, Id locationId, boolean doInsert){
			PBSI__PBSI_Sales_Order__c returnValue = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = accountId, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c=orderType, PBSI__From_Location__c = locationId);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class MasterOrderTestHelper extends TestDataSObjectHelper {
		public MasterOrderTestHelper(String sObjectApiName) {
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, RecordTypeId, Status__c, Proposal_status__c, Total_pre_order_discount__c, Early_bird_discount__c, Visibility_discount__c, Pre_order_discount__c, Customer__c, Customer_contact__c, From_location__c, On_Payment_Term__c FROM Master_order__c];
		}

		public Master_order__c createSObject(Id accountId, Id recordTypeId, boolean doInsert){
			Master_order__c returnValue = new Master_order__c(Customer__c = accountId, RecordTypeId = recordTypeId);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class TransferOrderTestHelper extends TestDataSObjectHelper {

		public TransferOrderTestHelper(String sObjectApiName){
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, PBSI__From_Location__c, PBSI__To_Location__c, PBSI__Transit_Location__c, Notified_Fulfiller__c, Transmission_Count__c
						FROM PBSI__Transfer_Order__c];
		}

		public PBSI__Transfer_order__c createSObject(Id fromLocation, Id toLocation, Id transitLocation, boolean doInsert){
			PBSI__Transfer_order__c returnValue = new PBSI__Transfer_order__c(PBSI__From_Location__c = fromLocation, PBSI__To_Location__c = toLocation, PBSI__Transit_Location__c = transitLocation);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class CollectionTestHelper extends TestDataSObjectHelper {

		public CollectionTestHelper(String sObjectApiName){
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, Collection_type__c, Status__c, Location__c FROM Collection__c];
		}

		public Collection__c createSObject(String name, String collectionType, String status, Id locationId, boolean doInsert){
			Collection__c returnValue = new Collection__c(Name = name, Collection_type__c = collectionType, Status__c = status, Location__c = locationId);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class ItemGroupTestHelper extends TestDataSObjectHelper {

		public ItemGroupTestHelper(String sObjectApiName){
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, PBSI__Item_Group_Code__c, CurrencyIsoCode,  Group_Description__c, PBSI__Description__c, PBSI__Parent_Group__c FROM PBSI__PBSI_Item_Group__c];
		}

		public PBSI__PBSI_Item_Group__c createSObject(String name, String code, String currencyIsoCode, String description, Id parentGroup, boolean doInsert){
			PBSI__PBSI_Item_Group__c returnValue = new PBSI__PBSI_Item_Group__c(Name = name, PBSI__Item_group_code__c = code, CurrencyIsoCode = currencyIsoCode, Group_Description__c = description, PBSI__Description__c = description, PBSI__Parent_Group__c = parentGroup);
			returnValue.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Item_Group__c', 'Shoes');
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class OnPaymentTermsTestHelper extends TestDataSObjectHelper {

		public OnPaymentTermsTestHelper(String sObjectApiName) {
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, Terms_Days__c FROM On_Payment_Terms__c];
		}

		public On_Payment_Terms__c createSObject(String name, Integer termDays, boolean doInsert) {
			On_Payment_Terms__c returnValue = new On_Payment_Terms__c(Name = name, Terms_Days__c = termDays);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class ItemTestHelper extends TestDataSObjectHelper {

		public ItemTestHelper(String sObjectApiName){
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, PBSI__purchaseprice__c, PBSI__salesprice__c, PBSI__description__c, PBSI__defaultunitofmeasure__c, PBSI__Default_Location__c, PBSI__Lot_Tracking__c, PBSI__Item_Group__c, EAN_Number__c FROM PBSI__PBSI_Item__c];
		}

		public PBSI__PBSI_Item__c createSObject(String name, Integer purchasePrice, Integer salesPrice, String description, Id defLocation, Id itemGroup, String eanNumber, boolean doInsert) {
			PBSI__PBSI_Item__c returnValue = new PBSI__PBSI_Item__c(Name = name, PBSI__PurchasePrice__c = purchasePrice, PBSI__SalesPrice__c = salesPrice, PBSI__description__c = description, PBSI__Default_Location__c = defLocation, PBSI__Item_Group__c = itemGroup, EAN_Number__c = eanNumber);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class SalesOrderLineTestHelper extends TestDataSObjectHelper {

		public SalesOrderLineTestHelper(String sObjectApiName) {
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, PBSI__Sales_Order__c, PBSI__Item__c, PBSI__Quantity_Needed__c, PBSI__Quantity_Picked__c, PBSI__Quantity_Left_To_Ship__c FROM PBSI__PBSI_Sales_Order_Line__c];
		}

		public PBSI__PBSI_Sales_Order_Line__c createSObject(Id orderId, Id itemId, Integer quantityNeeded, Integer quantityPacked, Boolean doInsert) {
			PBSI__PBSI_Sales_Order_Line__c returnValue = new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = orderId, PBSI__Item__c = itemId, PBSI__Quantity_Needed__c = quantityNeeded, PBSI__Quantity_Picked__c = quantityPacked);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class Dimension2TestHelper extends TestDataSObjectHelper {

		public Dimension2TestHelper(String sObjectApiName) {
			super(sObjectApiName, false);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Name, c2g__ReportingCode__c FROM c2g__codaDimension2__c];
		}

		public c2g__codaDimension2__c createSObject(Account a, boolean doInsert) {
			c2g__codaDimension2__c returnValue = new c2g__codaDimension2__c(Name = a.Name, c2g__ReportingCode__c = a.Account_Number_new__c);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}

	}

	public class OrderStageTestHelper extends TestDataSObjectHelper {

		public OrderStageTestHelper(String sObjectApiName) {
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [SELECT Id, Stage__c, Sales_Order__c FROM Order_stage__c];
		}

		public Order_stage__c createSObject(String stage, Id soId,  boolean doInsert) {
			return createSObject(stage, soId, 'Notification_SO', doInsert);
		}

		public Order_stage__c createSObject(String stage, Id soId, String rtName, boolean doInsert) {
			Id rtId = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', rtName);
			Order_stage__c returnValue = new Order_stage__c(Sales_Order__c = soId, Stage__c = stage, RecordTypeId = rtId);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}

	}

	public class TrackingTestHelper extends TestDataSObjectHelper {

		public TrackingTestHelper(String sObjectApiName){
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [select id, Movement_Order_Number__c, Is_Sales_Order__c, Is_Transfer_Order__c, Carrier_Code__c, Order_Stage__c from Tracking__c];
		}

		public Tracking__c createSObject(Id soId, boolean doInsert){
			return createSObject(null, soId, doInsert);
		}

		public Tracking__c createSObject(Id orderStageId, Id soId, boolean doInsert){
			return createSObject(orderStageId, soId, 'FDEG', doInsert);
		}

		public Tracking__c createSObject(Id orderStageId, Id soId, String carrierCode, boolean doInsert) {
			Tracking__c returnValue = new Tracking__c(Sales_Order__c = soId, Order_Stage__c = orderStageId, Carrier_Code__c = carrierCode);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class TrackingNumberTestHelper extends TestDataSObjectHelper {

		public TrackingNumberTestHelper(String sObjectApiName){
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [select id, Link__c, Number__c from Tracking_Number__c];
		}

		public Tracking_Number__c createSObject(Id trackingId, boolean doInsert){
			return createSObject('1236547890123', trackingId, '5 lb' , doInsert);
		}

		public Tracking_Number__c createSObject(string strNumber, Id trackingId, string pkgWeight, boolean doInsert){
			Tracking_Number__c returnValue = new Tracking_Number__c(Tracking__c = trackingId, Number__c = strNumber, Package_Weight__c = pkgWeight);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}

	public class TrackingNumberItemTestHelper extends TestDataSObjectHelper {

		public TrackingNumberItemTestHelper(String sObjectApiName){
			super(sObjectApiName, true);
		}

		protected override List<sObject> queryCurrentSObject(){
			return [select id, Item__c, Quantity__c, Tracking_Number__c from Tracking_Number_Item__c];
		}

		public Tracking_Number_Item__c createSObject(Id trackingNumberId, Id itemId, boolean doInsert){
			return createSObject(2, trackingNumberId, itemId, doInsert);
		}

		public Tracking_Number_Item__c createSObject(Integer qty, Id trackingNumberId, id itemId, boolean doInsert){
			Tracking_Number_Item__c returnValue = new Tracking_Number_Item__c(Tracking_Number__c = trackingNumberId, Item__c = itemId, Quantity__c = qty);
			addSObjectToMap(returnValue);
			if(doInsert) {
				insert returnValue;
			}
			return returnValue;
		}
	}
}