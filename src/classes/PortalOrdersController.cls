public with sharing class PortalOrdersController extends B2BPortalPageControllerBase {

	public User portalUser;
	public PortalDateWrapper filterOrderFrom {get; set;}
	public PortalDateWrapper filterOrderTo {get; set;}
	public PortalDateWrapper filterShipFrom {get; set;}
	public PortalDateWrapper filterShipTo {get; set;}
	public String dateFormatString {get; set;}
	public List<SelectOption> availableStages {get; set;}
	public List<SelectOption> availableTypes {get; set;}
	public List<String> selectedStages {get; set;}
	public List<String> selectedTypes {get; set;}
	public boolean isError {get; set;}
	public boolean mastersRequired {get; set;}

	public PortalOrdersController() {
		mastersRequired = false;
		isError = false;
		portalUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = : UserInfo.getUserId()];
		dateFormatString = DateFormat.getDateFormatForCurrentUser();
		dateFormatForSorting = DateFormat.getDateFormatForCurrentUser('/').toLowerCase();
		availableStages = getSelectOptionFromPicklist(PBSI__PBSI_Sales_Order__c.PBSI__Stage__c.getDescribe());
		availableTypes = new List<SelectOption> ();
		availableTypes.add(new SelectOption('Re-Order', 'Re-Order'));
		availableTypes.add(new SelectOption('Drop ship', 'Drop ship'));
		availableTypes.add(new SelectOption('Pre-Order', 'Pre-Order'));
		orderId = ApexPages.currentPage().getParameters().get('orderId');
		if(String.isNotBlank(orderId) && (orderId.getSObjectType() == PBSI__PBSI_Sales_Order__c.sObjectType || orderId.getSObjectType() == Master_order__c.sObjectType)){
			viewOrderMode = true;
		}
		setDefaultFilterValues();
	}

	public List<SalesOrderWrapper> getWrappedOrders () {
		List<SalesOrderWrapper> output = new List<SalesOrderWrapper>();
		try {
			for(PBSI__PBSI_Sales_Order__C so : getOrders()) {
				output.add(new SalesOrderWrapper(so));
			}
		} catch (Exception e) {
			LogService log = LogService.getLogService();
			log.addError().type('BACKSTAGE').relatedObjId(portalUser.Id).info(e.getMessage());
			log.save();
		}
		return output;
	}

	public List<SalesOrderWrapper> getFilteredOrders() {
		this.mastersRequired = false;
		boolean filterByStages = (selectedStages.size() > 0) ? true : false;
		Set<String> stagesSet = new Set<String>(selectedStages);
		Set<String> typesSet;
		if(selectedTypes.size() > 0){
			typesSet = new Set<String>(selectedTypes);
		} else {
			typesSet = getSetOfValuesFromSelectOptionList(availableTypes);
		}
		List<SalesOrderWrapper> result = new List<SalesOrderWrapper> ();
		for(SalesOrderWrapper current : getWrappedOrders()){
			if(isDateInPeriod(current.orderDate, filterOrderFrom.dateField, filterOrderTo.dateField)
				&& isDateInPeriod(current.dueDate, filterShipFrom.dateField, filterShipTo.dateField)
				&& (!filterByStages || stagesSet.contains(current.stage))
				&& typesSet.contains(current.type)){
				if(String.isNotBlank(current.masterId)) {
					this.mastersRequired = true;
				}
				result.add(current);
			}
		}
		System.debug('Filtered orders: ' + result);
		return result;
	}

	public PageReference getAvailabilityReference () {
		PageReference result = Page.OrderMatrix;
		result.getParameters().put('id', portalUser.accountId);
		return result;
	}

	private Set<String> getSetOfValuesFromSelectOptionList (List<SelectOption> lSelectOption) {
		Set<String> rtnSet = new Set<String>();
		for(SelectOption so : lSelectOption) {
			rtnSet.add(so.getValue());
		}
		return rtnSet;
	}

	public void setDefaultFilterValues() {
		selectedStages = new List<String> (getSetOfValuesFromSelectOptionList(availableStages));
		selectedTypes = new List<String> (getSetOfValuesFromSelectOptionList(availableTypes));
		filterOrderFrom = new PortalDateWrapper(Date.newInstance(Date.today().year(), 1, 1), this.dateFormatString);
		filterOrderTo = new PortalDateWrapper(Date.newInstance(Date.today().year(), 12, 31), this.dateFormatString);
		filterShipFrom = new PortalDateWrapper(Date.newInstance(Date.today().year(), 1, 1), this.dateFormatString);
		filterShipTo = new PortalDateWrapper(Date.newInstance(Date.today().year(), 12, 31), this.dateFormatString);
	}

    public void resetFilters() {
		filterOrderFrom.dateField = null;
		filterOrderTo.dateField = null;
		filterShipFrom.dateField = null;
		filterShipTo.dateField = null;
        selectedTypes.clear();
        selectedStages.clear();
    }

	private boolean isDateInPeriod(Date val, Date min, Date max) {
		if(min == null && max == null || val == null) {
			return true;
		} else if ( max == null && min != null) {
			return val >= min;
		} else if ( max != null && min == null) {
			return val <= max;
		}
		return val >= min && val <= max;
	}

	private List<SelectOption> getSelectOptionFromPicklist(Schema.DescribeFieldResult fieldResult){
		List<SelectOption> result = new List<SelectOption>();
		for(Schema.PicklistEntry current : fieldResult.getPicklistValues()){
			result.add(new SelectOption(current.getLabel(), current.getLabel()));
		}
		return result;
	}

	private List<PBSI__PBSI_Sales_Order__c> getOrders() {
		return [
			SELECT
				Name,
				PBSI__Due_Date__c,
				CurrencyIsoCode,
				Total_Shoes_Shipped__c,
				Total_Quantity_To_Ship__c,
				PBSI__Final_Order_Total__c,
				toLabel(PBSI__Stage__c),
				PBSI__Customer_Purchase_Order__c,
				Delivery_Date__c,
				PBSI__Type__c,
				PBSI__Order_Date__c,
				Sales_Order_Type__c,
				Pre_Order_Final_Order_Total__c,
				PBSI__Sales_Tax__c,
				PBSI__Shipping_Cost__c,
				PBSI__Order_Total__c,
				Total_Quantity_Of_Shoes_On_Order__c,
				Tracking_Number_1__c,
				Tracking_Number_2__c,
				Tracking_Number_3__c,
				PBSI__Status__c,
				Id,
				Master_order__r.Id,
				Master_order__r.Name,
				(SELECT Id, Name  FROM Attachments WHERE Name LIKE '%order confirmation%' AND ContentType = 'application/pdf' ORDER BY CreatedDate DESC LIMIT 1)
			FROM PBSI__PBSI_Sales_Order__c
			WHERE PBSI__Customer__c =: portalUser.AccountId
			AND Sales_Order_Type__c IN: getSetOfValuesFromSelectOptionList(availableTypes)
			ORDER BY CreatedDate DESC
			LIMIT 999
		];
	}
}