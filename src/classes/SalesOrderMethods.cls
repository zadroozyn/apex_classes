public without sharing class SalesOrderMethods {

	private static final Map<String, Sales_Order_Packing_Settings__c> M_SALES_ORDER_PACKING_SETTINGS = Sales_Order_Packing_Settings__c.getAll();
	private static boolean isCongaBatchScheduled = false;
	private static final Map<String, Id> M_DEVNAME_TO_RECORDTYPE_ID = new Map<String, Id>();
	public static final String WEB_ORDER_RECORD_TYPE_NAME = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('WEB_ORDER_RECORD_TYPE_NAME') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('WEB_ORDER_RECORD_TYPE_NAME').Value__c : 'Web_Order';
	public static final String SALES_ORDER_RECORD_TYPE_NAME = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('SALES_ORDER_RECORD_TYPE_NAME') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('SALES_ORDER_RECORD_TYPE_NAME').Value__c : 'Sales_Order';
	public static final String WEB_ORDER_COMPLETE_STATUS_VALUE = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('WEB_ORDER_COMPLETE_STATUS_VALUE') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('WEB_ORDER_COMPLETE_STATUS_VALUE').Value__c : 'Completion';
	public static final String SALES_ORDER_FINAL_STATUS = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('SALES_ORDER_FINAL_STATUS') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('SALES_ORDER_FINAL_STATUS').Value__c : 'closed';
	public static final String SALES_ORDER_FINAL_STAGE = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('SALES_ORDER_FINAL_STAGE') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('SALES_ORDER_FINAL_STAGE').Value__c : 'packed';
	public static final String SALES_ORDER_PARTIALLY_COMPLETE_STATUS = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('SALES_ORDER_PARTIALLY_COMPLETE_STATUS') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('SALES_ORDER_PARTIALLY_COMPLETE_STATUS').Value__c : 'partially complete';
	public static final String SALES_ORDER_OPEN_STAGE = SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.containsKey('SALES_ORDER_OPEN_STAGE') ? SalesOrderMethods.M_SALES_ORDER_PACKING_SETTINGS.get('SALES_ORDER_OPEN_STAGE').Value__c : 'open';
	private static final String ERROR_MESSAGE_NOT_ENOUGH_ITEMS_ON_STOCK = Label.SalesOrderPackagingProcess_LotQuantityMessage;
	public static final String B2B_PORTAL_ORDER_RECORD_TYPE_DEV_NAME = 'B2B_Portal';
	public static final String SALES_ORDER_RECORD_TYPE_DEV_NAME = 'Sales_Order';


	/**
	 * Method set number of styles of every sales order which ID is in given set.
	 *
	 * @param sSalesOrderIDs Set of Sales Order IDs.
	 * @author Ewa Byra <ewa.byra@nefoscdc.com>.
	 */
	public static void updateNumberOfStyles(Set<ID> sSalesOrderIDs) {
		List<PBSI__PBSI_Sales_Order__c> lSalesOrders = new List<PBSI__PBSI_Sales_Order__c>();
		Map<ID, List<PBSI__PBSI_Sales_Order_Line__c>> mSalesOrderIdToSalesOrderLines;
		Set<String> sStyleNumbers = new Set<String>();
		Map<String, Decimal> mNumberOfStylesToQuantityNeeded;
		String styleNo;
		Decimal quantity;

		mSalesOrderIdToSalesOrderLines = SalesOrderLineMethods.getMapSalesOrderIdToSalesOrderLines(new Set<String> { 'PBSI__Quantity_Needed__c', 'PBSI__Item__r.Name' }, sSalesOrderIDs);

		for (ID salesOrderID : sSalesOrderIDs) {
			sStyleNumbers.clear();

			if (!mSalesOrderIdToSalesOrderLines.containsKey(salesOrderID)) {
				lSalesOrders.add(new PBSI__PBSI_Sales_Order__c(ID = salesOrderID, Number_of_styles__c = 0));
				continue;
			}

			mNumberOfStylesToQuantityNeeded = new Map<String, Decimal>();

			for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : mSalesOrderIdToSalesOrderLines.get(salesOrderID)) {
				styleNo = SalesOrderLineMethods.getStyleNumber(salesOrderLine);
				quantity = salesOrderLine.PBSI__Quantity_Needed__c;

				if (mNumberOfStylesToQuantityNeeded.containsKey(styleNo)) {
					quantity += mNumberOfStylesToQuantityNeeded.get(styleNo);
				}

				mNumberOfStylesToQuantityNeeded.put(styleNo, quantity);
			}

			for (String key : mNumberOfStylesToQuantityNeeded.keySet()) {
				if (mNumberOfStylesToQuantityNeeded.get(key) > SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED) {
					sStyleNumbers.add(key);
				}
			}

			lSalesOrders.add(new PBSI__PBSI_Sales_Order__c(ID = salesOrderID, Number_of_styles__c = sStyleNumbers.size()));
		}

		update lSalesOrders;
	}

	public static void assignCompany(Map<Id, sObject> mOrdersOld, Map<Id, sObject> mOrdersNew) {
		final List<sObject> ordersWithChangedCountry = new List<sObject>();
		for(Id orderId : mOrdersNew.keySet()) {
			if(mOrdersOld.get(orderId).get('PBSI__Delivery_Country__c') != mOrdersNew.get(orderId).get('PBSI__Delivery_Country__c') || mOrdersNew.get(orderId).get('Ascent2FF__Company__c') == NULL) {
				ordersWithChangedCountry.add(mOrdersNew.get(orderId));
			}
		}
		assignCompany(ordersWithChangedCountry);
	}

	/**
	 * Method is invoking from SalesOrderTriggers on before update event.<br>
	 * It is using to assing value to Company field (API Name: Ascent2FF__Company__c) of Sales Orders based on value that is stored in Billing Country (API Name: PBSI__BillingCountry__c).
	 *
	 * @param mSalesOrdersOld map of old PBSI_PBSI_Sales_Order__c records.
	 * @param mSalesOrdersNew map of new PBSI_PBSI_Sales_Order__c records.
	 */
	public static void assignCompany(List<sObject> orders) {
		system.debug('assign company records :' + orders);
		String countryIsoCode;
		Map<String, CountryToCompanyMapping__c> mCountryToCompany = CountryToCompanyMapping__c.getAll();
		for(sObject current : orders) {
			if(current.get('PBSI__Delivery_Country__c') != null) {
				countryISOCode = Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.get((String)current.get('PBSI__Delivery_Country__c'));
				current.put('Ascent2FF__Company__c', mCountryToCompany.containsKey(countryISOCode) ? mCountryToCompany.get(countryISOCode).Company_ID__c : (mCountryToCompany.containsKey('default') ? mCountryToCompany.get('default').Company_ID__c : null));
			}
		}
	}

	/**
	 * Method is invoking from SalesOrderTriggers on after update event.<br>
	 * It handles automation of the packaging process.<br>
	 *
	 * @param mSalesOrders map of old PBSI_PBSI_Sales_Order__c records.
	 * @param lSalesOrders list of new PBSI_PBSI_Sales_Order__c records.
	 */
	public static List<PBSI__PBSI_Sales_Order__c> packWebOrders(Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrders, List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		if(lSalesOrders == null || lSalesOrders.size() == 0) {
			return null;
		}
		Map<PBSI__PBSI_Sales_Order__c, List<PBSI__PBSI_Sales_Order_Line__c>> mSalesOrderToSalesOrderLines = SalesOrderLineMethods.getWebSalesOrderToSalesOrderLines(lSalesOrders, mSalesOrders);
		Map<ID, List<PBSI__PBSI_Sales_Order__c>> mCompanyIDToSalesOrders = SalesOrderMethods.getCompanyIDToSalesOrdersMap(lSalesOrders);
		Map<ID, PBSI__PBSI_Inventory__c> mSalesOrderLineToInventory = SalesOrderLineMethods.getSalesOrderLineToInventoryMap(mSalesOrderToSalesOrderLines);
		Map<ID, Decimal> mInventoryIDToQuantity = new Map<ID, Decimal>();
		Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrdersToUpdate = new Map<ID, PBSI__PBSI_Sales_Order__c>();
		Map<ID, List<PBSI.SalesOrderAPI.WSShipInfoLine>> mSalesOrderIDToListOfShipLines = new Map<ID, List<PBSI.SalesOrderAPI.WSShipInfoLine>>();
		PBSI.SalesOrderAPI.WSShipInfoLine shipOrderLine;
		List<PBSI.SalesOrderAPI.WSShipInfoLine> lShipLines = new List<PBSI.SalesOrderAPI.WSShipInfoLine>();
		List<PBSI__PBSI_Sales_Order__c> lPackedSalesOrders = new List<PBSI__PBSI_Sales_Order__c>();
		String errorMessage, errorMessageSet;
		Decimal leftItems, quantityNeeded, totalQuantityOnStock;
		PBSI__PBSI_Inventory__c inventory;
		PBSI.SalesOrderAPI.WSResponse response;

		for (PBSI__PBSI_Inventory__c record : mSalesOrderLineToInventory.values()) {
			mInventoryIDToQuantity.put(record.ID, record.PBSI__qty__c);
		}

		for (PBSI__PBSI_Sales_Order__c salesOrder : mSalesOrderToSalesOrderLines.keySet()) {
			errorMessageSet = '';
			mSalesOrderIDToListOfShipLines.put(salesOrder.ID, new List<PBSI.SalesOrderAPI.WSShipInfoLine>());

			for (PBSI__PBSI_Sales_Order_Line__c salesOrderLine : mSalesOrderToSalesOrderLines.get(salesOrder)) {
				/*System.debug();*/
				errorMessage = '';
				inventory = mSalesOrderLineToInventory.get(salesOrderLine.ID);
				System.debug('First deb: ' +inventory);
				quantityNeeded = salesOrderLine.PBSI__Quantity_Needed__c;
				System.debug('First deb: ' +quantityNeeded);
				totalQuantityOnStock = mInventoryIDToQuantity.get(inventory.ID);
				System.debug('First deb: ' +totalQuantityOnStock);

				if (quantityNeeded - totalQuantityOnStock > 0) {
					errorMessage = SalesOrderMethods.ERROR_MESSAGE_NOT_ENOUGH_ITEMS_ON_STOCK;
					errorMessage = errorMessage.replace('{!QUANTITY_LEFT}', (quantityNeeded - totalQuantityOnStock).format());
					errorMessage = errorMessage.replace('{!SALES_ORDER_LINE_NO}', salesOrderLine.Name);
					errorMessageSet += (!errorMessageSet.equals('') ? '\n' : '') + errorMessage;
				}

				mSalesOrderIDToListOfShipLines.get(salesOrder.ID).add(SalesOrderLineMethods.createWSShipInfoLine(salesOrderLine, inventory.PBSI__Lot__r.Name, quantityNeeded));
				mInventoryIDToQuantity.put(inventory.ID, totalQuantityOnStock - quantityNeeded);

			}

			if (!errorMessageSet.equals('')) {
				mSalesOrdersToUpdate.put(salesOrder.ID, new PBSI__PBSI_Sales_Order__c(ID = salesOrder.ID, Error_Message__c = errorMessageSet, PBSI__Customer__c = salesOrder.PBSI__Customer__c, Ascent2FF__Company__c = salesOrder.Ascent2FF__Company__c));
			}
		}

		for (ID salesOrderID : mSalesOrderIDToListOfShipLines.keySet()) {
			if (!mSalesOrdersToUpdate.containsKey(salesOrderID)) { //there is enough shoes on stock to pack this sales order.
				lShipLines.addAll(mSalesOrderIDToListOfShipLines.get(salesOrderID));
			}
		}

		if (lShipLines.size() > 0) {
			System.debug(LoggingLevel.INFO, '>>>>>>>>>>>>>>>>>> lShipLines: ' + lShipLines);

			response = PBSI.SalesOrderAPI.ShipSalesOrderLines(lShipLines);

			System.debug(LoggingLevel.INFO, '>>>>>>>>>>>>>>>>>> response: ' + response);

			/* update error message on all processed sales orders, when in response is any error message (no orders are packed) */
			if (response.errorMessage != null) {
				errorMessageSet = '';
				errorMessage = response.errorMessage;

				System.debug(LoggingLevel.ERROR, '>>>>>>>>>>>>>>>>>> errorMessage: ' + errorMessage);

				for (PBSI__PBSI_Sales_Order__c salesOrder : mSalesOrderToSalesOrderLines.keySet()) {
					if (mSalesOrdersToUpdate.containsKey(salesOrder.ID)) {
						errorMessageSet = mSalesOrdersToUpdate.get(salesOrder.ID).Error_Message__c;
					}

					errorMessageSet += (!errorMessageSet.equals('') ? '\n' : '') + errorMessage;
					mSalesOrdersToUpdate.put(salesOrder.ID, new PBSI__PBSI_Sales_Order__c(ID = salesOrder.ID, Error_Message__c = errorMessageSet, PBSI__Customer__c = salesOrder.PBSI__Customer__c, Ascent2FF__Company__c = salesOrder.Ascent2FF__Company__c));
				}
			}
		}

		/* set statuses on all processed sales orders */
		for (PBSI__PBSI_Sales_Order__c salesOrder : mSalesOrderToSalesOrderLines.keySet()) {
			if (mSalesOrdersToUpdate.containsKey(salesOrder.ID)) { /* some error with packing occour - open & partially complete */
				// mSalesOrdersToUpdate.get(salesOrder.ID).PBSI__Status__c = SalesOrderMethods.SALES_ORDER_PARTIALLY_COMPLETE_STATUS;
				// mSalesOrdersToUpdate.get(salesOrder.ID).PBSI__Stage__c = SalesOrderMethods.SALES_ORDER_OPEN_STAGE;
			} else { /* no error with packing occour - packed & closed */
				mSalesOrdersToUpdate.put(salesOrder.ID, new PBSI__PBSI_Sales_Order__c(ID = salesOrder.ID,
							PBSI__Status__c = SalesOrderMethods.SALES_ORDER_FINAL_STATUS,
							PBSI__Stage__c = SalesOrderMethods.SALES_ORDER_FINAL_STAGE,
							PBSI__Customer__c = salesOrder.PBSI__Customer__c,
							Ascent2FF__Company__c = salesOrder.Ascent2FF__Company__c,
							Is_Automatically_Packed__c = true,
							PBSI__Packing_Date__c = Date.today()));
				//new ONRKeuneNagelGateway().despatchNotification(salesOrder); // send Purchase Confirmation to customer and Bill of Delivery, Return Information and Proforma Invoice to KN
				lPackedSalesOrders.add(salesOrder);
			}
		}

		update mSalesOrdersToUpdate.values();

		System.debug('packed sales orders: ' + lPackedSalesOrders);
		System.debug('packed sales orders to update: '+mSalesOrdersToUpdate.values());

		return mSalesOrdersToUpdate.values();
		/*return lPackedSalesOrders;*/
	}

	public static ID getRecordTypeID(String recordTypeName) {
		return RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', recordTypeName);
	}

	public static Map<ID, String> getSalesOrderIDToCountryISOCode(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		Map<ID, String> mSalesOrderIDToCountryISOCode = new Map<ID, String>();
		String countryISOCode;

		for (PBSI__PBSI_Sales_Order__c salesOrder : lSalesOrders) {
			countryISOCode = Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.containsKey(salesOrder.PBSI__Customer__r.BillingCountry) ?
				Utility.M_COUNTRY_NAME_TO_COUNTRY_ISO_CODE.get(salesOrder.PBSI__Customer__r.BillingCountry) :
				'';
			mSalesOrderIDToCountryISOCode.put(salesOrder.ID, countryISOCode);
		}

		return mSalesOrderIDToCountryISOCode;
	}

	/**
	 * Method used to get map of Company ID to List of related Sales Orders.
	 *
	 * @param lSalesOrders list of Sales Order records that need to be mapped to company.
	 * @return map of Company ID to List of related Sales Orders.
	 */
	public static Map<ID, List<PBSI__PBSI_Sales_Order__c>> getCompanyIDToSalesOrdersMap(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		Map<ID, List<PBSI__PBSI_Sales_Order__c>> mCompanyIDToSalesOrders = new Map<ID, List<PBSI__PBSI_Sales_Order__c>>();

		for (PBSI__PBSI_Sales_Order__c salesOrder : lSalesOrders) {
			if (!mCompanyIDToSalesOrders.containsKey(salesOrder.Ascent2FF__Company__c)) {
				mCompanyIDToSalesOrders.put(salesOrder.Ascent2FF__Company__c, new List<PBSI__PBSI_Sales_Order__c>());
			}

			mCompanyIDToSalesOrders.get(salesOrder.Ascent2FF__Company__c).add(salesOrder);
		}

		return mCompanyIDToSalesOrders;
	}

	/**
	 * Method used to get IDs of Sales Orders that get Traking Number 1, which mean that they are ready to be invoiced.<br>
	 * It is called from after update trigger, to get input for SalesInvoiceMethods.invoiceSalesOrders(Set<ID>) method.
	 *
	 * @param mSalesOrdersOld Map of Sales Orders before updation.
	 * @param mSalesOrdersNew Map of Sales Orders after updation.
	 * @author Ewa Byra <ewa.byra@nefoscdc.com>.
	 */
	public static Set<ID> getSalesOrderIDsThatAreReadyToBeInvoiced(Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrdersOld, Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrdersNew) {
		Set<ID> sSalesOrderIDs = new Set<ID>();
		ID webOrderRecordTypeID = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);

		for (PBSI__PBSI_Sales_Order__c salesOrder : mSalesOrdersNew.values()) {
			if (salesOrder.RecordTypeID == webOrderRecordTypeID &&
					!String.isBlank(salesOrder.Tracking_Number_1__c) &&
					String.isBlank(mSalesOrdersOld.get(salesOrder.ID).Tracking_Number_1__c)) {
				sSalesOrderIDs.add(salesOrder.ID);
					}
		}

		return sSalesOrderIDs;
	}

	public static void recalculateSharesForPortalUsers(Map<Id, SObject> mOldSobjects, Map<Id, SObject> mNewSobjects) {
		Map<Id, PBSI__PBSI_Sales_Order__c> mOldOrders = (Map<Id, PBSI__PBSI_Sales_Order__c>) mOldSobjects;
		Map<Id, PBSI__PBSI_Sales_Order__c> mNewOrders = (Map<Id, PBSI__PBSI_Sales_Order__c>) mNewSobjects;
		List<Id> orderIdsWithChangedCustomer = getOrderIdsWithChangedAcc(mOldOrders, mNewOrders);
		if(orderIdsWithChangedCustomer.size() == 0) {
			return;
		}
		List<PBSI__PBSI_Sales_Order__c> lNewChangedOrders = getOrdersFromMap(orderIdsWithChangedCustomer, mNewOrders);
		List<SObject> oldShares = ShareHandler.getShares(orderIdsWithChangedCustomer, 'PBSI__PBSI_Sales_Order__c', 'Portal_user_access__c');
		delete oldShares;
		BackstageShareService srv = new BackstageShareService();
		Database.insert(srv.createSharesForObjects(lNewChangedOrders, Schema.PBSI__PBSI_Sales_Order__c.sObjectType));
	}

	public static String generateOrderConfirmation(PBSI__PBSI_Sales_Order__c order, String sessionId){
		return CongaFileGenerator.sendRequest(order.Conga_Order_Confirmation_Link__c.replace('NULL_SESSION_ID', sessionId));
	}

	public static void performOrderConfirmationGeneration(Map<Id, sObject>mOldsObjects, Map<Id, sObject> mNewsObjects) {
		if(isCongaBatchScheduled) {
			return;
		}
		Map<Id, PBSI__PBSI_Sales_Order__c> ordersToProcess = SalesOrderMethods.selectSOForAttachementGeneration(mOldsObjects, mNewsObjects);
		String sessionId = UserInfo.getSessionId();
		Schema.sObjectType test = Schema.getGlobalDescribe().get('PBSI__PBSI_Sales_Order__c');
		if(!System.isBatch() && !ordersToProcess.isEmpty()) {
			CongaFileGeneratorBatch b = new CongaFileGeneratorBatch(ordersToProcess.keySet(), test, sessionId);
			Database.executeBatch(b, 1);
			isCongaBatchScheduled = true;
		}

	}

	private static Map<Id, PBSI__PBSI_Sales_Order__c> selectSOForAttachementGeneration(Map<Id, sObject> mOldsObjects, Map<Id, sObject> mNewsObjects) {
		Map<Id, PBSI__PBSI_Sales_Order__c> mOldOrders = (Map<Id, PBSI__PBSI_Sales_Order__c>) mOldSobjects;
		Map<Id, PBSI__PBSI_Sales_Order__c> mNewOrders = (Map<Id, PBSI__PBSI_Sales_Order__c>) mNewSobjects;
		Map<Id, PBSI__PBSI_Sales_Order__c> mOrdersToProcess = new Map<Id, PBSI__PBSI_Sales_Order__c>();
		for(PBSI__PBSI_Sales_Order__c currentSO : mNewOrders.values()){
			PBSI__PBSI_Sales_Order__c oldSO = mOldOrders.get(currentSO.Id);
			if(shouldGenerateConfirmation(oldSO, currentSO)) {
				mOrdersToProcess.put(currentSO.Id, currentSO);
			  }
		}
		return mOrdersToProcess;
	}

	private static boolean shouldGenerateConfirmation(PBSI__PBSI_Sales_Order__c oldOrder, PBSI__PBSI_Sales_Order__c newOrder) {
		Id b2bRecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'B2B_Portal');
		Id proposalRecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal');
		if(newOrder.RecordTypeId == b2bRecordTypeId) {
			if((newOrder.Sales_Order_Type__c == 're-order' || newOrder.Sales_Order_Type__c == 'drop ship')
					&& newOrder.pbsi__status__c == 'in progress'
					&& (oldOrder == NULL || oldOrder.pbsi__status__c  != 'in progress')
					&& newOrder.PBSI__Stage__c == 'open' 
			) {
				return true;
			} else if (
					oldOrder.RecordTypeId == proposalRecordTypeId
					&& newOrder.pbsi__status__c == 'in progress'
					&& newOrder.PBSI__Stage__c == 'open' 
			) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Method takes two maps(new and old trigger's map) and compares their PBSI__Customer__c.
	 * It returns Ids of orders with changed Customer
	 *
	 * @param mOldSobjects   Trigger.mapOld
	 * @param mOldSobjects   Trigger.mapNew
	 * @return               List with ids of orders with changed customer/account.
	 * @author Kamil Grzywacz <kamil.grzywacz@nefoscdc.com>
	 */
	private static List<Id> getOrderIdsWithChangedAcc(Map<Id, PBSI__PBSI_Sales_Order__c> mOldOrders, Map<Id, PBSI__PBSI_Sales_Order__c> mNewOrders) {
		List<Id> resultList = new List<Id>();
		for(Id currentId : mOldOrders.keySet()) {
			if(mOldOrders.get(currentId).PBSI__Customer__c != mNewOrders.get(currentId).PBSI__Customer__c) {
				resultList.add(mNewOrders.get(currentId).Id);
			}
		}
		return resultList;
	}


	/**
	 * Method filters map of orders by list of ids, and returns list of fitlered orders/
	 * 
	 * @param orderIds     Ids of orders that map should be filtered by
	 * @param mOrders      Map with orders to be filtered
	 * @return             List with filtered orders
	 * @author Kamil Grzywacz <kamil.grzywacz@nefoscdc.com>
	 */
	@testVisible
	private static List<PBSI__PBSI_Sales_Order__c> getOrdersFromMap(List<Id> orderIds, Map<Id, PBSI__PBSI_Sales_Order__c> mOrders) {
		List<PBSI__PBSI_Sales_Order__c> resultList = new List<PBSI__PBSI_Sales_Order__c>();
		for(Id currentId :orderIds) {
			resultList.add(mOrders.get(currentId));
		}
		return resultList;
	}

	public static void syncEstimatedShipDateOnLines (Map<Id, PBSI__PBSI_Sales_Order__c> orders) {
		system.debug('Trigger deb: ' + Trigger.isUpdate);
		final Set<String> lineFieldsToQuery = new Set<String>();
		lineFieldsToQuery.add('PBSI__Estimated_ship_date__c');
		final Map<Id, List<PBSI__PBSI_Sales_Order_Line__c>> lines = SalesOrderLineMethods.getMapSalesOrderIdToSalesOrderLines(lineFieldsToQuery, orders.keySet());
		final List<PBSI__PBSI_Sales_Order_Line__c> linesToUpdate = new List<PBSI__PBSI_Sales_Order_Line__c>();
		
		for(PBSI__PBSI_Sales_Order__c currentOrder : orders.values()){
			if(lines.get(currentOrder.Id) != null){
				for(PBSI__PBSI_Sales_Order_Line__c currentLine : lines.get(currentOrder.Id)){ 
					if(currentLine.PBSI__Estimated_ship_date__c != currentOrder.PBSI__Due_date__c) {
						currentLine.PBSI__Estimated_ship_date__c = currentOrder.PBSI__Due_date__c;
						linesToUpdate.add(currentLine);
					}
				}
			}
		}
		update linesToUpdate;
	}

	public static void packingAutomation (Map<Id, PBSI__PBSI_Sales_Order__c> mOrdersOld, Map<Id, PBSI__PBSI_Sales_Order__c> mOrdersNew) {
		List<PBSI__PBSI_Sales_Order__c> orders = packWebOrders(mOrdersOld, getWebOrdersForPacking(mOrdersNew).values());
		if(orders == null || orders.size() == 0){
			return;
		}
		despatchOrders(orders);

	}

	public static void cargoCareShippingNotification(list<PBSI__PBSI_Sales_Order__c> salesOrdersToUpdate){
		for(PBSI__PBSI_Sales_Order__c so: salesOrdersToUpdate){
			String fulfiller = so.Fulfiller__c;
			if(fulfiller == 'CargoCare' && so.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order')){
			    Boolean alreadySent = so.KN_Shipping_Notice_Sent__c;
		        Boolean checkoutComplete = (so.Web_Order_Stage_Reached__c == ONRLogisticsGateway.WEB_CHECKOUT_STAGE_COMPLETE);
		        Boolean trackingCodeExists = !String.isBlank(so.Tracking_Information__c);

		        if((!alreadySent) && (checkoutComplete) && (trackingCodeExists)) {
		            ONRWebService.shippingNotificationWeb(so);
		        }
		    }
	    }
	}

	private static void despatchOrders(List<PBSI__PBSI_Sales_Order__c> orders) {
		Set<Id> orderIds = new Set<Id>();
		for (PBSI__PBSI_Sales_Order__c currentOrder : orders) {
			orderIds.add(currentOrder.Id);
		}
		ONRWebService.autoNotifySync(orderIds);
	}

	public static void createTrackingObjects(Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrdersOld, 
		Map<ID, PBSI__PBSI_Sales_Order__c> mSalesOrdersNew, Map<Id,Set<String>> mapSalesOrderId2TrackNumbersProcessed){

		List<Tracking__c> lTrackings = new List<Tracking__c>();
		Map<Id,List<Tracking_number__c>> mapSalesOrderId2TrackingNumbers = new Map<Id,List<Tracking_number__c>>();
		for (Id soId: mSalesOrdersNew.keySet()){
			PBSI__PBSI_Sales_Order__c newSaleOrder = mSalesOrdersNew.get(soId);
			if(isB2BOrSalesOrderRecordType(newSaleOrder)){
				PBSI__PBSI_Sales_Order__c oldSaleOrder = mSalesOrdersOld.get(soId);
				Set<String> newTrackingNumbers = SalesOrderTrackingInformationHelper.clalculateNewTrackingNumbers(oldSaleOrder, newSaleOrder);
				Set<String> sProcessedNumbers = mapSalesOrderId2TrackNumbersProcessed.get(soId);
				if(sProcessedNumbers != null) {
					newTrackingNumbers.removeAll(sProcessedNumbers);
				} else {
					sProcessedNumbers = new Set<String>();
				}
				if(!newTrackingNumbers.isEmpty()) {
					sProcessedNumbers.addAll(newTrackingNumbers);
					mapSalesOrderId2TrackNumbersProcessed.put(soId,sProcessedNumbers);
						lTrackings.add(
						new Tracking__c(
							Sales_Order__c = newSaleOrder.Id,
							Contact__c = newSaleOrder.PBSI__Contact__c
						)
					);

					for(String trackingNumber: newTrackingNumbers) {
						Tracking_number__c tn = new Tracking_number__c(
							Number__c = trackingNumber
						);
						if(mapSalesOrderId2TrackingNumbers.containsKey(newSaleOrder.Id)) {
							mapSalesOrderId2TrackingNumbers.get(newSaleOrder.Id).add(tn);
						} else {
							mapSalesOrderId2TrackingNumbers.put(newSaleOrder.Id,new List<Tracking_number__c>{tn});
						}
						
					}
				}
				
			}
		}
		
		if(!lTrackings.isEmpty()) {
			insert lTrackings;
			List<Tracking_number__c> lAllTrackingNumbers = new List<Tracking_number__c>();
			for(Tracking__c tracking: lTrackings) {
				List<Tracking_number__c> tns = mapSalesOrderId2TrackingNumbers.get(tracking.Sales_Order__c);
				if(tns != null) {
					for(Tracking_number__c tn: tns) {
						tn.Tracking__c = tracking.Id;
						lAllTrackingNumbers.add(tn);
					}
				}
			}
			insert lAllTrackingNumbers;
		}
	}

	public static boolean isB2BOrSalesOrderRecordType(PBSI__PBSI_Sales_Order__c salesOrder){
		return salesOrder.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', B2B_PORTAL_ORDER_RECORD_TYPE_DEV_NAME)
			|| salesOrder.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', SALES_ORDER_RECORD_TYPE_DEV_NAME);
	}

	public static void setFromLocationToAccountsDefault (List<PBSI__PBSI_Sales_Order__c> orders) {
		Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Automatic_location_id__c FROM Account WHERE ID IN : sObjectMethods.getValuesFromTextField(orders, 'PBSI__Customer__c')]);
		for(PBSI__PBSI_Sales_Order__c currentOrder : orders) {
			if(mAccounts.containsKey(currentOrder.PBSI__Customer__c)) {
				if(!(Trigger.isInsert && currentOrder.PBSI__From_Location__c != NULL)) {
					currentOrder.PBSI__From_Location__c = mAccounts.get(currentOrder.PBSI__Customer__c).Automatic_location_id__c;
				}
			}
		}
	}

	public static void setCurrencyFromAccount (List<PBSI__PBSI_Sales_Order__c> orders, Id webRecTypId) {
		Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, CurrencyIsoCode FROM Account WHERE ID IN : sObjectMethods.getValuesFromTextField(orders, 'PBSI__Customer__c')]);
		for(PBSI__PBSI_Sales_Order__c currentOrder : orders) {
			if(mAccounts.containsKey(currentOrder.PBSI__Customer__c)) {
				if(currentOrder.recordtypeId != webRecTypId && currentOrder.PBSI__Opportunity__c == null){
					currentOrder.CurrencyIsoCode = mAccounts.get(currentOrder.PBSI__Customer__c).CurrencyIsoCode;
				}
			}
		}
	}
	
	public static Map<Id, PBSI__PBSI_Sales_Order__c>  filterByRecordType (Map<Id, PBSI__PBSI_Sales_Order__c> inputMap, String recordTypeDeveloperName) {
		return  convertMap(sObjectMethods.filterSObjectsByField(inputMap, 'RecordTypeId', RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', recordTypeDeveloperName)));
	}

	public static Map<Id, PBSI__PBSI_Sales_Order__c>  filterByRecordType (Map<Id, sObject> inputMap, String recordTypeDeveloperName) {
		return filterByRecordType((Map<Id, PBSI__PBSI_Sales_Order__c>) inputMap, recordTypeDeveloperName);
	}

	private	static Map<Id, PBSI__PBSI_Sales_Order__c> getWebOrdersForPacking (Map<Id, PBSI__PBSI_Sales_Order__c> input) {
		Map<Id, PBSI__PBSI_Sales_Order__c> temp = filterByRecordType(input, 'Web_Order');
		final Map<Id, PBSI__PBSI_Sales_Order__c> returnValue = new Map<Id, PBSI__PBSI_Sales_Order__c>();
		final List<PBSI__PBSI_Sales_Order__c> webOrdersToPack = SObjectMethods.filterSObjectsByField( temp.values(), 'Is_Packing_Disabled__c', false);
		for(PBSI__PBSI_Sales_Order__c current : webOrdersToPack) {
			returnValue.put(current.Id, temp.get(current.Id));
		}
		return returnValue;
	}

	public static Map<Id, PBSI__PBSI_Sales_Order__c> convertMap (Map<Id, sObject> inputMap) {
		return new Map<Id, PBSI__PBSI_Sales_Order__c>((List<PBSI__PBSI_Sales_Order__c>) inputMap.values());
	}

	public static void fillAttachmentIds(Map<Id, PBSI__PBSI_Sales_Order__c> oldMap, Map<Id, PBSI__PBSI_Sales_Order__c> newMap) {
		Set<Id> parents = new Set<Id>();
		for(PBSI__PBSI_Sales_Order__c current : newMap.values()){
			if((current.BoD_Generated__c && !oldMap.get(current.Id).BoD_Generated__c)
				|| (current.Return_information_generated__c && !oldMap.get(current.Id).Return_information_generated__c)){
				parents.add(current.Id);
			}
		}
		system.debug('Parents: ' + parents);
		List<Attachment> attachments = [SELECT Id, ParentId, Name From Attachment WHERE ParentId IN : parents AND Name IN ('Bill of Delivery.pdf', 'Return information.pdf') ORDER BY CreatedDate DESC];
		for(Id current : parents) {
			if(newMap.get(current).BoD_Generated__c && !oldMap.get(current).BoD_Generated__c) {
				for(Attachment a : attachments) {
					if(a.ParentId == current && a.Name == 'Bill of Delivery.pdf') {
						newMap.get(current).Bill_of_Delivery_PDF_Id__c = a.Id;
						newMap.get(current).BoD_Generated__c = false;
						break;
					}
				}
			}
			if(newMap.get(current).Return_information_generated__c && !oldMap.get(current).Return_information_generated__c) {
				for(Attachment a : attachments) {
					if(a.ParentId == current && a.Name == 'Return information.pdf') {
						newMap.get(current).Return_Information_PDF_Id__c = a.Id;
						newMap.get(current).Return_information_generated__c = false;
						break;
					}
				}
			}
		}
	}

	public static void copyPhoneFromAccountIfEmpty(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		Id webOrderRTId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c','Web_Order');
		for(PBSI__PBSI_Sales_Order__c so: lSalesOrders) {
			if( so.RecordTypeId == webOrderRTId
					&& (String.isBlank(so.PBSI__Delivery_ATTN_to_Phone__c) || so.PBSI__Delivery_ATTN_to_Phone__c == '.' )) {
				so.PBSI__Delivery_ATTN_to_Phone__c = so.Account_Phone_No__c;
			}
		}
	}

	public static void setupPreOrderDiscount(List<PBSI__PBSI_Sales_Order__c> lOrders) {
		if(lOrders.isEmpty()) {
			return;
		}
		Set<Id> moIds= new Set<Id>();
		Set<Id> accountIds = new Set<Id>();
		for(PBSI__PBSI_Sales_Order__c current : lOrders) {
			if(current.Master_order__c != null) {
				moIds.add(current.Master_order__c);
			} else if(current.Sales_Order_type__c == 'Pre-Order' && current.Pre_Order_Discount_override__c == null) {
				accountIds.add(current.PBSI__Customer__c);
			}
		}
		accountIds.remove(null);
		Map<Id, Account> mAccounts;
		Map<Id, Master_order__c> mMOrders;
		if(!accountIds.isEmpty()) {
			mAccounts = new Map<Id, Account>([SELECT Id, Pre_Order_Discount__c FROM Account WHERE Id IN: accountIds ]);
		}
		if(!moIds.isEmpty()) {
			mMOrders = new Map<Id, Master_order__c>([SELECT Id, Pre_Order_Discount__c, Early_Bird_discount__c, Visibility_discount__c FROM Master_Order__c WHERE Id IN : moIds]);
		}

		for(PBSI__PBSI_Sales_Order__c current : lOrders) {
			if(current.Master_order__c != null) {
				current.Pre_Order_Discount_New__c = mMOrders.get(current.Master_order__c).Pre_Order_discount__c;
				current.Early_Bird_Discount__c = mMOrders.get(current.Master_order__c).Early_Bird_Discount__c;
				current.Visibility_discount__c = mMOrders.get(current.Master_order__c).Visibility_discount__c;
			} else if(mAccounts != null && mAccounts.containsKey(current.PBSI__Customer__c) && current.Sales_Order_type__c == 'Pre-Order' && current.Pre_Order_Discount_override__c == null) {
				current.Pre_Order_Discount_New__c = mAccounts.get(current.PBSI__Customer__c).Pre_Order_Discount__c;
			} else if(current.Sales_Order_type__c == 'Pre-Order' && current.Pre_Order_Discount_override__c != null) {
				current.Pre_Order_Discount_New__c = current.Pre_Order_Discount_override__c;
			} else {
				current.Pre_Order_Discount_New__c = 0;
			}
		}

	}

	public static void assignNoSmsFlag(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		Id webOrderRTId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c','Web_Order');
		for(PBSI__PBSI_Sales_Order__c so: lSalesOrders) {
			if( so.RecordTypeId != webOrderRTId) {
				so.Fulfiller_no_sms__c = true;
			}
		}
	}

	public static void assignNoSmsFlag(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
		Id webOrderRTId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c','Web_Order');
		List<PBSI__PBSI_Sales_Order__c> lSalesOrdersChangedRecordType = new List<PBSI__PBSI_Sales_Order__c>();
		for(Id key: newMap.keySet()) {
			PBSI__PBSI_Sales_Order__c oldSO = (PBSI__PBSI_Sales_Order__c) oldMap.get(key);
			PBSI__PBSI_Sales_Order__c newSO = (PBSI__PBSI_Sales_Order__c) newMap.get(key);
			if(oldSO.RecordTypeId != newSO.RecordTypeId) {
				lSalesOrdersChangedRecordType.add(newSO);
			}
		}
		assignNoSmsFlag(lSalesOrdersChangedRecordType);
	}

	public static void copySpecialDiscountFromAccount(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		Set<Id> accIds = new Set<Id>();
		for(PBSI__PBSI_Sales_Order__c order: lSalesOrders) {
			accIds.add(order.PBSI__Customer__c);
		}
		Map<Id, Account> mapAccs = new Map<Id, Account>([SELECT Id, Special_Disconut__c, Special_Disconut_Name__c FROM Account WHERE Id IN :accIds]);
		for(PBSI__PBSI_Sales_Order__c order: lSalesOrders) {
			Account acc = mapAccs.get(order.PBSI__Customer__c);
			if(acc != null) {
				order.Special_Disconut__c = acc.Special_Disconut__c;
				order.Special_Disconut_Name__c = acc.Special_Disconut_Name__c;
			}
		}
	}
}