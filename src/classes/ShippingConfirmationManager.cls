public class ShippingConfirmationManager implements AsyncRequestManager, Queueable, Database.AllowsCallouts {

	private Id orderId;
	private HttpRequestBuilder request;

	public ShippingConfirmationManager(String orderId, HttpRequestBuilder request) {
		this.orderId = orderId;
		this.request = request;
	}

	public HttpRequestBuilder getRequestBuilder() {
		return this.request;
	}

	public void callback(HttpResponse response) {
		LogService log = LogService.getLogService();
		try {
		update new PBSI__PBSI_Sales_Order__c(Id = this.orderId, KN_Shipping_Notice_Sent__c = true);
		} catch (Exception e) {
			log.addError().exception(e).type('UPDATE').relatedObjId(this.orderId)
				.info('Update failed for one(or more of following objects during work of ShippingConfirmationManager class');
		}
		log.save();
	}

	public void onError(Exception e) {
		this.callback(null);
	}

	public Id enqueue() {
		return System.enqueueJob(this);
	}

	public void execute(QueueableContext context){
		LogService log = LogService.getLogService();
		HttpResponse response;
		try {
			log.addCallout().type('Conga').relatedObjId(this.orderId).info('Endpoint:\n' + this.getRequestBuilder().getRequest().getEndpoint());
			response = this.getRequestBuilder().sendRequest();
			this.callback(response);
		} catch (Exception e) {
			this.onError(e);
		}
		log.save();
	}
}