public abstract class RequestBuilder {

	final protected PBSI__PBSI_Sales_Order__c order;
	final protected String sessionId;
	final protected Id stageId;
	final protected Order_stage__c stage;
	private List<PBSI__Shipped_Sales_Order_Line__c> filteredLines;

	public abstract AsyncRequestManager getRequestManager();

	@testVisible
	protected boolean isPartial() {
		return !this.order.PBSI__Sales_Order_Lines__r.isEmpty() || this.order.PBSI__R00N60000001ZR62EAG__r.size() != this.getFilteredLines().size();
	}

	@testVisible
	protected List<PBSI__Shipped_Sales_Order_Line__c> getFilteredLines() {
		if(this.filteredLines == null) {
			this.filteredLines =  new List<PBSI__Shipped_Sales_Order_Line__c>();
			for(PBSI__Shipped_Sales_Order_Line__c current : this.order.PBSI__R00N60000001ZR62EAG__r) {
				if(current.Notification_transaction__c == this.stageId) {
					this.filteredLines.add(current);
				}
			}
		}
		return this.filteredLines;
	}
}