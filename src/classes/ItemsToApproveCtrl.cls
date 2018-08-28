public with sharing class ItemsToApproveCtrl {
	public ApprovalGroup aGroup {
		get;
		set {
			ApprovalGroup prevVal = aGroup;
			aGroup = value;
			if(prevVal == null) {
				paginator = new SetController(aGroup.approvalRecords);
				getNextPage();
			}
		}
	}
	public List<ApprovalGroup.PIWIWrapper> visibleRecords {
		get {
			if(visibleRecords == null) {
				visibleRecords = new List<ApprovalGroup.PIWIWrapper>();
			}
			return visibleRecords;
		}
		private set;
	}

	public SetController paginator {get;set;}

	private static final String baseUrl = new PageReference('/').getUrl();

	public String getBaseUrl() {
		return baseUrl;
	}

	public String getRetUrlHome() {
		return '&retURL=/home/home.jsp';
	}

	public String getApproveRejectUrl() {
		return baseUrl+'p/process/ProcessInstanceWorkitemWizardStageManager?id=';
	}

	public String getReassignUrlSuffix() {
		return '/e?et=REASSIGN'+getRetUrlHome();
	}

	public void getNextPage() {
		if(paginator.canGoNext()) {
			visibleRecords = castFromObjects(paginator.getNextPage());
		}
	}

	public Boolean getCanGoNext() {
		return paginator.canGoNext();
	}

	public void getPrevPage() {
		if(paginator.canGoPrev()) {
			visibleRecords = castFromObjects(paginator.getPrevPage());
		}
	}

	public Boolean getCanGoPrev() {
		return paginator.canGoPrev();
	}

	private List<ApprovalGroup.PIWIWrapper> castFromObjects(List<Object> lObjects) {
		List<ApprovalGroup.PIWIWrapper> retList = new List<ApprovalGroup.PIWIWrapper>();
		for(Object o: lObjects) {
			retList.add( (ApprovalGroup.PIWIWrapper) o);
		}
		return retList;
	}
}