@isTest public class TestCustomSettingsFactory {
	private List<sObject> customSettings;

	public TestCustomSettingsFactory () {
		customSettings = new List<sObject>();
		this.initializeCollections_order();
		this.initializeOM_collection_settings();
		this.initializeB2BNewOrderDateIntervals();
		this.initializeBackstageProfileSettings();
		this.initializePBSIProperties();
		this.initializeB24Settings();
		this.initializeOSCASettings();
		this.initializeCongaQueryMapping();
		insert customSettings;
	}

	private void initializeOM_collection_settings () {
        customSettings.add(new OM_collection_settings__c(Name='Setting1', Sales_orders_types__c='Pre-Order;Forecast;Blockorder',  Collection_type__c='After next collection',    Primary__c=True, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Green', Less_than_5__c='Green'));
        customSettings.add(new OM_collection_settings__c(Name='Setting2', Sales_orders_types__c='Pre-Order;Forecast;Blockorder',  Collection_type__c='Next collection',          Primary__c=False, Secondary__c=True, More_than_10__c='Green', Between_5_and_10__c='Green', Less_than_5__c='Green'));
        customSettings.add(new OM_collection_settings__c(Name='Setting3', Sales_orders_types__c='Pre-Order;Forecast;Blockorder',  Collection_type__c='Special collection',       Primary__c=False, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Green', Less_than_5__c='Green'));
        customSettings.add(new OM_collection_settings__c(Name='Setting4', Sales_orders_types__c='Re-Order;Stock clearance;Stock exchange;Exchange;Warranty',  Collection_type__c='Current collection',   Primary__c=True, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Orange', Less_than_5__c='Gray'));
        customSettings.add(new OM_collection_settings__c(Name='Setting5', Sales_orders_types__c='Re-Order;Stock clearance;Stock exchange;Exchange;Warranty',  Collection_type__c='Old collection',       Primary__c=False, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Orange', Less_than_5__c='Red'));
        customSettings.add(new OM_collection_settings__c(Name='Setting6', Sales_orders_types__c='',  Collection_type__c='Old collection',        Primary__c=False, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Orange', Less_than_5__c='Gray'));
        customSettings.add(new OM_collection_settings__c(Name='Setting7', Sales_orders_types__c='',  Collection_type__c='Current collection',    Primary__c=True, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Orange', Less_than_5__c='Gray'));
        customSettings.add(new OM_collection_settings__c(Name='Setting8', Sales_orders_types__c='',  Collection_type__c='Next collection',       Primary__c=False, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Green', Less_than_5__c='Green'));
        customSettings.add(new OM_collection_settings__c(Name='Setting9', Sales_orders_types__c='',  Collection_type__c='After next collection', Primary__c=False, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Green', Less_than_5__c='Green'));
        customSettings.add(new OM_collection_settings__c(Name='Setting10', Sales_orders_types__c='',  Collection_type__c='Special collection',    Primary__c=False, Secondary__c=False, More_than_10__c='Green', Between_5_and_10__c='Orange', Less_than_5__c='Gray'));
	}

	private void initializeCollections_order () {
        customSettings.add(new Collections_order__c(Name = 'Current collection', Collection_number__c=1));
        customSettings.add(new Collections_order__c(Name = 'Next collection', Collection_number__c=2));
        customSettings.add(new Collections_order__c(Name = 'After next collection', Collection_number__c=3));
        customSettings.add(new Collections_order__c(Name = 'Special collection', Collection_number__c=4));
        customSettings.add(new Collections_order__c(Name = 'Old collection', Collection_number__c=5));
	}

	private void initializeB2BNewOrderDateIntervals () {
		customSettings.add(new B2B_Portal_New_Order_Date_Intervals__c(Name = 'Pre-Order', Min_days_in_the_future__c=90));
		customSettings.add(new B2B_Portal_New_Order_Date_Intervals__c(Name = 'Re-Order', Min_days_in_the_future__c=0, Max_days_in_the_future__c=7));
	}

	private void initializeBackstageProfileSettings () {
		customSettings.add(new Backstage_Profile_Setting__c(SetupOwnerId = UserInfo.getOrganizationId(), Available_order_types__c='re-order;pre-order;'));
	}

	private void initializePBSIProperties() {
		customSettings.addAll(new List<sObject>{
			new PBSI__Property__c(PBSI__Property_Name__c='ExactShip',PBSI__Property_Value__c='No')
			,new PBSI__Property__c(PBSI__Property_Name__c='SN_Prefix', PBSI__Property_Value__c='')
			,new PBSI__Property__c(PBSI__Property_Name__c='SN_Sufix', PBSI__Property_Value__c='')
			,new PBSI__Property__c(PBSI__Property_Name__c='SN_Autogen', PBSI__Property_Value__c='No')
			,new PBSI__Property__c(PBSI__Property_Name__c='SN_Length', PBSI__Property_Value__c='')
			,new PBSI__Property__c(PBSI__Property_Name__c='AllowOnlyDigits', PBSI__Property_Value__c='No')
			,new PBSI__Property__c(PBSI__Property_Name__c='SN_Invindex', PBSI__Property_Value__c='0')
			,new PBSI__Property__c(PBSI__Property_Name__c='Lot_Usage', PBSI__Property_Value__c='No')
			,new PBSI__Property__c(PBSI__Property_Name__c='LotSortOrder', PBSI__Property_Value__c='Name Ascending')
			,new PBSI__Property__c(PBSI__Property_Name__c='EditClosedOpp', PBSI__Property_Value__c='Yes')
			,new PBSI__Property__c(PBSI__Property_Name__c='DecimalPlaces', PBSI__Property_Value__c='4')
			,new PBSI__Property__c(PBSI__Property_Name__c='PhantomSnAssing', PBSI__Property_Value__c='No')
			,new PBSI__Property__c(PBSI__Property_Name__c='ItemName', PBSI__Property_Value__c='Yes')
			,new PBSI__Property__c(PBSI__Property_Name__c='TradeDecimalPlaces', PBSI__Property_Value__c='4')
			,new PBSI__Property__c(PBSI__Property_Name__c='Item_Version', PBSI__Property_Value__c='Yes')
		});
	}

	private void initializeB24Settings() {
		B24_Integration__c b24int = new B24_Integration__c();
		b24int.Endpoint_Key__c = 'sample-for-tests';
		b24int.Username__c = 'test_user';
		b24int.Password__c = 'qwerty';
		Organization thisInstance = [SELECT Id, Name, IsSandbox from Organization];
  		String instanceName = thisInstance.IsSandbox ? (String) thisInstance.Id : 'Production';
  		b24int.Name = instanceName;
		customSettings.add(b24int);
	}

	private void initializeOSCASettings() {
		OSCA_credentials__c oscaInt = new OSCA_credentials__c();
		oscaInt.Interface_URL__c = 'https://uat.osca-web-onrunning.com/import/';
		oscaInt.Username__c = 'test_user';
		oscaInt.Password__c = 'qwerty';
		Organization thisInstance = [SELECT Id, Name, IsSandbox from Organization];
  		String instanceName = thisInstance.IsSandbox ? (String) thisInstance.Id : 'Production';
  		oscaInt.Name = instanceName;
		customSettings.add(oscaInt);
	}

	private void initializeCongaQueryMapping() {
		List<sObject> settings = new List<sObject>();
		settings.add(new Conga_Query_Mapping__c(Name = 'fullBodLines', Conga_Query_Id__c = '00OD0000005tU5X'));
		settings.add(new Conga_Query_Mapping__c(Name = 'partialBodLines', Conga_Query_Id__c = '00OD0000005tU5J'));
		settings.add(new Conga_Query_Mapping__c(Name = 'partialBodAlreadyDeliveredTotals', Conga_Query_Id__c = 'a1nD0000000snWF'));
		settings.add(new Conga_Query_Mapping__c(Name = 'partialBodInThisShipment', Conga_Query_Id__c = 'a1nD0000000snWU'));
		settings.add(new Conga_Query_Mapping__c(Name = 'shippingConfirmationLines', Conga_Query_Id__c = '00OD0000005tKe9'));
		customSettings.addAll(settings);
	}
}