public class SalesOrderTriggerHandler extends TriggerHandler {
    
    private static SalesOrderTriggerHandler singleton;
    
    public static SalesOrderTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new SalesOrderTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    private List<PBSI__PBSI_Sales_Order__c> lSOToSendTreckingInfo_B2B = new List<PBSI__PBSI_Sales_Order__c>();

    private Features_enable_disable_settings__c features_settings {
        get {
            if(features_settings == null) {
                Map<String, Features_enable_disable_settings__c> mFeatureSettings = Features_enable_disable_settings__c.getAll();
                if (mFeatureSettings.containsKey('organisation_setting')) {
                    features_settings = mFeatureSettings.get('organisation_setting');
                } else {
                    features_settings = new Features_enable_disable_settings__c();
                }
            }
            return features_settings;
        }
        private set;
    }

    public Id webRecTypId {
        get {
            if(webRecTypId == null) {
                webRecTypId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order');
            }
            return webRecTypId;
        }
        private set;
    }

	private Integer isBeforeUpdateCount = 0;
	private Integer isAfterUpdateCount = 0;
    private Map<Id,Set<String>> mapSalesOrderId2TrackNumbersProcessed = new Map<Id,Set<String>>();
    private Set<Id> sAccountsIdsActivated = new Set<Id>();

    protected override void handleBeforeInsert() {
		SalesOrderMethods.setupPreOrderDiscount(Trigger.new);
        SalesOrderMethods.copyPhoneFromAccountIfEmpty(Trigger.new);
        SalesOrderMethods.assignNoSmsFlag(Trigger.new);
		SalesOrderMethods.setFromLocationToAccountsDefault((List<PBSI__PBSI_Sales_Order__c>) Trigger.New);
        SalesOrderMethods.copySpecialDiscountFromAccount(Trigger.new);
        PaymentTermsService paymentTermsSrv = new PaymentTermsService(Trigger.new);
        paymentTermsSrv.assignPaymentTerms();
        SalesOrderMethods.setCurrencyFromAccount(Trigger.new, webRecTypId);
        activateAccounts(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
		SalesOrderMethods.setupPreOrderDiscount(Trigger.new);
        SalesOrderMethods.copyPhoneFromAccountIfEmpty(Trigger.new);
        SalesOrderMethods.assignNoSmsFlag(Trigger.oldMap, Trigger.newMap);
		SalesOrderMethods.fillAttachmentIds((Map<Id, PBSI__PBSI_Sales_Order__c>)Trigger.oldMap, (Map<Id, PBSI__PBSI_Sales_Order__c>)Trigger.newMap);
		SalesOrderMethods.setFromLocationToAccountsDefault(SalesOrderMethods.filterByRecordType(Trigger.newMap, 'web_order').values());
		System.debug('This is ' + isBeforeUpdateCount++ + ' of before update on Sales Order in this transaction');
        if(features_settings.Enable_company_assigment__c) {
            SalesOrderMethods.assignCompany(
                Trigger.oldMap, 
                sObjectMethods.filterSObjectsByField(
                    Trigger.newMap, 
                    'RecordTypeId', 
                    webRecTypId
                )
            );
        }
        PaymentTermsService paymentTermsSrv = new PaymentTermsService(
            PaymentTermsService.filterRevelantChanges(Trigger.oldMap, Trigger.newMap)
        );
        paymentTermsSrv.assignPaymentTerms();
        activateAccounts(Trigger.oldMap,Trigger.newMap);
    }

	protected override void handleAfterInsert() {
		BackstageShareService srv = new BackstageShareService();
		insert srv.createSharesForObjects(Trigger.new, Schema.PBSI__PBSI_Sales_Order__c.sObjectType);
        if (features_settings.Enable_Shipping_automation__c) {
            SalesOrderMethods.cargoCareShippingNotification((list<PBSI__PBSI_Sales_Order__c>) Trigger.new);
        }
	}

    protected override void handleAfterUpdate() {
        isAfterUpdateCount++;
        System.debug('This is ' + isAfterUpdateCount + ' of after update on Sales Order in this transaction');
        SalesOrderMethods.recalculateSharesForPortalUsers(Trigger.oldMap, Trigger.newMap);
        set<id> recalculatetradesoids=new set<id>();
        for (SObject sob: Trigger.newMap.values()) {
        PBSI__PBSI_Sales_Order__c  s = (PBSI__PBSI_Sales_Order__c ) sob;
            if (s.pbsi__due_date__c <>((PBSI__PBSI_Sales_Order__c ) Trigger.oldMap.get(s.id)).pbsi__due_Date__c) {
                recalculatetradesoids.add(s.id);
            }
        }
              
        if(recalculatetradesoids.size() > 0) {
            list<PBSI__pbsi_sales_order_line__c> solines = [select PBSI__ItemSalesPrice__c,CurrencyIsoCode, PBSI__Sales_Order_Ship_Date__c, PBSI__Price_Type__c,
                                                            PBSI__Sales_Order__c,id,PBSI__item__c,PBSI__discount__c,PBSI__Trade_agreement__c,PBSI__Quantity_Needed__c,
                                                            PBSI__SOAccount__c,PBSI__Item_Group__c,PBSI__SOAccountGr__c,PBSI__Disable_Sales_Trade_Agreement__c,
                                                            PBSI__HasInstructions__c ,PBSI__discount1__c,PBSI__Price__c,PBSI__Price4__c,PBSI__Unit_Of_Measure__c,Sales_Order_Type__c 
                                                        from pbsi__pbsi_sales_order_line__c  
                                                        where pbsi__sales_order__c in :recalculatetradesoids];
            UpdateSODetails.calculateTradeLine(solines,null,null);
            update solines;
        }
        
        if (features_settings.Enable_packing_automation__c) {
			SalesOrderMethods.packingAutomation((Map<ID, PBSI__PBSI_Sales_Order__c>) Trigger.oldMap, (Map<ID, PBSI__PBSI_Sales_Order__c>) Trigger.newMap);
        }

        if (features_settings.Enable_Shipping_automation__c) {
            SalesOrderMethods.cargoCareShippingNotification((list<PBSI__PBSI_Sales_Order__c>) Trigger.new);
        }

        if (features_settings.Enable_invoicing_automation__c) {
            Set<ID> sSalesOrderIDs = SalesOrderMethods.getSalesOrderIDsThatAreReadyToBeInvoiced(
                (Map<ID, PBSI__PBSI_Sales_Order__c>) Trigger.oldMap, 
                (Map<ID, PBSI__PBSI_Sales_Order__c>) Trigger.newMap
            );
            System.debug('sSalesOrderIDs: ' + sSalesOrderIDs);
            /* That function automaticaly create Sales Invoice for Sales Orders which have set Tracking Number 1 */
            SalesInvoiceMethods.invoiceSalesOrders(sSalesOrderIDs); 
        }
		SalesOrderMethods.performOrderConfirmationGeneration(Trigger.oldMap, Trigger.newMap);
		//Due to Salesforce implementation it is impossible to cast Map<Id, sObject> to anything
		//you can't really cast map of sobjects to anything despite note on following page:
		//https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_casting_collections.htm
		//That's why it was implemented in this way.
		SalesOrderMethods.syncEstimatedShipDateOnLines(
            SalesOrderMethods.convertMap(sObjectMethods.getSObjectsWithChangedValue(Trigger.newMap, Trigger.oldMap, 'PBSI__Due_date__c'))
        );
        SalesOrderMethods.createTrackingObjects(
            (Map<ID, PBSI__PBSI_Sales_Order__c>) Trigger.oldMap, 
            (Map<ID, PBSI__PBSI_Sales_Order__c>) Trigger.newMap,
            mapSalesOrderId2TrackNumbersProcessed
        );
        
    }

    private void activateAccounts(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
        Set<Id> sAccIds = new Set<Id>();
        for(PBSI__PBSI_Sales_Order__c so: lSalesOrders) {
            if(!String.isBlank(so.Sales_Order_Type__c) && !AccountApprovalService.SO_NOT_STARTING_PROCESS.contains(so.Sales_Order_Type__c)) {
                sAccIds.add(so.PBSI__Customer__c);
            }
        }
        sAccIds.removeAll(sAccountsIdsActivated);
        if(!sAccIds.isEmpty()) {
            List<Account> lAccounts = [SELECT Id,Name,Approval_Required__c,Status__c FROM Account 
                                            WHERE Id IN :sAccIds
                                                AND Approval_Required__c = true
                                                AND Status__c IN :AccountApprovalService.TO_AUTO_APPROVAL_STATUSES];
            sAccountsIdsActivated.addAll(sAccIds);
            AccountApprovalService approvalService = new AccountApprovalService(lAccounts);
            approvalService.startActivationProcess();
        }
        
    }

    private void activateAccounts(Map<Id,SObject> mapSalesOrdersOld, Map<Id,SObject> mapSalesOrdersNew) {
        List<PBSI__PBSI_Sales_Order__c> lSalesOrders = filterChangedField(mapSalesOrdersOld,mapSalesOrdersNew,'Sales_Order_Type__c');
        activateAccounts(lSalesOrders);
    }

    private List<PBSI__PBSI_Sales_Order__c> filterChangedField(Map<Id,SObject> mapSalesOrdersOld, Map<Id,SObject> mapSalesOrdersNew, String fieldName) {
        List<PBSI__PBSI_Sales_Order__c> lSalesOrdersFiltered = new List<PBSI__PBSI_Sales_Order__c>();
        for(Id key: mapSalesOrdersNew.keySet()) {
            PBSI__PBSI_Sales_Order__c soOld = (PBSI__PBSI_Sales_Order__c) mapSalesOrdersOld.get(key);
            PBSI__PBSI_Sales_Order__c soNew = (PBSI__PBSI_Sales_Order__c) mapSalesOrdersNew.get(key);

            if(soOld.get(fieldName) != soNew.get(fieldName)) {
                lSalesOrdersFiltered.add(soNew);
            }
        }
        return lSalesOrdersFiltered;
    }
}