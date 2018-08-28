public with sharing class PortalOrderDetailController extends B2BPortalComponentControllerBase {

	final public User portalUser;
	final public Account portalAccount;
	final public AccountWrapper accountWrapper {get; set;}
	final public PortalDateWrapper newDate { public get; private set;}
	final public PortalDateWrapper orderDate { public get; private set;}
	final public List<SelectOption> availableTypesForNewOrder {get; set;}
	final public List<SelectOption> shippingOptions {get; set;}
	final public String dateFormatString {get; set;}

	public PBSI__PBSI_Sales_Order__c currentOrder {get; set;} 
	public MasterOrderWrapper masterOrder {get; set;}
	public List<SalesOrderWrapper> wrappedOrders {get; set;}
	public SalesOrderWrapper wrappedSO {get; set;}
	public String newOrderType {get; set;}
	public Id orderIdForOM {get; set;}
	public boolean masterMode {get; set;}
	public boolean masterHasLines {get; set;}

	public boolean isCountryEditable {
		get {
			return this.portalAccount.Id == '001D0000017mGGiIAM';
		}
	}

	transient public String newOrderMsg {get; set;}

	public PortalOrderDetailController() {
		masterMode = false;
		masterHasLines = false;
		try {
			portalUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = : UserInfo.getUserId()];
			portalAccount = [SELECT Id, B2B_On_Payment_Terms__c, Pre_Order_Discount__c, IsPersonAccount, PBSI__Standard_Discount__c, BillingCountry, IsDistributor__c, pw_ccpro__ShippingCountryLookup__r.Dealer_location__c FROM Account WHERE Id =: portalUser.AccountId];
			accountWrapper = new AccountWrapper(portalAccount);
		} catch (Exception ex) {

		}
		availableTypesForNewOrder = getAvailableTypes();
		shippingOptions = getShippingOptions();
		dateFormatString = DateFormat.FOR_CURRENT_USER;
		newDate = new PortalDateWrapper(dateFormatString);
		orderDate = new PortalDateWrapper(dateFormatString);
		setDefaultValues();
	}

	public Account getPortalAccount(){
		return portalAccount;
	}

	public override void setPageController(B2BPortalPageControllerBase value) {
		if (value != null) {
			pageController = value;
			pageController.setComponentController(this);
			initalizeOrder();
		}
	}

	public override void initalizeOrder() {
		if(String.isBlank(this.pageController.orderId)) {
			return;
		}
		orderIdForOM = pageController.orderId;
		if(Master_order__c.sObjectType == this.pageController.orderId.getSObjectType()) {
			this.masterMode = true;
			this.masterOrder = new MasterOrderWrapper([select id, Proposal_status__c, RecordTypeId, name, Status__c, Total_pre_order_discount__c, Early_bird_discount__c, Pre_order_discount__c, Visibility_discount__c from master_order__c where id =: this.pageController.orderId], this.getOrders());
			this.masterHasLines = !this.masterOrder.orders.isEmpty();
		} else if(PBSI__PBSI_Sales_Order__c.sObjectType == this.pageController.orderId.getSObjectType()) {
			this.masterMode = false;
			currentOrder = getOrders()[0];
			wrappedSO = new SalesOrderWrapper(currentOrder);
			orderDate.dateField = currentOrder.PBSI__Due_Date__c;
		}
		System.debug(wrappedSO);
		System.debug('Initialized order is : ' + currentOrder);
		if (currentOrder != null){
			System.debug('Sales order lines are fetched: ' + currentOrder);
			for (PBSI__PBSI_Sales_Order_Line__c line: currentOrder.PBSI__Sales_Order_Lines__r){
				System.debug('Related line :' + line);
			}
		}
	}

	private List<PBSI__PBSI_Sales_Order__c> getOrders() {
		String query = 'SELECT '
			+ 'CreatedById,'
			+ 'CurrencyIsoCode,'
			+ 'Delivery_Date__c, Tracking_Number_1__c,'
			+ 'Early_bird_discount__c,'
			+ 'Master_order__r.Id,'
			+ 'Master_order__r.Name,'
			+ 'Name,'
			+ 'On_Payment_Term__r.Discount_Available__c,'
			+ 'OwnerId,'
			+ 'PBSI__Customer_Purchase_Order__c,'
			+ 'PBSI__Customer__r.B2B_Account_s_Manager_Email__c,'
			+ 'PBSI__Customer__r.B2B_On_Payment_Terms__c,'
			+ 'PBSI__Customer__r.IsPersonAccount,'
			+ 'PBSI__Customer__r.Name,'
			+ 'PBSI__Customer__r.On_Payment_Term__c,'
			+ 'PBSI__Customer__r.PBSI__Standard_Discount__c,'
			+ 'PBSI__Customer__r.Pre_Order_Discount__c,'
			+ 'PBSI__Delivery_City__c,'
			+ 'PBSI__Delivery_Company__c,'
			+ 'PBSI__Delivery_Country__c,'
			+ 'PBSI__Delivery_Postal_Code__c,'
			+ 'PBSI__Delivery_Streetnew__c,'
			+ 'PBSI__Final_Order_Total__c,'
			+ 'PBSI__Order_Date__c, PBSI__Due_Date__c,'
			+ 'PBSI__Order_Total__c,'
			+ 'PBSI__Sales_Tax__c,'
			+ 'PBSI__Shipping_Cost__c,'
			+ 'PBSI__Stage__c,'
			+ 'Pre_Order_Discount_override__c,'
			+ 'Pre_Order_Final_Order_Total__c,'
			+ 'Proposal_status__c,'
			+ 'RecordTypeId,'
			+ 'Sales_Order_Type__c, '
			+ 'Shipping_Options__c,'
			+ 'Show_discount_info__c,'
			+ 'Total_Quantity_Of_Shoes_On_Order__c,'
			+ 'Total_Quantity_To_Ship__c,'
			+ 'Total_Shoes_Shipped__c,'
			+ 'Tracking_Number_2__c, Tracking_Number_3__c,'
			+ 'VAT_Amount__c,'
			+ 'Visibility_discount__c,'
			+ 'toLabel(PBSI__Status__c),'
			+ '(SELECT Id,'
					+ 'PBSI__ItemDescription__c,'
					+ 'PBSI__Item__r.Name,'
					+ 'PBSI__Item__r.PBSI__Item_Group__r.Name,'
					+ 'PBSI__Item__r.PBSI__Item_Group__r.RecordTypeId,'
					+ 'PBSI__Item__r.Size__r.Type__c,'
					+ 'PBSI__Price4__c,'
					+ 'PBSI__Quantity_Left_To_Ship__c,'
					+ 'PBSI__Quantity_Needed__c,'
					+ 'PBSI__Quantity_Picked__c,'
					+ 'PBSI__Total_Price__c'
					+ ' FROM PBSI__Sales_Order_Lines__r),'
			+ '(SELECT Id FROM Attachments WHERE Name LIKE \'%order confirmation%\' AND ContentType = \'application/pdf\' ORDER BY CreatedDate DESC LIMIT 1)'
			+ ' FROM PBSI__PBSI_Sales_Order__c';
		if(this.masterMode) {
			query += ' WHERE Master_order__c = \'' +  this.pageController.orderId + '\'';
		} else {
			query += ' WHERE Id = \'' + pageController.orderId  + '\'';
		}
		return Database.query(query);
	}

	public PageReference createNewOrder() {
		sObject newOrder;
		if(newOrderType == Label.Pre_order_multiple_ship_dates) {
			newOrder = new Master_order__c(
					Customer__c = portalAccount.Id,
					Customer_contact__c = portalUser.ContactId
					);
		} else {
			if(validateDateOnOrder(newDate.dateField, newOrderType)){
				newOrderMsg = getErrorMessage(newOrderType);
				return null;
			}
			newOrder = new PBSI__PBSI_Sales_Order__c(
					Sales_Order_Type__c = newOrderType,
					PBSI__Status__c = 'open',
					PBSI__Stage__c = 'open',
					PBSI__Due_Date__c = newDate.dateField,
					PBSI__Customer__r = portalAccount,
					PBSI__Customer__c = portalAccount.Id,
					PBSI__Contact__c = portalUser.ContactId,
					PBSI__Order_Date__c = Date.today(),
					PBSI__From_Location__c = newOrderType == 'Re-Order' && portalAccount.IsDistributor__c == true ? portalAccount.pw_ccpro__ShippingCountryLookup__r.Dealer_location__c : null
					);
		}
		return this.submitNewOrder(newOrder);
	}

	private boolean validateDateOnOrder(Date orderDate, String orderType){
		B2B_Portal_New_Order_Date_Intervals__c currentInterval = B2B_Portal_New_Order_Date_Intervals__c.getInstance(orderType);
		if((currentInterval.Min_days_in_the_future__c == null
					|| orderDate >= Date.today().addDays((Integer)currentInterval.Min_days_in_the_future__c))
				&& (currentInterval.Max_days_in_the_future__c == null
					|| orderDate < Date.today().addDays((Integer)currentInterval.Max_days_in_the_future__c))){
			return false;
					}
		return true;
	}

	private String getErrorMessage(String orderType) {
		if(orderType == 're-order' || orderType == 'drop ship'){
			return Label.B2B_Re_Order_Date_Error;
		} else {
			return Label.B2B_Pre_Order_Date_Error;
		}
		return null;
	}

	public PageReference getOMRef() {
		PageReference output = Page.OrderComposer;
		output.getParameters().put('id', this.orderIdForOM);
		return output;
	}

	public PageReference submitNewOrder(sObject toInsert) {
		insert toInsert;
		system.debug(toInsert.Id);
		this.orderIdForOM = toInsert.Id;
		return getOMRef();
	}

	public boolean getIsOrderEditable () {
		try {
			if(masterMode) {
				return (masterOrder.status == 'Open' && masterOrder.rtId == RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Order')) 
					|| (masterOrder.proposalStatus == 'Sent' && masterOrder.rtId == RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal')) ;

			} else {
				if(currentOrder.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal')) {
					return currentOrder.Proposal_status__c == 'sent';
				} else {
					return currentOrder.PBSI__Status__c == 'open';
				}
			}
		} catch (Exception e) { }
		return false;
	}

	public void setDefaultValues () {
		newDate.dateField = Date.today();
		newOrderType = 'Re-Order';
		currentOrder = null;
	}

	public boolean getIsUSAccount(){
		return accountWrapper != null && accountWrapper.billingCountry == 'United States';
	}

	public void updateOrder() {
		try {
			if(wrappedSO.hasAddressChanged() && (wrappedSO.type == 're-order' || wrappedSO.type == 'drop ship')) {
				currentOrder.PBSI__Delivery_Company__c = wrappedSO.deliveryName = wrappedSO.newDeliveryName;
				currentOrder.PBSI__Delivery_Streetnew__c = wrappedSO.deliveryStreet = wrappedSO.newDeliveryStreet;
				currentOrder.PBSI__Delivery_City__c = wrappedSO.deliveryCity = wrappedSO.newDeliveryCity;
				currentOrder.PBSI__Delivery_Postal_Code__c = wrappedSO.deliveryPO = wrappedSO.newDeliveryPO;
				if(this.isCountryEditable) {
					currentOrder.PBSI__Delivery_Country__c = wrappedSO.deliveryCountry = wrappedSO.newDeliveryCountry;
				}
				currentOrder.Sales_Order_Type__c = 'Drop ship';
			}
			currentOrder.Shipping_Options__c = wrappedSO.deliveryOption;
		} catch (Exception e) {
		}
		OrderSaver saver = new OrderSaver();
		saver.updateOrder(this.currentOrder);
	}

	public PageReference openOrderMatrix() {
		if(!this.masterMode) {
			this.updateOrder();
		}
		PageReference output = Page.OrderComposer;
		output.getParameters().put('id', this.orderIdForOM);
		return output;
	}

	public void submitOrder() {
		LogService log = LogService.getLogService();
		if(masterMode) {
			submitMasterOrder();
		} else  {
			submitSalesOrder();
		}
		log.save();
	}

	private void submitSalesOrder() {
		Order_notification__c notification;
		if(currentOrder.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal') && currentOrder.Master_order__c == null) {
			notification = new Order_Notification__c();
			notification.Account__c = currentOrder.PBSI__Customer__c;
			notification.Order_Id__c = currentOrder.Id;
			notification.Order_Name__c = currentOrder.Name;
			notification.Type__c = 'Accepted';
			notification.Account_Owner_Email__c = currentOrder.PBSI__Customer__r.B2B_Account_s_Manager_Email__c;
			this.currentOrder.PBSI__Due_date__c = orderDate.dateField;
			this.currentOrder.Proposal_status__c = 'Accepted';
			this.currentOrder.OwnerId = this.currentOrder.CreatedById;
		} else {
			if(validateDateOnOrder(orderDate.dateField, currentOrder.Sales_order_type__c)){
				newOrderMsg = getErrorMessage(currentOrder.Sales_order_type__c.toLowerCase());
			} else if(!(currentOrder.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal'))) {
				currentOrder.PBSI__Due_date__c = orderDate.dateField;
				currentOrder.PBSI__Status__c = 'in progress';
				if(currentOrder.Sales_Order_Type__c == 'pre-order'){
					notification = new Order_Notification__c();
					notification.Account__c = currentOrder.PBSI__Customer__c;
					notification.Order_Id__c = currentOrder.Id;
					notification.Order_Name__c = currentOrder.Name;
					notification.Type__c = 'New';
					notification.Account_Owner_Email__c = currentOrder.PBSI__Customer__r.B2B_Account_s_Manager_Email__c;
				}
			}
		}
		if(notification != null) {
			insert notification;
		}
		updateOrder();
	}

	private void submitMasterOrder() {
		Master_order__c mOrder = [SELECT Id, RecordTypeId, Proposal_status__c, Status__c FROM Master_order__c WHERE Id =: orderIdForOm FOR UPDATE];
		if(mOrder.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Master_Order__c', 'Proposal')) {
			mOrder.Proposal_status__c = 'Accepted';
			this.masterOrder.proposalStatus = 'Accepted';
		} else {
			mOrder.Status__c = 'In progress';
			this.masterOrder.status = 'In progress';
		}
		update mOrder;
	}

	private List<SelectOption> getAvailableTypes () {
		final Set<String> availableTypes = new Set<String>(Backstage_profile_setting__c.getInstance().Available_order_types__c.split(';'));
		final List<Schema.PicklistEntry> allPicklistValues = PBSI__PBSI_Sales_Order__c.Sales_order_type__c.getDescribe().getPicklistValues();
		final List<SelectOption> returnValue = new List<SelectOption>();
		for(Schema.PicklistEntry pe : allPicklistValues) {
			if(availableTypes.contains(pe.getValue().toLowerCase())) {
				returnValue.add(new SelectOption(pe.getValue(), pe.getLabel()));
			}
		}
		returnValue.add(new SelectOption(Label.Pre_order_multiple_ship_dates, Label.Pre_order_multiple_ship_dates));
		return returnValue;
	}

	private List<SelectOption> getShippingOptions () {
		final List<SelectOption> returnValue = new List<SelectOption>();
		returnValue.add(new SelectOption('01', Label.Shipping_standard));
		returnValue.add(new SelectOption('02', Label.Shipping_express));
		returnValue.add(new SelectOption('03', Label.Shipping_overnight));
		return returnValue;
	}

	private without sharing class OrderSaver {

		private OrderSaver(){}

		private void updateOrder(PBSI__PBSI_Sales_Order__c order) {
			LogService log = LogService.getLogService();
			try {
				new DmlNoSharingService(order).doUpdate();
			} catch (DMLException e) {
				log.addError().exception(e).relatedObjId(order.Id);
			}
			log.save();
		}
	}
}