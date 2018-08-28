public with sharing class BackstageCaseService {

	final private BackstageService bss;
	final public PortalDateWrapper openedStart { get; private set;}
	final public PortalDateWrapper openedEnd { get; private set;}

	final private Id accountId;
	final private List<QueryOrder> sortOrder;
	final public String dateFormatString { get; set; }

	public ApexPages.StandardSetController collection;
	public final List<SelectOption> statuses {get; private set;}
	public List<String> selectedStatuses {get; set;}

	public Id selectedCaseId { private get; set; }

	public String lastSortBy {
		get;
		set {
			if(sortOrder.isEmpty()) {
				sortOrder.add(new QueryOrder(value));
			} else if (sortOrder.get(0).fieldName == value){
				sortOrder.get(0).swapAsc();
			} else {
				sortOrder.add(0, new QueryOrder(value));
			}
		}
	}

	public BackstageCaseService (BackstageService bss) {
		this.bss = bss;
		this.sortOrder = new List<QueryOrder>();
		this.dateFormatString = DateFormat.getDateFormatForCurrentUser();
		this.openedStart = new PortalDateWrapper(Date.newInstance(Date.today().year(), Date.today().addMonths(-1).month(), 1), dateFormatString);
		this.openedEnd = new PortalDateWrapper(Date.today(), dateFormatString);
		this.statuses = this.getStatusOptions();
		this.selectedStatuses = this.getSetOfValuesFromSOL(this.statuses);
	}

	public ApexPages.StandardSetController getCollection () {
		Date d1 = this.openedStart.dateField;
		if(this.openedEnd.dateField != null){
			Date d2 = this.openedEnd.dateField.addDays(1);
		}
		List<String> lStatus = this.selectedStatuses;
		if(this.collection == null) {
			collection = new ApexPages.StandardSetController(Database.getQueryLocator(this.buildQuery()));
			collection.setPageSize(10);
		}
		return this.collection;
	}

	public List<Case> getCases () {
		Date d1 = this.openedStart.dateField;
		if(this.openedEnd.dateField != null){
			Date d2 = this.openedEnd.dateField.addDays(1);
		}
		List<String> lStatus = this.selectedStatuses;
		system.debug(lStatus);
		system.debug(this.buildQuery());
		return (List<Case>) Database.query(this.buildQuery());
	}

	public void refreshCollection () {
		this.collection = null;
	}

	public PageReference loadCase () {
		PageReference output = Page.Case;
		output.getParameters().put('id', selectedCaseId);
		return output;
	}

	public void clearFilters () {
		selectedStatuses = new List<String>();
		openedStart.textField = '';
		openedEnd.textField = '';
		this.refreshCollection();
	}

	public List<SelectOption> getShoeCodes () {
		return getCodes(PBSI__PBSI_Sales_Order_Line__c.Return_Reason__c.getDescribe().getPicklistValues());
	}

	public List<SelectOption> getApparelCodes () {
		return getCodes(PBSI__PBSI_Sales_Order_Line__c.Warranty_reason_shoes__c.getDescribe().getPicklistValues());
	}

	private List<SelectOption> getCodes (List<Schema.PicklistEntry> picklistValues) {
		final List<SelectOption> returnValue = new List<SelectOption>();
		for(Schema.PicklistEntry pe : picklistValues) {
			returnValue.add(new SelectOption(pe.getValue(), pe.getLabel()));
		}
		return returnValue;
	}

	private String buildQuery () {
		String returnValue = 'SELECT Id, CaseNumber, Subject, Status, CreatedDate, Items_open__c, Items_approved__c, Items_declined__c FROM Case WHERE RecordTypeId =\''
		   + RecordTypeService.getRecordTypeIdByDeveloperName('Case', 'backstage_warranty') + '\'';
		if(!String.isBlank(this.bss.contextUser.AccountId)){
			returnValue += 'AND AccountId = \'' + this.bss.contextUser.AccountId + '\'' ;
		} else {
			returnValue += 'AND OwnerId = \'' + this.bss.contextUser.Id + '\'';
		}
		if(this.openedEnd.dateField != null || this.openedStart.dateField != null || !this.selectedStatuses.isEmpty()) {
			returnValue += this.getWhere();
		}
		if(!this.sortOrder.isEmpty()) {
			returnValue += ' ORDER BY ' + this.getOrderBy();
		}
		return returnValue;
	}

	private String getOrderBy () {
		String returnValue = '';
		for (QueryOrder qo : sortOrder) {
			if(String.isBlank(returnValue)) {
				returnValue += qo.fieldName + ' ' + (qo.isAscending ? 'ASC' : 'DESC');
			} else {
				returnValue += ', ' + qo.fieldName + ' ' + (qo.isAscending ? 'ASC' : 'DESC');
			}
		}
		return returnValue;
	}

	private String getWhere () {
		String returnValue = '';
		if(this.openedStart.dateField != null) {
			returnValue += ' AND CreatedDate >= : d1';
		}
		if(this.openedEnd.dateField != null) {
			returnValue += ' AND CreatedDate <= : d2';
		}
		if(!this.selectedStatuses.isEmpty()) {
			returnValue += ' AND Status IN : lStatus';
		}
		return returnValue;
	}

	private Class QueryOrder {
		final public String fieldName;
		public boolean isAscending;

		public QueryOrder (String fieldName) {
			this.fieldName = fieldName;
			this.isAscending = true;
		}

		public void swapAsc () {
			this.isAscending = !this.isAscending;
		}
	}

	private List<SelectOption> getStatusOptions () {
		final List<Schema.PicklistEntry> allPicklistValues = Case.Status.getDescribe().getPicklistValues();
		final List<SelectOption> returnValue = new List<SelectOption>();
		for(Schema.PicklistEntry pe : allPicklistValues) {
			if('new;in progress;closed'.containsIgnoreCase(pe.getValue()))
			returnValue.add(new SelectOption(pe.getValue(), pe.getLabel()));
		}
		return returnValue;
	}

	private List<String> getSetOfValuesFromSOL (List<SelectOption> lSelectOption) {
		List<String> rtnSet = new List<String>();
		for(SelectOption so : lSelectOption) {
			rtnSet.add(so.getValue());
		}
		return rtnSet;
	}
}